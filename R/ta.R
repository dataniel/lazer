# The two TA layouts ---------------------------------------------------------
#
# One row per field: where it sits on the line (1-based characters, `end = NA`
# runs to the end of the line), whether it is text or a number, and whether
# write_ta() writes it. read_ta() and write_ta() only follow these tables, so
# a change in a layout is a change here and nowhere else.

ta_layouts <- list(
  # Version 1, the old layout. Fields are separated by one blank.
  `1` = tibble::tribble(
    ~field,  ~start, ~end, ~type,    ~written,
    "nrnr",       1,    5, "text",   TRUE,
    "trans",      7,   12, "text",   TRUE,
    "brch",      14,   17, "text",   TRUE,
    "bas",       19,   31, "number", TRUE,
    "eng",       33,   43, "number", TRUE,
    "det",       45,   55, "number", TRUE,
    "afg",       57,   67, "number", TRUE,
    "moms",      69,   79, "number", TRUE,
    "kbx",       81,   91, "number", TRUE,
    "prim",      93,  103, "number", FALSE,
    "afstm",    105,  107, "text",   FALSE,
    "fval",     109,   NA, "text",   FALSE
  ),
  # Version 2, the new 140-character layout. Blank at 7-16 and 22-30.
  `2` = tibble::tribble(
    ~field,  ~start, ~end, ~type,    ~written,
    "nrnr",       1,    6, "text",   TRUE,
    "trans",     17,   21, "text",   TRUE,
    "brch",      31,   35, "text",   TRUE,
    "bas",       36,   60, "number", TRUE,
    "eng",       61,   76, "number", TRUE,
    "det",       77,   92, "number", TRUE,
    "afg",       93,  108, "number", TRUE,
    "moms",     109,  124, "number", TRUE,
    "kbx",      125,  140, "number", TRUE
  )
)

#' Read a Greenlandic TA file
#'
#' Reads a Greenlandic TA file in the old layout (version 1) or the new
#' 140-character layout (version 2), recognising which by itself.
#'
#' @details
#' **The layouts.** Character positions, 1-based. Text fields are read as
#' character, the rest as numbers.
#'
#' | Field | Version 1 | Version 2 | Type |
#' |-------|-----------|-----------|------|
#' | nrnr  | 1--5      | 1--6      | text |
#' | trans | 7--12     | 17--21    | text |
#' | brch  | 14--17    | 31--35    | text |
#' | bas   | 19--31    | 36--60    | number |
#' | eng   | 33--43    | 61--76    | number |
#' | det   | 45--55    | 77--92    | number |
#' | afg   | 57--67    | 93--108   | number |
#' | moms  | 69--79    | 109--124  | number |
#' | kbx   | 81--91    | 125--140  | number |
#' | prim  | 93--103   |           | number |
#' | afstm | 105--107  |           | text |
#' | fval  | 109--end  |           | text |
#'
#' **Recognising the version.** Version 2 lines are 140 characters, with
#' blanks at 7--16 and 22--30, where version 1 has `trans`, `brch` and `bas`.
#' When every line looks like version 2, the file is read as version 2; when
#' none does, as version 1. A mix is an error. Giving `version` skips the
#' guess, but a file that clearly is the other version is still an error,
#' rather than read into the wrong columns.
#'
#' **Values.** Fields are trimmed, and a blank field or `NA` is read as `NA`.
#' A number field that is not a number is an error listing every such field,
#' not a silent `NA`. Empty lines are skipped; line numbers in messages are
#' those of the file.
#'
#' @param path Path to the TA file.
#' @param version `1` (old layout), `2` (new layout), or `NULL` (default) to
#'   recognise it from the file.
#'
#' @return A tibble with one column per field: 12 for version 1, 9 for
#'   version 2.
#'
#' @examples
#' \dontrun{
#' df <- read_ta("ta.file")
#' df <- read_ta("ta.file", version = 2)
#' }
#'
#' @seealso [write_ta()]
#' @export
read_ta <- function(path, version = NULL) {
  lines <- readLines(path, warn = FALSE)
  line_no <- which(trimws(lines) != "")   # skip empty lines, keep the file's numbering
  lines <- lines[line_no]

  version <- ta_read_version(lines, line_no, version)
  layout <- ta_layouts[[version]]

  out <- list()
  problems <- character()
  for (i in seq_len(nrow(layout))) {
    f <- layout[i, ]
    end <- if (is.na(f$end)) nchar(lines) else f$end
    value <- trimws(substr(lines, f$start, end))
    value[value %in% c("", "NA")] <- NA

    if (f$type == "number") {
      number <- suppressWarnings(as.numeric(value))
      bad <- which(!is.na(value) & is.na(number))
      problems <- c(problems, sprintf('%s, line %d: "%s" is not a number.', f$field, line_no[bad], value[bad]))
      value <- number
    }
    out[[f$field]] <- value
  }

  if (length(problems) > 0) {
    cli::cli_abort(c("Cannot read {length(problems)} number field{?s}:", cap_bullets(problems)))
  }
  tibble::as_tibble(out)
}

# The version to read: the one given, or the one the lines look like. Either
# way a file that clearly is the other version is an error.
ta_read_version <- function(lines, line_no, version, call = rlang::caller_env()) {
  looks_v2 <- nchar(lines) >= 140 &
    substr(lines, 7, 16) == strrep(" ", 10) &
    substr(lines, 22, 30) == strrep(" ", 9)

  if (is.null(version)) {
    if (length(lines) == 0 || !any(looks_v2)) return("1")
    if (all(looks_v2)) return("2")
    cli::cli_abort(c(
      "Cannot tell which TA layout this file has.",
      "x" = "{sum(looks_v2)} of {length(lines)} lines look like version 2.",
      "i" = "Give {.arg version} to read it as one of them."
    ), call = call)
  }

  version <- ta_check_version(version, call = call)
  short <- line_no[nchar(lines) < 140]
  if (version == "2" && length(short) > 0) {
    cli::cli_abort(c(
      "{cli::qty(length(short))}Line{?s} {short} {cli::qty(length(short))}{?is/are} shorter than the 140 characters of version 2.",
      "i" = "Is this a version 1 file? Use {.code version = 1}."
    ), call = call)
  }
  if (version == "1" && length(lines) > 0 && all(looks_v2)) {
    cli::cli_abort(c(
      "This file looks like version 2: 140-character lines, blank at 7--16 and 22--30.",
      "i" = "Use {.code version = 2}, or leave {.arg version} out to recognise it."
    ), call = call)
  }
  version
}

ta_check_version <- function(version, call = rlang::caller_env()) {
  if (!(length(version) == 1 && version %in% c(1, 2))) {
    cli::cli_abort("{.arg version} must be 1 (the old layout) or 2 (the new 140-character layout).", call = call)
  }
  as.character(version)
}

#' Write a Greenlandic TA file
#'
#' Writes a data frame to a Greenlandic TA file in the old layout (version 1)
#' or the new 140-character layout (version 2). The layout must be named,
#' since it has to match what the receiver reads.
#'
#' @details
#' Writes the nine fields `nrnr`, `trans`, `brch`, `bas`, `eng`, `det`,
#' `afg`, `moms` and `kbx` in the positions [read_ta()] reads them from. If
#' `moms` is absent, it is derived: `NA` where `trans` is `"0100"` or
#' `"0700"` (no VAT in Greenland), `0` otherwise.
#'
#' **The file reads back unchanged.** A fixed-width file has no delimiters,
#' so a value wider than its field does not fail: it pushes every following
#' field out of place, and the file still parses, into the wrong columns.
#' `write_ta()` therefore refuses to write anything it cannot write exactly,
#' and lists every offending value at once:
#'
#' * Numbers are right-aligned, with the fewest decimals that reproduce the
#'   value exactly, so whole numbers have none. A number whose exact form is
#'   wider than its field is an error, never rounded.
#' * Text is left-aligned. Since [read_ta()] trims fields and reads blank
#'   fields and `"NA"` as `NA`, text that is too long, empty, `"NA"`, or
#'   starts or ends with a space is an error.
#' * `NA` is written as a blank field.
#'
#' @param x A data frame with the columns `nrnr`, `trans`, `brch`, `bas`,
#'   `eng`, `det`, `afg`, `kbx` and optionally `moms`. Other columns are an
#'   error.
#' @param path Path to write to.
#' @param version `1` (old layout) or `2` (new 140-character layout).
#'
#' @return `path`, invisibly.
#'
#' @examples
#' \dontrun{
#' write_ta(df, "ta.file", version = 2)
#' }
#'
#' @seealso [read_ta()], which shows both layouts.
#' @export
write_ta <- function(x, path, version) {
  if (missing(version)) {
    cli::cli_abort(c(
      "Say which TA layout to write.",
      "i" = "Use {.code version = 1} for the old layout or {.code version = 2} for the new 140-character one."
    ))
  }
  version <- ta_check_version(version)
  layout <- ta_layouts[[version]]
  layout <- layout[layout$written, ]

  extra <- setdiff(names(x), layout$field)
  if (length(extra) > 0) {
    cli::cli_abort(c(
      "Column{?s} {.field {extra}} in {.arg x} {?is not a TA field/are not TA fields}.",
      "i" = "TA fields: {.field {layout$field}}."
    ))
  }
  if (!"moms" %in% names(x)) {
    cli::cli_inform("{.field moms} is not in {.arg x}; writing it as {.code NA} for trans 0100 and 0700, {.code 0} otherwise.")
    x$moms <- ifelse(x$trans %in% c("0100", "0700"), NA_real_, 0)
  }
  missing_cols <- setdiff(layout$field, names(x))
  if (length(missing_cols) > 0) {
    cli::cli_abort("{.arg x} is missing column{?s} {.field {missing_cols}}.")
  }

  # Each field as text, padded to its width; collect what cannot be written
  pieces <- list()
  problems <- character()
  prev_end <- 0
  for (i in seq_len(nrow(layout))) {
    f <- layout[i, ]
    width <- f$end - f$start + 1
    value <- x[[f$field]]

    if (f$type == "number") {
      text <- ta_format_number(value, width)
      bad <- which(is.na(text) | nchar(text) > width)
      why <- sprintf("%s needs more than %d characters to be exact", format(value[bad], digits = 17), width)
      padded <- formatC(text, width = width)          # right-aligned
    } else {
      text <- ifelse(is.na(value), "", as.character(value))
      bad <- which(!is.na(value) & (nchar(text) > width | text %in% c("", "NA") | text != trimws(text)))
      why <- sprintf('"%s" %s', text[bad], ta_text_problem(text[bad], width))
      padded <- formatC(text, width = width, flag = "-")  # left-aligned
    }
    problems <- c(problems, sprintf("%s, row %d: %s.", f$field, bad, why))

    pieces <- c(pieces, list(strrep(" ", f$start - prev_end - 1), padded))
    prev_end <- f$end
  }

  if (length(problems) > 0) {
    cli::cli_abort(c(
      "Cannot write {length(problems)} value{?s} so that {.fn read_ta} reads {cli::qty(length(problems))}{?it/them} back unchanged:",
      cap_bullets(problems)
    ))
  }

  writeLines(do.call(paste0, pieces), path)
  invisible(path)
}

#' Convert a Greenlandic TA file between the two layouts
#'
#' Reads a TA file in one layout and writes it in the other: version 1 to
#' version 2, or version 2 to version 1.
#'
#' @details
#' This is [read_ta()] followed by [write_ta()], with their checks:
#'
#' * **1 to 2:** version 2 has no `prim`, `afstm` or `fval`. If any of them
#'   holds a value, a warning says how many rows lose it.
#' * **2 to 1:** the fields of version 1 are narrower (numbers 11 or 13
#'   characters instead of 16 or 25, `nrnr` 5 instead of 6). A value that does
#'   not fit exactly is an error listing every such value, never truncated or
#'   rounded.
#'
#' @param path Path to the TA file to convert. Its version is recognised, as
#'   in [read_ta()].
#' @param out Path to write the converted file to. Must differ from `path`.
#' @param to The version to convert to: `1` or `2`.
#'
#' @return `out`, invisibly.
#'
#' @examples
#' \dontrun{
#' convert_ta("old.ta", "new.ta", to = 2)
#' convert_ta("new.ta", "old.ta", to = 1)
#' }
#'
#' @seealso [read_ta()] for both layouts.
#' @export
convert_ta <- function(path, out, to) {
  to <- ta_check_version(to)
  if (normalizePath(path, mustWork = FALSE) == normalizePath(out, mustWork = FALSE)) {
    cli::cli_abort("{.arg out} must differ from {.arg path}, so the original file is kept.")
  }

  lines <- readLines(path, warn = FALSE)
  line_no <- which(trimws(lines) != "")
  from <- ta_read_version(lines[line_no], line_no, NULL)
  if (from == to) {
    cli::cli_abort("{.file {basename(path)}} is already version {to}.")
  }

  x <- read_ta(path, version = from)
  if (to == "2") {
    dropped <- c("prim", "afstm", "fval")
    lost <- vapply(dropped, function(f) sum(!is.na(x[[f]])), numeric(1))
    if (any(lost > 0)) {
      cli::cli_warn(c(
        "Version 2 has no {.field {dropped[lost > 0]}}, so {cli::qty(sum(lost > 0))}{?its/their} values are not written:",
        cap_bullets(sprintf("%s: %d row%s", dropped[lost > 0], lost[lost > 0], ifelse(lost[lost > 0] == 1, "", "s")), bullet = "*")
      ))
    }
    x <- x[setdiff(names(x), dropped)]
  }
  write_ta(x, out, version = to)
}

# The shortest fixed-point text that reads back as exactly `value`, trying
# more decimals only for the values that need them. NA is a blank field; a
# value with no exact form in `width` characters is NA, reported by the caller.
ta_format_number <- function(value, width) {
  value <- as.double(value)
  text <- ifelse(is.na(value), "", NA_character_)
  for (digits in 0:(width - 2)) {
    todo <- which(is.na(text))
    if (length(todo) == 0) break
    candidate <- formatC(value[todo], format = "f", digits = digits)
    exact <- as.double(candidate) == value[todo]
    text[todo[exact]] <- candidate[exact]
  }
  text
}

ta_text_problem <- function(text, width) {
  ifelse(nchar(text) > width, sprintf("is %d characters, the field holds %d", nchar(text), width),
  ifelse(text == "", "is empty and would read back as NA",
  ifelse(text == "NA", "would read back as NA",
         "has leading or trailing spaces, which read_ta() trims")))
}
