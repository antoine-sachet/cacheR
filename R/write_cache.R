#' Write a named list to cache
#'
#' @param x Object to save.
#' @param path Cache directory. A subdirectory will be created.
#' @param name Optional: name of the directory to create. Default = NULL to use
#'   the expression passed as `x`.
#' @param overwrite Set to TRUE to overwrite an existing cache or directory.
#' @param ... Passed to write functions.
#'
#' @export
#'
write_cache <- function(x, path, name = NULL, overwrite = FALSE, ...) {
  x <- enquo(x)

  # Checking name
  if (is.null(name)) {
    name <- quo_text(x)
  } else {
    if (!is_string(name)) {
      stop("Name must be a single string.")
    }
  }

  # Checking cache directory
  if (!dir.exists(path)) {
    stop(glue("Cache directory does not exist"))
  }

  # Creating the subdirectory if needed
  object_root <- file.path(path, name)
  if (dir.exists(object_root)) {
    if (!overwrite) {
      stop(glue("{object_root} already exists. Use overwrite = TRUE to overwrite."))
    } else {
      # Erasing existing dir!
      unlink(path, recursive = TRUE)
    }
  }
  create_if_needed(object_root)
  # Starting recursive write
  write_cache_recursive(eval_tidy(x), object_root, ...)
}

#' @title Generic for write_cache_recursive
#' @description Internal workhorse for write_cache.
#'
#' @param x An object to write
#' @param path A path to write it to
#' @param ... Pasedd to write functions
write_cache_recursive <- function(x, path, ...) {
  create_if_needed(path)
  UseMethod("write_cache_recursive", x)
}


#' @describeIn write_cache_recursive Default method (save as rds.gz)
write_cache_recursive.default <- function(x, path, ...) {
  set_cache_type(path, "rds.gz")
  readr::write_rds(x, file.path(path, "object"), compress = "gz")
}

#' @describeIn write_cache_recursive List method (save as subdirectories)
#' @importFrom stringi stri_pad_left
write_cache_recursive.list <- function(x, path, ...) {
  meta <- list(
    cache_type = "list",
    names = names(x)
  )
  set_cache_meta(path, meta)
  write_attributes(x, path)

  len <- length(x)
  if (len > 0) {
    max_width <- floor(log10(len)) + 1;
    elem_names <- stringi::stri_pad_left(1:len, width = max_width, pad = "0")
    for (i in 1:len) {
      write_cache_recursive(x[[i]], file.path(path, elem_names[i]), ...)
    }
  }
}
