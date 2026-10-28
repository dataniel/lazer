# lazer 0.1.0

* First version. The readers and writers move here from daos, which
  forwards to them so existing scripts keep working: `read_files()`,
  `read_workbook()`, `inspect_excel()`, `write_excel()` and `read_access()`.

* The TA functions are one family for both layouts. `read_ta()` recognises
  version 1 and 2 by itself, `write_ta(version = )` writes either, and
  `convert_ta()` converts a file between them. Both layouts are one table
  each in the source, which reader and writer follow. Files are written
  byte for byte as before. `read_ta()` now checks number fields in
  version 1 too, and skips empty lines instead of reading them as a row
  of `NA`.
