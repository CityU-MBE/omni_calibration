#include "computeDerivative.h"
// #include "mex.h"
// #include "math.h"

// calculate the derivative of the functions c1, c2, c3 
// dc1 / dc2 / dc3 with respect to A	(da[0]  / da[1]  / da[2])
// dc1 / dc2 / dc3 with respect to B	(da[3]  / da[4]  / da[5])
// dc1 / dc2 / dc3 with respect to C	(da[6]  / da[7]  / da[8])
// dc1 / dc2 / dc3 with respect to dy	(da[9]  / da[10] / da[11])
// dc1 / dc2 / dc3 with respect to dz	(da[12] / da[13] / da[14])
// dc1 / dc2 / dc3 with respect to u	(da[15] / da[16] / da[17])
// dc1 / dc2 / dc3 with respect to v	(da[18] / da[19] / da[20])
// dc1 / dc2 / dc3 with respect to w	(da[21] / da[22] / da[23])

void computeDerivative (double* in, double* da) {

    double A    = in[0];
    double B    = in[1];
    double D    = in[2];
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

    da[0] = v*dzdA - dy*dzdA + z*dy + A*dy*dzdA - v*z - A*v*dzdA;
    da[1] = -u*dzdA + z*u + A*u*dzdA;
    da[2] = - z*u*dy - A*u*dy*dzdA;
 
    da[3] = v*dzdB - dy*dzdB + 1/2*dy - 1/2*v + A*dy*dzdB - A*v*dzdB;
    da[4] = 1/2*u - u*dzdB + A*u*dzdB;
    da[5] = - 1/2*u*dy - A*u*dy*dzdB;
 
	da[6] = v*dzdC - dy*dzdC + A*dy*dzdC - A*v*dzdC;
	da[7] = - u*dzdC + A*u*dzdC;
	da[8] = - A*u*dy*dzdC;
 
	da[9]  = v*dzddy + w - dzddy*dy - z + 1/2*B + A*dzddy*dy + A*z - A*dzddy*v;
	da[10] = -dzddy*u + A*dzddy*u;
	da[11] = - 1/2*B*u - A*dzddy*u*dy - A*z*u;
 
	da[12] = v*dzddz - v - dzddz*dy + A*dzddz*dy - A*dzddz*v;
	da[13] = u - dzddz*u + A*dzddz*u;
	da[14] = - A*dzddz*u*dy;
 
	da[15] = v*dzdu - dzdu*dy + A*dzdu*dy - A*dzdu*v;
	da[16] = 1/2*B + dz - dzdu*u - z + A*dzdu*u + A*z;
	da[17] = - 1/2*B*dy - A*dzdu*u*dy - A*z*dy;
 
	da[18] = z + v*dzdv - dz - dzdv*dy - 1/2*B + A*dzdv*dy - A*dzdv*v - A*z;
	da[19] = -dzdv*u + A*dzdv*u;
	da[20] = - A*dzdv*u*dy;
 
	da[21] = v*dzdw + dy - dzdw*dy + A*dzdw*dy - A*dzdw*v;
	da[22] = -dzdw*u + A*dzdw*u;
	da[23] = - A*dzdw*u*dy;         
}

