# Read me

# Data file format specifications
# You must provide a xlsx file with one or more sheets
# The sheets names must be different from each other
# In each sheet:
#   1. The first row must contains the names of three drugs in the first three cells
#   2. Drug name order: row drug, column drug, third drug
#   3. The second row must be blank
#   4. If two or more data matrices : always separated by a blank row

# The name of figure will be composed by:
#   1. the name of the corresponding sheet
#   2. the rank of the corresponding matrix in the sheet
#   3. the rank of drug permutation used for the array dimensions (from 1 to 3 for each matrix)

# Create a folder named "output" in the wd, in order to collect the figure files
# Modify the settings in the corresponding section here below and it's done


######################################################################################################
# Changes since the previous version: 
# - save the index as .xlsx


## set wd
wd <- "~/Matrices/3drugs/"
filename <- paste0(wd, "data-modele.xlsx")
output <- paste0(wd, "output/")
setwd(output)


## loading libraries
library(readxl)
library(gplots)
library(dplyr)
library(gtools)
library(gridExtra)
library(gridGraphics)
library(ggplot2)
library(ggpubr)
library(reshape2)
library(xlsx)


### remettre dans l'ordre les doses si pas dans le bon sens


sheets <- excel_sheets(filename)
for(sheet_n in 1:length(sheets)){
  
  excel <- read_excel(filename, sheet = sheets[sheet_n], col_names = FALSE)
  sep <- c(which(rowSums(!is.na(excel)) == 0), nrow(excel)+1)
  
  drugs.n <- list(c(1,2,3), c(2,3,1), c(3,1,2))
  drugs <- lapply(drugs.n, function(x) as.character(excel[1, 1:3])[x])
  
  for(sep_n in 1:(length(sep)-1)){
    
    ## data formating 
    data <- as.matrix(excel[(sep[sep_n]+1):(sep[sep_n+1]-1),])
    class(data) <- "numeric"
    
    doses <- list(drugA = as.numeric(unique(data[-nrow(data), 1])),
                  drugB = as.numeric(data[nrow(data), -c(1, ncol(data))]),
                  drugC = as.numeric(unique(data[-nrow(data), ncol(data)])))
    
    
    data <- round(data[-nrow(data), -c(1, ncol(data))], 0)
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
      # write.csv2(index, file = paste0(output, sheets[sheet_n], "_", sep_n, "_", dimnam_i, "_index.csv"), row.names = FALSE, quote = FALSE)
      write.xlsx(index, file = paste0(output, sheets[sheet_n], "_", sep_n, "_", dimnam_i, "_index.xlsx"), row.names = FALSE)
      
      ## plots 
      colbreaks <- seq(-100, 100, 20)
      
      # plot data
      matrices.data <- c()
      for (l in dose_c) {
        
        data.plot <- as.data.frame(data_array[, , as.character(l)])
        data.plot$doseA <- rownames(data.plot)
        data.plot <- reshape2::melt(data.plot, id.vars = "doseA")
        
        plot.data <- ggplot(data.plot, aes(x = variable, y = doseA, fill = value)) +
          geom_tile() +
          scale_y_discrete(position = "left", limits = rev(as.character(dose_a))) +
          scale_x_discrete(position = "bottom", limits = as.character(dose_b)) +
          scale_fill_gradient(low = "dodgerblue1", high = "navy", 
                              limits = c(0, 100),
                              breaks = c(0, 50, 100)) +
          labs(x = name_b, y = name_a, title = paste(name_c, as.character(l))) +
          geom_text(aes(label = round(value)), color = "white") +
          theme_minimal() +
          theme(axis.title = element_text(size = 14),
                axis.text = element_text(size = 12))
        
        matrices.data <- c(matrices.data, list(plot.data))
      }
      
      
      # plot Diff
      matrices.Diff <- c()
      for (l in dose_c) {
        
        Diff.plot <- as.data.frame(Diff[, , as.character(l)])
        Diff.plot$doseA <- rownames(Diff.plot)
        Diff.plot <- reshape2::melt(Diff.plot, id.vars = "doseA")
        
        plot.Diff <- ggplot(Diff.plot, aes(x = variable, y = doseA, fill = value)) +
          geom_tile() +
          scale_y_discrete(position = "left", limits = rev(as.character(dose_a))) +
          scale_x_discrete(position = "bottom", limits = as.character(dose_b)) +
          scale_fill_gradientn(colors = c("#00FF00", "#004e00", "#000000", "#000000", "#000000", "#4e0000", "#FF0000"),
                               values = c(0, 0.425, 0.426, 0.5, 0.575, 0.576, 1),
                               limits = c(colbreaks[1], colbreaks[11]),
                               breaks = c(colbreaks[1], 0, colbreaks[11])) +
          labs(x = name_b, y = name_a, title = paste(name_c, as.character(l))) +
          geom_text(aes(label = round(value)), color = "white") +
          theme_minimal() +
          theme(axis.title = element_text(size = 14),
                axis.text = element_text(size = 12))
        
        matrices.Diff <- c(matrices.Diff, list(plot.Diff))
      }
      
      
      ## PDF manip 
      pdf(paste0(output, sheets[sheet_n], "_", sep_n, "_", dimnam_i, ".pdf"))
      
      print(matrices.data)
      print(matrices.Diff)
      
      bpEI <- barplot(EIab, col = "dodgerblue1", ylim = c(min(0, min(EIab) * 1.5), max(0, max(EIab) * 1.5)),
                      main = as.character(paste("EI for matrices", " \n ", "with", name_a, "and", name_b)))
      text(bpEI, EIab, labels = round(EIab, 1), EIab, pos = 3)
      
      bpAI <- barplot(AIab, col = "green", ylim = c(min(0, min(AIab) * 1.5), max(0, max(AIab * 1.5))),
                      main = as.character(paste("AI for matrices", " \n ", "with", name_a, "and", name_b)))
      text(bpAI, AIab, labels = round(AIab, 1), AIab, pos = 3)
      
      bpCI <- barplot(CIab, col = "red", ylim = c(min(0, min(CIab) * 1.5), max(0, max(CIab * 1.5))),
                      main = as.character(paste("CI for matrices", " \n ", "with", name_a, "and", name_b)))
      text(bpCI, CIab, labels = round(CIab, 1), CIab, pos = 3)
      
      plot(EIab, CIab, main = "EI vs CI", xlab = "EI", ylab = "CI", pch = 19)
      plot(AIab, CIab, main = "AI vs CI", xlab = "AI", ylab = "CI", pch = 19)
      plot(dose_c, CIab/EIab, main = "CI/EI", xlab = as.character(name_c), ylab = "CI/EI", pch = 19)
      
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
      for (page_i in unique(resume.pdf$page)) {
        
        resume.temp <- dplyr::filter(resume.pdf, page == page_i)
        matrices <- resume.temp$matrices
        
        row1 <- matrices.data[[matrices[1]]]
        for (i in 2:length(matrices)) {
          len <- 1/i
          if (i < length(matrices)) row1 <- ggarrange(row1, matrices.data[[matrices[i]]], widths = c(1-len, len), legend = "none")
          if (i == length(matrices)) row1 <- ggarrange(row1, matrices.data[[matrices[i]]], widths = c(1-len, len), legend = "right", common.legend = TRUE)
        }
        
        row2 <- matrices.Diff[[matrices[1]]]
        for (i in 2:length(matrices)) {
          len <- 1/i
          if (i < length(matrices)) row2 <- ggarrange(row2, matrices.Diff[[matrices[i]]], widths = c(1-len, len), legend = "none")
          if (i == length(matrices)) row2 <- ggarrange(row2, matrices.Diff[[matrices[i]]], widths = c(1-len, len), legend = "right", common.legend = TRUE)
        }
        
        if (length(matrices) < max(table.page)) {
          empty <- ggplot() + theme_void()
          i <- length(matrices)
          while (i < max(table.page)) {
            i <- i + 1
            len <- 1/i
            row1 <- ggarrange(row1, empty, widths = c(1-len, len))
            row2 <- ggarrange(row2, empty, widths = c(1-len, len))
          }
        }
        
        p <- ggarrange(row1, row2, nrow = 2)
        list.plot <- c(list.plot, list(p))
      }
      ggexport(plotlist = list.plot, filename = paste0(output, sheets[sheet_n], "_", sep_n, "_", dimnam_i, "_matrices.pdf"), width = max(resume.pdf$width.cum), height = height, onefile = T)
      
    }
  }
}