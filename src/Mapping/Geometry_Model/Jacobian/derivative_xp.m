% Derivative of xp with respect to A; B; C; dy; dz; u; v; w;
function dx = derivative_xp (A, B, C, yp, zp, dzp, dyp, ind, X, Cam)


if (sqrt(C - A*zp^2 - B*zp - yp^2) == 0)
    dx = [0, 0, 0, 0, 0, 0, 0, 0];
elseif ind == 1 || ind == 3
    % Derivative of xp with respect to A; B; C; dy; dz; u; v; w;
    dxp_dA  = 1/2 * (    - zp^2 - 2*A*zp*dzp(1)         - B*dzp(1)  - 2*yp*dyp(1)  ) / sqrt(C - A*zp^2 - B*zp - yp^2);
    dxp_dB  = 1/2 * (           - 2*A*zp*dzp(2) - zp    - B*dzp(2)  - 2*yp*dyp(2)  ) / sqrt(C - A*zp^2 - B*zp - yp^2);
    dxp_dC  = 1/2 * ( 1         - 2*A*zp*dzp(3)         - B*dzp(3)  - 2*yp*dyp(3)  ) / sqrt(C - A*zp^2 - B*zp - yp^2);
    dxp_ddy = 1/2 * (           - 2*A*zp*dzp(4)         - B*dzp(4)  - 2*yp*dyp(4)  ) / sqrt(C - A*zp^2 - B*zp - yp^2);
    dxp_ddz = 1/2 * (           - 2*A*zp*dzp(5)         - B*dzp(5)  - 2*yp*dyp(5)  ) / sqrt(C - A*zp^2 - B*zp - yp^2);
    dxp_du  = 1/2 * (           - 2*A*zp*dzp(6)         - B*dzp(6)  - 2*yp*dyp(6)  ) / sqrt(C - A*zp^2 - B*zp - yp^2);
    dxp_dv  = 1/2 * (           - 2*A*zp*dzp(7)         - B*dzp(7)  - 2*yp*dyp(7)  ) / sqrt(C - A*zp^2 - B*zp - yp^2);
    dxp_dw  = 1/2 * (           - 2*A*zp*dzp(8)         - B*dzp(8)  - 2*yp*dyp(8)  ) / sqrt(C - A*zp^2 - B*zp - yp^2);
    
    dx = [dxp_dA, dxp_dB, dxp_dC, dxp_ddy, dxp_ddz, dxp_du, dxp_dv, dxp_dw];
    
elseif ind == 2 || ind == 4
    % Derivative of xp with respect to A; B; C; dy; dz; u; v; w;
    dxp_dA  = - 1/2 * (    - zp^2 - 2*A*zp*dzp(1)         - B*dzp(1)  - 2*yp*dyp(1)  ) / sqrt(C - A*zp^2 - B*zp - yp^2);
    dxp_dB  = - 1/2 * (           - 2*A*zp*dzp(2) - zp    - B*dzp(2)  - 2*yp*dyp(2)  ) / sqrt(C - A*zp^2 - B*zp - yp^2);
    dxp_dC  = - 1/2 * ( 1         - 2*A*zp*dzp(3)         - B*dzp(3)  - 2*yp*dyp(3)  ) / sqrt(C - A*zp^2 - B*zp - yp^2);
    dxp_ddy = - 1/2 * (           - 2*A*zp*dzp(4)         - B*dzp(4)  - 2*yp*dyp(4)  ) / sqrt(C - A*zp^2 - B*zp - yp^2);
    dxp_ddz = - 1/2 * (           - 2*A*zp*dzp(5)         - B*dzp(5)  - 2*yp*dyp(5)  ) / sqrt(C - A*zp^2 - B*zp - yp^2);
    dxp_du  = - 1/2 * (           - 2*A*zp*dzp(6)         - B*dzp(6)  - 2*yp*dyp(6)  ) / sqrt(C - A*zp^2 - B*zp - yp^2);
    dxp_dv  = - 1/2 * (           - 2*A*zp*dzp(7)         - B*dzp(7)  - 2*yp*dyp(7)  ) / sqrt(C - A*zp^2 - B*zp - yp^2);
    dxp_dw  = - 1/2 * (           - 2*A*zp*dzp(8)         - B*dzp(8)  - 2*yp*dyp(8)  ) / sqrt(C - A*zp^2 - B*zp - yp^2);
    
    dx = [dxp_dA, dxp_dB, dxp_dC, dxp_ddy, dxp_ddz, dxp_du, dxp_dv, dxp_dw];
end

end

% alle Ableitung okay!!!
function test_dx ()

psi = 10^(-8);
Apsi = A + psi;
yp = 30*A+2;   dyp = 30;   ypA = 30*Apsi+2;
zp = -100*A^2+2; dzp = -200*A; zpA = -100*Apsi^2+2;
xp = sqrt(C - A*zp^2 - B*zp - yp^2);
xpA = sqrt(C - Apsi*zpA^2 - B*zpA - ypA^2);
dxp_d  =  1/2 * (    - zp^2 - 2*A*zp*dzp         - B*dzp  - 2*yp*dyp  ) / sqrt(C - A*zp^2 - B*zp - yp^2);
dxp_dA = (xpA - xp ) / psi;
diffA = (dxp_dA - dxp_d)

psi = 10^(-8);
Bpsi = B + psi;
yp = 30*B+2;        dyp = 30;       ypB = 30*Bpsi+2;
zp = -100*B^2+2;    dzp = -200*B;   zpB = -100*Bpsi^2+2;
xp = sqrt(C - A*zp^2 - B*zp - yp^2);
xpB = sqrt(C - A*zpB^2 - Bpsi*zpB - ypB^2);
dxp_d  =  1/2 * (           - 2*A*zp*dzp - zp    - B*dzp  - 2*yp*dyp  ) / sqrt(C - A*zp^2 - B*zp - yp^2);
dxp_dB = (xpB - xp ) / psi;
diffB = (dxp_dB - dxp_d)

psi = 10^(-8);
Cpsi = C + psi;
yp = 30*C+2;        dyp = 30;       ypC = 30*Cpsi+2;
zp = -100*C^2+2;    dzp = -200*C;   zpC = -100*Cpsi^2+2;
xp = sqrt(C - A*zp^2 - B*zp - yp^2);
xpC = sqrt(Cpsi - A*zpC^2 - B*zpC - ypC^2);
dxp_d  =   1/2 * ( 1         - 2*A*zp*dzp         - B*dzp  - 2*yp*dyp  ) / sqrt(C - A*zp^2 - B*zp - yp^2);
dxp_dC = (xpC - xp ) / psi;
diffC = (dxp_dC - dxp_d)

psi = 10^(-8);
dypsi = Cam(2) + psi; dy = Cam(2);
yp = 30*dy+2;        dyp = 30;       ypdy = 30*dypsi+2;
zp = -100*dy^2+2;    dzp = -200*dy;   zpdy = -100*dypsi^2+2;
xp = sqrt(C - A*zp^2 - B*zp - yp^2);
xpdy = sqrt(C - A*zpdy^2 - B*zpdy - ypdy^2);
dxp_d  =   1/2 * (           - 2*A*zp*dzp         - B*dzp  - 2*yp*dyp  ) / sqrt(C - A*zp^2 - B*zp - yp^2);
dxp_ddy = (xpdy - xp ) / psi;
diffdy = (dxp_ddy - dxp_d)

psi = 10^(-8);
dzpsi = Cam(3) + psi; dz = Cam(3);
yp = 30*dz+2;        dyp = 30;       ypdz = 30*dzpsi+2;
zp = -100*dz^2+2;    dzp = -200*dz;   zpdz = -100*dzpsi^2+2;
xp = sqrt(C - A*zp^2 - B*zp - yp^2);
xpdz = sqrt(C - A*zpdz^2 - B*zpdz - ypdz^2);
dxp_d  =   1/2 * (           - 2*A*zp*dzp         - B*dzp  - 2*yp*dyp  ) / sqrt(C - A*zp^2 - B*zp - yp^2);
dxp_ddz = (xpdz - xp ) / psi;
diffdz = (dxp_ddz - dxp_d)

psi = 10^(-8);
upsi = X(1) + psi; u = X(1);
yp = 30*u+2;        dyp = 30;       ypu = 30*upsi+2;
zp = -100*u^2+2;    dzp = -200*u;   zpu = -100*upsi^2+2;
xp = sqrt(C - A*zp^2 - B*zp - yp^2);
xpu = sqrt(C - A*zpu^2 - B*zpu - ypu^2);
dxp_d  =   1/2 * (           - 2*A*zp*dzp         - B*dzp  - 2*yp*dyp  ) / sqrt(C - A*zp^2 - B*zp - yp^2);
dxp_du = (xpu - xp ) / psi;
diffu = (dxp_du - dxp_d)

psi = 10^(-8);
vpsi = X(2) + psi; v = X(2);
yp = 30*v+2;        dyp = 30;       ypv = 30*vpsi+2;
zp = -100*v^2+2;    dzp = -200*v;   zpv = -100*vpsi^2+2;
xp = sqrt(C - A*zp^2 - B*zp - yp^2);
xpv = sqrt(C - A*zpv^2 - B*zpv - ypv^2);
dxp_d  =   1/2 * (           - 2*A*zp*dzp         - B*dzp  - 2*yp*dyp  ) / sqrt(C - A*zp^2 - B*zp - yp^2);
dxp_dv = (xpv - xp ) / psi;
diffv = (dxp_dv - dxp_d)

psi = 10^(-8);
wpsi = X(3) + psi; w = X(3);
yp = 30*w+2;        dyp = 30;       ypw = 30*wpsi+2;
zp = -100*w^2+2;    dzp = -200*w;   zpw = -100*wpsi^2+2;
xp = sqrt(C - A*zp^2 - B*zp - yp^2);
xpw = sqrt(C - A*zpw^2 - B*zpw - ypw^2);
dxp_d  =   1/2 * (           - 2*A*zp*dzp         - B*dzp  - 2*yp*dyp  ) / sqrt(C - A*zp^2 - B*zp - yp^2);
dxp_dw = (xpw - xp ) / psi;
diffw = (dxp_dw - dxp_d)
end
