# read_ta() refuses to read a file as the wrong version

    Code
      read_ta(fixture("v1_written.ta"), version = 2)
    Condition
      Error in `read_ta()`:
      ! Lines 1, 2, 3, and 4 are shorter than the 140 characters of version 2.
      i Is this a version 1 file? Use `version = 1`.

---

    Code
      read_ta(fixture("v2_written.ta"), version = 1)
    Condition
      Error in `read_ta()`:
      ! This file looks like version 2: 140-character lines, blank at 7--16 and 22--30.
      i Use `version = 2`, or leave `version` out to recognise it.

# read_ta() refuses a mix of versions

    Code
      read_ta(path)
    Condition
      Error in `read_ta()`:
      ! Cannot tell which TA layout this file has.
      x 1 of 2 lines look like version 2.
      i Give `version` to read it as one of them.

# read_ta() lists every number field that is not a number, by file line

    Code
      read_ta(path)
    Condition
      Error in `read_ta()`:
      ! Cannot read 2 number fields:
      x eng, line 2: "1.2.3" is not a number.
      x kbx, line 5: "abc" is not a number.

# write_ta() needs a version

    Code
      write_ta(expected$x2, withr::local_tempfile())
    Condition
      Error in `write_ta()`:
      ! Say which TA layout to write.
      i Use `version = 1` for the old layout or `version = 2` for the new 140-character one.

---

    Code
      write_ta(expected$x2, withr::local_tempfile(), version = 3)
    Condition
      Error in `write_ta()`:
      ! `version` must be 1 (the old layout) or 2 (the new 140-character layout).

# write_ta() lists every value it cannot write exactly

    Code
      write_ta(x, withr::local_tempfile(), version = 2)
    Condition
      Error in `write_ta()`:
      ! Cannot write 5 values so that `read_ta()` reads them back unchanged:
      x nrnr, row 2: "1234567" is 7 characters, the field holds 6.
      x trans, row 3: " 100" has leading or trailing spaces, which read_ta() trims.
      x brch, row 1: "NA" would read back as NA.
      x bas, row 1: 1e+30 needs more than 25 characters to be exact.
      x eng, row 2: 0.33333333333333331 needs more than 16 characters to be exact.

# convert_ta() warns about values version 2 has no field for

    Code
      convert_ta(fixture("v1_full.ta"), withr::local_tempfile(), to = 2)
    Condition
      Warning:
      Version 2 has no prim, afstm, and fval, so their values are not written:
      * prim: 2 rows
      * afstm: 2 rows
      * fval: 2 rows

# convert_ta() lists values too wide for version 1

    Code
      convert_ta(fixture("v2_written.ta"), withr::local_tempfile(), to = 1)
    Condition
      Error in `write_ta()`:
      ! Cannot write 1 value so that `read_ta()` reads it back unchanged:
      x nrnr, row 1: "123456" is 6 characters, the field holds 5.

# convert_ta() keeps the original and refuses a file already in that version

    Code
      convert_ta(path, path, to = 1)
    Condition
      Error in `convert_ta()`:
      ! `out` must differ from `path`, so the original file is kept.

---

    Code
      convert_ta(path, withr::local_tempfile(), to = 2)
    Condition
      Error in `convert_ta()`:
      ! 'file' is already version 2.

# write_ta() rejects columns that are not TA fields, and missing ones

    Code
      write_ta(cbind(x, extra = 1), withr::local_tempfile(), version = 2)
    Condition
      Error in `write_ta()`:
      ! Column extra in `x` is not a TA field.
      i TA fields: nrnr, trans, brch, bas, eng, det, afg, moms, and kbx.

---

    Code
      write_ta(x[setdiff(names(x), "kbx")], withr::local_tempfile(), version = 2)
    Condition
      Error in `write_ta()`:
      ! `x` is missing column kbx.

