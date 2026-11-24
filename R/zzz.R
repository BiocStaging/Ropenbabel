## Location of the vendored Open Babel install tree inside this package.
## Must match OB_PREFIX in src/Makevars.common.
.obPrefix <- function() {
    ## R_ARCH is "/x64" on Windows and normally "" elsewhere.
    sub <- "openbabel"
    if (nzchar(.Platform$r_arch))
        sub <- file.path(sub, .Platform$r_arch)
    system.file(sub, package = "Ropenbabel", mustWork = TRUE)
}

## Compiler / linker flags for packages that link to Open Babel.
## Use from a client package's src/Makevars(.win); see ?pkgconfig.
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
        ## Libraries linked after these (Cairo, zlib), recorded at build
        ## time by src/Makevars.common.
        extraFile <- file.path(libdir, "extra-libs.txt")
        extra <- "-lz"
        if (file.exists(extraFile))
            extra <- trimws(readLines(extraFile, warn = FALSE))
        extra <- extra[nzchar(extra)]
        paste(c(sprintf("'%s'", libs), extra), collapse = " ")
    }
    ## Printed, not returned: this is read by $(shell ...) in Makevars.
    cat(config)
}

## Directory holding Open Babel's data files (force fields, SMARTS
## patterns, ...).
dataDir <- function() {
    base <- file.path(.obPrefix(), "share", "openbabel")
    d <- list.dirs(base, recursive = FALSE)
    if (length(d)) d[[1L]] else base
}

obVersion <- function() .Call(C_Ropenbabel_version)

## Open Babel (here and in every package that links it) looks up its data
## files through the BABEL_DATADIR environment variable; the compiled-in
## default points at the temporary build location. Only set it if the user
## hasn't.
.onLoad <- function(libname, pkgname) {
    if (!nzchar(Sys.getenv("BABEL_DATADIR")))
        Sys.setenv(BABEL_DATADIR = dataDir())
}
