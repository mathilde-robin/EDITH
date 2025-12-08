#' Main function to run EDITH analysis.
#'
#' @returns pdf and excel files saved in the output directory.
#' @export
#'
#' @examples
#' ## Not run:
#' # run_EDITH()
#' ## End(Not run)
run_EDITH <- function () {

  # options(warn = -1)

  # say_hello()

  filename <- file.choose(new = TRUE) %>%
    stringr::str_replace_all(pattern = "\\\\", replacement = "/")

  output_dir <- filename %>%
    stringr::str_replace(pattern = ".xlsx", replacement = "_output/")

  dir.create(output_dir, showWarnings = FALSE)
  setwd(output_dir)

  sheet_names <- readxl::excel_sheets(path = filename)

  invisible(
    sapply(sheet_names, function (sheet_name) {

      sheet_data <- readxl::read_excel(
        path = filename, sheet = sheet_name,
        col_names = FALSE, progress = FALSE, .name_repair = "minimal"
      )

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
      type <- NA
      if (drug_names$drugC %in% c("NA", "", " ", NA)) {
        two_drugs(sheet_name = sheet_name, drug_names = drug_names, sheet_data = sheet_data)
      } else {
        three_drugs(sheet_name = sheet_name, drug_names = drug_names, sheet_data = sheet_data)
      }
    })
  )
}
