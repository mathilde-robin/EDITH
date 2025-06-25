# Application Shiny pour mesurer la synergie de drogues avec la formule de Bliss
# Version 2.0 - Support PDF et HTML
# Auteur: Assistant IA
# Date: 1 juin 2025

library(shiny)
library(shinydashboard)
library(DT)
library(plotly)
library(dplyr)
library(rhandsontable)
library(rmarkdown)
library(knitr)

# Source des fonctions utilitaires
source("utils/bliss_functions.R")

# Interface utilisateur
ui <- dashboardPage(
  dashboardHeader(title = "Analyse de Synergie - Formule de Bliss v2.0"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Analyse Simple", tabName = "simple", icon = icon("calculator")),
      menuItem("Analyse de Dose", tabName = "dose", icon = icon("chart-line")),
      menuItem("Données Multiples", tabName = "multiple", icon = icon("table")),
      menuItem("À propos", tabName = "about", icon = icon("info-circle"))
    )
  ),
  
  dashboardBody(
    tags$head(
      tags$style(HTML("
        .btn-pdf { background-color: #e74c3c; border-color: #c0392b; }
        .btn-pdf:hover { background-color: #c0392b; border-color: #a93226; }
        .btn-html { background-color: #f39c12; border-color: #e67e22; }
        .btn-html:hover { background-color: #e67e22; border-color: #d68910; }
      "))
    ),
    
    tabItems(
      # Onglet Analyse Simple
      tabItem(tabName = "simple",
        fluidRow(
          box(width = 6, title = "Paramètres d'entrée", status = "primary", solidHeader = TRUE,
            numericInput("effect_A", "Effet de la drogue A (0-1):", value = 0.3, min = 0, max = 1, step = 0.01),
            numericInput("effect_B", "Effet de la drogue B (0-1):", value = 0.4, min = 0, max = 1, step = 0.01),
            numericInput("observed_effect", "Effet observé combiné (0-1):", value = 0.8, min = 0, max = 1, step = 0.01),
            br(),
            actionButton("calculate", "Calculer la Synergie", class = "btn-primary", width = "100%")
          ),
          
          box(width = 6, title = "Résultats", status = "success", solidHeader = TRUE,
            verbatimTextOutput("results_simple"),
            br(),
            plotlyOutput("plot_simple", height = "300px")
          )
        ),
        
        fluidRow(
          box(width = 6, title = "Interprétation", status = "info", solidHeader = TRUE,
            uiOutput("interpretation")
          ),
          
          box(width = 6, title = "Rapports", status = "warning", solidHeader = TRUE,
            p("Téléchargez un rapport complet de cette analyse :"),
            br(),
            fluidRow(
              column(6, 
                downloadButton("download_simple_pdf", "📄 Rapport PDF", 
                              class = "btn-pdf", width = "100%", style = "color: white;")
              ),
              column(6,
                downloadButton("download_simple_html", "🌐 Rapport HTML", 
                              class = "btn-html", width = "100%", style = "color: white;")
              )
            )
          )
        )
      ),
      
      # Onglet Analyse de Dose
      tabItem(tabName = "dose",
        fluidRow(
          box(width = 4, title = "Configuration", status = "primary", solidHeader = TRUE,
            numericInput("max_dose_A", "Dose maximale A:", value = 100, min = 1),
            numericInput("max_dose_B", "Dose maximale B:", value = 100, min = 1),
            numericInput("n_points", "Nombre de points:", value = 10, min = 3, max = 20),
            actionButton("generate_matrix", "Générer Matrice", class = "btn-primary", width = "100%")
          ),
          
          box(width = 8, title = "Matrice de Synergie", status = "success", solidHeader = TRUE,
            plotlyOutput("synergy_heatmap", height = "400px")
          )
        ),
        
        fluidRow(
          box(width = 6, title = "Données de la Matrice", status = "info", solidHeader = TRUE,
            DT::dataTableOutput("synergy_table")
          ),
          
          box(width = 6, title = "Rapports", status = "warning", solidHeader = TRUE,
            p("Téléchargez un rapport complet de l'analyse de matrice :"),
            br(),
            fluidRow(
              column(6, 
                downloadButton("download_matrix_pdf", "📄 Rapport PDF", 
                              class = "btn-pdf", width = "100%", style = "color: white;")
              ),
              column(6,
                downloadButton("download_matrix_html", "🌐 Rapport HTML", 
                              class = "btn-html", width = "100%", style = "color: white;")
              )
            )
          )
        )
      ),
      
      # Onglet Données Multiples
      tabItem(tabName = "multiple",
        fluidRow(
          box(width = 6, title = "Import de Données", status = "primary", solidHeader = TRUE,
            fileInput("file_upload", "Charger fichier CSV:",
                     accept = c(".csv", ".txt")),
            helpText("Format attendu: colonnes 'effet_A', 'effet_B', 'effet_observe'"),
            br(),
            h4("Ou saisie manuelle:"),
            rHandsontableOutput("data_table"),
            br(),
            actionButton("add_row", "Ajouter ligne", class = "btn-info"),
            actionButton("calculate_multiple", "Analyser", class = "btn-primary")
          ),
          
          box(width = 6, title = "Résultats Statistiques", status = "success", solidHeader = TRUE,
            verbatimTextOutput("stats_results"),
            br(),
            plotlyOutput("distribution_plot", height = "300px")
          )
        ),
        
        fluidRow(
          box(width = 6, title = "Résultats Détaillés", status = "info", solidHeader = TRUE,
            DT::dataTableOutput("detailed_results")
          ),
          
          box(width = 6, title = "Rapports", status = "warning", solidHeader = TRUE,
            p("Téléchargez un rapport complet de l'analyse multiple :"),
            br(),
            fluidRow(
              column(6, 
                downloadButton("download_multiple_pdf", "📄 Rapport PDF", 
                              class = "btn-pdf", width = "100%", style = "color: white;")
              ),
              column(6,
                downloadButton("download_multiple_html", "🌐 Rapport HTML", 
                              class = "btn-html", width = "100%", style = "color: white;")
              )
            )
          )
        )
      ),
      
      # Onglet À propos
      tabItem(tabName = "about",
        fluidRow(
          box(width = 12, title = "À propos de la Formule de Bliss", status = "primary", solidHeader = TRUE,
            h3("La Formule de Bliss pour l'Analyse de Synergie"),
            p("Cette application utilise la formule de Bliss pour évaluer les interactions entre deux drogues."),
            
            h4("Principe de Base"),
            p("L'effet attendu selon Bliss est calculé comme :"),
            withMathJax("$$E_{attendu} = E_A + E_B - (E_A \\times E_B)$$"),
            
            h4("Types d'Interaction"),
            tags$ul(
              tags$li(strong("Synergie"), " : L'effet observé est supérieur à l'effet attendu"),
              tags$li(strong("Additivité"), " : L'effet observé est égal à l'effet attendu"),
              tags$li(strong("Antagonisme"), " : L'effet observé est inférieur à l'effet attendu")
            ),
            
            h4("Nouvelles Fonctionnalités v2.0"),
            tags$ul(
              tags$li("📄 ", strong("Export PDF"), " : Rapports haute qualité pour publications"),
              tags$li("🌐 ", strong("Export HTML"), " : Rapports interactifs partageables"),
              tags$li("📊 ", strong("Graphiques améliorés"), " : Visualisations statiques et interactives"),
              tags$li("⚡ ", strong("Performance optimisée"), " : Génération plus rapide")
            )
          )
        )
      )
    )
  )
)

# Serveur
server <- function(input, output, session) {
  
  # Valeurs réactives
  values <- reactiveValues(
    synergy_data = NULL,
    matrix_data = NULL,
    multiple_data = data.frame(
      effet_A = c(0.2, 0.3, 0.4),
      effet_B = c(0.3, 0.4, 0.2),
      effet_observe = c(0.6, 0.8, 0.5)
    ),
    multiple_results = NULL
  )
  
  # Analyse simple
  observeEvent(input$calculate, {
    result <- calculate_bliss_synergy(input$effect_A, input$effect_B, input$observed_effect)
    values$synergy_data <- result
  })
  
  output$results_simple <- renderText({
    if (is.null(values$synergy_data)) return("Cliquez sur 'Calculer' pour voir les résultats")
    
    result <- values$synergy_data
    paste(
      sprintf("Effet attendu (Bliss): %.3f", result$expected_effect),
      sprintf("Effet observé: %.3f", result$observed_effect),
      sprintf("Différence: %.3f", result$difference),
      sprintf("Pourcentage de synergie: %.1f%%", result$synergy_percent),
      sprintf("Type d'interaction: %s", result$interaction_type),
      sep = "\n"
    )
  })
  
  output$plot_simple <- renderPlotly({
    if (is.null(values$synergy_data)) return(NULL)
    plot_bliss_comparison(values$synergy_data)
  })
  
  output$interpretation <- renderUI({
    if (is.null(values$synergy_data)) return(NULL)
    
    result <- values$synergy_data
    
    if (result$interaction_type == "Synergique") {
      color <- "green"
      icon_name <- "arrow-up"
      text <- "Les deux drogues agissent de manière synergique. L'effet combiné est supérieur à ce qui était attendu selon le modèle de Bliss."
    } else if (result$interaction_type == "Antagoniste") {
      color <- "red"
      icon_name <- "arrow-down"
      text <- "Les deux drogues présentent un antagonisme. L'effet combiné est inférieur à ce qui était attendu."
    } else {
      color <- "blue"
      icon_name <- "minus"
      text <- "Les drogues agissent de manière additive, conformément au modèle de Bliss."
    }
    
    tags$div(
      style = paste0("color: ", color, "; font-size: 16px;"),
      icon(icon_name), " ", text
    )
  })
  
  # Analyse de matrice de doses
  observeEvent(input$generate_matrix, {
    matrix_data <- generate_dose_matrix(input$max_dose_A, input$max_dose_B, input$n_points)
    values$matrix_data <- matrix_data
  })
  
  output$synergy_heatmap <- renderPlotly({
    if (is.null(values$matrix_data)) return(NULL)
    plot_synergy_heatmap(values$matrix_data)
  })
  
  output$synergy_table <- DT::renderDataTable({
    if (is.null(values$matrix_data)) return(NULL)
    values$matrix_data
  }, options = list(pageLength = 10, scrollX = TRUE))
  
  # Interface pour données multiples
  output$data_table <- renderRHandsontable({
    rhandsontable(values$multiple_data, width = "100%", height = "200px") %>%
      hot_col("effet_A", format = "0.000") %>%
      hot_col("effet_B", format = "0.000") %>%
      hot_col("effet_observe", format = "0.000")
  })
  
  observeEvent(input$data_table, {
    if (!is.null(input$data_table)) {
      values$multiple_data <- hot_to_r(input$data_table)
    }
  })
  
  observeEvent(input$add_row, {
    new_row <- data.frame(effet_A = 0, effet_B = 0, effet_observe = 0)
    values$multiple_data <- rbind(values$multiple_data, new_row)
  })
  
  # Analyse de données multiples
  observeEvent(input$calculate_multiple, {
    results <- analyze_multiple_combinations(values$multiple_data)
    values$multiple_results <- results
  })
  
  output$stats_results <- renderText({
    if (is.null(values$multiple_results)) return("Analysez les données pour voir les statistiques")
    
    stats <- values$multiple_results$statistics
    paste(
      sprintf("Nombre d'échantillons: %d", stats$n_samples),
      sprintf("Synergie moyenne: %.3f", stats$mean_synergy),
      sprintf("Écart-type: %.3f", stats$sd_synergy),
      sprintf("Synergiques: %d (%.1f%%)", stats$n_synergistic, stats$percent_synergistic),
      sprintf("Additifs: %d (%.1f%%)", stats$n_additive, stats$percent_additive),
      sprintf("Antagonistes: %d (%.1f%%)", stats$n_antagonistic, stats$percent_antagonistic),
      sep = "\n"
    )
  })
  
  output$distribution_plot <- renderPlotly({
    if (is.null(values$multiple_results)) return(NULL)
    plot_synergy_distribution(values$multiple_results$results)
  })
  
  output$detailed_results <- DT::renderDataTable({
    if (is.null(values$multiple_results)) return(NULL)
    values$multiple_results$results
  }, options = list(pageLength = 10, scrollX = TRUE))
  
  # Gestion de l'upload de fichier
  observeEvent(input$file_upload, {
    if (!is.null(input$file_upload)) {
      tryCatch({
        df <- read.csv(input$file_upload$datapath)
        if (all(c("effet_A", "effet_B", "effet_observe") %in% names(df))) {
          values$multiple_data <- df[, c("effet_A", "effet_B", "effet_observe")]
          showNotification("Fichier chargé avec succès!", type = "success")
        } else {
          showNotification("Le fichier doit contenir les colonnes: effet_A, effet_B, effet_observe", type = "error")
        }
      }, error = function(e) {
        showNotification("Erreur lors du chargement du fichier", type = "error")
      })
    }
  })
  
  # Fonction helper pour générer les rapports
  generate_report <- function(format, analysis_type, data_list) {
    
    # Validation des données
    data_check <- switch(analysis_type,
      "simple" = !is.null(data_list$simple_data),
      "matrix" = !is.null(data_list$matrix_data), 
      "multiple" = !is.null(data_list$multiple_results)
    )
    
    if (!data_check) {
      error_msg <- switch(analysis_type,
        "simple" = "Veuillez d'abord effectuer l'analyse avant de générer le rapport",
        "matrix" = "Veuillez d'abord générer la matrice avant de créer le rapport",
        "multiple" = "Veuillez d'abord analyser les données multiples avant de générer le rapport"
      )
      showNotification(error_msg, type = "error")
      return(NULL)
    }
    
    # Choisir le template selon le format
    template_file <- ifelse(format == "pdf", "report_template_pdf.Rmd", "report_template_html.Rmd")
    
    # Créer environnement temporaire
    tempReport <- file.path(tempdir(), template_file)
    file.copy(template_file, tempReport, overwrite = TRUE)
    
    # Copier les fonctions utilitaires
    tempUtils <- file.path(tempdir(), "utils")
    if (!dir.exists(tempUtils)) dir.create(tempUtils)
    file.copy("utils/bliss_functions.R", file.path(tempUtils, "bliss_functions.R"), overwrite = TRUE)
    
    # Paramètres pour le rapport
    params <- list(
      analysis_type = analysis_type,
      simple_data = data_list$simple_data,
      matrix_data = data_list$matrix_data,
      multiple_data = data_list$multiple_data,
      multiple_results = data_list$multiple_results
    )
    
    return(list(tempReport = tempReport, params = params))
  }
  
  # Download handlers pour les rapports PDF - ANALYSE SIMPLE
  output$download_simple_pdf <- downloadHandler(
    filename = function() {
      paste0("rapport_synergie_simple_", Sys.Date(), ".pdf")
    },
    content = function(file) {
      data_list <- list(
        simple_data = values$synergy_data,
        matrix_data = NULL,
        multiple_data = NULL,
        multiple_results = NULL
      )
      
      report_info <- generate_report("pdf", "simple", data_list)
      if (is.null(report_info)) return(NULL)
      
      withProgress(message = 'Génération du rapport PDF...', value = 0, {
        incProgress(0.5, detail = "Compilation en cours...")
        rmarkdown::render(report_info$tempReport, 
                         output_file = file,
                         params = report_info$params,
                         envir = new.env(parent = globalenv()))
        incProgress(1, detail = "Terminé!")
      })
    }
  )
  
  # Download handlers pour les rapports HTML - ANALYSE SIMPLE
  output$download_simple_html <- downloadHandler(
    filename = function() {
      paste0("rapport_synergie_simple_", Sys.Date(), ".html")
    },
    content = function(file) {
      data_list <- list(
        simple_data = values$synergy_data,
        matrix_data = NULL,
        multiple_data = NULL,
        multiple_results = NULL
      )
      
      report_info <- generate_report("html", "simple", data_list)
      if (is.null(report_info)) return(NULL)
      
      withProgress(message = 'Génération du rapport HTML...', value = 0, {
        incProgress(0.5, detail = "Compilation en cours...")
        rmarkdown::render(report_info$tempReport, 
                         output_file = file,
                         params = report_info$params,
                         envir = new.env(parent = globalenv()))
        incProgress(1, detail = "Terminé!")
      })
    }
  )
  
  # Download handlers pour les rapports PDF - ANALYSE MATRICE
  output$download_matrix_pdf <- downloadHandler(
    filename = function() {
      paste0("rapport_synergie_matrice_", Sys.Date(), ".pdf")
    },
    content = function(file) {
      data_list <- list(
        simple_data = NULL,
        matrix_data = values$matrix_data,
        multiple_data = NULL,
        multiple_results = NULL
      )
      
      report_info <- generate_report("pdf", "matrix", data_list)
      if (is.null(report_info)) return(NULL)
      
      withProgress(message = 'Génération du rapport PDF...', value = 0, {
        incProgress(0.5, detail = "Compilation en cours...")
        rmarkdown::render(report_info$tempReport, 
                         output_file = file,
                         params = report_info$params,
                         envir = new.env(parent = globalenv()))
        incProgress(1, detail = "Terminé!")
      })
    }
  )
  
  # Download handlers pour les rapports HTML - ANALYSE MATRICE
  output$download_matrix_html <- downloadHandler(
    filename = function() {
      paste0("rapport_synergie_matrice_", Sys.Date(), ".html")
    },
    content = function(file) {
      data_list <- list(
        simple_data = NULL,
        matrix_data = values$matrix_data,
        multiple_data = NULL,
        multiple_results = NULL
      )
      
      report_info <- generate_report("html", "matrix", data_list)
      if (is.null(report_info)) return(NULL)
      
      withProgress(message = 'Génération du rapport HTML...', value = 0, {
        incProgress(0.5, detail = "Compilation en cours...")
        rmarkdown::render(report_info$tempReport, 
                         output_file = file,
                         params = report_info$params,
                         envir = new.env(parent = globalenv()))
        incProgress(1, detail = "Terminé!")
      })
    }
  )
  
  # Download handlers pour les rapports PDF - ANALYSE MULTIPLE
  output$download_multiple_pdf <- downloadHandler(
    filename = function() {
      paste0("rapport_synergie_multiple_", Sys.Date(), ".pdf")
    },
    content = function(file) {
      data_list <- list(
        simple_data = NULL,
        matrix_data = NULL,
        multiple_data = values$multiple_data,
        multiple_results = values$multiple_results
      )
      
      report_info <- generate_report("pdf", "multiple", data_list)
      if (is.null(report_info)) return(NULL)
      
      withProgress(message = 'Génération du rapport PDF...', value = 0, {
        incProgress(0.5, detail = "Compilation en cours...")
        rmarkdown::render(report_info$tempReport, 
                         output_file = file,
                         params = report_info$params,
                         envir = new.env(parent = globalenv()))
        incProgress(1, detail = "Terminé!")
      })
    }
  )
  
  # Download handlers pour les rapports HTML - ANALYSE MULTIPLE
  output$download_multiple_html <- downloadHandler(
    filename = function() {
      paste0("rapport_synergie_multiple_", Sys.Date(), ".html")
    },
    content = function(file) {
      data_list <- list(
        simple_data = NULL,
        matrix_data = NULL,
        multiple_data = values$multiple_data,
        multiple_results = values$multiple_results
      )
      
      report_info <- generate_report("html", "multiple", data_list)
      if (is.null(report_info)) return(NULL)
      
      withProgress(message = 'Génération du rapport HTML...', value = 0, {
        incProgress(0.5, detail = "Compilation en cours...")
        rmarkdown::render(report_info$tempReport, 
                         output_file = file,
                         params = report_info$params,
                         envir = new.env(parent = globalenv()))
        incProgress(1, detail = "Terminé!")
      })
    }
  )
}

# Lancement de l'application
shinyApp(ui = ui, server = server)
