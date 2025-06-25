# Installation des packages requis pour l'application Shiny
# avec support PDF et HTML pour les rapports

cat("Installation des packages pour l'application de synergie...\n\n")

# Liste des packages requis
packages <- c(
  # Packages Shiny de base
  "shiny",
  "shinydashboard", 
  "DT",
  "plotly",
  "dplyr",
  "rhandsontable",
  
  # Packages pour génération de rapports
  "rmarkdown",
  "knitr",
  "tinytex",     # Support LaTeX pour PDF
  "ggplot2",
  "kableExtra",  # Tableaux avancés
  "htmltools",
  
  # Packages additionnels
  "yaml",
  "base64enc"
)

# Fonction pour installer un package s'il n'est pas déjà installé
install_if_missing <- function(package) {
  if (!require(package, character.only = TRUE, quietly = TRUE)) {
    cat("Installation de", package, "...\n")
    install.packages(package, dependencies = TRUE)
    return(TRUE)
  } else {
    cat("✓", package, "déjà installé\n")
    return(FALSE)
  }
}

# Installer tous les packages
newly_installed <- sapply(packages, install_if_missing)

cat("\n=== RÉSUMÉ ===\n")
cat("Packages installés:", sum(newly_installed), "\n")
cat("Packages déjà présents:", sum(!newly_installed), "\n")

# Configuration TinyTeX pour PDF (si pas déjà installé)
if (!tinytex::is_tinytex()) {
  cat("\n📄 Installation de TinyTeX pour le support PDF...\n")
  cat("Ceci peut prendre quelques minutes...\n")
  try({
    tinytex::install_tinytex()
    cat("✅ TinyTeX installé avec succès!\n")
  }, silent = FALSE)
} else {
  cat("✅ TinyTeX déjà installé\n")
}

# Vérification de Pandoc
pandoc_version <- rmarkdown::pandoc_version()
if (is.null(pandoc_version)) {
  cat("\n⚠️  ATTENTION: Pandoc n'est pas détecté\n")
  cat("Pour générer des rapports, installez Pandoc:\n")
  cat("macOS: brew install pandoc\n")
  cat("Ubuntu: sudo apt-get install pandoc\n")
  cat("Windows: https://pandoc.org/installing.html\n")
} else {
  cat("✅ Pandoc version:", as.character(pandoc_version), "\n")
}

cat("\n🎉 Installation terminée!\n")
cat("Lancez l'application avec: shiny::runApp('app.R')\n")
