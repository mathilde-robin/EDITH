# Save results for replicates of 2-drug combination experiments.

Save results for replicates of 2-drug combination experiments.

## Usage

``` r
save_replicat_2drugs(sheet_name, drug_names, global)
```

## Arguments

- sheet_name:

  The name of the sheet being processed.

- drug_names:

  A list where each element is the name of the corresponding drug.

- global:

  A list where each element corresponds to a replicate and contains:

  - drug_doses: List of numeric vectors with the doses for each drug

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
