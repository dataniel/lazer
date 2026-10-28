# Write a Greenlandic SUT file

Writes a data frame to a Greenlandic supply and use table file (SUT; in
Danish a TA file, *tilgang-anvendelse*) in the old layout (version 1) or
the new 140-character layout (version 2). The layout must be named,
since it has to match what the receiver reads.

## Usage

``` r
write_sut(x, path, version)
```

## Arguments

- x:

  A data frame with the columns `nrnr`, `trans`, `brch`, `bas`, `eng`,
  `det`, `afg`, `kbx` and optionally `moms`. Other columns are an error.

- path:

  Path to write to.

- version:

  `1` (old layout) or `2` (new 140-character layout).

## Value

`path`, invisibly.

## Details

Writes the nine fields `nrnr`, `trans`, `brch`, `bas`, `eng`, `det`,
`afg`, `moms` and `kbx` in the positions
[`read_sut()`](https://dataniel.github.io/lazer/reference/read_sut.md)
reads them from. If `moms` is absent, it is derived: `NA` where `trans`
is `"0100"` or `"0700"` (no VAT in Greenland), `0` otherwise.

**The file reads back unchanged.** A fixed-width file has no delimiters,
so a value wider than its field does not fail: it pushes every following
field out of place, and the file still parses, into the wrong columns.
`write_sut()` therefore refuses to write anything it cannot write
exactly, and lists every offending value at once:

- Numbers are right-aligned, with the fewest decimals that reproduce the
  value exactly, so whole numbers have none. A number whose exact form
  is wider than its field is an error, never rounded.

- Text is left-aligned. Since
  [`read_sut()`](https://dataniel.github.io/lazer/reference/read_sut.md)
  trims fields and reads blank fields and `"NA"` as `NA`, text that is
  too long, empty, `"NA"`, or starts or ends with a space is an error.

- `NA` is written as a blank field.

## See also

[`read_sut()`](https://dataniel.github.io/lazer/reference/read_sut.md),
which shows both layouts.

## Examples

``` r
if (FALSE) { # \dontrun{
write_sut(df, "ta19l", version = 2)
} # }
```
