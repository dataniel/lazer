#' lazer: read and write the files an economics team works with
#'
#' One place for the readers and writers of day-to-day work. Start here:
#'
#' * [read_files()] reads many files at once in most formats, and can bind
#'   them into one table or unpack them as variables.
#' * [read_workbook()] reads every sheet of an Excel workbook, finding the
#'   table on each sheet, or the ranges, named ranges or Excel tables you
#'   choose. [inspect_excel()] runs its layout check on its own.
#' * [write_excel()] writes presentable Excel files: bold, frozen header and
#'   readable number formats.
#' * [read_access()] reads from a Microsoft Access database.
#' * [read_sut()], [write_sut()] and [convert_sut()] read, write and convert
#'   Greenlandic supply and use table files (SUT; TA files in Danish) in both
#'   layouts.
#'
#' The readers share a few habits: they are quiet when all is well, check
#' what they read, and report every problem in one message instead of
#' stopping at the first.
#'
#' @keywords internal
"_PACKAGE"
