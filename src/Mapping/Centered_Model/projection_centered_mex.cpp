#include "mex.h"
#include <math.h>

void projection_centered(double* p,double* q,int num,double* v,double* x) {
  
  double vx = v[0];
  double vy = v[1];
  double vz = v[2];
  
  double cu = x[0];
  double cv = x[1];
  double x0 = x[2];
  double x1 = x[3];
  double x2 = x[4];
  double x3 = x[5];
  
  int kp=0;
  int kq=0;
  for (int i=0; i<num; i++) {
    
    double wx = p[kp++];
    double wy = p[kp++];
    double wz = p[kp++];
    
    double a1 = atan(wz/sqrt(wx*wx+wy*wy));
    double a2 = atan2(wy,wx);
    
//     double da1dx = -wz*wx /( pow( wx*wx + wy*wy ,(3.0/2.0)) * ( 1 + ( wz*wz ) / ( wx*wx + wy*wy ) ) );
// 	double da1dy = -wz*wy /( pow( wx*wx + wy*wy ,(3.0/2.0)) * ( 1 + ( wz*wz ) / ( wx*wx + wy*wy ) ) );
// 	double da1dz = 1 / ( sqrt( wx*wx + wy*wy )              * ( 1 + ( wz*wz ) / ( wx*wx + wy*wy ) ) );
//     
// 	double da2dx = -wy / ( wx*wx * ( 1 + ((wy*wy) / (wx*wx)) ) );
//     double da2dy = 1   / ( wx    * ( 1 + ((wy*wy) / (wx*wx)) ) );
//     double da2dz = 0;
    
    double r = x0+x1*a1+x2*a1*a1+x3*a1*a1*a1;
    
//     double drda1 = x1 + 2*x2*a1 + 3*x3*a1*a1;
        
    q[kq++] = cu + r*cos(a2);
    q[kq++] = cv + r*sin(a2);
//     q[8*i]   = cu + r*cos(a2);
//     q[8*i+1] = cv + r*sin(a2);
    
//     double duda1 = drda1 * cos(a2);
//     double duda2 = - r * sin(a2);
//     double dvda1 = drda1 * sin(a2);
//     double dvda2 = r * cos(a2);
//     
//     double dudx = duda1 * da1dx + duda2 * da2dx;
//     double dudy = duda1 * da1dy + duda2 * da2dy;
//     double dudz = duda1 * da1dz + duda2 * da2dz;
//     
//     double dvdx = dvda1 * da1dx + dvda2 * da2dx;
//     double dvdy = dvda1 * da1dy + dvda2 * da2dy;
//     double dvdz = dvda1 * da1dz + dvda2 * da2dz;
//     
//     q[8*i+2] = dudx;
//     q[8*i+3] = dvdx;
//     q[8*i+4] = dudy;
//     q[8*i+5] = dvdy;
//     q[8*i+6] = dudz;
//     q[8*i+7] = dvdz;
    
    
  }
}

void mexFunction (int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[]) {
    
    // check arguments
    if (nrhs!=3)
      mexErrMsgTxt("3 inputs and required (p,vp,param).");
    if (!mxIsDouble(prhs[0]) || mxGetM(prhs[0])!=3)
      mexErrMsgTxt("Input must be a double 3xN matrix.");

    // allocate output memory
    int num = mxGetN(prhs[0]);
    const int dims[] = {2,num};
    plhs[0] = mxCreateNumericArray(2,dims,mxDOUBLE_CLASS,mxREAL);
    
    // get pointer to data
    double* p = (double*)mxGetPr(prhs[0]);
    double* v = (double*)mxGetPr(prhs[1]);
    double* x = (double*)mxGetPr(prhs[2]);
    double* q = (double*)mxGetPr(plhs[0]);
    
    // project points
    projection_centered(p,q,num,v,x);
}
