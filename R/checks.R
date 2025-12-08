#' Checks on the input data matrix.
#'
#' @param data_init A matrix or array containing the initial data.
#'
#' @returns A cleaned numeric matrix if all checks are passed; otherwise, NULL.
#' @export
#'
#' @examples
#' NULL
checks <- function (data_init) {

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
  if (any(c(min(rownames(data_init)), min(colnames(data_init))) != "0")) {
    svDialogs::dlg_message(message = "The first dose of one of the drugs is non-zero", type = "ok")
    return (NULL)
  }

  # check that there are at least 3 doses
  if (any(c(ncol(data_init), nrow(data_init)) < 3)) {
    svDialogs::dlg_message(message = "One of the drugs has less than 3 doses", type = "ok")
    return (NULL)
  }

  # check that doses in rows are in ascending order
  doses_rows <- order(as.numeric(rownames(data_init)))
  if (any(doses_rows != 1:length(doses_rows))) {
    svDialogs::dlg_message(message = "Row doses not in ascending order \u2192 reordered", type = "ok")
    data_init <- data_init[doses_rows,]
  }

  # check that doses in cols are in ascending order
  doses_cols <- order(as.numeric(colnames(data_init)))
  if (any(doses_cols != 1:length(doses_cols))) {
    svDialogs::dlg_message(message = "Column doses not in ascending order \u2192 reordered", type = "ok")
    data_init <- data_init[,doses_cols]
  }

  # check that the dilution step is constant in row
  steps_rows <- log(as.numeric(rownames(data_init)[-1]))
  delta_rows <- round(x = steps_rows[2:length(steps_rows)] - steps_rows[1:(length(steps_rows)-1)], digits = 2)
  if (length(unique(delta_rows)) != 1) {
    answer <- svDialogs::dlg_message(message = "The dilution step does not seem constant for drug in row \u2192 indices may be impacted", type = "yesno")$res
    if (answer == "no") return (NULL)
  }

  # check that the dilution step is constant in column
  steps_cols <- log(as.numeric(colnames(data_init)[-1]))
  delta_cols <- round(x = steps_cols[2:length(steps_cols)] - steps_cols[1:(length(steps_cols)-1)], digits = 2)
  if (length(unique(delta_rows)) != 1) {
    answer <- svDialogs::dlg_message(message = "The dilution step does not seem constant for drug in column \u2192 indices may be impacted", type = "yesno")$res
    if (answer == "no") return (NULL)
  }

  return (data_init)
}
