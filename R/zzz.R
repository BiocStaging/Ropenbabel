## Location of the vendored Open Babel install tree inside this package.
## Must match OB_PREFIX in src/Makevars.common.
.obPrefix <- function() {
    ## R_ARCH is "/x64" on Windows and normally "" elsewhere.
    sub <- if (nzchar(.Platform$r_arch)) file.path("openbabel", .Platform$r_arch) else "openbabel"
    system.file(sub, package = "Ropenbabel", mustWork = TRUE)
}

## Compiler / linker flags for packages that link to Open Babel.
## Use from a client package's src/Makevars(.win), e.g.
##   PKG_CPPFLAGS = $(shell "$(R_HOME)/bin/Rscript" -e "Ropenbabel::pkgconfig('PKG_CPPFLAGS')")
##   PKG_LIBS     = $(shell "$(R_HOME)/bin/Rscript" -e "Ropenbabel::pkgconfig('PKG_LIBS')")
## Keep in sync with PKG_CPPFLAGS / PKG_LIBS in src/Makevars.common.
pkgconfig <- function(opt = c("PKG_LIBS", "PKG_CPPFLAGS")) {
    opt <- match.arg(opt)
    prefix <- .obPrefix()
    config <- if (opt == "PKG_CPPFLAGS") {
        sprintf("-I'%s'", file.path(prefix, "include", "openbabel3"))
    } else {
        libdir <- file.path(prefix, "lib")
        ## Order matters for static linking: openbabel before its deps.
        libs <- file.path(libdir, c("libopenbabel.a", "libinchi.a"))
        libs <- libs[file.exists(libs)]
        ## Link flags for optional dependencies (Cairo) found at build time.
        extra <- file.path(libdir, "extra-libs.txt")
        extra <- if (file.exists(extra)) trimws(readLines(extra, warn = FALSE)) else character()
        paste(c(sprintf("'%s'", libs), extra[nzchar(extra)], "-lz"), collapse = " ")
    }
    cat(config)
}

## Directory holding Open Babel's data files (force fields, SMARTS
## patterns, ...). Client packages should set BABEL_DATADIR to this.
dataDir <- function() {
    d <- list.dirs(file.path(.obPrefix(), "share", "openbabel"),
                   recursive = FALSE)
    if (length(d)) d[[1L]] else file.path(.obPrefix(), "share", "openbabel")
}

obVersion <- function() .Call(C_Ropenbabel_version)

.onLoad <- function(libname, pkgname) {
    if (!nzchar(Sys.getenv("BABEL_DATADIR")))
        Sys.setenv(BABEL_DATADIR = dataDir())
}
