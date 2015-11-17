#include "mex.h"
#include "iostream"
#include <opencv2/opencv.hpp>
#include <opencv2/calib3d/calib3d.hpp>

void rodrigues ( double* in, double* out) {
 
    cv::Mat in_Mat = (cv::Mat_<double>(3,1) << in[0], in[1], in[2]);
    
    cv::Mat out_Mat;
    cv::Mat out_Mat2;
        
    cv::Rodrigues( in_Mat, out_Mat, out_Mat2 );
    
    for ( int i = 0; i < 3; i++ ) {
        for ( int j = 0; j < 3; j++) {
           
            out[j+12*i] = out_Mat.at<double>(j,i);
        }
    }
    
    for (int i = 0; i < 3; i++ )
        for ( int j = 0; j < 9; j++)
            
            out[j+3+12*i] = out_Mat2.at<double>(i,j);
}


void mexFunction (int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[]) {
    
    // check arguments
    if (nrhs!=1)
      mexErrMsgTxt("1 input required.");
    if (!mxIsDouble(prhs[0]) || mxGetM(prhs[0])!=1 || mxGetN(prhs[0])!=3)
      mexErrMsgTxt("Input must be a double 1x8 matrix.");

    // allocate output memory
    const int dims[] = {12,3};
    plhs[0] = mxCreateNumericArray(2,dims,mxDOUBLE_CLASS,mxREAL);
    
    // get pointer to data
    double* in   = (double*)mxGetPr(prhs[0]);
    double* out  = (double*)mxGetPr(plhs[0]);
    
    rodrigues (in,out);
}