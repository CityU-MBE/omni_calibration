#include "calculate_cc_coefficients.h"

void calculate_cc_coefficients (double* in, double* da) {

    double A    = in[0];
    double B    = in[1];
    double dy   = in[2];
    double dz   = in[3];
    double u    = in[4];
    double v    = in[5];
    double w    = in[6];
    double z    = in[7];

    da[0] = v*z-v*dz+w*dy-z*dy+(1.00/2.00)*B*dy-(1.00/2.00)*B*v+A*z*dy-A*z*v;
    da[1] = (1.00/2.00)*B*u+dz*u-z*u+A*z*u;
    da[2] = -(1.00/2.00)*u*dy*B - A*z*u*dy;
    
}

