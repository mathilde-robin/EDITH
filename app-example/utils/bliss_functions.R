# Fonctions utilitaires pour l'analyse de synergie avec la formule de Bliss
# Version 2.0 avec support PDF et HTML

library(ggplot2)
library(plotly)
library(dplyr)

# Fonction principale pour calculer la synergie selon Bliss
calculate_bliss_synergy <- function(effect_A, effect_B, observed_effect) {
  # Validation des entrées
  if (any(c(effect_A, effect_B, observed_effect) < 0 | c(effect_A, effect_B, observed_effect) > 1)) {
    stop("Tous les effets doivent être entre 0 et 1")
  }
  
  # Calcul de l'effet attendu selon Bliss
  expected_effect <- effect_A + effect_B - (effect_A * effect_B)
  
  # Calcul de la différence
  difference <- observed_effect - expected_effect
  
  # Calcul du pourcentage de synergie
  synergy_percent <- ifelse(expected_effect > 0, (difference / expected_effect) * 100, 0)
  
  # Classification de l'interaction
  threshold <- 0.05
  if (difference > threshold) {
    interaction_type <- "Synergique"
  } else if (difference < -threshold) {
    interaction_type <- "Antagoniste"
  } else {
    interaction_type <- "Additif"
  }
  
  return(list(
    effect_A = effect_A,
    effect_B = effect_B,
    observed_effect = observed_effect,
    expected_effect = expected_effect,
    difference = difference,
    synergy_percent = synergy_percent,
    interaction_type = interaction_type
  ))
}

# Fonction pour créer un graphique de comparaison Bliss
plot_bliss_comparison <- function(synergy_data) {
  # Données pour le graphique
  data <- data.frame(
    Type = c("Drogue A", "Drogue B", "Attendu (Bliss)", "Observé"),
    Effet = c(synergy_data$effect_A, synergy_data$effect_B, 
              synergy_data$expected_effect, synergy_data$observed_effect),
    Couleur = c("Drogue A", "Drogue B", "Attendu", "Observé")
  )
  
  # Graphique ggplot2 (pour rapports PDF/HTML)
  p <- ggplot(data, aes(x = Type, y = Effet, fill = Couleur)) +
    geom_col(width = 0.7, alpha = 0.8) +
    geom_text(aes(label = round(Effet, 3)), vjust = -0.3, size = 4) +
    scale_fill_manual(values = c("Drogue A" = "#FF6B6B", "Drogue B" = "#4ECDC4", 
                                "Attendu" = "#45B7D1", "Observé" = "#96CEB4")) +
    scale_y_continuous(limits = c(0, max(data$Effet) * 1.1)) +
    labs(title = "Comparaison des Effets - Formule de Bliss",
         subtitle = paste("Type d'interaction:", synergy_data$interaction_type),
         x = "Type d'Effet", y = "Effet (0-1)", fill = "Légende") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1),
          plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
          plot.subtitle = element_text(hjust = 0.5, size = 12))
  
  # Version interactive pour Shiny
  plotly_version <- ggplotly(p, tooltip = c("x", "y"))
  
  return(plotly_version)
}

# Version statique pour rapports PDF
plot_bliss_comparison_static <- function(synergy_data) {
  data <- data.frame(
    Type = c("Drogue A", "Drogue B", "Attendu (Bliss)", "Observé"),
    Effet = c(synergy_data$effect_A, synergy_data$effect_B, 
              synergy_data$expected_effect, synergy_data$observed_effect),
    Couleur = c("Drogue A", "Drogue B", "Attendu", "Observé")
  )
  
  ggplot(data, aes(x = Type, y = Effet, fill = Couleur)) +
    geom_col(width = 0.7, alpha = 0.8) +
    geom_text(aes(label = round(Effet, 3)), vjust = -0.3, size = 4) +
    scale_fill_manual(values = c("Drogue A" = "#FF6B6B", "Drogue B" = "#4ECDC4", 
                                "Attendu" = "#45B7D1", "Observé" = "#96CEB4")) +
    scale_y_continuous(limits = c(0, max(data$Effet) * 1.1)) +
    labs(title = "Comparaison des Effets - Formule de Bliss",
         subtitle = paste("Type d'interaction:", synergy_data$interaction_type),
         x = "Type d'Effet", y = "Effet (0-1)", fill = "Légende") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1),
          plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
          plot.subtitle = element_text(hjust = 0.5, size = 12))
}

# Fonction pour générer une matrice de doses
generate_dose_matrix <- function(max_dose_A, max_dose_B, n_points) {
  # Création des séquences de doses
  doses_A <- seq(0, max_dose_A, length.out = n_points)
  doses_B <- seq(0, max_dose_B, length.out = n_points)
  
  # Combinaisons de toutes les doses
  combinations <- expand.grid(dose_A = doses_A, dose_B = doses_B)
  
  # Simulation des effets (modèle sigmoïde)
  combinations$effect_A <- 1 / (1 + exp(-0.05 * (combinations$dose_A - 30)))
  combinations$effect_B <- 1 / (1 + exp(-0.05 * (combinations$dose_B - 30)))
  
  # Simulation des effets observés avec variabilité
  set.seed(123)
  combinations$observed_effect <- pmin(1, 
    combinations$effect_A + combinations$effect_B - 
    (combinations$effect_A * combinations$effect_B) + 
    rnorm(nrow(combinations), 0, 0.1))
  combinations$observed_effect <- pmax(0, combinations$observed_effect)
  
  # Calcul des synergies
  combinations$expected_effect <- combinations$effect_A + combinations$effect_B - 
                                 (combinations$effect_A * combinations$effect_B)
  combinations$difference <- combinations$observed_effect - combinations$expected_effect
  combinations$synergy_percent <- ifelse(combinations$expected_effect > 0, 
                                        (combinations$difference / combinations$expected_effect) * 100, 0)
  
  # Classification
  combinations$interaction_type <- ifelse(combinations$difference > 0.05, "Synergique",
                                         ifelse(combinations$difference < -0.05, "Antagoniste", "Additif"))
  
  return(combinations)
}

# Fonction pour créer une heatmap de synergie
plot_synergy_heatmap <- function(matrix_data) {
  p <- ggplot(matrix_data, aes(x = dose_A, y = dose_B, fill = difference)) +
    geom_tile() +
    scale_fill_gradient2(low = "red", mid = "white", high = "blue", 
                        midpoint = 0, name = "Différence\nBliss") +
    labs(title = "Heatmap de Synergie",
         subtitle = "Rouge: Antagonisme, Blanc: Additif, Bleu: Synergie",
         x = "Dose Drogue A", y = "Dose Drogue B") +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5, face = "bold"),
          plot.subtitle = element_text(hjust = 0.5))
  
  return(ggplotly(p))
}

# Version statique pour rapports
plot_synergy_heatmap_static <- function(matrix_data) {
  ggplot(matrix_data, aes(x = dose_A, y = dose_B, fill = difference)) +
    geom_tile() +
    scale_fill_gradient2(low = "red", mid = "white", high = "blue", 
                        midpoint = 0, name = "Différence\nBliss") +
    labs(title = "Heatmap de Synergie",
         subtitle = "Rouge: Antagonisme, Blanc: Additif, Bleu: Synergie",
         x = "Dose Drogue A", y = "Dose Drogue B") +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5, face = "bold"),
          plot.subtitle = element_text(hjust = 0.5))
}

# Fonction pour analyser plusieurs combinaisons
analyze_multiple_combinations <- function(data) {
  # Validation
  required_cols <- c("effet_A", "effet_B", "effet_observe")
  if (!all(required_cols %in% names(data))) {
    stop("Le dataframe doit contenir les colonnes: effet_A, effet_B, effet_observe")
  }
  
  # Calculs pour chaque ligne
  results <- data %>%
    rowwise() %>%
    mutate(
      expected_effect = effet_A + effet_B - (effet_A * effet_B),
      difference = effet_observe - expected_effect,
      synergy_percent = ifelse(expected_effect > 0, (difference / expected_effect) * 100, 0),
      interaction_type = case_when(
        difference > 0.05 ~ "Synergique",
        difference < -0.05 ~ "Antagoniste",
        TRUE ~ "Additif"
      )
    ) %>%
    ungroup()
  
  # Statistiques résumées
  stats <- list(
    n_samples = nrow(results),
    mean_synergy = mean(results$difference, na.rm = TRUE),
    sd_synergy = sd(results$difference, na.rm = TRUE),
    n_synergistic = sum(results$interaction_type == "Synergique"),
    n_additive = sum(results$interaction_type == "Additif"),
    n_antagonistic = sum(results$interaction_type == "Antagoniste"),
    percent_synergistic = round(sum(results$interaction_type == "Synergique") / nrow(results) * 100, 1),
    percent_additive = round(sum(results$interaction_type == "Additif") / nrow(results) * 100, 1),
    percent_antagonistic = round(sum(results$interaction_type == "Antagoniste") / nrow(results) * 100, 1)
  )
  
  return(list(results = results, statistics = stats))
}

# Fonction pour créer un graphique de distribution des synergies
plot_synergy_distribution <- function(results_data) {
  p <- ggplot(results_data, aes(x = difference, fill = interaction_type)) +
    geom_histogram(bins = 20, alpha = 0.7, color = "white") +
    scale_fill_manual(values = c("Synergique" = "#4ECDC4", 
                                "Additif" = "#FFE66D", 
                                "Antagoniste" = "#FF6B6B")) +
    labs(title = "Distribution des Différences de Synergie",
         x = "Différence (Observé - Attendu)", 
         y = "Fréquence",
         fill = "Type d'Interaction") +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5, face = "bold"))
  
  return(ggplotly(p))
}

# Version statique pour rapports
plot_synergy_distribution_static <- function(results_data) {
  ggplot(results_data, aes(x = difference, fill = interaction_type)) +
    geom_histogram(bins = 20, alpha = 0.7, color = "white") +
    scale_fill_manual(values = c("Synergique" = "#4ECDC4", 
                                "Additif" = "#FFE66D", 
                                "Antagoniste" = "#FF6B6B")) +
    labs(title = "Distribution des Différences de Synergie",
         x = "Différence (Observé - Attendu)", 
         y = "Fréquence",
         fill = "Type d'Interaction") +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5, face = "bold"))
}

# Fonction pour graphique en secteurs (camembert)
plot_interaction_pie <- function(stats) {
  data <- data.frame(
    Type = c("Synergique", "Additif", "Antagoniste"),
    Count = c(stats$n_synergistic, stats$n_additive, stats$n_antagonistic),
    Percent = c(stats$percent_synergistic, stats$percent_additive, stats$percent_antagonistic)
  )
  
  ggplot(data, aes(x = "", y = Count, fill = Type)) +
    geom_col(width = 1) +
    coord_polar("y", start = 0) +
    scale_fill_manual(values = c("Synergique" = "#4ECDC4", 
                                "Additif" = "#FFE66D", 
                                "Antagoniste" = "#FF6B6B")) +
    labs(title = "Répartition des Types d'Interaction",
         fill = "Type") +
    theme_void() +
    theme(plot.title = element_text(hjust = 0.5, face = "bold")) +
    geom_text(aes(label = paste0(Percent, "%")), 
              position = position_stack(vjust = 0.5), size = 4)
}
