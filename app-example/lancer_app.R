#!/usr/bin/env Rscript

# Script de lancement de l'application Synergie v2.0

cat("🚀 Lancement de l'Application d'Analyse de Synergie v2.0\n")
cat("===============================================\n\n")

# Vérification de l'environnement
cat("🔍 Vérification de l'environnement...\n")

# Packages requis
required_packages <- c("shiny", "shinydashboard", "DT", "plotly", 
                      "dplyr", "rhandsontable", "rmarkdown", "knitr", 
                      "ggplot2", "tinytex")

missing_packages <- c()
for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    missing_packages <- c(missing_packages, pkg)
  }
}

if (length(missing_packages) > 0) {
  cat("❌ Packages manquants:", paste(missing_packages, collapse = ", "), "\n")
  cat("📦 Installation en cours...\n")
  install.packages(missing_packages, repos = "https://cran.rstudio.com/")
  cat("✅ Installation terminée\n\n")
} else {
  cat("✅ Tous les packages sont installés\n\n")
}

# Vérification TinyTeX
if (tinytex::is_tinytex()) {
  cat("✅ TinyTeX disponible pour PDF\n")
} else {
  cat("⚠️  TinyTeX non installé - Export PDF indisponible\n")
}

# Vérification Pandoc
pandoc_version <- rmarkdown::pandoc_version()
if (!is.null(pandoc_version)) {
  cat("✅ Pandoc version:", as.character(pandoc_version), "\n")
} else {
  cat("⚠️  Pandoc non détecté - Export HTML peut échouer\n")
}

cat("\n🌐 Lancement de l'application...\n")
cat("📍 URL: http://127.0.0.1:3838\n")
cat("⏹️  Appuyez sur Ctrl+C pour arrêter\n\n")

# Lancement
shiny::runApp("app.R", port = 3838, host = "127.0.0.1", launch.browser = TRUE)
