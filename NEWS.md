# cacheR (in development)

* Switched to `read/write_csv` as back-end for plaintext files. This is not
backward compatible!

* Newline characters in strings are now properly escaped by the new back-end. (#3)

* The cache now logs the version of cacheR used to create it.

* `write_cache` now returns the input data invisibly.


# cacheR 1.0.2

* Removed dependency on deprecated `rlang` functions.

* `inspect_cache` now prints a directory tree using `data.tree` package if available.

* Fix read-back bug causing lists with attributes to receive an extra element. (#2)

* Added a `NEWS.md` file to track changes to the package.

# cacheR 1.0.1

* Fix overwrite issue causing wrong directory deletion. (#1)
