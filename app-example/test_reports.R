# Test de Génération de Rapports
# Ce script teste la génération PDF et HTML

library(rmarkdown)

cat("🧪 Test de génération de rapports...\n\n")

# Données de test pour l'analyse simple
test_data <- list(
  effect_A = 0.3,
  effect_B = 0.4,
  observed_effect = 0.8,
  expected_effect = 0.58,
  difference = 0.22,
  synergy_percent = 37.93,
  interaction_type = "Synergique"
)

# Test génération HTML
cat("📄 Test génération HTML...\n")
tryCatch({
  rmarkdown::render(
    "report_template_html.Rmd",
    output_file = "test_report.html",
    params = list(
      analysis_type = "simple",
      simple_data = test_data,
      matrix_data = NULL,
      multiple_data = NULL,
      multiple_results = NULL
    ),
    quiet = TRUE
  )
  cat("✅ Rapport HTML généré : test_report.html\n")
}, error = function(e) {
  cat("❌ Erreur HTML :", e$message, "\n")
})

# Test génération PDF
cat("📄 Test génération PDF...\n")
tryCatch({
  rmarkdown::render(
    "report_template_pdf.Rmd",
    output_file = "test_report.pdf",
    params = list(
      analysis_type = "simple",
      simple_data = test_data,
      matrix_data = NULL,
      multiple_data = NULL,
      multiple_results = NULL
    ),
    quiet = TRUE
  )
  cat("✅ Rapport PDF généré : test_report.pdf\n")
}, error = function(e) {
  cat("❌ Erreur PDF :", e$message, "\n")
})

cat("\n🎉 Tests terminés !\n")
