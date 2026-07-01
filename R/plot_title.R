#' Add a title to a plot
#'
#' @param title The title text to be added to the plot.
#'
#' @returns A grid text object representing the title, positioned at the top left of the plot.
#' @export
#'
#' @examples
plot_title <- function (title) {
  grid::grid.text(
    label = title,
    x = unit(5, "mm"), y = unit(1, "npc") - unit(5, "mm"),
    just = c("left", "top"),
    gp = grid::gpar(fontsize = 14, fontface = "bold")
  )
}
