################################################################################
# Script       : EDITH.R
# Author       : Mathilde Robin, Raphaël Romero, Diego Tosi
# Date         : 2025-05-15
# Description  : Evaluation of Drug Interactions in the setting of THerapy combinations
#                (2 or 3 drugs)
# Version      : 1.0.1
# Dependencies : packages
# Input        : 
# Output       : 
################################################################################

################################################################################
# Packages installation
################################################################################

install_or_not <- function (package, CRAN = TRUE)  {
  if (!requireNamespace(package = package, quietly = TRUE)) {
    if (CRAN) {
      utils::install.packages(pkgs = package)
    } else {
      BiocManager::install(pkgs = package)
    }
  }
} 

packages_CRAN <- c("tidyverse", "readxl", "circlize", "grid", "openxlsx", "BiocManager", "gridExtra", "svDialogs")
invisible(lapply(packages_CRAN, function (x) install_or_not(package = x, CRAN = TRUE)))

packages_BIOCONDUCTOR <- c("ComplexHeatmap")
invisible(lapply(packages_BIOCONDUCTOR, function (x) install_or_not(package = x, CRAN = FALSE)))

################################################################################
# `tidyverse` loading
################################################################################

suppressPackageStartupMessages(library(tidyverse))

################################################################################
# Functions
################################################################################

say_hello <- function () {
  
  hello <- svDialogs::dlg_message(
    message = "Bonjour Utilisateur, je m'appelle EDITH v1.0.1. Je quantifie les
    interractions entre les drogues. Pour l'instant je peux faire entre 2 et 3
    drogues sur la même matrice ! Cependant, il faut que la matrice soit dans le
    bon format, tel que spécifié dans la documentation fournie avec le code.
    Je suis capable de détecter si le format n'est pas bon et je ferai de mon
    mieux pour te prévenir, mais je ne peux pas détecter toutes les erreurs !
    Si tu fais appel à mes programmeurs pour leur dire que je bug et qu'il
    s'avère que la solution était à la première ligne de leur documentation,
    ils te condamneront à faire du R pendant 1 semaine !
    En cliquant sur 'OK' vous acceptez les termes de ce contrat.", 
    type = "okcancel")$res
  
  if(hello == "cancel") {
    # q(save="ask")
    stop  ("Contrat refusé", call. = FALSE)
  }
}

clean_subtable <- function (df) {
  
  # numerics matrix conversion
  subtable <- df[-1, -1] %>%
    dplyr::mutate(dplyr::across(dplyr::everything(), as.numeric)) %>%
    as.matrix()
  
  # dimnames
  rownames(subtable) <- df[-1,1][[1]]
  colnames(subtable) <- df[1,-1]
  
  # remove NA column 
  # this can happen if not all replicates have the same number of doses
  ids <- which(apply(subtable, 2, function (x) !all(is.na(x))))
  subtable <- subtable[,ids]
  
  return (subtable)
}

checks <- function (data_init) {
  
  # check that there are no NA in the matrix 
  if (anyNA(data_init)) {
    svDialogs::dlg_message(message = "Missing data in one matrix", type = "ok")
    return (NULL)
  }
  
  # check that there are negative values in the matrix 
  if (any(data_init < 0)) {
    svDialogs::dlg_message(message = "Negative values in one matrix → transformed into 0", type = "ok")
    data_init[which(data_init < 0)] <- 0
  }
  
  # check that there are high values in the matrix 
  if (any(data_init > 100)) {
    # svDialogs::dlg_message(message = "Too high values in one matrix → transformed into 100", type = "ok")
    data_init[which(data_init > 100)] <- 100
  }
  
  # check that the first dose of each drug is 0
  if (any(c(min(rownames(data_init)), min(colnames(data_init))) != "0")) {
    svDialogs::dlg_message(message = "The first dose of one of the drugs is non-zero", type = "ok")
    return (NULL)
  }
  
  # check that there are at least 3 doses
  if (any(c(ncol(data_init), nrow(data_init)) < 3)) {
    svDialogs::dlg_message(message = "One of the drugs has less than 3 doses", type = "ok")
    return (NULL)
  }
  
  # check that doses in rows are in ascending order
  doses_rows <- order(as.numeric(rownames(data_init)))
  if (any(doses_rows != 1:length(doses_rows))) {
    svDialogs::dlg_message(message = "Row doses not in ascending order → reordered", type = "ok")
    data_init <- data_init[doses_rows,]
  }
  
  # check that doses in cols are in ascending order
  doses_cols <- order(as.numeric(colnames(data_init)))
  if (any(doses_cols != 1:length(doses_cols))) {
    svDialogs::dlg_message(message = "Column doses not in ascending order → reordered", type = "ok")
    data_init <- data_init[,doses_cols] 
  }
  
  # check that the dilution step is constant in row
  steps_rows <- log(as.numeric(rownames(data_init)[-1])) 
  delta_rows <- round(x = steps_rows[2:length(steps_rows)] - steps_rows[1:(length(steps_rows)-1)], digits = 2)
  if (length(unique(delta_rows)) != 1) {
    answer <- svDialogs::dlg_message(message = "The dilution step does not seem constant for drug in row → indices may be impacted", type = "yesno")$res
    if (answer == "no") return (NULL)
  }
  
  # check that the dilution step is constant in column
  steps_cols <- log(as.numeric(colnames(data_init)[-1])) 
  delta_cols <- round(x = steps_cols[2:length(steps_cols)] - steps_cols[1:(length(steps_cols)-1)], digits = 2)
  if (length(unique(delta_rows)) != 1) {
    answer <- svDialogs::dlg_message(message = "The dilution step does not seem constant for drug in column → indices may be impacted", type = "yesno")$res
    if (answer == "no") return (NULL)
  }
  
  return (data_init)
}

bliss_matrix <- function (data_init) {
  # calculate the additivity matrix according to Bliss' method
  
  fua <- data_init[1,]
  fub <- data_init[,1]
  
  fu <- vector()
  for (a in fua) {
    for (b in fub) {
      fu <- append(fu, c(a, b))
    }
  } 
  
  fu <- matrix(fu, ncol = 2, byrow = TRUE, dimnames = list(c(), c("a", "b")))/100
  data_bliss <- apply(fu, 1, prod) * 100
  data_bliss <- matrix(data_bliss, dim(data_init), dimnames = dimnames(data_init))
  
  return (data_bliss)
}

index <- function (data_init, data_bliss) {
  # calculate of syntetic indexes according to Lehar's method
  
  dfa <- as.numeric(colnames(data_init)[3]) / as.numeric(colnames(data_init)[2])
  dfb <- as.numeric(rownames(data_init)[3]) / as.numeric(rownames(data_init)[2])
  
  # additivity index
  AI <- log(dfa) * log(dfb) * sum(100 - data_bliss, na.rm = TRUE) / 100
  
  # combination index
  CI <- log(dfa) * log(dfb) * sum(data_bliss - data_init, na.rm = TRUE) / 100
  
  # efficacy index
  EI <- log(dfa) * log(dfb) * sum(100 - data_init[-1,-1], na.rm = TRUE) / 100
  
  return (list(AI = AI, CI = CI, EI = EI))
}

convert_scientific <- function (vect) {
  
  vect <- as.numeric(vect)
  sapply(vect, function (x) {
    if (nchar(x) > 6){
      format(x, scientific = TRUE, digits = 3)
    } else {
      as.character(x)
    }
  })
}

plot_heatmap <- function (data, drugs, color) {
  
  rownames(data) <- convert_scientific(vect = rownames(data))
  colnames(data) <- convert_scientific(vect = colnames(data))
  
  if (color == 1) {
    color_palette <- circlize::colorRamp2(breaks = c(0, 100), colors = c("dodgerblue1", "navy"))
  } else {
    color_palette <- circlize::colorRamp2(
      breaks = c(-100, -15.1, -15, 0, 15, 15.1, 100), 
      colors = c("#00FF00", "#004e00", "#000000", "#000000", "#000000", "#4e0000", "#FF0000"))
  }
  
  p <- ComplexHeatmap::Heatmap(
    matrix = data,
    name = "value",
    cluster_rows = FALSE,
    cluster_columns = FALSE,
    row_title = drugs$drugA,
    row_title_side = "left",
    row_names_side = "left",
    row_names_centered = TRUE,
    column_title = drugs$drugB,
    column_title_side = "bottom",
    column_names_side = "bottom",
    column_names_rot = 0,
    column_names_centered = TRUE,
    col = color_palette,
    rect_gp = grid::gpar(col = "white", lwd = 0.05),
    cell_fun = function(j, i, x, y, width, height, fill) {
      grid::grid.text(label = round(x = data[i,j], digits = 0), x = x, y = y, gp = grid::gpar(fontsize = 10, col = "white"))
    }
  )
  
  return(p)
}

save_replicat_2drugs <- function (global, i) {
  
  # remove null replicates
  global <- global[sapply(global, function (x) !is.null(x))]
  
  # pdf for each replicate
  sapply(1:length(global), function (block) {
    pdf(paste0(excel_sheets[i], "_", block, ".pdf"))
    ComplexHeatmap::draw(global[[block]][["heatmap_init"]])
    ComplexHeatmap::draw(global[[block]][["heatmap_bliss"]])
    ComplexHeatmap::draw(global[[block]][["heatmap_diff"]])
    dev.off()
  })
  
  # check that all replicates have the same doses in row
  doses_rows <- lapply(global, function (block) {
    rownames(block[["data_init"]])
  })
  
  if (!all(sapply(doses_rows, function(x) identical(x, doses_rows[[1]])))){
    svDialogs::dlg_message("Replicates don't have the same doses in row", type = "ok")
  }
  
  # check that replicates have the same doses in column
  doses_cols <- lapply(global, function (block) {
    colnames(block[["data_init"]])
  })
  
  if (!all(sapply(doses_cols, function(x) identical(x, doses_cols[[1]])))){
    svDialogs::dlg_message("Replicates don't have the same doses in column", type = "ok")
  }
  
  grobs <- c(
    lapply(1:length(global), function (block) {
      grid::grid.grabExpr(ComplexHeatmap::draw(global[[block]][["heatmap_init"]]))
    }),
    lapply(1:length(global), function (block) {
      grid::grid.grabExpr(ComplexHeatmap::draw(global[[block]][["heatmap_diff"]]))
    })
  )
  
  width  <- max(sapply(global, function(block) ncol(block$data_init))) * length(global) * 1.33
  height <- max(sapply(global, function(block) nrow(block$data_init))) * 2
  
  pdf(paste0(excel_sheets[i], ".pdf"), width = grid::unit(x = width, units = "in"), height = grid::unit(x = height, units = "in"))
  gridExtra::grid.arrange(grobs = grobs, nrow = 2, ncol = length(global))
  dev.off()
}

two_drugs <- function (i, drugs, excel_sheet) {
  
  # replicates identification
  sep    <- which(apply(excel_sheet, 1, function(x) all(is.na(x))))
  starts <- c(1, sep + 1)
  ends   <- c(sep - 1, nrow(excel_sheet))
  blocks <- purrr::map2(starts, ends, ~ .x:.y) %>% 
    purrr::discard(~length(.) < 4)
  
  # for each replicate
  global <- lapply(blocks, function (block) {
    
    data_init <- clean_subtable(df = excel_sheet[block,])
    data_init <- checks(data_init)
    
    if (is.null(data_init)) {
      stop(call. = FALSE)
    }
    
    data_bliss <- bliss_matrix(data_init = data_init)
    data_diff  <- round(data_bliss - data_init, 1)
    
    return (list(
      data_init = data_init, 
      data_bliss = data_bliss, 
      index_list = index(data_init = data_init, data_bliss = data_bliss),
      heatmap_init  = plot_heatmap(data = data_init, drugs = drugs, color = 1),
      heatmap_bliss = plot_heatmap(data = data_bliss, drugs = drugs, color = 1),
      heatmap_diff  = plot_heatmap(data = data_diff, drugs = drugs, color = 2)
    ))
  })
  
  save_replicat_2drugs(global = global, i = i)
}

three_drugs <- function (i, drugs, excel_sheet) {
  
}

################################################################################
# Main
################################################################################

options(warn = -1)

# say_hello()

filename <- file.choose(new = TRUE) %>%
  stringr::str_replace_all(string = ., pattern = "\\\\", replacement = "/")

output_dir <- filename %>%
  stringr::str_replace(string = ., pattern = ".xlsx", replacement = "_output/")

dir.create(output_dir, showWarnings = FALSE)
setwd(output_dir)

excel_sheets <- readxl::excel_sheets(path = filename)

invisible(
  sapply(1:length(excel_sheets), function (i) {
    excel_sheet <- readxl::read_excel(path = filename, sheet = excel_sheets[i], col_names = FALSE)
    
    # verifier que les premieres cases sont remplies 
    # si 2 -> code 2 drugs
    # si 3 -> code 3 drugs
    
    # drugs names extraction
    drugs <- list(
      drugA = as.character(excel_sheet[1,1]), 
      drugB = as.character(excel_sheet[1,2]),
      drugC = as.character(excel_sheet[1,3])
    )
    
    if (any(c(drugs$drugA, drugs$drugB) %in% c("NA", "", " ", NA))) {
      svDialogs::dlg_message(message = paste0("Drug name(s) are missing in sheet ", i), type = "ok")
      return (NULL)
    }
    
    # 2 or 3 drugs?
    if (drugs$drugC %in% c("NA", "", " ", NA)) {
      two_drugs(i = i, drugs = drugs, excel_sheet = excel_sheet)
    } else {
      three_drugs(i = i, drugs = drugs, excel_sheet = excel_sheet)
    }
  })
)
