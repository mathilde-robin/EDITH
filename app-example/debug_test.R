# Test Simple de Génération HTML

cat("🧪 Test de génération HTML simple...\n")

# Créer un test minimal
test_simple <- function() {
  tryCatch({
    # Test avec du code R minimal
    rmarkdown::render(
      input = "report_template_html.Rmd",
      output_file = "test_simple.html",
      params = list(
        analysis_type = "simple",
        simple_data = list(
          effect_A = 0.3,
          effect_B = 0.4,
          observed_effect = 0.8,
          expected_effect = 0.58,
          difference = 0.22,
          synergy_percent = 37.93,
          interaction_type = "Synergique"
        ),
        matrix_data = NULL,
        multiple_data = NULL,
        multiple_results = NULL
      ),
      envir = new.env(parent = globalenv()),
      quiet = FALSE  # Afficher les erreurs
    )
    cat("✅ Succès !\n")
    return(TRUE)
  }, error = function(e) {
    cat("❌ Erreur:", e$message, "\n")
    return(FALSE)
  })
}

# Exécuter le test
library(rmarkdown)
source("utils/bliss_functions.R")
test_simple()
