# lazer 0.1.0

* First version. The readers and writers move here from daos:
  `read_files()`, `read_workbook()`, `inspect_excel()`, `write_excel()` and
  `read_access()`. lazer is independent of daos and expectr.

* `read_workbook()` reads every sheet of an Excel workbook into a named
  list, finding the table on each sheet instead of reading every non-empty
  cell: titles, source notes and stray comments are left out, and one
  warning lists what was left behind. Choose the area yourself with
  `range`, one per sheet if needed, or a named range from the workbook
  (`range = "Sales"`), or read defined Excel tables by name with `table`.
  A password-protected workbook gives a clear error.

* `inspect_excel()` lists the blocks of cells outside the table as a
  tibble, empty when the layout is clean.

* `read_files()` is quiet on success and reports problems together: CSV
  files no longer print the locale and column specification for every
  file; a file that fails to read no longer stops the rest; unsupported
  extensions are caught before anything is read; `out = "bind"` re-types
  only the columns whose types clash; and files that share a name give a
  warning, and an error with `out = "unpack"`.

* The functions for supply and use table files (SUT; TA files in Danish,
  *tilgang-anvendelse*) are one family for both layouts, replacing daos's
  `read_ta()`, `read_ta2()`, `write_ta()` and `write_ta2()`. `read_sut()`
  recognises version 1 and 2 by itself, `write_sut(version = )` writes
  either, and `convert_sut()` converts a file between them. Both layouts
  are one table each in the source, which reader and writer follow. Files
  are written byte for byte as before. `read_sut()` now checks number
  fields in version 1 too, and skips empty lines instead of reading them as
  a row of `NA`.
