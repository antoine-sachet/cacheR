#' Create a directory if it does not already exist.
create_if_needed <- function(dir) {
  if (dir.exists(dir)) {
    return(TRUE)
  }
  status <- dir.create(dir, showWarnings = FALSE, recursive = TRUE)
  if (!status) {
    stop(glue("Failed to create directory {dir}"))
  }
  status
}
