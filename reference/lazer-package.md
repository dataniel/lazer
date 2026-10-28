# lazer: read and write the files an economics team works with

One place for the readers and writers of day-to-day work. Start here:

## Details

- [`read_files()`](https://dataniel.github.io/lazer/reference/read_files.md)
  reads many files at once in most formats, and can bind them into one
  table or unpack them as variables.

- [`read_workbook()`](https://dataniel.github.io/lazer/reference/read_workbook.md)
  reads every sheet of an Excel workbook, finding the table on each
  sheet, or the ranges, named ranges or Excel tables you choose.
  [`inspect_excel()`](https://dataniel.github.io/lazer/reference/inspect_excel.md)
  runs its layout check on its own.

- [`write_excel()`](https://dataniel.github.io/lazer/reference/write_excel.md)
  writes presentable Excel files: bold, frozen header and readable
  number formats.

- [`read_access()`](https://dataniel.github.io/lazer/reference/read_access.md)
  reads from a Microsoft Access database.

- [`read_ta()`](https://dataniel.github.io/lazer/reference/read_ta.md)
  and
  [`write_ta()`](https://dataniel.github.io/lazer/reference/write_ta.md)
  read and write Greenlandic TA files in both layouts.

The readers share a few habits: they are quiet when all is well, check
what they read, and report every problem in one message instead of
stopping at the first.

## See also

Useful links:

- <https://dataniel.github.io/lazer>

- <https://github.com/dataniel/lazer>

- Report bugs at <https://github.com/dataniel/lazer/issues>

## Author

**Maintainer**: Daniel Madsen <danielmadsen@live.dk>

Authors:

- Daniel Madsen <danielmadsen@live.dk>
