#' Save results for replicates of 2-drug combination experiments.
#'
#' @param sheet_name The name of the sheet being processed.
#' @param drug_names A list where each element is the name of the corresponding drug.
#' @param global A list where each element corresponds to a replicate and contains:
#' - drug_doses: List of numeric vectors with the doses for each drug
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
save_replicat_2drugs <- function (sheet_name, drug_names, global) {

  # remove null replicates
  global <- global[sapply(global, function (x) !is.null(x))]

  # combine index
  index_df <- do.call(rbind, lapply(1:length(global), function (rep) {
    df <- as.data.frame(global[[rep]][["index_list"]])
    df$rep <- rep
    return (df[, c("rep", "AI", "CI", "EI")])
  }))

  openxlsx::write.xlsx(x = index_df, file = paste0(sheet_name, "_index.xlsx"))

  # pdf for each replicate
  sapply(1:length(global), function (rep) {
    grDevices::pdf(file = paste0(sheet_name, "_rep", rep, ".pdf"))
    ComplexHeatmap::draw(global[[rep]][["heatmap_init"]])
    ComplexHeatmap::draw(global[[rep]][["heatmap_bliss"]])
    ComplexHeatmap::draw(global[[rep]][["heatmap_diff"]])
    grDevices::dev.off()
  })

  # check that all replicates have the same doses in drugA
  doses_drugA <- lapply(global, function (rep) rep[["drug_doses"]][[drug_names$drugA]])
  if (!all(sapply(doses_drugA, function(x) identical(x, doses_drugA[[1]])))){
    svDialogs::dlg_message("Replicates don't have the same doses in row", type = "ok")
  }

  # check that replicates have the same doses in drugB
  doses_drugB <- lapply(global, function (rep) rep[["drug_doses"]][[drug_names$drugB]])
  if (!all(sapply(doses_drugB, function(x) identical(x, doses_drugB[[1]])))){
    svDialogs::dlg_message("Replicates don't have the same doses in column", type = "ok")
  }

  # compare replicates heatmaps in a single pdf
  grobs <- c(
    lapply(global, function (rep) {
      grid::grid.grabExpr(ComplexHeatmap::draw(rep[["heatmap_init"]]))
    }),
    lapply(global, function (rep) {
      grid::grid.grabExpr(ComplexHeatmap::draw(rep[["heatmap_diff"]]))
    })
  )

  width  <- max(sapply(global, function (rep) length(rep[["drug_doses"]][[drug_names$drugA]]))) * length(global) * 0.7 # * 1.33
  height <- max(sapply(global, function (rep) length(rep[["drug_doses"]][[drug_names$drugB]]))) * 2

  grDevices::pdf(
    file = paste0(sheet_name, "_matrices.pdf"),
    width = grid::unit(x = width, units = "in"), height = grid::unit(x = height, units = "in")
  )
  gridExtra::grid.arrange(grobs = grobs, nrow = 2, ncol = length(global))
  grDevices::dev.off()
}
