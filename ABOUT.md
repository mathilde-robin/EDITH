---
title: "About"
output: html_document
date: "2025-06-11"
---

**Interprétation** :
- **Synergie** : Effet observé > Effet attendu
- **Additivité** : Effet observé ≈ Effet attendu  
- **Antagonisme** : Effet observé < Effet attendu




Ce code est un script R qui permet d'évaluer les interactions entre des médicaments dans le cadre de combinaisons thérapeutiques (2 ou 3 médicaments). Le script prend en entrée un fichier excel, comme suit: 
photo 2 drogues, 
photo 2 drogue + replicat
photo feuilles excel
photo 3 drogues + replicats



Ensuite, il charge le package `tidyverse` pour la manipulation des données et la visualisation. Il définit plusieurs fonctions pour effectuer des tâches spécifiques, telles que l'affichage d'un message de bienvenue, le nettoyage des sous-tableaux, la vérification des données, le calcul de la matrice d'additivité selon la méthode de Bliss, le calcul des indices synthétiques selon la méthode de Lehar, et la création de graphiques de chaleur.
Le script lit un fichier Excel sélectionné par l'utilisateur, extrait les noms des médicaments et les données de chaque feuille de calcul, puis effectue les analyses pour chaque bloc de données (représentant un réplica). Pour chaque bloc, il nettoie les données, effectue les vérifications nécessaires, calcule la matrice d'additivité et les indices synthétiques, et génère des graphiques de chaleur pour visualiser les résultats.
Enfin, il enregistre les graphiques dans des fichiers PDF et affiche un message si les doses des médicaments ne sont pas cohérentes entre les réplicas.
Le script est conçu pour être interactif, avec des boîtes de dialogue pour informer l'utilisateur des erreurs ou des avertissements, et pour lui permettre de choisir le fichier Excel à analyser.
Le script est structuré de manière à être facilement extensible pour inclure d'autres analyses ou visualisations à l'avenir.
Le script est conçu pour être utilisé dans un environnement R et nécessite que l'utilisateur ait les droits d'écriture dans le répertoire de sortie spécifié.




La formule de Bliss est utilisée pour évaluer l'additivité des effets de deux ou plusieurs médicaments lorsqu'ils sont administrés en combinaison. Elle repose sur l'idée que si deux médicaments agissent indépendamment l'un de l'autre, l'effet combiné devrait être égal au produit des effets individuels de chaque médicament.
La formule de Bliss est généralement exprimée comme suit :
E_combined = E_A + E_B - (E_A * E_B)
où :
- E_combined est l'effet combiné des deux médicaments.
- E_A est l'effet du médicament A.
- E_B est l'effet du médicament B.
Cette formule suppose que les effets des médicaments sont mesurés sur une échelle de 0 à 1, où 0 représente l'absence d'effet et 1 représente l'effet maximal.
En d'autres termes, si les médicaments A et B sont administrés séparément, leurs effets individuels sont additionnés, mais l'effet combiné est ajusté en soustrayant le produit de leurs effets individuels. Cela permet de tenir compte du fait que les médicaments peuvent interagir de manière additive ou synergique.
La formule de Bliss est souvent utilisée dans les études pharmacologiques pour évaluer si une combinaison de médicaments produit un effet supérieur à celui attendu en fonction de leurs effets individuels. Si l'effet combiné est supérieur à celui prédit par la formule de Bliss, cela suggère une synergie entre les médicaments. Si l'effet combiné est inférieur, cela peut indiquer une antagonisme ou une interaction négative.



La formule de Lehar est utilisée pour évaluer l'efficacité des combinaisons de médicaments en tenant compte de leur interaction. Elle est souvent utilisée dans le contexte de la pharmacologie pour quantifier l'effet d'une combinaison de médicaments par rapport à leurs effets individuels.
La formule de Lehar est généralement exprimée comme suit :
CI = (E_A * E_B) / E_combined
où :
- CI est l'indice de combinaison, qui quantifie l'interaction entre les médicaments.
- E_A est l'effet du médicament A.
- E_B est l'effet du médicament B.
- E_combined est l'effet combiné des deux médicaments lorsqu'ils sont administrés ensemble.
L'indice de combinaison (CI) est utilisé pour évaluer si l'effet combiné des médicaments est supérieur, inférieur ou égal à la somme de leurs effets individuels. Un CI inférieur à 1 indique une synergie entre les médicaments, c'est-à-dire que leur effet combiné est supérieur à ce qui serait attendu en additionnant leurs effets individuels. Un CI égal à 1 indique une additivité, tandis qu'un CI supérieur à 1 suggère un antagonisme, où l'effet combiné est inférieur à la somme des effets individuels.
La formule de Lehar est souvent utilisée dans les études pharmacologiques pour évaluer l'efficacité des combinaisons de médicaments, en particulier dans le contexte du traitement du cancer ou d'autres maladies où plusieurs médicaments sont utilisés simultanément. Elle permet aux chercheurs de mieux comprendre comment les médicaments interagissent entre eux et d'optimiser les schémas thérapeutiques.
