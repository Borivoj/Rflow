
# Generic job class -------------------------------------------------------


#' jobs
#' * can be run = must evaluate() method
#' * can have dependencies (nodes)
#' * running them leads to consequences (nodes) that can be verified
#'
#' @export
job <- function(x, ...) {
  UseMethod("job", x)
}

#' @export
evaluate <- function(x, ...) {
  UseMethod("evaluate", x)
}

#' @export
evaluate.node <- function(x, ...) {
  x$eval(...)
}

#' @export
evaluate.job <- function(x, ...) {
  warning("This an empty method!")
}

print.job <- function(x, ...) {
  warning("This an empty method!")
}

#' @export
job_file <- function(x, ...) {

  struct <- list(
    path = x,
    hash = hash_file(x)
  )

  struct <- union.list(list(...), struct)

  structure(struct, class = c("job_file", "job"))
}


#' @export
read.job_file <- function(x, ...) {
  paste0(readLines(x$path, ...))
}



# R jobs ------------------------------------------------------------------


#' @export
job.expression <- function(x, ...) {
  job_r(x, ...)
}

#' @export
job_r <- function(x, ...) {
  UseMethod("job_r", x)
}

#' @export
job_r.default <- function(x, ...) {
  job_r(as.expression(x), ...)
}

#' @export
job_r.expression <- function(x, ...) {
  job <-
    structure(
      list(
        r_expr = x,
        code   = deparse_nicely(x)
      ),
      class = c("job_r_expr", "job_r", "job"))

  job
}

#' @export
job_r.function <- function(x, ...) {
  structure(
    list(
      r_fn = x
    ),
    class = c("job_r_fn", "job_r", "job")
  )
}

#' @export
job_r.character <- function(x, file = FALSE, ...) {

  if (isTRUE(file)) return(job_r_file(x, ...))
  # else:

  job <-
    structure(
      list(
        r_expr = parse(text = x),
        code   = x
      ),
      class = c("job_r_expr", "job_r", "job"))

  job
}

#' @export
evaluate.job_r_expr <- function(x, ...) {
  eval(x$r_expr, ...)
}

#' @export
evaluate.job_r_fn <- function(x, ..., quote = FALSE, envir = parent.frame()) {
  do.call(x$r_fn, args = list(...), quote = quote, envir = envir)
}

#' @export
job_r_file <- function(x, ...) {
  job <- job_file(x, ...)
  class(job) <- unique(c("job_r_file", "job_r", "job_file", class(job)))

  job
}

#' @export
evaluate.job_r_file <- function(x, ...) {
  source(x$path, ...)$value
}


# SQL jobs ----------------------------------------------------------------

#' @export
job_sql_code <- function(x, mode = "execute", ...) {

}

#' @export
job_sql_file <- function(x, mode = "execute", ...) {
  job <- job_file(x, mode = mode, ...)
  class(job) <- c("job_sql_file", "job_sql", "job_file", class(job))

  job
}



# Python jobs -------------------------------------------------------------

#' @export
job_python <- function(x, ...) {
  UseMethod("job_python", x)
}


#' @export
job_python.character <- function(x, file = FALSE, ...) {
  job <-
    structure(
      list(
        src = x
      ),
      class = c("job_python_code", "job"))

  job
}


#' @export
job_python_file <- function(x, ...) {
  job <- job_file(x, ...)
  class(job) <- c("job_python_file", "job_python", class(job))

  job
}


#' @export
evaluate.job_python_code <- function(x, ...) {
  stopifnot(reticulate::py_available())
  reticulate::py_run_string(x$src)
}


#' @export
evaluate.job_python_file <- function(x, ...) {
  reticulate::py_run_file(x$fp)
}


# Misc tools --------------------------------------------------------------------


hash_file <- function(x, algo = "md5", ...) {
  structure(
    list(
      value = digest::digest(x, algo = algo, file = TRUE, ...),
      path = x,
      time = Sys.time()
    ),
    class = c("hash_file", "hash")
  )
}

expr2fun <- function(expr, depends, envir = NULL) {

  # this seems work better then as.function()
  f <- function() {}
  body(f) <- expr

  . <- paste0('.RFLOW[["', depends, '"]]$get()')
  . <- lapply(., str2lang)
  names(.) <- depends
  . -> formals(f)

  if (is.environment(envir)) environment(f) <- envir

  return(f)
}


strip_srcrefs <- function(expr) {
  attr(expr[[1]], "srcref")      <- NULL
  attr(expr[[1]], "srcfile")     <- NULL
  attr(expr[[1]], "wholeSrcref") <- NULL

  expr
}

#' Returns R expression from either R expression or parsed R code
#'
#' @param x either character or R expression vector of R code
#'
#' @return an R expression object with src attribute containing original code that can be used for printing
#' @export
#'
#' @examples
#' \dontrun{
#' as_r_expr("{\n1+1\n}")
#' }
as_r_expr <- function(x) {
  UseMethod("as_r_expr", x)
}

#' @export
#' @rdname as_r_expr
as_r_expr.NULL <- function(x) {
  return(NULL)
}

#' @export
#' @rdname as_r_expr
as_r_expr.default <- function(x) {
  warning("Coercing ", substitute(x), " to a character")
  as_r_expr(as.character(x))
}

#' @export
#' @rdname as_r_expr
as_r_expr.expression <- function(x) {

  if (length(x)) {

    if (length(attr(x, "src"))) return(x)
    # else:
    return(
      structure(
        strip_srcrefs(x),
        src = paste0(deparse(x, control = "useSource"), collapse = "\n")
      )
    )
  } # else:
  return(structure(expression(), src = ""))
}

#' @export
#' @rdname as_r_expr
as_r_expr.character <- function(x) {
  if (length(x)) {

    return(
      structure(
        parse(text = x),
        src = x
      )
    )
  } # else if (legnth(r_file))

  # else:
  return(structure(expression(), src = ""))
}


#' Expression with source code references stripped off
#'
#' @param ... expression (see \code{\link[base]{expression}})
#'
#' @return
#' `expression_r` returns expression object similar to the one returned from \code{\link[base]{expression}} except references to source code
#' @export
#' @seealso \code{\link[base]{expression}}
#' @examples
#' \dontrun{
#' identical(expression(1+1), expression_r(1+1))
#' identical(expression({1+1}), expression_r({1+1}))
#' }
expression_r <- function(x){
  # simulate behaviour of expression() (but accept only one argument)
  exprs <- match.call(expand.dots = TRUE)
  exprs[1] <- expression(expression)
  exprs <- eval(exprs)

  return(as_r_expr(exprs))
}

#' Print with prefix
#'
#' @param x value to print
#' @param verbose_prefix prefix to be added after every new-line symbol
add_prefix <- function(x, prefix = "", color_main = NULL, color_prefix = NULL) {
  . <- unlist(crayon::col_strsplit(x, split = "\n", fixed = TRUE))
  . <- paste0(prefix, .)
  .
}

# add_prefix <- function(x, prefix = "", color_main = NULL, color_prefix = NULL) {
#   . <- unlist(stringr::str_split(x, stringr::fixed("\n")))
#   if (length(color_main))   . <-  color_main(.)
#   if (length(color_prefix)) . <-  color_prefix(.)
#   . <- paste0(prefix, .)
#   .
# }



#' Print with prefix
#'
#' @param x value to print
#' @param verbose_prefix prefix to be added after every new-line symbol
cat_with_prefix <- function(x, prefix = "", sep = "\n", ...) {
  cat(
    add_prefix(x, prefix = prefix),
    sep = sep,
    ...
  )
}

# deparse expressions (if not already deparsed in "src" attribute)
deparse_nicely <- function(x, ...) {
  UseMethod("deparse_nicely", x)
}

deparse_nicely.expression <- function(x) {
  if (length(attr(x, "src"))) return(attr(x, "src")) else paste0(deparse(x, control = "useSource"), collapse = "\n")
}

deparse_nicely.default <- function(x) {
  as.character(x)
}
