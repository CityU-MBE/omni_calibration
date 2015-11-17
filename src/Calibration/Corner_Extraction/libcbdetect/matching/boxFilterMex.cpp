#include "mex.h"

#include <vector>
#include <iostream>
#include <stdlib.h>
#include <stdint.h>

using namespace std;

inline int getAddressOffset (int32_t u,int32_t v,int32_t height) {
  return u*height+v;
}

// get response from integral image
inline double getSumFromIntegralImage (double *img_integral,int32_t height,int32_t u1,int32_t u2,int32_t v1,int32_t v2) {
  double          sum  = *(img_integral+getAddressOffset(u2,v2,height));
  if (u1>0)       sum -= *(img_integral+getAddressOffset(u1-1,v2,height));
  if (v1>0)       sum -= *(img_integral+getAddressOffset(u2,v1-1,height));
  if (v1>0&&u1>0) sum += *(img_integral+getAddressOffset(u1-1,v1-1,height));
  return sum;
}

// create integral image
void createIntegralImage(double *I, double *I_integral,const int *dims) {
    
  // extract image width and height and number of disparities
  const int width  = dims[1];
  const int height = dims[0];

  double *S = (double*)calloc(height*width,sizeof(double));

  int32_t addr_u_v;
  int32_t addr_u1_v;
  int32_t addr_u_v1;

  // for all pixels do
  for (int u=0; u<width; u++) {
    for (int v=0; v<height; v++) {

      addr_u_v = getAddressOffset(u,v,height);
      
      // S(v,u) = I(v,u);
      if (u==0) {
        *(S+addr_u_v) = *(I+addr_u_v);

      // S(v,u) = S(v,u-1) + I(v,u);
      } else {
        addr_u1_v = getAddressOffset(u-1,v,height);
        *(S+addr_u_v) = *(S+addr_u1_v) + *(I+addr_u_v);
      }

      // I_integral(v,u) = S(v,u);
      if (v==0) {
        *(I_integral+addr_u_v) = *(S+addr_u_v);

      // I_integral(v,u) = I_integral(v-1,u) + S(v,u);
      } else {
        addr_u_v1 = getAddressOffset(u,v-1,height);
        *(I_integral+addr_u_v) = *(I_integral+addr_u_v1) + *(S+addr_u_v);                
      }
    }
  }
  free(S);
}

void boxFilter (double *img,double *box,const int32_t *dims,int32_t radius) {
  
  const int width  = dims[1];
  const int height = dims[0];
  
  double *img_integral = (double*)calloc(width*height,sizeof(double));
  
  createIntegralImage(img,img_integral,dims);
  
  // for all pixels do
  for (int32_t u=0; u<width; u++) {
    for (int32_t v=0; v<height; v++) {
      int32_t u1 = max(u-radius,0);
      int32_t u2 = min(u+radius,width-1);
      int32_t v1 = max(v-radius,0);
      int32_t v2 = min(v+radius,height-1);
      double sum = getSumFromIntegralImage(img_integral,height,u1,u2,v1,v2);
      *(box+getAddressOffset(u,v,height)) = sum/(double)((u2-u1+1)*(v2-v1+1));
    }
  }
  
  free(img_integral);
}

void mexFunction (int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[]) {

  // check for proper number of arguments
  if(nrhs!=2) 
    mexErrMsgTxt("2 inputs required (img,radius).");
  if(nlhs!=1) 
    mexErrMsgTxt("One output required (box).");  

  // check for proper argument types and sizes
  if(!mxIsDouble(prhs[0]) || mxGetNumberOfDimensions(prhs[0])!=2)
    mexErrMsgTxt("Input img must be a double matrix.");
  if(!mxIsDouble(prhs[1]) || mxGetN(prhs[1])*mxGetM(prhs[1])!=1)
    mexErrMsgTxt("Input radius must be a double scalar.");
  
  // get pointers
  double* img         =   (double*)mxGetPr(prhs[0]);
  const int32_t *dims =    mxGetDimensions(prhs[0]);
  int32_t  radius     = *((double*)mxGetPr(prhs[1]));
  
  // create output
  plhs[0] = mxCreateNumericArray(2,dims,mxDOUBLE_CLASS,mxREAL);
  double* box = (double*)mxGetPr(plhs[0]);
   
  // do computation
  boxFilter(img,box,dims,radius);
}
