# Save permutation results for 3-drug combinations.

Save permutation results for 3-drug combinations.

## Usage

``` r
save_perm_3drugs(sheet_name, rep, perm, drug_doses, drug_names, global)
```

## Arguments

- sheet_name:

  The name of the sheet being processed.

- rep:

  A numeric value indicating the replicate number.

- perm:

  A numeric value indicating the permutation number.

- drug_doses:

  A list of numeric vectors with the doses for each drug.

- drug_names:

  A list where each element is the name of the corresponding drug.

- global:

  A list where each element corresponds to a replicate and contains:

  - data_init: Numeric matrix/array of the response values

  - data_bliss: Numeric matrix/array of the Bliss expected response
    value

  - index_list: List with the calculated indexes: Additivity Index (AI),
    Combination Index (CI), and Efficacy Index (EI)

  - heatmap_init: ComplexHeatmap object of the initial data

  - heatmap_bliss: ComplexHeatmap object of the Bliss expected data

  - heatmap_diff: ComplexHeatmap object of the difference between Bliss
    expected and initial data

## Value

pdf and excel files saved in the output directory.

## Examples

``` r
NULL
#> NULL
```
