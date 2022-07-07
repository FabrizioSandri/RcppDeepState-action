#include <Rcpp.h>

using namespace std;

// [[Rcpp::export]]
int sum(int arg1, int arg2){
    return(arg1 + arg2);
}