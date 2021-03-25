### palette utilities
# imgpal, show_pal
#
# unexported:
# rescaler
###


rescaler <- function(x, to = c(0, 1), from = range(x, na.rm = TRUE)) {
  (x - from[1L]) / diff(from) * diff(to) + to[1L]
}

#' Image palettes
#' 
#' Extract unique and most commonly-used unique colors from an image file
#' (requires \href{https://imagemagick.org/index.php}{ImageMagick}).
#' 
#' @param path full file path to image
#' @param n maximum number of colors to extract, result will be <= \code{n},
#' and the calculated number of unique colors will also be provided
#' @param options a (optional) character string of additional options passed
#' to \href{https://www.imagemagick.org/script/command-line-options.php}{\code{magick}}
#' 
#' @return
#' A list of class \code{"imgpal"} with the following elements:
#' \item{filename}{the image file name}
#' \item{n_unique}{the calculated number of unique colors}
#' \item{col}{a vector of colors (does not return transparent or white colors)}
#' \item{counts}{frequency counts for each \code{col}}
#' \item{call}{the call made to \code{magick}}
#' \item{magick}{the result of \code{call}}
#' 
#' @seealso
#' \code{\link{show_pal}}; \pkg{\code{magick}} package
#' 
#' @examples
#' go <- 'https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png'
#' ip <- imgpal(go)
#' show_pal(ip, n = 4)
#' 
#' ## extra options to magick
#' ip <- imgpal(go, options = '-colorize 0,0,50')
#' show_pal(ip)
#' 
#' ## faulkner::faulkners
#' img <- system.file('fig', package = 'faulkner')
#' img <- list.files(img, full.names = TRUE, pattern = 'g$')[1:6]
#' op <- par(mfrow = n2mfrow(length(img)))
#' sapply(img, function(x) show_pal(imgpal(x), fullrange = TRUE))
#' par(op)
#' 
#' @export

imgpal <- function(path, n = 10L, options = '') {
  cmd <- sprintf(
    # https://www.imagemagick.org/script/command-line-options.php
    "magick %s +dither -colors %s -layers flatten %s \\
    -define histogram:unique-colors=true \\
    -format '%%f, n=%%k\n%%c\n' histogram:info:",
    path, n, options
  )
  capture.output(
    res <- system(cmd, intern = TRUE)
  )
  if (!is.null(attr(res, 'status')))
    stop(res)
  
  res <- trimws(res[nzchar(res)])
  
  dat <- read.table(
    comment.char = '', stringsAsFactors = FALSE,
    text = gsub('\\s*(\\d+):.*(#\\S+).*', '\\1 \\2', res[-1L])
  )
  dat <- dat[order(dat[, 1L], decreasing = TRUE), ]
  
  ## remove fully transparent or white colors
  idx <- grepl('(?i)#(.{6}00|ffffff)', dat[, 2L])
  dat <- dat[!idx, ]
  
  res <- list(
    filename = gsub(', n.*', '', res[1L]),
    n_unique = type.convert(gsub('n=(\\d+)$|.', '\\1', res[1L])),
    col = gsub('(#.{6})|.', '\\1', dat[, 2L]), counts = dat[, 1L],
    call = gsub('\\s{2,}', ' ', gsub('\\\n', ' ', cmd, fixed = TRUE)),
    magick = res
  )
  
  structure(res, class = 'imgpal')
}

#' Show palettes
#' 
#' Show palettes as an image.
#' 
#' @param x one of 1) a \code{faulkners} name; 2) a vector of two or more
#' colors; 3) an \code{\link{imgpal}} object
#' @param n the first \code{n} colors will be shown
#' @param fullrange logical; for \code{\link{imgpal}} objects, if \code{TRUE},
#' the entire palette is shown; otherwise, only the unique colors (estimated
#' from ImageMagick) are shown
#' @param counts logical; for \code{\link{imgpal}} objects, if \code{TRUE},
#' the frequencies are shown for each color
#' 
#' @examples
#' show_pal(1:5)
#' show_pal(rainbow(8))
#' show_pal('alice')
#' 
#' go <- 'https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png'
#' ip <- imgpal(go)
#' show_pal(ip, n = 4)
#' 
#' @export

show_pal <- function(x, n = NULL, fullrange = FALSE,
                     counts = inherits(x, 'imgpal')) {
  imgpal <- inherits(x, 'imgpal')
  
  if (inherits(x, 'faulkner')) {
    name <- attr(x, 'name')
    pal <- x
  } else if (length(x) == 1L) {
    idx <- match(tolower(x), names(faulkners), nomatch = 0L)
    if (idx == 0L)
      stop(sprintf('palette %s not found', shQuote(x)))
    pal <- faulkners[[idx]]
    name <- x
  } else if (imgpal) {
    obj <- x
    pal <- obj$col
    len <- length(pal)
    name <- obj$filename
    pal <- pal[seq.int(if (fullrange) len else pmin(obj$n_unique, len))]
  } else {
    pal <- x
    name <- deparse(substitute(x))
  }
  
  n <- if (is.null(n))
    length(pal) else pmin(length(pal), n)
  i <- seq.int(n)
  pal <- pal[seq.int(n)]
  
  op <- par(mar = rep_len(1, 4L))
  on.exit(par(op))
  
  image(i, 1, matrix(i), col = pal, ann = FALSE, axes = FALSE)
  abline(v = i + 0.5, col = 'white')
  
  ## add bars of color frequencies
  if (imgpal && counts) {
    ht <- obj$counts[i]
    ht <- rescaler(ht, par('usr')[3:4], c(0, sum(ht)))
    rect(i - 0.5, par('usr')[3L], i + 0.25, ht,
         col = 'white', density = 10, angle = 45)
    rect(i - 0.5, par('usr')[3L], i + 0.25, ht,
         col = 'white', density = 10, angle = -45)
  }
  
  col <- adjustcolor('white', 0.8)
  rect(0, 0.9, n + 1, 1.1, col = col, border = NA)
  text((n + 1) / 2, 1, name)
  if (n <= 20L)
    text(i + 0.5, par('usr')[4L], i, col = col, adj = c(2, 2))
  
  pal
}
