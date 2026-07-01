#' Main function to run EDITH analysis.
#'
#' @param palette Character string specifying the color palette for synergistic data. Options are "classic" (green-black-red) or "alternative" (blue-black-orange).
#'
#' @returns pdf and excel files saved in the output directory.
#' @export
#'
#' @examples
#' ## Not run:
#' # run_EDITH()
#' ## End(Not run)
run_EDITH <- function (palette = "classic") {

  # options(warn = -1)

  # say_hello()

  filename <- file.choose() %>%
    stringr::str_replace_all(pattern = "\\\\", replacement = "/")

  output_dir <- filename %>%
    stringr::str_replace(pattern = ".xlsx|.csv", replacement = "_output/")

  dir.create(output_dir, showWarnings = FALSE)
  setwd(output_dir)

  if (stringr::str_detect(string = filename, pattern = ".xlsx$")) {
    format <- "xlsx"
    sheet_names <- readxl::excel_sheets(path = filename)
  }

  if (stringr::str_detect(string = filename, pattern = ".csv$")) {
    format <- "csv"
    sheet_names <- stringr::str_split(string = filename, pattern = "/")[[1]]
    sheet_names <- utils::tail(x = sheet_names, n = 1)
    sheet_names <- stringr::str_split(string = sheet_names, pattern = "[.]")[[1]][1]
  }

  invisible(
    sapply(sheet_names, function (sheet_name) {

      cat(paste0("Excel sheet: ", which(sheet_names == sheet_name), "/", length(sheet_names), " "))

      if (format == "xlsx") {
        sheet_data <- readxl::read_excel(
          path = filename, sheet = sheet_name,
          col_names = FALSE, progress = FALSE, .name_repair = "minimal"
        )

        sheet_data <- as.data.frame(sheet_data)
      }

      if (format == "csv") {

        sep <- readLines(con = filename, n = 2)[2]
        sep <- substr(x = sep, start = 1, stop = 1)

        sheet_data <- utils::read.table(
          file = filename, header = FALSE, sep = sep, dec = "."
        )

        sheet_data[which(sheet_data == "", arr.ind = TRUE)] <- NA
      }

      # rename empty colnames
      colnames(sheet_data) <- 1:ncol(sheet_data)

      # if empty rows at the end of the file
      while (all(sheet_data[nrow(sheet_data),] %in% c("NA", "", " ", NA))) {
        sheet_data <- sheet_data[-nrow(sheet_data),]
      }

      # drugs names extraction
      drug_names <- list(
        drugA = as.character(sheet_data[1,1]),
        drugB = as.character(sheet_data[1,2]),
        drugC = as.character(sheet_data[1,3])
      )

      if (any(c(drug_names$drugA, drug_names$drugB) %in% c("NA", "", " ", NA))) {
        svDialogs::dlg_message(message = paste0("Drug name(s) are missing in sheet ", sheet_name), type = "ok")
        return (NULL)
      }

      # 2 or 3 drugs?
      if (drug_names$drugC %in% c("NA", "", " ", NA)) {
        two_drugs(sheet_name = sheet_name, drug_names = drug_names, sheet_data = sheet_data, palette = palette)
      } else {
        three_drugs(sheet_name = sheet_name, drug_names = drug_names, sheet_data = sheet_data, palette = palette)
      }

      cat("\u2705 \n")
    })
  )
}
