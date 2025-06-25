# Application d'Analyse de Synergie v2.0

## Description
Application Shiny pour analyser la synergie de drogues en utilisant la formule de Bliss avec support complet pour l'export en **PDF** et **HTML**.

## Nouveautés Version 2.0
- ✅ **Export PDF** : Rapports haute qualité pour publications
- ✅ **Export HTML** : Rapports interactifs partageables
- ✅ **Interface améliorée** : Boutons séparés pour chaque format
- ✅ **Graphiques optimisés** : Versions statiques (PDF) et interactives (HTML)
- ✅ **Templates professionnels** : Mise en forme adaptée à chaque format

## Structure du Projet
```
synergie_drogues_app_v2/
├── app.R                      # Application Shiny principale
├── install_packages.R         # Installation des dépendances
├── report_template_html.Rmd   # Template pour rapports HTML
├── report_template_pdf.Rmd    # Template pour rapports PDF
├── utils/
│   └── bliss_functions.R      # Fonctions utilitaires
└── README.md                  # Ce fichier
```

## Installation

1. **Installer les packages requis** :
```r
source("install_packages.R")
```

2. **Lancer l'application** :
```r
shiny::runApp("app.R")
```

## Fonctionnalités

### 📊 Analyse Simple
- Calcul de synergie pour une combinaison de deux drogues
- Visualisation interactive des résultats
- **Export PDF/HTML** avec interprétation détaillée

### 📈 Analyse de Matrice de Doses
- Génération automatique de matrices dose-réponse
- Heatmap de synergie interactive
- **Export PDF/HTML** avec statistiques complètes

### 📋 Données Multiples
- Import CSV ou saisie manuelle
- Analyse statistique de plusieurs combinaisons
- **Export PDF/HTML** avec distribution et graphiques

## Types d'Export

### 📄 Rapports PDF
- Format professionnel pour publications
- Graphiques statiques haute résolution
- Mise en page optimisée pour impression
- Formules mathématiques LaTeX

### 🌐 Rapports HTML
- Format interactif pour partage web
- Bootstrap styling responsive
- Table des matières flottante
- Graphiques zoomables

## Utilisation des Rapports

1. **Effectuer une analyse** dans l'un des onglets
2. **Choisir le format** : 
   - 📄 Bouton rouge pour PDF
   - 🌐 Bouton orange pour HTML
3. **Télécharger** le rapport généré

## Support Technique

### Prérequis
- R >= 4.0
- Packages : shiny, rmarkdown, tinytex, ggplot2, etc.
- TinyTeX pour la génération PDF
- Pandoc pour la conversion

### Dépannage
- Si l'export PDF échoue : vérifier l'installation TinyTeX
- Si l'export HTML échoue : vérifier Pandoc
- Pour les formules : s'assurer que MathJax est disponible

## Formule de Bliss
```
E_attendu = E_A + E_B - (E_A × E_B)

Où :
- E_A = Effet de la drogue A
- E_B = Effet de la drogue B
- E_attendu = Effet attendu selon Bliss
```

**Interprétation** :
- **Synergie** : Effet observé > Effet attendu
- **Additivité** : Effet observé ≈ Effet attendu  
- **Antagonisme** : Effet observé < Effet attendu

## Auteur
Application développée avec GitHub Copilot
Version 2.0 - Support PDF/HTML complet
