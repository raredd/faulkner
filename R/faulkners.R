### faulkner palettes
# faulkners, faulkner
# 
# S3 methods
# print.faulkner
###


#' Faulkner palettes
#' 
#' Color palettes stripped from the original paintings of Henry Faulkner.
#' 
#' @param name the palette name, one of \code{names(faulkners)} or an
#' unambiguous abbreviation
#' @param n the first \code{n} colors from the palette to use
#' @param z for \code{type = 'continuous'}, the number of colors to
#' interpolate from the sequence of \code{n} palette colors
#' @param type return a discrete or continuous (gradient) of colors
#' @param rev logical; if \code{TRUE}, the palette is reversed
#' 
#' @seealso
#' \code{\link{imgpal}}; \code{\link{palette}}; \code{\link{colorRampPalette}};
#' \code{wesanderson::wes_palettes}; \code{nord::nord_palettes}
#' 
#' @examples
#' ## some built-in palettes
#' names(faulkners)
#' 
#' op <- par(mfrow = n2mfrow(length(faulkners)))
#' for (ii in seq_along(faulkners))
#'   show_pal(structure(faulkners[[ii]], class = 'faulkner', name = names(faulkners)[ii]))
#' par(op)
#' 
#' ## use or generate new palettes from existing
#' show_pal(faulkner('delphiniums1'))
#' show_pal(faulkner('delphiniums1', 4))
#' show_pal(faulkner('delphiniums1', 4, 100, type = 'continuous'))
#' 
#' ## view palettes from other sources
#' # show_pal(nord::nord_palettes$afternoon_prarie)
#' show_pal(rainbow(8))
#' 
#' filled.contour(volcano, col = faulkner('delphiniums1', n = 4, 21, type = 'c'))
#' filled.contour(volcano, col = faulkner('delphiniums1', z = 21, type = 'c'))
#' filled.contour(volcano, col = faulkner('alice', 4, 21, type = 'c'))
#'
#' @export

faulkners <- list(
  alice =
    c('#4F524B', '#1FABD2', '#DFD6AA', '#D1B957', '#59AC43', '#8F70AC'),
  butterfly =
    c('#4C6B31', '#36522E', '#A0A62C', '#222B2C', '#30515C', '#3F6F8C'),
  cats =
    c('#354C2F', '#526E4B', '#4368AD', '#70A2C4', '#90CFED'),
  delphiniums1 =
    c('#E79E60', '#EFDAA5', '#F4D7D1', '#D7DDE3', '#A8D2E3', '#9DADD6'),
  delphiniums2 =
    c('#E79E60', '#39669D', '#C16B51', '#F1D26A', '#A0709B'),
  dome =
    c('#503324', '#5D9CAD', '#B7AE3B', '#699449', '#607988', '#D0B49D'),
  flowers =
    c('#CC5C0D', '#B3981C', '#6C8B40', '#2F3957', '#567191'),
  gated1 =
    c('#4D3628', '#9A7031', '#9F955C', '#927353', '#D1CCB4'),
  gated2 =
    c('#4D3628', '#2C7090', '#C14F2C', '#6E9361', '#66899A'),
  giotto1 =
    c('#323525', '#55582D', '#676167', '#8B6E54', '#AEA89C', '#395028'),
  giotto2 =
    c('#549031', '#C57E82', '#9B7991', '#3B5488', '#7C838D', '#A79F4A'),
  huntmorgan =
    c('#D3AE9D', '#CDBF60', '#5EA5C3', '#739C5E'),
  leaning =
    c('#5F645E', '#626437', '#996D56', '#5E648D', '#AE9860', '#D2AEB7'),
  neworleans =
    c('#E6CFB6', '#4EA1CC', '#1878CB', '#246897', '#31516D', '#4C4E4F')
)

#' @rdname faulkners
#' @export
faulkner <- function(name, n = NULL, z = n, type = c('discrete', 'continuous'),
                     rev = FALSE) {
  type <- match.arg(type)
  name <- gsub('\\s', '', tolower(name))
  name <- match.arg(name, names(faulkners))
  
  pal <- faulkners[[name]]
  
  if (rev)
    pal <- rev(pal)
  
  if (is.null(n))
    n <- length(pal)
  
  if (is.null(pal))
    stop(sprintf('palette %s not found', shQuote(name)))
  
  if (type == 'discrete' & n > length(pal)) {
    type <- 'continuous'
    z <- n
    n <- length(pal)
    warning(sprintf('%s palette has %s colors, try type = \'continuous\'',
                    shQuote(name), n))
  }
  
  pal <- pal[seq.int(pmin(length(pal), n))]
  res <- switch(type, continuous = colorRampPalette(pal)(z), discrete = pal)
  
  structure(res, class = 'faulkner', name = name)
}

#' @export
print.faulkner <- function(x, ...) {
  # show_pal(x)
  print(x[seq_along(x)])
  invisible(x)
}
