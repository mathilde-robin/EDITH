#' Plot the calculated indexes (AI, CI, EI) for each drug concentration.
#'
#' @param index_df A data frame containing the calculated indexes: Additivity Index (AI), Combination Index (CI), and Efficacy Index (EI) for each drug concentration.
#'
#' @returns A patchwork plot with three bar plots for AI, CI, and EI.
#' @export
#'
#' @examples
#' NULL
plot_index <- function (index_df) {

  drug_name <- colnames(index_df)[1]
  colnames(index_df)[1] <- "drug"

  index_df <- index_df %>%
    dplyr::mutate(
      drug = factor(drug),
      AI = round(x = AI, digits = 2),
      CI = round(x = CI, digits = 2),
      EI = round(x = EI, digits = 2))

  patchwork::wrap_plots(
    index_df %>%
      ggplot2::ggplot(ggplot2::aes(x = drug, y = AI, label = AI)) +
      ggplot2::geom_col() +
      ggplot2::geom_text(ggplot2::aes(vjust = ifelse(AI >= 0, 1.5, -1)), color = "white", size = 3) +
      ggplot2::labs(x = drug_name, y = "Additivity Index (AI)") +
      ggplot2::theme_bw(),
    index_df %>%
      ggplot2::ggplot(ggplot2::aes(x = drug, y = CI, label = CI)) +
      ggplot2::geom_col() +
      ggplot2::geom_text(ggplot2::aes(vjust = ifelse(CI >= 0, 1.5, -1)), color = "white", size = 3) +
      ggplot2::labs(x = drug_name, y = "Combination Index (CI)") +
      ggplot2::theme_bw(),
    index_df %>%
      ggplot2::ggplot(ggplot2::aes(x = drug, y = EI, label = EI)) +
      ggplot2::geom_col() +
      ggplot2::geom_text(ggplot2::aes(vjust = ifelse(EI >= 0, 1.5, -1)), color = "white", size = 3) +
      ggplot2::labs(x = drug_name, y = "Efficacy Index (EI)") +
      ggplot2::theme_bw(),
    nrow = 1
  )
}
