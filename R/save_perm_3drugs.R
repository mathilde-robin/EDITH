#' Save permutation results for 3-drug combinations.
#'
#' @param sheet_name The name of the sheet being processed.
#' @param rep A numeric value indicating the replicate number.
#' @param perm A numeric value indicating the permutation number.
#' @param drug_doses A list of numeric vectors with the doses for each drug.
#' @param drug_names A list where each element is the name of the corresponding drug.
#' @param global A list where each element corresponds to a replicate and contains:
#' - data_init: Numeric matrix/array of the response values
#' - data_bliss: Numeric matrix/array of the Bliss expected response value
#' - index_list: List with the calculated indexes: Additivity Index (AI), Combination Index (CI), and Efficacy Index (EI)
#' - heatmap_init: ComplexHeatmap object of the initial data
#' - heatmap_bliss: ComplexHeatmap object of the Bliss expected data
#' - heatmap_diff: ComplexHeatmap object of the difference between Bliss expected and initial data
#'
#' @returns pdf and excel files saved in the output directory.
#' @export
#'
#' @examples
#' NULL
save_perm_3drugs <- function (sheet_name, rep, perm, drug_doses, drug_names, global) {

  # remove null rotation
  global <- global[sapply(global, function (x) !is.null(x))]

  # combine index
  index_df <- do.call(rbind, lapply(1:length(global), function (dose_c) {
    df <- as.data.frame(global[[dose_c]][["index_list"]])
    df$dose_c <- drug_doses[[drug_names[3]]][dose_c]
    df <- df[, c("dose_c", "AI", "CI", "EI")]
    colnames(df)[1] <- drug_names[3]
    return (df)
  }))

  openxlsx::write.xlsx(x = index_df, file = paste0(sheet_name, "_rep", rep, "_perm", perm, "_index.xlsx"))

  # global pdf
  grDevices::pdf(file = paste0(sheet_name, "_rep", rep, "_perm", perm, ".pdf"))
  for (dose_c in 1:length(global)) ComplexHeatmap::draw(global[[dose_c]][["heatmap_init"]])
  for (dose_c in 1:length(global)) ComplexHeatmap::draw(global[[dose_c]][["heatmap_bliss"]])
  for (dose_c in 1:length(global)) ComplexHeatmap::draw(global[[dose_c]][["heatmap_diff"]])
  grDevices::dev.off()

  # global pdf - one file
  grobs <- c(
    lapply(1:length(global), function (dose_c) {
      grid::grid.grabExpr(ComplexHeatmap::draw(global[[dose_c]][["heatmap_init"]]))
    }),
    lapply(1:length(global), function (dose_c) {
      grid::grid.grabExpr(ComplexHeatmap::draw(global[[dose_c]][["heatmap_diff"]]))
    })
  )

  width  <- length(drug_doses[[drug_names[2]]]) * length(drug_doses[[drug_names[3]]]) * 1.33
  height <- 2 * length(drug_doses[[drug_names[1]]])

  grDevices::pdf(
    file = paste0(sheet_name, "_rep", rep, "_perm", perm, "_matrices.pdf"),
    width = grid::unit(x = width, units = "in"), height = grid::unit(x = height, units = "in")
  )
  gridExtra::grid.arrange(grobs = grobs, nrow = 2, ncol = length(drug_doses[[drug_names[3]]]))
  grDevices::dev.off()
}
