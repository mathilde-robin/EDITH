#' Install package if not already installed
#'
#' @param package Package name
#' @param CRAN Boolean, whether the package is from CRAN or Bioconductor
#'
#' @returns
#' NULL
#' @export
#'
#' @examples
#' ## Not run:
#' # install_or_not("dplyr", CRAN = TRUE)
#' ## End(Not run)
install_or_not <- function (package, CRAN = TRUE)  {
  if (!requireNamespace(package = package, quietly = TRUE)) {
    if (CRAN) {
      utils::install.packages(pkgs = package)
    } else {
      BiocManager::install(pkgs = package)
    }
  }
}

#' Check and install required packages
#'
#' @returns
#' NULL
#' @export
#'
#' @examples
#' ## Not run:
#' # check_packages()
#' ## End(Not run)
check_packages <- function () {
  packages_CRAN <- c(
    "dplyr", "readxl", "circlize", "grid", "openxlsx", "BiocManager", "gridExtra",
    "svDialogs", "grDevices", "magrittr", "purrr", "stringr"
  )
  invisible(lapply(packages_CRAN, function (x) install_or_not(package = x, CRAN = TRUE)))

  packages_BIOCONDUCTOR <- c("ComplexHeatmap")
  invisible(lapply(packages_BIOCONDUCTOR, function (x) install_or_not(package = x, CRAN = FALSE)))
}
