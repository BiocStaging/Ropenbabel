stopifnot(.Call(Ropenbabel:::C_Ropenbabel_selftest))
stopifnot(dir.exists(Ropenbabel::dataDir()))
message("Open Babel ", Ropenbabel::obVersion(), " OK")
