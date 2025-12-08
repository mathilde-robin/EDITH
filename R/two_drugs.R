#' Process data for two-drug combination experiments.
#'
#' @param sheet_name The name of the sheet being processed.
#' @param drug_names A list where each element is the name of the corresponding drug.
#' @param sheet_data A dataframe of the sheet data.
#'
#' @returns Cf. `save_replicat_2drugs` function.
#' @export
#'
#' @examples
#' NULL
two_drugs <- function (sheet_name, drug_names, sheet_data) {
  type <- 2

  # replicates identification
  sep    <- which(apply(sheet_data, 1, function(x) all(is.na(x))))
  starts <- c(1, sep + 1)
  ends   <- c(sep - 1, nrow(sheet_data))
  blocks <- purrr::map2(starts, ends, ~ .x:.y) %>%
    purrr::discard(~length(.) < 4)

  # for each replicate
  global <- lapply(blocks, function (block) {

    subtable <- clean_subtable(df = sheet_data[block,], drug_names = drug_names, type = type)

    data_init <- subtable[["data_init"]]
    data_init <- checks(data_init)

    if (is.null(data_init)) {
      stop (call. = FALSE)
    }

    data_bliss <- bliss_matrix(data_init = data_init, type = type)
    data_diff  <- data_bliss - data_init

    return (list(
      drug_doses = subtable[["drug_doses"]],
      data_init = data_init,
      data_bliss = data_bliss,
      index_list = index(data_init = data_init, data_bliss = data_bliss),
      heatmap_init  = plot_heatmap(data = data_init, drug_names = drug_names, color = 1, title = "Observed viability (%)"),
      heatmap_bliss = plot_heatmap(data = data_bliss, drug_names = drug_names, color = 1, title = "Bliss expected viability (%)"),
      heatmap_diff  = plot_heatmap(data = data_diff, drug_names = drug_names, color = 2, title = "Interaction effect (%)")
    ))
  })

  save_replicat_2drugs(sheet_name = sheet_name, drug_names = drug_names, global = global)
}
