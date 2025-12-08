# Convert to scientific notation.

Convert to scientific notation.

## Usage

``` r
convert_scientific(vect)
```

## Arguments

- vect:

  A numeric vector.

## Value

A character vector with numbers in scientific notation if they have more
than 6 characters.

## Examples

``` r
convert_scientific(c(0.000123456, 1234, 12.3456, 1234567))
#> [1] "1.23e-04" "1234"     "1.23e+01" "1.23e+06"
```
