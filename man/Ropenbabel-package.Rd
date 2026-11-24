\name{Ropenbabel-package}
\alias{Ropenbabel-package}
\alias{Ropenbabel}
\docType{package}
\title{Open Babel C++ library for R packages}
\description{
  \pkg{Ropenbabel} builds the Open Babel cheminformatics library from
  bundled sources as a static library when the package is installed, and
  installs its headers and data files. Other packages, such as
  \pkg{ChemmineOB}, link to it with the flags from \code{\link{pkgconfig}},
  so they need no system installation of Open Babel.
}
\seealso{\code{\link{pkgconfig}}, \code{vignette("Ropenbabel")}}
\keyword{package}
