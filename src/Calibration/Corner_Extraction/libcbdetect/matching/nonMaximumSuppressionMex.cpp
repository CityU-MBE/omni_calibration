#include "mex.h"
#include <vector>
#include <iostream>

using namespace std;

struct maximum {
  int32_t maxi;
  int32_t maxj;
  double  maxval;
  maximum (int32_t i,int32_t j, double val) {
    maxi = i;
    maxj = j;
    maxval = val;
  }
};

vector<maximum> nonMaximumSuppression (double *img,const int32_t *dims,int32_t n,double tau,int32_t margin) {
  
  // vector containing the maxima
  vector<maximum> maxima;
  
  // extract parameters
  int32_t width  = dims[1];
  int32_t height = dims[0];
  
  // loop variables
  int32_t mini,minj,maxi,maxj;
  double maxval,currval;
  int32_t addr;
  
  for (int32_t i=n+margin; i<width-n-margin;i+=n+1) {
    for (int32_t j=n+margin; j<height-n-margin;j+=n+1) {

      mini = i; minj = j; maxi = i; maxj = j;
      
      addr   = i*height+j;
      maxval = *(img+addr);

      for (int32_t i2=i; i2<=i+n; i2++) {
        for (int32_t j2=j; j2<=j+n; j2++) {
          addr    = i2*height+j2;
          currval = *(img+addr);
          if (currval>maxval) {
            maxi   = i2;
            maxj   = j2;
            maxval = currval;
          }
        }
      }

      // maximum
      for (int32_t i2=maxi-n; i2<=min(maxi+n,width-1-margin); i2++) {
        for (int32_t j2=maxj-n; j2<=min(maxj+n,height-1-margin); j2++) {
          currval = *(img+i2*height+j2);
          if (currval>maxval && (i2<i || i2>i+n || j2<j || j2>j+n))
            goto failed;
        }
      }
      if (maxval>=tau)
        maxima.push_back(maximum(maxi,maxj,maxval));
      failed:;
    }
  }
  
  // return found maxima
  return maxima;
}

void mexFunction (int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[]) {

  // check for proper number of arguments
  if(nrhs!=4) 
    mexErrMsgTxt("4 inputs required (img,n,tau,margin).");
  if(nlhs!=1) 
    mexErrMsgTxt("One output required (maxima).");  

  // check for proper argument types and sizes
  if(!mxIsDouble(prhs[0]) || mxGetNumberOfDimensions(prhs[0])!=2)
    mexErrMsgTxt("Input img must be a double matrix.");
  if(!mxIsDouble(prhs[1]) || mxGetN(prhs[1])*mxGetM(prhs[1])!=1)
    mexErrMsgTxt("Input n must be a double scalar.");
  if(!mxIsDouble(prhs[2]) || mxGetN(prhs[2])*mxGetM(prhs[2])!=1)
    mexErrMsgTxt("Input tau must be a double scalar.");
  if(!mxIsDouble(prhs[3]) || mxGetN(prhs[3])*mxGetM(prhs[3])!=1)
    mexErrMsgTxt("Input margin must be a double scalar.");

  // get pointers
  double* img         =   (double*)mxGetPr(prhs[0]);
  const int32_t *dims =    mxGetDimensions(prhs[0]);
  int32_t  n          = *((double*)mxGetPr(prhs[1]));
  double   tau        = *((double*)mxGetPr(prhs[2]));
  int32_t  margin     = *((double*)mxGetPr(prhs[3]));
   
  // do computation
  vector<maximum> maxima = nonMaximumSuppression(img,dims,n,tau,margin);
  
  // create output matrix planes and get pointer
  const int maxima_dims[] = {maxima.size(),3};
  plhs[0] = mxCreateNumericArray(2,maxima_dims,mxDOUBLE_CLASS,mxREAL);
  double* maxima_mex = (double*)mxGetPr(plhs[0]);
  int32_t k=0;
  for (int32_t i=0; i<maxima.size(); i++) {
    maxima_mex[0*maxima.size()+i] = maxima[i].maxi+1; // MATLAB indices
    maxima_mex[1*maxima.size()+i] = maxima[i].maxj+1; // MATLAB indices 
    maxima_mex[2*maxima.size()+i] = maxima[i].maxval;
  }    
}
