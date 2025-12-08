#' Formatting subtable data for analysis.
#'
#' @param df A dataframe of the subtable (repicate).
#' @param drug_names A list where each element is the name of the corresponding drug.
#' @param type An integer indicating the type of experiment: 2 for two-drug combinations, 3 for three-drug combinations.
#'
#' @returns A list with two elements:
#' - data_init: Numeric matrix/array of the response values
#' - drug_doses: List of numeric vectors with the doses for each drug
#'
#' @export
#'
#' @examples
#' NULL
clean_subtable <- function (df, drug_names, type) {

  if (type == 2) {

    # numerics matrix conversion
    subtable <- df[-1, -1] %>%
      dplyr::mutate(dplyr::across(dplyr::everything(), as.numeric)) %>%
      as.matrix()

    # dimnames
    rownames(subtable) <- df[-1,1][[1]]
    colnames(subtable) <- df[1,-1]

    # remove NA column
    # this can happen if not all replicates have the same number of doses
    ids <- which(apply(subtable, 2, function (x) !all(is.na(x))))
    subtable <- subtable[,ids]

    # doses
    drug_doses = list(
      drugA = as.numeric(rownames(subtable)),
      drugB = as.numeric(colnames(subtable))
    )

    names(drug_doses) <- unlist(drug_names)[1:2]
  }

  if (type == 3) {

    subtable <- df[-1, -c(1, ncol(df))] %>%
      dplyr::mutate(dplyr::across(dplyr::everything(), as.numeric)) %>%
      as.matrix()

    drug_doses <- list(
      drugA = as.numeric(unlist(unique(df[-1, 1]))),
      drugB = as.numeric(df[1, -c(1, ncol(df))]),
      drugC = as.numeric(unlist(unique(df[-1, ncol(df)])))
    )

    names(drug_doses) <- unlist(drug_names)

    subtable <- t(subtable)
    dim(subtable) <- lengths(drug_doses[c(2,1,3)])
    subtable <- aperm(subtable, c(2,1,3))
    dimnames(subtable) <- drug_doses
  }

  return (list(data_init = subtable, drug_doses = drug_doses))
}
