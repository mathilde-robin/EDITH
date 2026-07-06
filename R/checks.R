#' Checks on the input data matrix.
#'
#' @param data_init A matrix or array containing the initial data.
#' @param drug_names A character vector containing the names of the drugs.
#' @param type An integer indicating the type of experiment: 2 for two-drug combinations, 3 for three-drug combinations.
#'
#' @returns A cleaned numeric matrix if all checks are passed; otherwise, NULL.
#' @export
#'
#' @examples
#' NULL
checks <- function (data_init, drug_names, type) {

  # check that there are no NA in the matrix
  if (anyNA(data_init)) {
    svDialogs::dlg_message(message = "Missing data in one matrix", type = "ok")
    return (NULL)
  }

  # check that there are negative values in the matrix
  if (any(data_init < 0)) {
    svDialogs::dlg_message(message = "Negative values in one matrix \u2192 transformed into 0", type = "ok")
    data_init[which(data_init < 0)] <- 0
  }

  # check that there are high values in the matrix
  if (any(data_init > 100)) {
    # svDialogs::dlg_message(message = "Too high values in one matrix \u2192 transformed into 100", type = "ok")
    data_init[which(data_init > 100)] <- 100
  }

  # check that the first dose of each drug is 0
  if (any(sapply(dimnames(data_init), function (x) min(as.numeric(x)) != 0))) {
    svDialogs::dlg_message(message = "The first dose of one of the drugs is non-zero", type = "ok")
    return (NULL)
  }

  # check that there are at least 3 doses
  if (any(dim(data_init) < 3)) {
    svDialogs::dlg_message(message = "One of the drugs has less than 3 doses", type = "ok")
    return (NULL)
  }

  # check that doses are in ascending order
  lapply(1:length(dim(data_init)), function (i) {

    doses_i <- order(as.numeric(dimnames(data_init)[[i]]))
    if (any(doses_i != 1:length(doses_i))) {
      svDialogs::dlg_message(message = paste(drug_names[[i]], "doses not are in ascending order \u2192 reordered"), type = "ok")

      if (type == 2) {
        if (i == 1) data_init <- data_init[doses_i,]
        if (i == 2) data_init <- data_init[, doses_i]
      }

      if (type == 3) {
        if (i == 1) data_init <- data_init[doses_i,,]
        if (i == 2) data_init <- data_init[, doses_i,]
        if (i == 3) data_init <- data_init[,,doses_i]
      }
    }
  })

  # check that the dilution step is constant
  for (i in 1:length(dim(data_init))) {
    steps <- log(as.numeric(dimnames(data_init)[[i]][-1]))
    delta <- round(x = steps[2:length(steps)] - steps[1:(length(steps)-1)], digits = 2)
    if (length(unique(delta)) != 1) {
      answer <- svDialogs::dlg_message(message = paste("The dilution step does not seem constant for", drug_names[[i]], "\u2192 indices may be impacted. Continue?"), type = "yesno")$res
      if (answer == "no") return (NULL)
    }
  }

  return (data_init)
}
