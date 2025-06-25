# Guide d'Utilisation - Application Synergie v2.0

## 🚀 Démarrage Rapide

### 1. Vérification de l'Installation
```bash
# Vérifier que l'application fonctionne
R -e "shiny::runApp('app.R', port=3838, launch.browser=TRUE)"
```

### 2. Accès à l'Application
- **URL locale** : http://127.0.0.1:3838
- **Interface** : Dashboard avec 4 onglets

## 📊 Fonctionnalités

### Onglet 1 : Analyse Simple
1. **Saisir les valeurs** :
   - Effet drogue A (ex: 0.3)
   - Effet drogue B (ex: 0.4)  
   - Effet observé (ex: 0.8)

2. **Cliquer** sur "Calculer la Synergie"

3. **Exporter le rapport** :
   - 📄 **Bouton Rouge** → Rapport PDF
   - 🌐 **Bouton Orange** → Rapport HTML

### Onglet 2 : Analyse de Dose
1. **Configurer la matrice** :
   - Dose maximale A (ex: 100)
   - Dose maximale B (ex: 100)
   - Nombre de points (ex: 10)

2. **Générer** la matrice

3. **Exporter** : PDF ou HTML disponibles

### Onglet 3 : Données Multiples
1. **Import de données** :
   - Format CSV avec colonnes : `effet_A`, `effet_B`, `effet_observe`
   - Ou saisie manuelle dans le tableau

2. **Analyser** les données

3. **Exporter** les résultats

## 🔧 Résolution de Problèmes

### Export PDF ne fonctionne pas
```r
# Vérifier TinyTeX
tinytex::is_tinytex()

# Réinstaller si nécessaire
tinytex::install_tinytex()
```

### Export HTML ne fonctionne pas
```r
# Vérifier Pandoc
rmarkdown::pandoc_version()
```

### Application ne se lance pas
```r
# Réinstaller les packages
source("install_packages.R")
```

## 📋 Exemple de Données CSV

Créer un fichier `exemple.csv` :
```csv
effet_A,effet_B,effet_observe
0.2,0.3,0.6
0.3,0.4,0.8
0.1,0.2,0.35
0.4,0.5,0.95
```

## 🎯 Résultats Attendus

### Types d'Interaction
- **Synergie** : Effet observé > Effet Bliss (différence > 0.05)
- **Additivité** : Effet observé ≈ Effet Bliss (|différence| ≤ 0.05)
- **Antagonisme** : Effet observé < Effet Bliss (différence < -0.05)

### Formats de Rapport
- **PDF** : Publication, impression, partage professionnel
- **HTML** : Web, interactif, visualisation en ligne

## ✅ Test de Fonctionnement

### Test Simple dans l'Application
1. Aller à l'onglet "Analyse Simple"
2. Utiliser les valeurs par défaut (0.3, 0.4, 0.8)
3. Cliquer "Calculer"
4. Vérifier que le résultat indique "Synergique"
5. Tester l'export PDF et HTML

### Validation des Résultats
- **Effet attendu Bliss** : 0.3 + 0.4 - (0.3 × 0.4) = 0.58
- **Différence** : 0.8 - 0.58 = 0.22
- **Type** : Synergique (différence > 0.05)

## 🆘 Support

En cas de problème :
1. Vérifier les logs R dans la console
2. S'assurer que tous les packages sont installés
3. Vérifier les permissions d'écriture pour l'export
4. Tester avec les données d'exemple

---
**Version** : 2.0 - Support PDF/HTML
**Date** : Juin 2025
