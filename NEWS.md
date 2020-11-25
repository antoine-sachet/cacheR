# cacheR (in development)

* Now using stricter arguments when using `read_csv` to ensure we read exactly what was written.

# cacheR 1.2.0

* Renamed internal files created by `write_cache` to avoid hidden files and
directories. They were causing notes in R CMD check when present in a package.
This is not backward compatible (although it could easily be if needed).

* Atomic vectors of type 'complex' are now saved in plaintext.

* Updated calls to `readr` functions following the renaming of their `path` argument.

* Improved tests in both depth and coverage

* Added CI checks and code coverage reports

# cacheR 1.1.0

* Switched to `read/write_csv` as back-end for plaintext files. This is not
backward compatible!

* Newline characters in strings are now properly escaped by the new back-end. (#3)

* The cache now logs the version of cacheR used to create it.

* `read_cache` now gives a warning if the current version of cacheR is different
than the one used to create the cache. Note version <= 1.0.2 is no longer
supported as the plaintext format is different.

* `write_cache` now returns the input data invisibly.


# cacheR 1.0.2

* Removed dependency on deprecated `rlang` functions.

* `inspect_cache` now prints a directory tree using `data.tree` package if available.

* Fix read-back bug causing lists with attributes to receive an extra element. (#2)

* Added a `NEWS.md` file to track changes to the package.

# cacheR 1.0.1

* Fix overwrite issue causing wrong directory deletion. (#1)
