.onAttach <- function(...) {
      packageStartupMessage("AlleleShift ", utils::packageDescription("AlleleShift", field="Version"),
      ": Please see https://doi.org/10.1101/2021.01.15.426775 - choose functions count.model and freq.model to calibrate frequencies.")
}

