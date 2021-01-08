.onAttach <- function(...) {
      packageStartupMessage("AlleleShift ", utils::packageDescription("AlleleShift", field="Version"),
      ": choose functions count.model and freq.model to calibrate frequencies.")
}

