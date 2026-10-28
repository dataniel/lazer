# Convert a Greenlandic SUT file between the two layouts

Reads a SUT file (TA file) in one layout and writes it in the other:
version 1 to version 2, or version 2 to version 1.

## Usage

``` r
convert_sut(path, out, to)
```

## Arguments

- path:

  Path to the SUT file to convert. Its version is recognised, as in
  [`read_sut()`](https://dataniel.github.io/lazer/reference/read_sut.md).

- out:

  Path to write the converted file to. Must differ from `path`.

- to:

  The version to convert to: `1` or `2`.

## Value

`out`, invisibly.

## Details

This is
[`read_sut()`](https://dataniel.github.io/lazer/reference/read_sut.md)
followed by
[`write_sut()`](https://dataniel.github.io/lazer/reference/write_sut.md),
with their checks:

- **1 to 2:** version 2 has no `prim`, `afstm` or `fval`. If any of them
  holds a value, a warning says how many rows lose it.

- **2 to 1:** the fields of version 1 are narrower (numbers 11 or 13
  characters instead of 16 or 25, `nrnr` 5 instead of 6). A value that
  does not fit exactly is an error listing every such value, never
  truncated or rounded.

## See also

[`read_sut()`](https://dataniel.github.io/lazer/reference/read_sut.md)
for both layouts.

## Examples

``` r
if (FALSE) { # \dontrun{
convert_sut("old.sut", "new.sut", to = 2)
convert_sut("new.sut", "old.sut", to = 1)
} # }
```
