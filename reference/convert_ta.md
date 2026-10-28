# Convert a Greenlandic TA file between the two layouts

Reads a TA file in one layout and writes it in the other: version 1 to
version 2, or version 2 to version 1.

## Usage

``` r
convert_ta(path, out, to)
```

## Arguments

- path:

  Path to the TA file to convert. Its version is recognised, as in
  [`read_ta()`](https://dataniel.github.io/lazer/reference/read_ta.md).

- out:

  Path to write the converted file to. Must differ from `path`.

- to:

  The version to convert to: `1` or `2`.

## Value

`out`, invisibly.

## Details

This is
[`read_ta()`](https://dataniel.github.io/lazer/reference/read_ta.md)
followed by
[`write_ta()`](https://dataniel.github.io/lazer/reference/write_ta.md),
with their checks:

- **1 to 2:** version 2 has no `prim`, `afstm` or `fval`. If any of them
  holds a value, a warning says how many rows lose it.

- **2 to 1:** the fields of version 1 are narrower (numbers 11 or 13
  characters instead of 16 or 25, `nrnr` 5 instead of 6). A value that
  does not fit exactly is an error listing every such value, never
  truncated or rounded.

## See also

[`read_ta()`](https://dataniel.github.io/lazer/reference/read_ta.md) for
both layouts.

## Examples

``` r
if (FALSE) { # \dontrun{
convert_ta("old.ta", "new.ta", to = 2)
convert_ta("new.ta", "old.ta", to = 1)
} # }
```
