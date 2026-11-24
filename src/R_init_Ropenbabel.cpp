// Small shim so the package has a shared object, and so that loading
// Ropenbabel proves the static library links and its plugins register.
// Open Babel (and the C++ standard library) must come before R headers:
// Rinternals.h defines macros such as length() that break libstdc++.
#include <openbabel/babelconfig.h>
#include <openbabel/mol.h>
#include <openbabel/obconversion.h>

#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>
#include <R_ext/Rdynload.h>

extern "C" {

SEXP Ropenbabel_version(void) {
    return Rf_mkString(BABEL_VERSION);
}

// Round-trips a SMILES string. Fails if the static plugin table
// (OB_STATIC_PLUGIN in plugin.h) didn't get linked in.
SEXP Ropenbabel_selftest(void) {
    OpenBabel::OBConversion conv;
    OpenBabel::OBMol mol;
    bool ok = conv.SetInAndOutFormats("smi", "can") &&
              conv.ReadString(&mol, "c1ccccc1O") &&
              mol.NumAtoms() == 7;
    return Rf_ScalarLogical(ok);
}

static const R_CallMethodDef callMethods[] = {
    {"C_Ropenbabel_version",  (DL_FUNC) &Ropenbabel_version,  0},
    {"C_Ropenbabel_selftest", (DL_FUNC) &Ropenbabel_selftest, 0},
    {NULL, NULL, 0}
};

void R_init_Ropenbabel(DllInfo *dll) {
    R_registerRoutines(dll, NULL, callMethods, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
    R_forceSymbols(dll, TRUE);
}

}
