#' Convert to scientific notation.
#'
#' @param vect A numeric vector
#'
#' @returns A character vector with numbers in scientific notation if they have more than 6 characters.
#' @export
#'
#' @examples
#' convert_scientific(c(0.000123456, 1234, 12.3456, 1234567))
convert_scientific <- function (vect) {

  vect <- as.numeric(vect)
  sapply(vect, function (x) {
    if (nchar(x) > 6){
      format(x, scientific = TRUE, digits = 3)
    } else {
      as.character(x)
    }
  })
}
