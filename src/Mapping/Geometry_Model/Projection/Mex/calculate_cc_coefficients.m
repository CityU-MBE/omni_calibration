function [c1, c2, c3] = calculate_cc_coefficients (A, B, C, Cam, P, z)

u = P(1,:);
v = P(2,:);
w = P(3,:);

dy = Cam(2,:);
dz = Cam(3,:);

% c1 = (B + 2*A*z)*(dy-v) + 2*dy*(w-z) + 2*v*(z-dz);
% c2 = u*(B + 2*dz - 2*z + 2*A*z);
% c3 = -u*dy*(B + 2*A*z);

c1 = v*z-v*dz+w*dy-z*dy+(1/2)*B*dy-(1/2)*B*v+A*z*dy-A*z*v;
c2 = (1/2)*B*u+dz*u-z*u+A*z*u;
c3 = -(1/2)*u*dy*B - A*z*u*dy;

end