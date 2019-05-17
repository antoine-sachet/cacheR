#' @rdname attributes
#' @title  Read and write attributes
#' @param path Directory
read_attributes <- function(path) {
  attr_path <- file.path(path, ".attributes")
  if (file.exists(attr_path)) {
    out <- read_cache(attr_path)
  } else {
    out <- NULL
  }
  return(out)
}

#' @rdname attributes
#' @param x Object whose attributes to write
#' @param exclude Attributes to ignore. Default to `names`, as names are handled
#'   separately.
write_attributes <- function(x, path, exclude = c("names")) {
  att <- attributes(x)
  if (!is.null(att)) {
    if (length(exclude) > 0) {
      att <- att[!names(att) %in% exclude]
    }
    if (length(att) > 0) {
      write_cache_recursive(att, file.path(path, ".attributes"))
    }
  }
}
