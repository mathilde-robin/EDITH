#' Calculate synthetic indexes according to Lehar's method.
#'
#' @param data_init A matrix or array containing the initial data.
#' @param data_bliss A matrix or array of the same dimensions as `data_init`, containing the calculated Bliss additivity values.
#'
#' @returns A list containing the Additivity Index (AI), Combination Index (CI), and Efficacy Index (EI).
#' @export
#'
#' @examples
#' NULL
index <- function (data_init, data_bliss) {

  dfa <- as.numeric(colnames(data_init)[3]) / as.numeric(colnames(data_init)[2])
  dfb <- as.numeric(rownames(data_init)[3]) / as.numeric(rownames(data_init)[2])

  # additivity index
  AI <- log(dfa) * log(dfb) * sum(100 - data_bliss, na.rm = TRUE) / 100

  # combination index
  CI <- log(dfa) * log(dfb) * sum(data_bliss - data_init, na.rm = TRUE) / 100

  # efficacy index
  EI <- log(dfa) * log(dfb) * sum(100 - data_init[-1,-1], na.rm = TRUE) / 100

  return (list(AI = AI, CI = CI, EI = EI))
}
