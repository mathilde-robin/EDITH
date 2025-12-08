#' Process data for three-drug combination experiments.
#'
#' @param sheet_name The name of the sheet being processed.
#' @param drug_names A list where each element is the name of the corresponding drug.
#' @param sheet_data A dataframe of the sheet data.
#'
#' @returns Cf. `save_perm_3drugs` function.
#' @export
#'
#' @examples
#' NULL
three_drugs <- function (sheet_name, drug_names, sheet_data) {
  type <- 3

  drugs.n <- list(c(1,2,3), c(2,3,1), c(3,1,2))
  drug_perm <- lapply(drugs.n, function (x) unlist(drug_names[x]))
  drug_perm <- lapply(drug_perm, function (x) {
    names(x) <- c("drugA", "drugB", "drugC")
    return (x)
  })

  # replicates identification
  sep    <- which(apply(sheet_data, 1, function(x) all(is.na(x))))
  starts <- c(1, sep + 1)
  ends   <- c(sep - 1, nrow(sheet_data))
  blocks <- purrr::map2(starts, ends, ~ .x:.y) %>%
    purrr::discard(~length(.) < 4)

  # for each replicate
  lapply(1:length(blocks), function (rep) {

    block <- blocks[[rep]]

    subtable <- clean_subtable(df = sheet_data[block,], drug_names = drug_names, type = type)
    data_init  <- subtable[["data_init"]]
    drug_doses <- subtable[["drug_doses"]]

    ############################################################################
    # Creer une fonction checks pour 3 drugs
    # data_init <- checks(data_init)
    #
    # if (is.null(data_init)) {
    #   stop (call. = FALSE)
    # }
    ############################################################################

    # drugs permutation
    lapply(1:length(drug_perm), function (perm) {

      drug_names_perm <- drug_perm[[perm]]
      data_perm <- aperm(data_init, perm = drug_names_perm)

      data_bliss <- bliss_matrix(data_init = data_perm, type = type)
      data_diff <- round(data_bliss - data_perm, 1)

      global <- lapply(drug_doses[[drug_names_perm[3]]], function (dose_c) {

        dose_c <- as.character(dose_c)
        subtitle <- paste0(drug_names_perm[3],": ", dose_c)

        heatmap_init <- plot_heatmap(
          data = data_perm[,, dose_c], drug_names = as.list(drug_names_perm), color = 1,
          title = "Observed viability (%)", subtitle = subtitle
        )

        heatmap_bliss <- plot_heatmap(
          data = data_bliss[,, dose_c], drug_names = as.list(drug_names_perm), color = 1,
          title = "Bliss expected viability (%)", subtitle = subtitle
        )

        heatmap_diff <- plot_heatmap(
          data = data_diff[,, dose_c], drug_names = as.list(drug_names_perm), color = 2,
          title = "Interaction effect (%)", subtitle = subtitle
        )

        return (list(
          data_init = data_perm[,, dose_c],
          data_bliss = data_bliss[,, dose_c],
          index_list = index(data_init = data_perm[,, dose_c], data_bliss = data_bliss[,, dose_c]),
          heatmap_init = heatmap_init,
          heatmap_bliss = heatmap_bliss,
          heatmap_diff = heatmap_diff
        ))
      })

      save_perm_3drugs(
        sheet_name = sheet_name, rep = rep, perm = perm, drug_doses = drug_doses,
        drug_names = drug_names_perm, global = global
      )
    })
  })
}
