
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
Le script lit un fichier Excel sélectionné par l'utilisateur, extrait les noms des médicaments et les données de chaque feuille de calcul, puis effectue les analyses pour chaque bloc de données (représentant un réplicat). Pour chaque bloc, il nettoie les données, effectue les vérifications nécessaires, calcule la matrice d'additivité et les indices synthétiques, et génère des heatmaps pour visualiser les résultats.
Enfin, il enregistre les graphiques dans des fichiers PDF et affiche un message si les doses des médicaments ne sont pas cohérentes entre les réplicats.
Le script est conçu pour être interactif, avec des boîtes de dialogue pour informer l'utilisateur des erreurs ou des avertissements, et pour lui permettre de choisir le fichier Excel à analyser.
Le script est conçu pour être utilisé dans un environnement R et nécessite que l'utilisateur ait les droits d'écriture dans le répertoire de sortie spécifié.

La formule de Bliss est utilisée pour évaluer l'additivité des effets de deux ou plusieurs médicaments lorsqu'ils sont administrés en combinaison. Elle repose sur l'idée que si deux médicaments agissent indépendamment l'un de l'autre, l'effet combiné devrait être égal à la somme des effets individuels de chaque médicament.
La formule de Bliss est généralement exprimée comme suit :

E_combined = E_A + E_B - (E_A * E_B)
où :
- E_combined est l'effet combiné des deux médicaments.
- E_A est l'effet du médicament A.
- E_B est l'effet du médicament B.

  
(((Cette formule suppose que les effets des médicaments sont mesurés sur une échelle de 0 à 1, où 0 représente l'absence d'effet et 1 représente l'effet maximal.))) ????
En d'autres termes, si les médicaments A et B sont administrés séparément, leurs effets individuels sont additionnés, mais l'effet combiné est ajusté en soustrayant le produit de leurs effets individuels. Cela permet de tenir compte du fait que les médicaments peuvent interagir de manière additive ou synergique.
La formule de Bliss est souvent utilisée dans les études pharmacologiques pour évaluer si une combinaison de médicaments produit un effet supérieur à celui attendu en fonction de leurs effets individuels. Si l'effet combiné est supérieur à celui prédit par la formule de Bliss, cela suggère une synergie entre les médicaments. Si l'effet combiné est inférieur, cela indique un antagonisme.

La formule de Lehar est utilisée pour évaluer l'efficacité des combinaisons de médicaments en tenant compte de leur interaction. Elle est souvent utilisée dans le contexte de la pharmacologie pour quantifier l'effet d'une combinaison de médicaments par rapport à leurs effets individuels.
La formule de Lehar est généralement exprimée comme suit :
CI = (E_A * E_B) / E_combined
où :
- CI est l'indice de combinaison, qui quantifie l'interaction entre les médicaments.
- E_A est l'effet du médicament A.
- E_B est l'effet du médicament B.
- E_combined est l'effet combiné des deux médicaments lorsqu'ils sont administrés ensemble.
L'indice de combinaison (CI) est utilisé pour évaluer si l'effet combiné des médicaments est supérieur, inférieur ou égal à la somme de leurs effets individuels. Un CI supérieur à 1 indique une synergie entre les médicaments, c'est-à-dire que leur effet combiné est supérieur à ce qui serait attendu en additionnant leurs effets individuels. Un CI égal à 1 indique une additivité, tandis qu'un CI inférieur à 1 suggère un antagonisme, où l'effet combiné est inférieur à la somme des effets individuels.
La formule de Lehar est souvent utilisée dans les études pharmacologiques pour évaluer l'efficacité des combinaisons de médicaments, en particulier dans le contexte du traitement du cancer ou d'autres maladies où plusieurs médicaments sont utilisés simultanément. Elle permet aux chercheurs de mieux comprendre comment les médicaments interagissent entre eux et d'optimiser les schémas thérapeutiques.

-----

**Method**:

*Index*:

According to the approach proposed by Lehar (Lehár et al., 2007, 2008, 2009), a point-by-point calculation of the expected values in case of absence of interaction effect is performed over all the matrix concentration combinations in order to obtain an expected-value matrix. Then, a **combination index**, **CI**, is calculated as follows: $CI = \ln f_A \ln f_B \sum_{A,B} (M_0 - M_E)$ where $M_O$ and $M_E$ are the matrices of the observed and expected values, respectively, and $f_A$ and $f_B$ are the dilution factors for the drugs A and B. The **CI** is a positive-gated, effect-weighted volume over the lack of interaction effect (i.e. Bliss independence), adjusted for variable dilution factors $f_A$ and $f_B$. An **efficacy index** is also calculated as follow: $EI = \ln f_A \ln f_B \sum_{A,B} M_0$. 

Lehár, J., Zimmermann, G.R., Krueger, A.S., Molnar, R.A., Ledell, J.T., Heilbut, A.M., Short, G.F., Giusti, L.C., Nolan, G.P., Magid, O.A., et al. (2007). Chemical combination effects predict connectivity in biological systems. Mol. Syst. Biol. 3, 80.

Lehár, J., Stockwell, B.R., Giaever, G., and Nislow, C. (2008). Combination chemical genetics. Nat. Chem. Biol. 4, 674–681.

Lehár, J., Krueger, A.S., Avery, W., Heilbut, A.M., Johansen, L.M., Price, E.R., Rickles, R.J., Short, G.F., Staunton, J.E., Jin, X., et al. (2009). Synergistic drug combinations tend to improve therapeutically relevant selectivity. Nat. Biotechnol. 27, 659–666.

Note: $M_O$ et $M_E$ correspondent aux nombres de cellules mortes (et pas vivantes comme dans nos calculs ...)
