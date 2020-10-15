# cacheR (in development)

* Removed dependency on deprecated `rlang` functions.

* `inspect_cache` now prints a directory tree using `data.tree` package if available.

* Fix read-back bug causing lists with attributes to receive an extra element. (#2)

* Added a `NEWS.md` file to track changes to the package.

# cacheR 1.0.1

* Fix overwrite issue causing wrong directory deletion. (#1)
