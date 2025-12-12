# Theory

  

## 🎯 **Motivations**

Characterizing interactions between drugs is an area of major interest
for drug  
development, as exploiting synergism between drugs could allow
increasing treatment efficacy using lower doses of single drugs, and
avoiding antagonistic interaction is needed to maintain the therapeutic
efficacy of drugs. Broadly speaking, synergism and antagonism could be
defined as an increase or a reduction of the effect of a drug
combination compared to the effect expected for the combination on the
basis of the single agent effects.

The `EDITH` package enables the synergistic effects of two or three
drugs to be explored, based on cell viability data obtained from
combination experiments. The package is designed to analyze and
visualize drug interactions and implements a widely used method for
assessing drug interactions: *the Bliss independence model*.

  

## 📐 **Bliss independence model**

The Bliss independence model is a mathematical framework used to
evaluate the independence (ie. the absence of any interaction effect) of
two drugs when they are administered in combination. The general form of
Bliss independence model is the following equation:

$$E_{combined} = E_{A} + E_{B} - \left( E_{A}*E_{B} \right)$$ where:

- $E_{A}$ is the effect of drug A,
- $E_{B}$ is the effect of drug B,
- $E_{combined}$ is the expected effect of the drug combination.

In the case of a cancer cell population, the effect will correspond to
the fraction of cells killed by the drug(s). For example, if drug A
kills 30% of the cells, $E_{A} = 0.3$ and drug B kills 40% of the cells
$E_{B} = 0.4$. According to the Bliss independence model, the expected
effect of the combination of drugs A and B would be:
$$E_{combined} = 0.3 + 0.4 - (0.3*0.4) = 0.58$$ This means that the
combination of drugs A and B is expected to kill 58% of the cells if
they act independently.

The Bliss equation can be recast in terms of unaffected cells as
follows:

$$U_{combined} = U_{A}*U_{B}$$

where:

- $U_{A}$ is the fraction of unaffected cells by drug A (ie. viability
  after treatment with drug A),
- $U_{B}$ is the fraction of unaffected cells by drug B (ie. viability
  after treatment with drug B),
- $U_{combined}$ is the expected fraction of unaffected cells by the
  drug combination.

For example, if drug A leaves 70% of the cells unaffected, $U_{A} = 0.7$
and drug B leaves 60% of the cells unaffected $U_{B} = 0.6$. According
to the Bliss independence model, the expected fraction of unaffected
cells by the combination of drugs A and B would be:

$$U_{combined} = 0.7*0.6 = 0.42$$ This means that the combination of
drugs A and B is expected to leave 42% of the cells unaffected if they
act independently.

The generalized form of the Bliss equation for a combination of n drugs
is:

$$U_{combined} = \prod\limits_{i = 1}^{n}U_{i}$$

where:

- $i = 1,...,n$ indexes the drugs in the combination,
- $U_{i}$ is the fraction of unaffected cells by drug $i$.

🚨 **Important**: the values in the input matrix must correspond to the
percentage of living cells.

  

## 👀 ️**Visual example**

To illustrate the Bliss independence model, consider the following
example with two drugs, A and B:

![theory - visual](../reference/figures/theory_visual.png)

  

## 🔍 **Evaluation of drug interactions**

To evaluate the interaction between drugs, the observed effect of the
drug combination is compared to the expected effect calculated using the
Bliss independence model. This is simply done by subtracting the
observed effect from the expected effect:

$$Interaction = E_{expected} - E_{observed}$$

  

## 🧩 **Interpretation**:

The interaction can be classified into three categories based on this
comparison:

- ⚡ **Synergy**: More cells killed than expected → positive interaction
  effect ($E_{expected} < E_{observed}$)
- ⚖️ **Additivity**: As many cells killed as expected → no interaction
  effect ($E_{expected} \approx E_{observed}$)
- ⚔️ **Antagonism**: Less cells killed than expected → negative
  interaction effect ($E_{expected} > E_{observed}$)

  

## 👀 ️**Visual example**

To illustrate the interaction estimation, consider the following example
with two drugs, A and B:

![theory - visual 2](../reference/figures/theory_visual_2.png)

  

## 🧮 **Quantification of drug interactions**

Different measures can be used to quantify drug interactions. In the
`EDITH` package, we implement three different indexes: the additive
index, the combination index and the efficacy index.

### **Additive index**

### **Combination index**

### **Efficacy index**

La formule de Lehar est utilisée pour évaluer l’efficacité des
combinaisons de médicaments en tenant compte de leur interaction. Elle
est souvent utilisée dans le contexte de la pharmacologie pour
quantifier l’effet d’une combinaison de médicaments par rapport à leurs
effets individuels. La formule de Lehar est généralement exprimée comme
suit : CI = (E_A \* E_B) / E_combined où : - CI est l’indice de
combinaison, qui quantifie l’interaction entre les médicaments. - E_A
est l’effet du médicament A. - E_B est l’effet du médicament B. -
E_combined est l’effet combiné des deux médicaments lorsqu’ils sont
administrés ensemble.

L’indice de combinaison (CI) est utilisé pour évaluer si l’effet combiné
des médicaments est supérieur, inférieur ou égal à la somme de leurs
effets individuels. Un CI supérieur à 1 indique une synergie entre les
médicaments, c’est-à-dire que leur effet combiné est supérieur à ce qui
serait attendu en additionnant leurs effets individuels. Un CI égal à 1
indique une additivité, tandis qu’un CI inférieur à 1 suggère un
antagonisme, où l’effet combiné est inférieur à la somme des effets
individuels. La formule de Lehar est souvent utilisée dans les études
pharmacologiques pour évaluer l’efficacité des combinaisons de
médicaments, en particulier dans le contexte du traitement du cancer ou
d’autres maladies où plusieurs médicaments sont utilisés simultanément.
Elle permet aux chercheurs de mieux comprendre comment les médicaments
interagissent entre eux et d’optimiser les schémas thérapeutiques.

*Index*:

According to the approach proposed by Lehar (Lehár et al., 2007, 2008,
2009), a point-by-point calculation of the expected values in case of
absence of interaction effect is performed over all the matrix
concentration combinations in order to obtain an expected-value matrix.
Then, a **combination index**, **CI**, is calculated as follows:
$CI = \ln f_{A}\ln f_{B}\sum_{A,B}\left( M_{0} - M_{E} \right)$ where
$M_{O}$ and $M_{E}$ are the matrices of the observed and expected
values, respectively, and $f_{A}$ and $f_{B}$ are the dilution factors
for the drugs A and B. The **CI** is a positive-gated, effect-weighted
volume over the lack of interaction effect (i.e. Bliss independence),
adjusted for variable dilution factors $f_{A}$ and $f_{B}$. An
**efficacy index** is also calculated as follow:
$EI = \ln f_{A}\ln f_{B}\sum_{A,B}M_{0}$.

Lehár, J., Zimmermann, G.R., Krueger, A.S., Molnar, R.A., Ledell, J.T.,
Heilbut, A.M., Short, G.F., Giusti, L.C., Nolan, G.P., Magid, O.A., et
al. (2007). Chemical combination effects predict connectivity in
biological systems. Mol. Syst. Biol. 3, 80.

Lehár, J., Stockwell, B.R., Giaever, G., and Nislow, C. (2008).
Combination chemical genetics. Nat. Chem. Biol. 4, 674–681.

Lehár, J., Krueger, A.S., Avery, W., Heilbut, A.M., Johansen, L.M.,
Price, E.R., Rickles, R.J., Short, G.F., Staunton, J.E., Jin, X., et
al. (2009). Synergistic drug combinations tend to improve
therapeutically relevant selectivity. Nat. Biotechnol. 27, 659–666.
