#' Calculate the additivity matrix according to Bliss' method.
#'
#' @param data_init A matrix or array containing the initial data.
#' @param type An integer indicating the type of experiment: 2 for two-drug combinations, 3 for three-drug combinations.
#'
#' @returns A matrix or array of the same dimensions as `data_init`, containing the calculated Bliss additivity values.
#' @export
#'
#' @examples
#' NULL
bliss_matrix <- function (data_init, type) {

  if (type == 2) {

    fua <- data_init[1,]
    fub <- data_init[,1]

    fu <- vector()
    for (a in fua) {
      for (b in fub) {
        fu <- append(fu, c(a, b))
      }
    }

    fu <- matrix(fu, ncol = 2, byrow = TRUE, dimnames = list(c(), c("a", "b")))/100
    data_bliss <- apply(fu, 1, prod) * 100
    data_bliss <- matrix(data_bliss, dim(data_init), dimnames = dimnames(data_init))

    return (data_bliss)
  }

  if (type == 3) {

    fua <- data_init[, "0", "0"]
    fub <- data_init["0", , "0"]
    fuc <- data_init["0", "0", ]

    fu <- vector()
    for (c in fuc) {
      for (b in fub) {
        for (a in fua) {
          fu <- append(fu, c(a, b, c))
        }
      }
    }

    fu <- matrix(fu, ncol = 3, byrow = TRUE, dimnames = list(c(), c("a", "b", "c"))) / 100
    data_bliss <- apply(fu, 1, prod) * 100
    data_bliss <- array(data_bliss, dim(data_init), dimnames = dimnames(data_init))

    return (data_bliss)
  }
}
