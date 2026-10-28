# The fixtures were written and read with the functions this replaces
# (daos::write_ta(), write_ta2(), read_ta(), read_ta2()). The files must stay
# byte-identical and read back to the same tibbles.
fixture <- function(name) test_path("fixtures", name)
expected <- readRDS(test_path("fixtures", "expected.rds"))

test_that("write_ta() writes version 1 byte-identically to the old write_ta()", {
  path <- withr::local_tempfile()
  suppressMessages(write_ta(expected$x1, path, version = 1))
  expect_identical(readLines(path), readLines(fixture("v1_written.ta")))
})

test_that("write_ta() writes version 2 byte-identically to the old write_ta2()", {
  path <- withr::local_tempfile()
  write_ta(expected$x2, path, version = 2)
  expect_identical(readLines(path), readLines(fixture("v2_written.ta")))
})

test_that("read_ta() reads version 1 as the old read_ta() did", {
  expect_equal(read_ta(fixture("v1_written.ta")), expected$v1_written)
  # The old reader turned the empty third line into a row of NA; it is skipped now
  expect_equal(read_ta(fixture("v1_full.ta")), expected$v1_full[-3, ])
})

test_that("read_ta() reads version 2 as the old read_ta2() did", {
  expect_equal(read_ta(fixture("v2_written.ta")), expected$v2_written)
})

test_that("read_ta() recognises the version, and a given version wins", {
  expect_length(read_ta(fixture("v1_written.ta")), 12)
  expect_length(read_ta(fixture("v2_written.ta")), 9)
  expect_equal(read_ta(fixture("v2_written.ta"), version = 2), expected$v2_written)
  expect_equal(read_ta(fixture("v1_written.ta"), version = "1"), expected$v1_written)
})

test_that("read_ta() refuses to read a file as the wrong version", {
  expect_snapshot(read_ta(fixture("v1_written.ta"), version = 2), error = TRUE)
  expect_snapshot(read_ta(fixture("v2_written.ta"), version = 1), error = TRUE)
})

test_that("read_ta() refuses a mix of versions", {
  path <- withr::local_tempfile()
  writeLines(c(readLines(fixture("v1_written.ta"))[1], readLines(fixture("v2_written.ta"))[1]), path)
  expect_snapshot(read_ta(path), error = TRUE)
})

test_that("read_ta() lists every number field that is not a number, by file line", {
  path <- withr::local_tempfile()
  lines <- readLines(fixture("v2_written.ta"))
  substr(lines[2], 61, 76) <- formatC("1.2.3", width = 16)
  substr(lines[4], 125, 140) <- formatC("abc", width = 16)
  writeLines(c(lines[1:2], "", lines[3:4]), path)
  expect_snapshot(read_ta(path), error = TRUE)
})

test_that("write_ta() and read_ta() round-trip in both versions", {
  x <- expected$x2
  for (v in 1:2) {
    path <- withr::local_tempfile()
    if (v == 1) x$nrnr[1] <- "12345"
    write_ta(x, path, version = v)
    back <- read_ta(path, version = v)
    expect_equal(as.data.frame(back[names(x)]), x, ignore_attr = TRUE)
  }
})

test_that("write_ta() needs a version", {
  expect_snapshot(write_ta(expected$x2, withr::local_tempfile()), error = TRUE)
  expect_snapshot(write_ta(expected$x2, withr::local_tempfile(), version = 3), error = TRUE)
})

test_that("write_ta() derives moms when it is missing", {
  path <- withr::local_tempfile()
  x <- expected$x2
  x$moms <- NULL
  expect_message(write_ta(x, path, version = 2), "moms")
  expect_equal(read_ta(path)$moms, c(NA, NA, 0, 0))
})

test_that("write_ta() lists every value it cannot write exactly", {
  x <- expected$x2
  x$nrnr[2] <- "1234567"
  x$trans[3] <- " 100"
  x$brch[1] <- "NA"
  x$bas[1] <- 1e30        # 31 digits exactly, the field holds 25
  x$eng[2] <- 1 / 3       # exact in 19 characters, the field holds 16
  expect_snapshot(write_ta(x, withr::local_tempfile(), version = 2), error = TRUE)
})

test_that("convert_ta() converts version 1 to 2 and back", {
  v2 <- withr::local_tempfile()
  v1 <- withr::local_tempfile()
  convert_ta(fixture("v1_written.ta"), v2, to = 2)
  expect_equal(read_ta(v2, version = 2), expected$v1_written[1:9])
  convert_ta(v2, v1, to = 1)
  expect_identical(readLines(v1), readLines(fixture("v1_written.ta")))
})

test_that("convert_ta() warns about values version 2 has no field for", {
  expect_snapshot(convert_ta(fixture("v1_full.ta"), withr::local_tempfile(), to = 2))
})

test_that("convert_ta() lists values too wide for version 1", {
  expect_snapshot(convert_ta(fixture("v2_written.ta"), withr::local_tempfile(), to = 1), error = TRUE)
})

test_that("convert_ta() keeps the original and refuses a file already in that version", {
  path <- withr::local_tempfile()
  file.copy(fixture("v2_written.ta"), path)
  expect_snapshot(convert_ta(path, path, to = 1), error = TRUE, transform = \(x) sub("file[0-9a-f]+", "file", x))
  expect_snapshot(convert_ta(path, withr::local_tempfile(), to = 2), error = TRUE, transform = \(x) sub("file[0-9a-f]+", "file", x))
})

test_that("write_ta() rejects columns that are not TA fields, and missing ones", {
  x <- expected$x2
  expect_snapshot(write_ta(cbind(x, extra = 1), withr::local_tempfile(), version = 2), error = TRUE)
  expect_snapshot(write_ta(x[setdiff(names(x), "kbx")], withr::local_tempfile(), version = 2), error = TRUE)
})
