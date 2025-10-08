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

plot_heatmap <- function (data, drugs, color, title = "") {
  
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
    },
    top_annotation = ComplexHeatmap::HeatmapAnnotation(
      foo = ComplexHeatmap::anno_block(
        gp = grid::gpar(fill = "white", col = "white"),
        labels = title, 
        labels_gp = grid::gpar(col = "black", fontsize = 12, fontface = "bold"))
    )
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
    data_diff  <- data_bliss - data_init
    
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
  
  drugs.n <- list(c(1,2,3), c(2,3,1), c(3,1,2))
  drugs <- lapply(drugs.n, function(x) as.character(excel_sheet[1, 1:3])[x])
  
  # replicates identification
  sep    <- which(apply(excel_sheet, 1, function(x) all(is.na(x))))
  starts <- c(1, sep + 1)
  ends   <- c(sep - 1, nrow(excel_sheet))
  blocks <- purrr::map2(starts, ends, ~ .x:.y) %>% 
    purrr::discard(~length(.) < 4)
  
  # for each replicate
  global <- lapply(1:length(blocks), function (sep_n) {
    
    block <- blocks[[sep_n]]
    data <- as.matrix(excel_sheet[block,])
    class(data) <- "numeric"
    
    doses <- list(drugA = as.numeric(unique(data[-1, 1])),
                  drugB = as.numeric(data[1, -c(1, ncol(data))]),
                  drugC = as.numeric(unique(data[-1, ncol(data)])))
    
    
    data <- round(data[-1, -c(1, ncol(data))], 0)
    data[which(data > 100)] <- 100 
    
    data <- t(data)
    dim(data) <- lengths(doses[c(2,1,3)])
    data <- aperm(data, c(2,1,3))
    dimnames(data) <- doses
    
    
    ## drugs permutation
    for(dimnam_i in 1:length(drugs)){
      
      data_array <- aperm(data, perm = drugs.n[[dimnam_i]])
      
      name_a <- drugs[[dimnam_i]][1]
      name_b <- drugs[[dimnam_i]][2]
      name_c <- drugs[[dimnam_i]][3]
      
      dose_a <- doses[[drugs.n[[dimnam_i]][1]]]
      dose_b <- doses[[drugs.n[[dimnam_i]][2]]]
      dose_c <- doses[[drugs.n[[dimnam_i]][3]]]
      
      
      ## Bliss additive effect estimation
      fua <- data_array[, "0", "0"]
      fub <- data_array["0", , "0"]
      fuc <- data_array["0", "0", ]
      
      fu <- vector()
      for(c in fuc){
        for(b in fub){
          for(a in fua){
            fu <- append(fu, c(a, b, c))
          }
        }
      }
      
      fu <- matrix(fu, ncol = 3, byrow = TRUE, dimnames = list(c(), c("a", "b", "c"))) / 100
      Bliss <- apply(fu, 1, prod) * 100
      Bliss <- array(Bliss, dim(data_array), dimnames = dimnames(data_array))
      
      
      ## difference matrix
      Diff <- round(Bliss - data_array, 1)
      
      
      ## calculation of syntetic indexes according to Lehar's method
      ## (combination + additivity + efficacy indexes)
      
      ### il faut que les drug a et b aient plus de 2 doses
      
      dfa <- tail(dose_a, 2)[1]/tail(dose_a, 1)
      dfb <- tail(dose_b, 2)[1]/tail(dose_b, 1)
      dfc <- tail(dose_c, 2)[1]/tail(dose_c, 1)
      
      CIab <- matrix(NA, 1, length(dose_c), dimnames = list(NULL, dose_c))
      for(l in as.character(dose_c)) {
        CIab[1, l] <- log(dfa) * log(dfb) * sum(Diff[, , l], na.rm = TRUE) / 100
      } 
      CI <- log(dfa) * log(dfb) * log(dfc) * sum(Diff, na.rm = TRUE) / 100
      
      AIab <- matrix(NA, 1, length(dose_c), dimnames = list(NULL, dose_c)) 
      for(l in c(as.character(dose_c))){
        AIab[1, l] <- log(dfa) * log(dfb) * sum((100 - data_array - Diff)[, , l], na.rm = TRUE) / 100
      }
      AI <- log(dfa) * log(dfb) * log(dfc) * sum(100 - data_array - Diff, na.rm = TRUE) / 100
      
      EIab <- matrix(NA, 1, length(dose_c), dimnames = list(NULL, dose_c))
      for(l in c(as.character(dose_c))){
        EIab[1, l] = log(dfa) * log(dfb) * sum(100 - data_array[-1, -1, l], na.rm = TRUE) / 100
      }
      EI <- log(dfa) * log(dfb) * log(dfc) * sum(100 - data_array[-1, -1, ], na.rm = TRUE) / 100
      
      index <- data.frame(dose = colnames(EIab), EI = as.numeric(EIab), CI = as.numeric(CIab), AI = as.numeric(AIab))
      openxlsx::write.xlsx(index, file = paste0(output_dir, excel_sheets[i], "_", sep_n, "_", dimnam_i, "_index.xlsx"), row.names = FALSE)
      
      ## plots 
      colbreaks <- seq(-100, 100, 20)
      
      # plot data
      matrices.data <- c()
      for (l in dose_c) {
        
        plot.data <- plot_heatmap(
          data = data_array[, , as.character(l)], 
          drugs = list(drugA = drugs[[dimnam_i]][1], drugB = drugs[[dimnam_i]][2]), 
          color = 1, 
          title = paste0(drugs[[dimnam_i]][3]," = ",l)
        )
        
        matrices.data <- c(matrices.data, list(plot.data))
      }
      
      
      # plot Diff
      matrices.Diff <- c()
      for (l in dose_c) {
        
        plot.Diff <- plot_heatmap(
          data = Diff[, , as.character(l)], 
          drugs = list(drugA = drugs[[dimnam_i]][1], drugB = drugs[[dimnam_i]][2]), 
          color = 2, 
          title = paste0(drugs[[dimnam_i]][3]," = ",l)
        )
        
        matrices.Diff <- c(matrices.Diff, list(plot.Diff))
      }
      
      
      ## PDF manip 
      pdf(paste0(output_dir, excel_sheets[i], "_", sep_n, "_", dimnam_i, ".pdf"))
      
      print(matrices.data)
      print(matrices.Diff)
      
    
      dev.off()
      
      
      ## PDF matrices
      width <- length(dose_b) * length(matrices.data)
      height <- length(dose_a) * 2
      
      # maximum = 10*10 in = 100 in
      # 1PDF = 50 in
      # max heatmap = 10 in 
      
      nb.page.estim <- ceiling(width / 50)
      nb.mat.estim <- ceiling(length(matrices.data) / nb.page.estim)
      
      resume.pdf <- data.frame(page = rep(1:nb.page.estim, each = nb.mat.estim)[1:length(matrices.data)], 
                               matrices = 1:length(matrices.data), 
                               width = length(dose_b),
                               width.tot = cumsum(rep(length(dose_b), length(matrices.data))))
      
      resume.pdf <- resume.pdf %>% group_by(page) %>% mutate(width.cum = cumsum(width))
      
      while (any(max(resume.pdf$width.cum) > 50)) {
        ind.sup <- min(which(resume.pdf$width.cum > 50)):nrow(resume.pdf)
        resume.pdf$width.cum[ind.sup] <- cumsum(resume.pdf$width[ind.sup])
        resume.pdf$page[ind.sup] <- resume.pdf$page[ind.sup[1]] + c(rep(1, nb.mat.estim), rep(2, max(0, length(ind.sup) - nb.mat.estim)))[1:length(ind.sup)]
      }
      
      table.page <- as.numeric(table(resume.pdf$page))
      
      list.plot <- c()
      for (page_j in unique(resume.pdf$page)) {
        
        resume.temp <- dplyr::filter(resume.pdf, page == page_j)
        matrices <- resume.temp$matrices
        
        row1 <- matrices.data[[matrices[1]]]
        for (j in 2:length(matrices)) {
          len <- 1/j
          if (j < length(matrices)) row1 <- ggpubr::ggarrange(row1, matrices.data[[matrices[j]]], widths = c(1-len, len), legend = "none")
          if (j == length(matrices)) row1 <- ggpubr::ggarrange(row1, matrices.data[[matrices[j]]], widths = c(1-len, len), legend = "right", common.legend = TRUE)
        }
        
        row2 <- matrices.Diff[[matrices[1]]]
        for (j in 2:length(matrices)) {
          len <- 1/j
          if (j < length(matrices)) row2 <- ggpubr::ggarrange(row2, matrices.Diff[[matrices[j]]], widths = c(1-len, len), legend = "none")
          if (j == length(matrices)) row2 <- ggpubr::ggarrange(row2, matrices.Diff[[matrices[j]]], widths = c(1-len, len), legend = "right", common.legend = TRUE)
        }
        
        if (length(matrices) < max(table.page)) {
          empty <- ggplot() + theme_void()
          j <- length(matrices)
          while (j < max(table.page)) {
            j <- j + 1
            len <- 1/j
            row1 <- ggpubr::ggarrange(row1, empty, widths = c(1-len, len))
            row2 <- ggpubr::ggarrange(row2, empty, widths = c(1-len, len))
          }
        }
        
        p <- ggpubr::ggarrange(row1, row2, nrow = 2)
        list.plot <- c(list.plot, list(p))
      }
      ggpubr::ggexport(plotlist = list.plot, filename = paste0(output_dir, excel_sheets[i], "_", sep_n, "_", dimnam_i, "_matrices.pdf"), width = max(resume.pdf$width.cum), height = height, onefile = T)
      
    }
  })
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
    
    # if empty rows at the end of the file
    while (all(excel_sheet[nrow(excel_sheet),] %in% c("NA", "", " ", NA))) {
      excel_sheet <- excel_sheet[-nrow(excel_sheet),]
    }
    
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
