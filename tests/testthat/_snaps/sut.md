# read_sut() refuses to read a file as the wrong version

    Code
      read_sut(fixture("v1_written.sut"), version = 2)
    Condition
      Error in `read_sut()`:
      ! Lines 1, 2, 3, and 4 are shorter than the 140 characters of version 2.
      i Is this a version 1 file? Use `version = 1`.

---

    Code
      read_sut(fixture("v2_written.sut"), version = 1)
    Condition
      Error in `read_sut()`:
      ! This file looks like version 2: 140-character lines, blank at 7--16 and 22--30.
      i Use `version = 2`, or leave `version` out to recognise it.

# read_sut() refuses a mix of versions

    Code
      read_sut(path)
    Condition
      Error in `read_sut()`:
      ! Cannot tell which SUT layout this file has.
      x 1 of 2 lines look like version 2.
      i Give `version` to read it as one of them.

# read_sut() lists every number field that is not a number, by file line

    Code
      read_sut(path)
    Condition
      Error in `read_sut()`:
      ! Cannot read 2 number fields:
      x eng, line 2: "1.2.3" is not a number.
      x kbx, line 5: "abc" is not a number.

# write_sut() needs a version

    Code
      write_sut(expected$x2, withr::local_tempfile())
    Condition
      Error in `write_sut()`:
      ! Say which SUT layout to write.
      i Use `version = 1` for the old layout or `version = 2` for the new 140-character one.

---

    Code
      write_sut(expected$x2, withr::local_tempfile(), version = 3)
    Condition
      Error in `write_sut()`:
      ! `version` must be 1 (the old layout) or 2 (the new 140-character layout).

# write_sut() lists every value it cannot write exactly

    Code
      write_sut(x, withr::local_tempfile(), version = 2)
    Condition
      Error in `write_sut()`:
      ! Cannot write 5 values so that `read_sut()` reads them back unchanged:
      x nrnr, row 2: "1234567" is 7 characters, the field holds 6.
      x trans, row 3: " 100" has leading or trailing spaces, which read_sut() trims.
      x brch, row 1: "NA" would read back as NA.
      x bas, row 1: 1e+30 needs more than 25 characters to be exact.
      x eng, row 2: 0.33333333333333331 needs more than 16 characters to be exact.

# convert_sut() warns about values version 2 has no field for

    Code
      convert_sut(fixture("v1_full.sut"), withr::local_tempfile(), to = 2)
    Condition
      Warning:
      Version 2 has no prim, afstm, and fval, so their values are not written:
      * prim: 2 rows
      * afstm: 2 rows
      * fval: 2 rows

# convert_sut() lists values too wide for version 1

    Code
      convert_sut(fixture("v2_written.sut"), withr::local_tempfile(), to = 1)
    Condition
      Error in `write_sut()`:
      ! Cannot write 1 value so that `read_sut()` reads it back unchanged:
      x nrnr, row 1: "123456" is 6 characters, the field holds 5.

# convert_sut() keeps the original and refuses a file already in that version

    Code
      convert_sut(path, path, to = 1)
    Condition
      Error in `convert_sut()`:
      ! `out` must differ from `path`, so the original file is kept.

---

    Code
      convert_sut(path, withr::local_tempfile(), to = 2)
    Condition
      Error in `convert_sut()`:
      ! 'file' is already version 2.

# write_sut() rejects columns that are not SUT fields, and missing ones

    Code
      write_sut(cbind(x, extra = 1), withr::local_tempfile(), version = 2)
    Condition
      Error in `write_sut()`:
      ! Column extra in `x` is not a SUT field.
      i SUT fields: nrnr, trans, brch, bas, eng, det, afg, moms, and kbx.

---

    Code
      write_sut(x[setdiff(names(x), "kbx")], withr::local_tempfile(), version = 2)
    Condition
      Error in `write_sut()`:
      ! `x` is missing column kbx.

