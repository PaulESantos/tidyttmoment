.onAttach <- function(libname, pkgname) {
  needed <- core_unloaded()
  if (length(needed) > 0) {
    tidyttmoment_attach()
    msg <- tidyttmoment_attach_message(needed)
    if (!is.null(msg)) {
      packageStartupMessage(msg)
    }
  } else {
    packageStartupMessage(
      paste0("tidyttmoment ", package_version_h("tidyttmoment"))
    )
  }
}

# -------------------------------------------------------------------------

show_progress <- function() {
  isTRUE(getOption("tidyttmoment.show_progress")) && # user disables progress bar
    interactive() # Not actively knitting a document
}



.onLoad <- function(libname, pkgname) {
  opt <- options()
  opt_tidyttmoment <- list(
    tidyttmoment.show_progress = TRUE
  )
  to_set <- !(names(opt_tidyttmoment) %in% names(opt))
  if (any(to_set)) options(opt_tidyttmoment[to_set])
  invisible()
}

# -------------------------------------------------------------------------
if(getRversion() >= "2.15.1") utils::globalVariables(c("distinctiveness", "Ui", "species", "val", "weight_val", ":="))
