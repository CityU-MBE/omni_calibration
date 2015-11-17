#include "computeDerivative.h"
#include "calculate_cc_coefficients.h"
#include "mex.h"
#include "math.h"

void calculate_derivative_abc (double* in, double* out) {
  
    double A    = in[0];
    double B    = in[1];
    double E    = in[2];
    double dy   = in[3];
    double dz   = in[4];
    double u    = in[5];
    double v    = in[6];
    double w    = in[7];
    double z    = in[8];
    
    double dzdA  = in[9];
    double dzdB  = in[10];
    double dzdC  = in[11];
    double dzddy = in[12];
    double dzddz = in[13];
    double dzdu  = in[14];
    double dzdv  = in[15];
    double dzdw  = in[16];
    
    double ind   = in[17];
      
    double in2[] = {A, B, dy, dz, u, v, w, z};
    double c [3];
    calculate_cc_coefficients (in2, c);  
    
    double dC [23];
    computeDerivative (in, dC);
    
    double da [23];
    // compute abc
    da[0] = 2*c[0]*dC[0]  + 2*c[1]*dC[1];
    da[1] = 2*c[0]*dC[3]  + 2*c[1]*dC[4];
    da[2] = 2*c[0]*dC[6]  + 2*c[1]*dC[7];
    da[3] = 2*c[0]*dC[9]  + 2*c[1]*dC[10];
    da[4] = 2*c[0]*dC[12] + 2*c[1]*dC[13];
    da[5] = 2*c[0]*dC[15] + 2*c[1]*dC[16];
    da[6] = 2*c[0]*dC[18] + 2*c[1]*dC[19];
    da[7] = 2*c[0]*dC[21] + 2*c[1]*dC[22];

    da[8]  = 2*dC[1] *c[2] + 2*c[1]*dC[2];
    da[9]  = 2*dC[4] *c[2] + 2*c[1]*dC[5];
    da[10] = 2*dC[7] *c[2] + 2*c[1]*dC[8];
    da[11] = 2*dC[10]*c[2] + 2*c[1]*dC[11];
    da[12] = 2*dC[13]*c[2] + 2*c[1]*dC[14];
    da[13] = 2*dC[16]*c[2] + 2*c[1]*dC[17];
    da[14] = 2*dC[19]*c[2] + 2*c[1]*dC[20];
    da[15] = 2*dC[22]*c[2] + 2*c[1]*dC[23];

    da[16] = 2*c[2]*dC[2]  + 2*c[0]*(A*z*z+B*z-E)*dC[0]  + c[0]*c[0]*(2*A*z*dzdA + z*z + B*dzdA );
    da[17] = 2*c[2]*dC[5]  + 2*c[0]*(A*z*z+B*z-E)*dC[3]  + c[0]*c[0]*(2*A*z*dzdB + z   + B*dzdB );
    da[18] = 2*c[2]*dC[8]  + 2*c[0]*(A*z*z+B*z-E)*dC[6]  + c[0]*c[0]*(2*A*z*dzdC       + B*dzdC - 1 );
    da[19] = 2*c[2]*dC[11] + 2*c[0]*(A*z*z+B*z-E)*dC[9]  + c[0]*c[0]*(2*A*z*dzddy      + B*dzddy );
    da[20] = 2*c[2]*dC[14] + 2*c[0]*(A*z*z+B*z-E)*dC[12] + c[0]*c[0]*(2*A*z*dzddz      + B*dzddz );
    da[21] = 2*c[2]*dC[17] + 2*c[0]*(A*z*z+B*z-E)*dC[15] + c[0]*c[0]*(2*A*z*dzdu       + B*dzdu );
    da[22] = 2*c[2]*dC[20] + 2*c[0]*(A*z*z+B*z-E)*dC[18] + c[0]*c[0]*(2*A*z*dzdv       + B*dzdv );
    da[23] = 2*c[2]*dC[23] + 2*c[0]*(A*z*z+B*z-E)*dC[21] + c[0]*c[0]*(2*A*z*dzdw       + B*dzdw );
    
    double aa = c[0]*c[0] + c[1]*c[1];
    double bb = 2*c[1]*c[2];
    double cc = c[2]*c[2] + c[0]*c[0]*(A*z*z + B*z - E);

    double sq = sqrt(bb*bb - 4*aa*cc);
    
    double dyda; double dydb; double dydc;

    if (sq == 0) {
        dyda = -(1.0/2.0)*(-bb)/(aa*aa); 
        dydb =  (1.0/2.0)*(-1)/aa;
        dydc = 0;
    } else if (ind == 1) {
        dyda = -cc/(sq*aa) - (1.0/2.0)*(-bb+sq)/(aa*aa); 
        dydb = (1.0/2.0)*(-1+bb/sq)/aa;
        dydc = -1/sq;
    } else if (ind == 2) {
        dyda = cc/(sq*aa) - (1.0/2.0)*(-bb-sq)/(aa*aa);
        dydb = (1.0/2.0)*(-1-bb/sq)/aa;
        dydc = 1/sq;
    }

//     out[0] = dyda;
//     out[1] = dydb;
//     out[2] = dydc;
    //dydA
    out[0] = dyda*da[0]+dydb*da[8] +dydc*da[16];
    //dydB
    out[1] = dyda*da[1]+dydb*da[9] +dydc*da[17];
    //dydC
    out[2] = dyda*da[2]+dydb*da[10]+dydc*da[18];
    //dyddy 
    out[3] = dyda*da[3]+dydb*da[11]+dydc*da[19];
    //dyddz 
    out[4] = dyda*da[4]+dydb*da[12]+dydc*da[20];
    //dydu 
    out[5] = dyda*da[5]+dydb*da[13]+dydc*da[21];
    // dydv
    out[6] = dyda*da[6]+dydb*da[14]+dydc*da[22];
    //dydw 
    out[7] = dyda*da[7]+dydb*da[15]+dydc*da[23];
    
}


void mexFunction (int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[]) {
    
    // check arguments
    if (nrhs!=1)
      mexErrMsgTxt("1 input required.");
    if (!mxIsDouble(prhs[0]) || mxGetM(prhs[0])!=1 || mxGetN(prhs[0])!=18)
      mexErrMsgTxt("Input must be a double 1x8 matrix.");

    // allocate output memory
    const int dims[] = {1,8};
    plhs[0] = mxCreateNumericArray(2,dims,mxDOUBLE_CLASS,mxREAL);
    
    // get pointer to data
    double* in  = (double*)mxGetPr(prhs[0]);
    double* out = (double*)mxGetPr(plhs[0]);
    
    calculate_derivative_abc (in,out);
}
