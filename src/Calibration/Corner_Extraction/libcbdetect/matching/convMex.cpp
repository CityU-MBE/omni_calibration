#include "mex.h"
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <iostream>

using namespace std;

void conv(double *I,double *T,double *C,const int *I_dims,const int *T_dims) {
  double eps = 10e-5;
  int iw = I_dims[1]; int ih = I_dims[0];
  int tw = T_dims[1]; int th = T_dims[0];
  int r = (tw-1)/2;
  
  int num = 0;
  double val = 0;
  for (int u=0; u<tw; u++) {
    for (int v=0; v<th; v++) {
      if (T[u*th+v]>eps) {
        num++;
        val = T[u*th+v];
      }
    }
  }
  
  int* offset = new int[num];
  
  int k=0;
  for (int u=0; u<tw; u++)
    for (int v=0; v<th; v++)
      if (T[u*th+v]>eps)
        offset[k++] = u*ih+v;

  for (int u=0; u<iw-tw+1; u++)
    for (int v=0; v<ih-th+1; v++)
      for (int k=0; k<num; k++)
        C[(u+r)*ih+(v+r)] += I[u*ih+v + offset[k]];

  for (int i=0; i<iw*ih; i++)
    C[i] *= val;

  delete offset;
}

// main function (input: MI,I1,I2,num_disp,outlier_penalty; output: C)
void mexFunction (int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[]) {

    // check for proper number of arguments
    if(nrhs!=2) 
        mexErrMsgTxt("2 input2 required (I,T).");
    if(nlhs!=1) 
        mexErrMsgTxt("1 output required (C).");  
    
    // check for proper argument types and sizes
    if(!mxIsDouble(prhs[0]) || mxGetNumberOfDimensions(prhs[0])!=2)
        mexErrMsgTxt("Input I must be a double image.");
    if(!mxIsDouble(prhs[1]) || mxGetNumberOfDimensions(prhs[1])!=2)
        mexErrMsgTxt("Input T must be a double image.");
    
    // dimensions
    const int *I_dims = mxGetDimensions(prhs[0]);
    const int *T_dims = mxGetDimensions(prhs[1]);
      
    // initialize output
    plhs[0] = mxCreateNumericArray(2,I_dims,mxDOUBLE_CLASS,mxREAL);
    
    // get pointers
    double* I = (double*)mxGetPr(prhs[0]);
    double* T = (double*)mxGetPr(prhs[1]);
    double* C = (double*)mxGetPr(plhs[0]);
    
    // do computation
    conv(I,T,C,I_dims,T_dims);
}
