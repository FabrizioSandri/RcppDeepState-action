// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <Rcpp.h>

using namespace Rcpp;

#ifdef RCPP_USE_GLOBAL_ROSTREAM
Rcpp::Rostream<true>&  Rcpp::Rcout = Rcpp::Rcpp_cout_get();
Rcpp::Rostream<false>& Rcpp::Rcerr = Rcpp::Rcpp_cerr_get();
#endif

// sum
int sum(int arg1, int arg2);
RcppExport SEXP _TestPackage_sum(SEXP arg1SEXP, SEXP arg2SEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< int >::type arg1(arg1SEXP);
    Rcpp::traits::input_parameter< int >::type arg2(arg2SEXP);
    rcpp_result_gen = Rcpp::wrap(sum(arg1, arg2));
    return rcpp_result_gen;
END_RCPP
}

static const R_CallMethodDef CallEntries[] = {
    {"_TestPackage_sum", (DL_FUNC) &_TestPackage_sum, 2},
    {NULL, NULL, 0}
};

RcppExport void R_init_TestPackage(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}