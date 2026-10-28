# Read a Greenlandic SUT file

Reads a Greenlandic supply and use table file (SUT; in Danish a TA file,
*tilgang-anvendelse*) in the old layout (version 1) or the new
140-character layout (version 2), recognising which by itself.

## Usage

``` r
read_sut(path, version = NULL)
```

## Arguments

- path:

  Path to the SUT file.

- version:

  `1` (old layout), `2` (new layout), or `NULL` (default) to recognise
  it from the file.

## Value

A tibble with one column per field: 12 for version 1, 9 for version 2.

## Details

**The fields.** One line per product (`nrnr`), transaction (`trans`) and
industry (`brch`), with the value at each price layer: basic prices
(`bas`), wholesale and retail margins (`eng`, `det`), taxes (`afg`), VAT
(`moms`) and purchasers' prices (`kbx`).

**The layouts.** Character positions, 1-based. Text fields are read as
character, the rest as numbers.

|       |           |           |        |
|-------|-----------|-----------|--------|
| Field | Version 1 | Version 2 | Type   |
| nrnr  | 1–5       | 1–6       | text   |
| trans | 7–12      | 17–21     | text   |
| brch  | 14–17     | 31–35     | text   |
| bas   | 19–31     | 36–60     | number |
| eng   | 33–43     | 61–76     | number |
| det   | 45–55     | 77–92     | number |
| afg   | 57–67     | 93–108    | number |
| moms  | 69–79     | 109–124   | number |
| kbx   | 81–91     | 125–140   | number |
| prim  | 93–103    |           | number |
| afstm | 105–107   |           | text   |
| fval  | 109–end   |           | text   |

**Recognising the version.** Version 2 lines are 140 characters, with
blanks at 7–16 and 22–30, where version 1 has `trans`, `brch` and `bas`.
When every line looks like version 2, the file is read as version 2;
when none does, as version 1. A mix is an error. Giving `version` skips
the guess, but a file that clearly is the other version is still an
error, rather than read into the wrong columns.

**Values.** Fields are trimmed, and a blank field or `NA` is read as
`NA`. A number field that is not a number is an error listing every such
field, not a silent `NA`. Empty lines are skipped; line numbers in
messages are those of the file.

## See also

[`write_sut()`](https://dataniel.github.io/lazer/reference/write_sut.md)

## Examples

``` r
if (FALSE) { # \dontrun{
df <- read_sut("ta19l")
df <- read_sut("ta19l", version = 2)
} # }
```
