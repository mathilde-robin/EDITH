#' Plot heatmap for drug combination data (data_init/data_bliss/data_diff).
#'
#' @param data A matrix or array containing initial, additivity or synergistic data.
#' @param drug_names A list where each element is the name of the corresponding drug.
#' @param color 1 for initial/additivity data, 2 for synergistic data.
#' @param title Character string for the title of the heatmap.
#' @param subtitle Character string for the subtitle of the heatmap.
#'
#' @returns A ComplexHeatmap object representing the heatmap.
#' @export
#'
#' @examples
#' NULL
plot_heatmap <- function (data, drug_names, color, title = "", subtitle = "") {

  if (!requireNamespace("ComplexHeatmap", quietly = TRUE)) {
    stop ("The ComplexHeatmap package must be installed. Use BiocManager::install('ComplexHeatmap')")
  }

  rownames(data) <- convert_scientific(vect = rownames(data))
  colnames(data) <- convert_scientific(vect = colnames(data))

  if (color == 1) {
    color_palette <- circlize::colorRamp2(breaks = c(0, 100), colors = c("dodgerblue1", "navy"))
    color_breaks <- c(0, 50, 100)
    color_labels <- c("  0", "  50", "  100")
  } else {
    color_palette <- circlize::colorRamp2(
      breaks = c(-100, -15.1, -15, 0, 15, 15.1, 100),
      colors = c("#00FF00", "#004e00", "#000000", "#000000", "#000000", "#4e0000", "#FF0000"))
    color_breaks <- c(-100, -50, 0, 50, 100)
    color_labels <- c("-100", "-50", "  0", "  50", "  100")
  }

  p <- ComplexHeatmap::Heatmap(
    matrix = data,
    name = "value",
    cluster_rows = FALSE,
    cluster_columns = FALSE,
    row_title = drug_names$drugA,
    row_title_side = "left",
    row_names_side = "left",
    row_names_centered = TRUE,
    column_title = drug_names$drugB,
    column_title_side = "bottom",
    column_names_side = "bottom",
    column_names_rot = 0,
    column_names_centered = TRUE,
    col = color_palette,
    rect_gp = grid::gpar(col = "white", lwd = 0.05),
    cell_fun = function(j, i, x, y, width, height, fill) {
      grid::grid.text(
        label = round(x = data[i,j], digits = 0),
        x = x, y = y, gp = grid::gpar(fontsize = 10, col = "white"))
    },
    top_annotation = ComplexHeatmap::HeatmapAnnotation(
      title = ComplexHeatmap::anno_block(
        gp = grid::gpar(fill = "white", col = "white"),
        labels = ifelse(subtitle == "", subtitle, title),
        labels_gp = grid::gpar(col = "black", fontsize = 12, fontface = "bold")),
      subtitle = ComplexHeatmap::anno_block(
        gp = grid::gpar(fill = "white", col = "white"),
        labels = ifelse(subtitle == "", title, subtitle),
        labels_gp = grid::gpar(
          col = "black", fontsize = ifelse(subtitle == "", 12, 10),
          fontface = ifelse(subtitle == "", "bold", "plain")))
    ),
    heatmap_legend_param = list(at = color_breaks, labels = color_labels)
  )

  return (p)
}
