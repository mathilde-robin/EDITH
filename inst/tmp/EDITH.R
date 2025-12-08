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

clean_subtable <- function (df, drug_names) {
  
  if (type == 2) {
    
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
    
    # doses
    drug_doses = list(
      drugA = as.numeric(rownames(subtable)),
      drugB = as.numeric(colnames(subtable))
    )
    
    names(drug_doses) <- unlist(drug_names)[1:2]
  }
  
  if (type == 3) {
    
    subtable <- df[-1, -c(1, ncol(df))] %>%
      dplyr::mutate(dplyr::across(dplyr::everything(), as.numeric)) %>%
      as.matrix()
    
    drug_doses <- list(
      drugA = as.numeric(unlist(unique(df[-1, 1]))),
      drugB = as.numeric(df[1, -c(1, ncol(df))]),
      drugC = as.numeric(unlist(unique(df[-1, ncol(df)])))
    )
    
    names(drug_doses) <- unlist(drug_names)
    
    subtable <- t(subtable)
    dim(subtable) <- lengths(drug_doses[c(2,1,3)])
    subtable <- aperm(subtable, c(2,1,3))
    dimnames(subtable) <- drug_doses
  }
  
  return (list(data_init = subtable, drug_doses = drug_doses))
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
  
  if (type == 2) {
    
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
  
  if (type == 3) {
    
    fua <- data_init[, "0", "0"]
    fub <- data_init["0", , "0"]
    fuc <- data_init["0", "0", ]
    
    fu <- vector()
    for (c in fuc) {
      for (b in fub) {
        for (a in fua) {
          fu <- append(fu, c(a, b, c))
        }
      }
    }
    
    fu <- matrix(fu, ncol = 3, byrow = TRUE, dimnames = list(c(), c("a", "b", "c"))) / 100
    data_bliss <- apply(fu, 1, prod) * 100
    data_bliss <- array(data_bliss, dim(data_init), dimnames = dimnames(data_init))
    
    return (data_bliss)
  }
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

plot_heatmap <- function (data, drug_names, color, title = "", subtitle = "") {
  
  rownames(data) <- convert_scientific(vect = rownames(data))
  colnames(data) <- convert_scientific(vect = colnames(data))
  
  if (color == 1) {
    color_palette <- circlize::colorRamp2(breaks = c(0, 100), colors = c("dodgerblue1", "navy"))
    color_breaks <- c(0, 50, 100)
    color_labels <- c("  0", "  50", "  100")
  } else {
    color_palette <- circlize::colorRamp2(
      breaks = c(-100, -15.1, -15, 0, 15, 15.1, 100), 
      colors = c("#00FF00", "#004e00", "#000000", "#000000", "#000000", "#4e0000", "#FF0000"))
    color_breaks <- c(-100, -50, 0, 50, 100)
    color_labels <- c("-100", "-50", "  0", "  50", "  100")
  }
  
  p <- ComplexHeatmap::Heatmap(
    matrix = data,
    name = "value",
    cluster_rows = FALSE,
    cluster_columns = FALSE,
    row_title = drug_names$drugA,
    row_title_side = "left",
    row_names_side = "left",
    row_names_centered = TRUE,
    column_title = drug_names$drugB,
    column_title_side = "bottom",
    column_names_side = "bottom",
    column_names_rot = 0,
    column_names_centered = TRUE,
    col = color_palette,
    rect_gp = grid::gpar(col = "white", lwd = 0.05),
    cell_fun = function(j, i, x, y, width, height, fill) {
      grid::grid.text(
        label = round(x = data[i,j], digits = 0), 
        x = x, y = y, gp = grid::gpar(fontsize = 10, col = "white"))
    },
    top_annotation = ComplexHeatmap::HeatmapAnnotation(
      title = ComplexHeatmap::anno_block(
        gp = grid::gpar(fill = "white", col = "white"),
        labels = ifelse(subtitle == "", subtitle, title), 
        labels_gp = grid::gpar(col = "black", fontsize = 12, fontface = "bold")),
      subtitle = ComplexHeatmap::anno_block(
        gp = grid::gpar(fill = "white", col = "white"),
        labels = ifelse(subtitle == "", title, subtitle), 
        labels_gp = grid::gpar(
          col = "black", fontsize = ifelse(subtitle == "", 12, 10), 
          fontface = ifelse(subtitle == "", "bold", "plain")))
    ),
    heatmap_legend_param = list(at = color_breaks, labels = color_labels)
  )
  
  return (p)
}

two_drugs <- function (sheet_name, drug_names, sheet_data) {
  
  # replicates identification
  sep    <- which(apply(sheet_data, 1, function(x) all(is.na(x))))
  starts <- c(1, sep + 1)
  ends   <- c(sep - 1, nrow(sheet_data))
  blocks <- purrr::map2(starts, ends, ~ .x:.y) %>% 
    purrr::discard(~length(.) < 4)
  
  # for each replicate
  global <- lapply(blocks, function (block) {
    
    subtable <- clean_subtable(df = sheet_data[block,], drug_names = drug_names)
    
    data_init <- subtable[["data_init"]]
    data_init <- checks(data_init)
    
    if (is.null(data_init)) {
      stop (call. = FALSE)
    }
    
    data_bliss <- bliss_matrix(data_init = data_init)
    data_diff  <- data_bliss - data_init
    
    return (list(
      drug_doses = subtable[["drug_doses"]],
      data_init = data_init, 
      data_bliss = data_bliss, 
      index_list = index(data_init = data_init, data_bliss = data_bliss),
      heatmap_init  = plot_heatmap(data = data_init, drug_names = drug_names, color = 1, title = "Observed viability (%)"),
      heatmap_bliss = plot_heatmap(data = data_bliss, drug_names = drug_names, color = 1, title = "Bliss expected viability (%)"),
      heatmap_diff  = plot_heatmap(data = data_diff, drug_names = drug_names, color = 2, title = "Interaction effect (%)")
    ))
  })
  
  save_replicat_2drugs(sheet_name = sheet_name, drug_names = drug_names, global = global)
}

save_replicat_2drugs <- function (sheet_name, drug_names, global) {
  
  # remove null replicates
  global <- global[sapply(global, function (x) !is.null(x))]
  
  # combine index
  index_df <- do.call(rbind, lapply(1:length(global), function (rep) {
    df <- as.data.frame(global[[rep]][["index_list"]])
    df$rep <- rep
    return (df[, c("rep", "AI", "CI", "EI")])
  }))
  
  openxlsx::write.xlsx(x = index_df, file = paste0(sheet_name, "_index.xlsx"))
  
  # pdf for each replicate
  sapply(1:length(global), function (rep) {
    pdf(file = paste0(sheet_name, "_rep", rep, ".pdf"))
    ComplexHeatmap::draw(global[[rep]][["heatmap_init"]])
    ComplexHeatmap::draw(global[[rep]][["heatmap_bliss"]])
    ComplexHeatmap::draw(global[[rep]][["heatmap_diff"]])
    dev.off()
  })
  
  # check that all replicates have the same doses in drugA
  doses_drugA <- lapply(global, function (rep) rep[["drug_doses"]][[drug_names$drugA]])
  if (!all(sapply(doses_drugA, function(x) identical(x, doses_drugA[[1]])))){
    svDialogs::dlg_message("Replicates don't have the same doses in row", type = "ok")
  }
  
  # check that replicates have the same doses in drugB
  doses_drugB <- lapply(global, function (rep) rep[["drug_doses"]][[drug_names$drugB]])
  if (!all(sapply(doses_drugB, function(x) identical(x, doses_drugB[[1]])))){
    svDialogs::dlg_message("Replicates don't have the same doses in column", type = "ok")
  }
  
  # compare replicates heatmaps in a single pdf
  grobs <- c(
    lapply(global, function (rep) {
      grid::grid.grabExpr(ComplexHeatmap::draw(rep[["heatmap_init"]]))
    }),
    lapply(global, function (rep) {
      grid::grid.grabExpr(ComplexHeatmap::draw(rep[["heatmap_diff"]]))
    })
  )
  
  width  <- max(sapply(global, function (rep) length(rep[["drug_doses"]][[drug_names$drugA]]))) * length(global) * 0.7 # * 1.33
  height <- max(sapply(global, function (rep) length(rep[["drug_doses"]][[drug_names$drugB]]))) * 2
  
  pdf(
    file = paste0(sheet_name, "_matrices.pdf"), 
    width = grid::unit(x = width, units = "in"), height = grid::unit(x = height, units = "in")
  )
  gridExtra::grid.arrange(grobs = grobs, nrow = 2, ncol = length(global))
  dev.off()
}

three_drugs <- function (sheet_name, drug_names, sheet_data) {
  
  drugs.n <- list(c(1,2,3), c(2,3,1), c(3,1,2))
  drug_perm <- lapply(drugs.n, function (x) unlist(drug_names[x]))
  drug_perm <- lapply(drug_perm, function (x) {
    names(x) <- c("drugA", "drugB", "drugC")
    return (x)
  })
  
  # replicates identification
  sep    <- which(apply(sheet_data, 1, function(x) all(is.na(x))))
  starts <- c(1, sep + 1)
  ends   <- c(sep - 1, nrow(sheet_data))
  blocks <- purrr::map2(starts, ends, ~ .x:.y) %>% 
    purrr::discard(~length(.) < 4)
  
  # for each replicate
  lapply(1:length(blocks), function (rep) {
    
    block <- blocks[[rep]]
    
    subtable <- clean_subtable(df = sheet_data[block,], drug_names = drug_names)
    data_init  <- subtable[["data_init"]]
    drug_doses <- subtable[["drug_doses"]]
    
    ############################################################################
    # Creer une fonction checks pour 3 drugs
    # data_init <- checks(data_init)
    # 
    # if (is.null(data_init)) {
    #   stop (call. = FALSE)
    # }
    ############################################################################
    
    # drugs permutation
    lapply(1:length(drug_perm), function (perm) {
      
      drug_names_perm <- drug_perm[[perm]]
      data_perm <- aperm(data_init, perm = drug_names_perm)
      
      data_bliss <- bliss_matrix(data_init = data_perm)
      data_diff <- round(data_bliss - data_perm, 1)
      
      global <- lapply(drug_doses[[drug_names_perm[3]]], function (dose_c) {
        
        dose_c <- as.character(dose_c)
        subtitle <- paste0(drug_names_perm[3],": ", dose_c)
        
        heatmap_init <- plot_heatmap(
          data = data_perm[,, dose_c], drug_names = as.list(drug_names_perm), color = 1, 
          title = "Observed viability (%)", subtitle = subtitle
        )
        
        heatmap_bliss <- plot_heatmap(
          data = data_bliss[,, dose_c], drug_names = as.list(drug_names_perm), color = 1, 
          title = "Bliss expected viability (%)", subtitle = subtitle
        )
        
        heatmap_diff <- plot_heatmap(
          data = data_diff[,, dose_c], drug_names = as.list(drug_names_perm), color = 2, 
          title = "Interaction effect (%)", subtitle = subtitle
        )
        
        return (list(
          data_init = data_perm[,, dose_c],
          data_bliss = data_bliss[,, dose_c],
          index_list = index(data_init = data_perm[,, dose_c], data_bliss = data_bliss[,, dose_c]),
          heatmap_init = heatmap_init,
          heatmap_bliss = heatmap_bliss,
          heatmap_diff = heatmap_diff
        ))
      })
      
      save_perm_3drugs(
        sheet_name = sheet_name, rep = rep, perm = perm, drug_doses = drug_doses, 
        drug_names = drug_names_perm, global = global
      )
    })
  })
}

save_perm_3drugs <- function (sheet_name, rep, perm, drug_doses, drug_names, global) {
  
  # remove null rotation
  global <- global[sapply(global, function (x) !is.null(x))]
  
  # combine index
  index_df <- do.call(rbind, lapply(1:length(global), function (dose_c) {
    df <- as.data.frame(global[[dose_c]][["index_list"]])
    df$dose_c <- drug_doses[[drug_names[3]]][dose_c]
    df <- df[, c("dose_c", "AI", "CI", "EI")]
    colnames(df)[1] <- drug_names[3]
    return (df)
  }))
  
  openxlsx::write.xlsx(x = index_df, file = paste0(sheet_name, "_rep", rep, "_perm", perm, "_index.xlsx"))
  
  # global pdf
  pdf(file = paste0(sheet_name, "_rep", rep, "_perm", perm, ".pdf"))
  for (dose_c in 1:length(global)) ComplexHeatmap::draw(global[[dose_c]][["heatmap_init"]])
  for (dose_c in 1:length(global)) ComplexHeatmap::draw(global[[dose_c]][["heatmap_bliss"]])
  for (dose_c in 1:length(global)) ComplexHeatmap::draw(global[[dose_c]][["heatmap_diff"]])
  dev.off()
  
  # global pdf - one file
  grobs <- c(
    lapply(1:length(global), function (dose_c) {
      grid::grid.grabExpr(ComplexHeatmap::draw(global[[dose_c]][["heatmap_init"]]))
    }),
    lapply(1:length(global), function (dose_c) {
      grid::grid.grabExpr(ComplexHeatmap::draw(global[[dose_c]][["heatmap_diff"]]))
    })
  )
  
  width  <- length(drug_doses[[drug_names[2]]]) * length(drug_doses[[drug_names[3]]]) * 1.33
  height <- 2 * length(drug_doses[[drug_names[1]]])
  
  pdf(
    file = paste0(sheet_name, "_rep", rep, "_perm", perm, "_matrices.pdf"), 
    width = grid::unit(x = width, units = "in"), height = grid::unit(x = height, units = "in")
  )
  gridExtra::grid.arrange(grobs = grobs, nrow = 2, ncol = length(drug_doses[[drug_names[3]]]))
  dev.off()
}

################################################################################
# Main
################################################################################

run_EDITH <- function () {
  
  # options(warn = -1)
  
  # say_hello()
  
  filename <- file.choose(new = TRUE) %>%
    stringr::str_replace_all(string = ., pattern = "\\\\", replacement = "/")
  
  output_dir <- filename %>%
    stringr::str_replace(string = ., pattern = ".xlsx", replacement = "_output/")
  
  dir.create(output_dir, showWarnings = FALSE)
  setwd(output_dir)
  
  sheet_names <- readxl::excel_sheets(path = filename)
  
  invisible(
    sapply(sheet_names, function (sheet_name) {
      
      sheet_data <- readxl::read_excel(
        path = filename, sheet = sheet_name, 
        col_names = FALSE, progress = FALSE, .name_repair = "minimal"
      )
      
      # rename empty colnames
      colnames(sheet_data) <- 1:ncol(sheet_data)
      
      # if empty rows at the end of the file
      while (all(sheet_data[nrow(sheet_data),] %in% c("NA", "", " ", NA))) {
        sheet_data <- sheet_data[-nrow(sheet_data),]
      }
      
      # drugs names extraction
      drug_names <- list(
        drugA = as.character(sheet_data[1,1]), 
        drugB = as.character(sheet_data[1,2]),
        drugC = as.character(sheet_data[1,3])
      )
      
      if (any(c(drug_names$drugA, drug_names$drugB) %in% c("NA", "", " ", NA))) {
        svDialogs::dlg_message(message = paste0("Drug name(s) are missing in sheet ", i), type = "ok")
        return (NULL)
      }
      
      # 2 or 3 drugs?
      type <- NA
      if (drug_names$drugC %in% c("NA", "", " ", NA)) {
        type <<- 2
        two_drugs(sheet_name = sheet_name, drug_names = drug_names, sheet_data = sheet_data)
      } else {
        type <<- 3
        three_drugs(sheet_name = sheet_name, drug_names = drug_names, sheet_data = sheet_data)
      }
    })
  )
}

run_EDITH() 
