# lazer

Readers and writers for the files of day-to-day statistical and economic
work, in one place. *lazer* sounds like *læser*: reading is most of what it
does, and it checks what it reads.

```r
# install.packages("pak")
pak::pak("dataniel/lazer")
```

## What it looks like

```r
library(lazer)

# Many files at once, in most formats; bind them, keeping the source
panel <- read_files("data/dat{2020:2024}.parquet", names = 2020:2024,
                    out = "bind", .id = "year")

# Every sheet of a workbook, the table found on each sheet
sheets <- read_workbook("data/report.xlsx")
sales  <- read_workbook("data/report.xlsx", range = "Salesdata")   # a named range

# Presentable Excel output
write_excel(list(Overview = overview, Detail = detail), "out.xlsx")

# Greenlandic TA files, both layouts
ta <- read_ta("ta.file")                          # version recognised
write_ta(ta, "ta_new.file", version = 2)
convert_ta("old.ta", "new.ta", to = 2)
```

The readers share a few habits: quiet when all is well, every problem in
one message instead of one rerun per problem, and nothing dropped or
reinterpreted without a word.

## Functions

| Function | Purpose |
|----------|---------|
| `read_files()` | Read many files at once (csv, parquet, Excel, SAS, Stata, SPSS, JSON, YAML, ...), and optionally bind or unpack them |
| `read_workbook()` | Read every sheet of a workbook, finding the table on each, or chosen ranges, named ranges or Excel tables; warn about cells left outside |
| `inspect_excel()` | List the blocks of cells outside the table in a workbook |
| `write_excel()` | Write presentable xlsx: bold, frozen header and readable number formats; create, append or replace sheets |
| `read_access()` | Read from a Microsoft Access database via ODBC |
| `read_ta()` / `write_ta()` | Read and write Greenlandic TA files, version 1 (old) or 2 (140 characters) |
| `convert_ta()` | Convert a TA file between the two versions |

## Relation to daos

These functions used to live in [daos](https://github.com/dataniel/daos).
The two packages are independent; use `library(lazer)` for the readers and
writers.
