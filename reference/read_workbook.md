# Read the sheets or tables of an Excel workbook

Reads every sheet of a workbook into a named list, finding the table on
each sheet, or the sheets, ranges or defined Excel tables you choose.
Warns when cells outside what was read are left behind.

## Usage

``` r
read_workbook(
  path,
  sheet = NULL,
  range = NULL,
  table = NULL,
  check = TRUE,
  ...
)
```

## Arguments

- path:

  Path to an Excel file (`.xlsx`, `.xlsm` or `.xls`).

- sheet:

  Sheet names or positions. `NULL` (default) reads every sheet.

- range:

  The area to read, where the default `NULL` finds the table on each
  sheet. One range, such as `"B3:F40"` (with a single `sheet`) or
  `"Sheet1!B3:F40"`; or one per sheet as a named vector,
  `c(Sheet1 = "B3:F40", Sheet2 = NA)`, where `NA` means find the table.
  Sheets not named are found automatically.

  A range can also be a named range from the workbook (Formulas \> Name
  Manager), such as `"Sales"`. A name carries its own sheet, so
  `range = c("Sales", "Costs")` reads both, named by the names, wherever
  they are; in a per-sheet vector the name must lie on that sheet. Named
  ranges need an `.xlsx` file and the `xml2` package.

- table:

  Names of defined Excel tables, or `TRUE` for all of them. Cannot be
  combined with `sheet` or `range`. `.xlsx` and `.xlsm` only.

- check:

  If `TRUE` (default), warn about cells outside what was read.

- ...:

  Passed on to
  [`readxl::read_excel()`](https://readxl.tidyverse.org/reference/read_excel.html),
  such as `col_types`, `na` or `skip`. `skip` is applied before the
  table is found.

## Value

A tibble when a single sheet, range or table is named; otherwise a named
list of tibbles, also when the workbook has only one sheet, so the shape
depends on the call and not on the file.

## Details

**Sheets.** With `sheet = NULL` (default), every sheet is read and the
result is a list named by sheet. Name or number the sheets to read only
those.

**Finding the table.** Without a range, `readxl` reads the smallest
rectangle around *all* non-empty cells, so a title becomes the header, a
note below the table becomes extra rows, and a comment to the right
becomes a column named `...7`. `read_workbook()` instead finds the table
on each sheet, the largest block of cells not split by an entirely empty
row or column, with title rows on top left out (see
[`inspect_excel()`](https://dataniel.github.io/lazer/reference/inspect_excel.md)),
and reads only that. Whatever lies outside is not read, and a warning
lists it, except titles above the table, which are expected.

**Speed.** Everything is read by `readxl`'s C++ reader: each sheet once
as text to find the table, and once more for the table itself with
proper column types. That is about twice a plain
[`readxl::read_excel()`](https://readxl.tidyverse.org/reference/read_excel.html),
for `.xlsx` and `.xls` alike. Give `range` and `check = FALSE` to read
with a single call.

**Passwords.** A workbook with a password to open is encrypted, and
`readxl` cannot read it; `read_workbook()` says so instead of failing
with a zip error. Sheet or workbook protection without a password to
open does not encrypt the file and reads as usual.

**Choosing the area yourself.** `range` takes one range for one sheet,
or a named vector with one range per sheet, where `NA` (or leaving a
sheet out) means find the table. `table` reads defined Excel tables
(Insert \> Table) by name, or all of them with `table = TRUE`. A table
keeps its range when rows are added in Excel, which a hard-coded `range`
does not, so prefer it when the workbook has one. A table's totals row
is not read. `readxl` has no support for tables; their ranges are looked
up in the file and read as ranges.

## See also

[`inspect_excel()`](https://dataniel.github.io/lazer/reference/inspect_excel.md)
for the check on its own,
[`read_files()`](https://dataniel.github.io/lazer/reference/read_files.md)
to read many files at once.

## Examples

``` r
if (FALSE) { # \dontrun{
# Every sheet, the table found on each, as a named list:
sheets <- read_workbook("data/report.xlsx")

# One sheet, as a tibble:
df <- read_workbook("data/report.xlsx", sheet = "2024")

# Your own range, for one sheet or per sheet (NA: find it):
df     <- read_workbook("data/report.xlsx", range = "2024!B3:F40")
sheets <- read_workbook("data/report.xlsx", range = c(`2024` = "B3:F40", `2023` = NA))

# Named ranges (Formulas > Name Manager), wherever they are:
sales  <- read_workbook("data/report.xlsx", range = "Sales")
parts  <- read_workbook("data/report.xlsx", range = c("Sales", "Costs"))

# A defined table, or all of them:
sales  <- read_workbook("data/report.xlsx", table = "Sales")
tables <- read_workbook("data/report.xlsx", table = TRUE)
} # }
```
