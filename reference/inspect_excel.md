# Find cells outside the table in an Excel workbook

Lists the blocks of non-empty cells that lie outside the area being
read: a note under the table, a total row set apart by an empty row, a
second table to the right, a title above. Returns an empty tibble when
there are none, so it can be used as a checkpoint.

## Usage

``` r
inspect_excel(path, sheet = NULL, range = NULL, table = NULL, skip = 0)
```

## Arguments

- path:

  Path to an Excel file (`.xlsx`, `.xlsm` or `.xls`).

- sheet:

  Sheet names or positions. `NULL` (default) means every sheet.

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

  Names of defined Excel tables (Insert \> Table), or `TRUE` for all of
  them. Cannot be combined with `sheet` or `range`. `.xlsx` and `.xlsm`
  only, and needs the `xml2` package.

- skip:

  Rows at the top of each sheet to leave out before the table is found,
  as in
  [`readxl::read_excel()`](https://readxl.tidyverse.org/reference/read_excel.html).
  Not used for a given `range` or `table`.

## Value

A tibble with one row per block outside the read area: `sheet`, `area`
(the area read, such as `"B3:F40"` or `"Sales (B3:F40)"`), `block` (the
block's range), `position` (`"title"`, `"above"`, `"below"`, `"left"`,
`"right"`, a combination such as `"below right"`, or `"around"` for a
block that wraps a corner), `cells` (non-empty cells in the block) and
`first` (the first value in the block, for recognition).

## Details

**Why this exists.** `readxl` reads the smallest rectangle that holds
*every* non-empty cell on a sheet. A source note three rows under the
table therefore becomes extra data rows, and a comment two columns to
the right becomes a column named `...7`, without a warning. With a
`range`, the opposite happens: cells outside it are dropped without a
word. Either way the surprise is silent, and it is cheap to rule out by
looking at where the cells actually are.

**Finding the table.** Without a range for a sheet, the table is the
largest block of cells that is not split by an entirely empty row or
column, which is what a person looking at the sheet would call the
table. Single-cell rows on top of it, such as a title with no empty row
below it, are left out, so the header is the first row of the area. This
is the area
[`read_workbook()`](https://dataniel.github.io/lazer/reference/read_workbook.md)
reads by default.

**Reporting.** Cells outside the area are grouped into blocks the same
way and reported with their position relative to the nearest area. A
block above the table with at most one cell per row, in any column, is
reported as a `"title"`. When reading by `table`, cells that belong to
any defined table on the sheet are never reported, so two tables side by
side do not report each other.

Only cells with a value count; formatting, borders and empty strings do
not. The cells are found with `readxl` itself, reading the sheet once as
text, so the check costs about one extra read and agrees with `readxl`
on what is empty.

## See also

[`read_workbook()`](https://dataniel.github.io/lazer/reference/read_workbook.md),
which reads the same areas and runs this check.

## Examples

``` r
if (FALSE) { # \dontrun{
inspect_excel("data/report.xlsx")
inspect_excel("data/report.xlsx", table = TRUE)

inspect_excel("data/report.xlsx", range = "Sheet1!B3:F40") |>
  expectr::expect_empty(warn_msg = "cells outside the table")
} # }
```
