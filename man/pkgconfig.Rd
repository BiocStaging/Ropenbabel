\name{pkgconfig}
\alias{pkgconfig}
\alias{dataDir}
\alias{obVersion}
\title{Build flags, data directory and version of the bundled Open Babel}
\description{
  Helpers for packages that link to the static Open Babel library shipped
  in \pkg{Ropenbabel}.
}
\usage{
pkgconfig(opt = c("PKG_LIBS", "PKG_CPPFLAGS"))
dataDir()
obVersion()
}
\arguments{
  \item{opt}{Which flags to print: \code{"PKG_CPPFLAGS"} (include path)
    or \code{"PKG_LIBS"} (static libraries plus any system libraries,
    such as Cairo, that they were built against).}
}
\details{
  \code{pkgconfig} is meant to be called from a client package's
  \file{src/Makevars} (or \file{src/Makevars.win}):
\preformatted{
RSCRIPT = "$(R_HOME)/bin/Rscript"
PKG_CPPFLAGS = $(shell $(RSCRIPT) -e "Ropenbabel::pkgconfig('PKG_CPPFLAGS')")
PKG_LIBS     = $(shell $(RSCRIPT) -e "Ropenbabel::pkgconfig('PKG_LIBS')")
}
  together with \code{LinkingTo: Ropenbabel} and \code{Imports: Ropenbabel}
  in \file{DESCRIPTION}.

  Open Babel reads force fields, atom types and other data files from the
  directory named by the \env{BABEL_DATADIR} environment variable.
  \pkg{Ropenbabel} sets it to \code{dataDir()} when loaded, unless it is
  already set.
}
\value{
  \code{pkgconfig} prints the flags with \code{cat} and returns
  \code{NULL} invisibly. \code{dataDir} returns the path of the Open Babel
  data directory. \code{obVersion} returns the Open Babel version as a
  character string.
}
\examples{
pkgconfig("PKG_CPPFLAGS")
pkgconfig("PKG_LIBS")
dataDir()
obVersion()
}
\keyword{utilities}
