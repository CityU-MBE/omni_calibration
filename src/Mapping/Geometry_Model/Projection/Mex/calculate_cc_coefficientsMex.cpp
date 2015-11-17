#include "calculate_cc_coefficients.h"
#include "mex.h"

// void calculate_cc_coefficients (double* in, double* da) {
// 
//     double A    = in[0];
//     double B    = in[1];
//     double dy   = in[2];
//     double dz   = in[3];
//     double u    = in[4];
//     double v    = in[5];
//     double w    = in[6];
//     double z    = in[7];
// 
//     da[0] = v*z-v*dz+w*dy-z*dy+(1.00/2.00)*B*dy-(1.00/2.00)*B*v+A*z*dy-A*z*v;
//     da[1] = (1.00/2.00)*B*u+dz*u-z*u+A*z*u;
//     da[2] = -(1.00/2.00)*u*dy*B - A*z*u*dy;
//     
// }


void mexFunction (int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[]) {
    
    // check arguments
    if (nrhs!=1)
      mexErrMsgTxt("1 input required.");
    if (!mxIsDouble(prhs[0]) || mxGetM(prhs[0])!=1 || mxGetN(prhs[0])!=8)
      mexErrMsgTxt("Input must be a double 1x8 matrix.");

    // allocate output memory
    const int dims[] = {1,3};
    plhs[0] = mxCreateNumericArray(2,dims,mxDOUBLE_CLASS,mxREAL);
    
    // get pointer to data
    double* in  = (double*)mxGetPr(prhs[0]);
    double* out = (double*)mxGetPr(plhs[0]);
    
    calculate_cc_coefficients (in,out);
}
