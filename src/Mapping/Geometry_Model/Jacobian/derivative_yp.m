% Derivative of yp with respect to A; B; C; dy; dz; u; v; w;
function dy = derivative_yp (A, B, C, Cam, X, Xm, dzp, ind)

dC = Derivative_C_Mex([ A, B, C, Cam(2), Cam(3), X(1), X(2), X(3), Xm(3), ...
    dzp(1), dzp(2), dzp(3), dzp(4), dzp(5), dzp(6), dzp(7), dzp(8)]);

u=X(1); v=X(2); w=X(3);
dy=Cam(2); dz=Cam(3);
z=Xm(3);

c = calculate_cc_coefficientsMex ([A, B, dy, dz, u, v, w, z ]);  

[da, db, dc] = compute_abc (A, B, C, Cam, X, Xm(3), dC, dzp);

aa = c(1)^2+c(2)^2;
bb = 2*c(2)*c(3);
cc = c(3)^2+c(1)^2*(A*z^2+B*z-C);

sq = sqrt(bb^2-4*aa*cc);

if sq == 0
    dyda = -(1/2)*(-bb)/aa^2; 
    dydb = (1/2)*(-1)/aa;
    dydc = 0;
elseif ind == 1
    dyda = -cc/(sq*aa) - (1/2)*(-bb+sq)/aa^2; 
    dydb = (1/2)*(-1+bb/sq)/aa;
    dydc = -1/sq;
elseif ind == 2
    dyda = cc/(sq*aa) - (1/2)*(-bb-sq)/aa^2;
    dydb = (1/2)*(-1-bb/sq)/aa;
    dydc = 1/sq;
end

dydA  = dyda*da(1)+dydb*db(1)+dydc*dc(1);
dydB  = dyda*da(2)+dydb*db(2)+dydc*dc(2);
dydC  = dyda*da(3)+dydb*db(3)+dydc*dc(3);
dyddy = dyda*da(4)+dydb*db(4)+dydc*dc(4);
dyddz = dyda*da(5)+dydb*db(5)+dydc*dc(5);
dydu  = dyda*da(6)+dydb*db(6)+dydc*dc(6);
dydv  = dyda*da(7)+dydb*db(7)+dydc*dc(7);
dydw  = dyda*da(8)+dydb*db(8)+dydc*dc(8);

dy = [dydA, dydB, dydC, dyddy, dyddz, dydu, dydv, dydw];
end

function [da, db, dc] = compute_abc (A, B, E, Cam, X, z, dC, dzp)

[c1, c2, c3] = calculate_cc_coefficients (A, B, E, Cam, X, z );  

da(1) = 2*c1*dC(1,1) + 2*c2*dC(2,1);
da(2) = 2*c1*dC(1,2) + 2*c2*dC(2,2);
da(3) = 2*c1*dC(1,3) + 2*c2*dC(2,3);
da(4) = 2*c1*dC(1,4) + 2*c2*dC(2,4);
da(5) = 2*c1*dC(1,5) + 2*c2*dC(2,5);
da(6) = 2*c1*dC(1,6) + 2*c2*dC(2,6);
da(7) = 2*c1*dC(1,7) + 2*c2*dC(2,7);
da(8) = 2*c1*dC(1,8) + 2*c2*dC(2,8);

db(1) = 2*dC(2,1)*c3 + 2*c2*dC(3,1);
db(2) = 2*dC(2,2)*c3 + 2*c2*dC(3,2);
db(3) = 2*dC(2,3)*c3 + 2*c2*dC(3,3);
db(4) = 2*dC(2,4)*c3 + 2*c2*dC(3,4);
db(5) = 2*dC(2,5)*c3 + 2*c2*dC(3,5);
db(6) = 2*dC(2,6)*c3 + 2*c2*dC(3,6);
db(7) = 2*dC(2,7)*c3 + 2*c2*dC(3,7);
db(8) = 2*dC(2,8)*c3 + 2*c2*dC(3,8);

dc(1) = 2*c3*dC(3,1) + 2*c1*(A*z^2+B*z-E)*dC(1,1) + c1^2*(2*A*z*dzp(1) + z^2 + B*dzp(1) );
dc(2) = 2*c3*dC(3,2) + 2*c1*(A*z^2+B*z-E)*dC(1,2) + c1^2*(2*A*z*dzp(2) + z   + B*dzp(2) );
dc(3) = 2*c3*dC(3,3) + 2*c1*(A*z^2+B*z-E)*dC(1,3) + c1^2*(2*A*z*dzp(3)       + B*dzp(3) - 1 );
dc(4) = 2*c3*dC(3,4) + 2*c1*(A*z^2+B*z-E)*dC(1,4) + c1^2*(2*A*z*dzp(4)       + B*dzp(4) );
dc(5) = 2*c3*dC(3,5) + 2*c1*(A*z^2+B*z-E)*dC(1,5) + c1^2*(2*A*z*dzp(5)       + B*dzp(5) );
dc(6) = 2*c3*dC(3,6) + 2*c1*(A*z^2+B*z-E)*dC(1,6) + c1^2*(2*A*z*dzp(6)       + B*dzp(6) );
dc(7) = 2*c3*dC(3,7) + 2*c1*(A*z^2+B*z-E)*dC(1,7) + c1^2*(2*A*z*dzp(7)       + B*dzp(7) );
dc(8) = 2*c3*dC(3,8) + 2*c1*(A*z^2+B*z-E)*dC(1,8) + c1^2*(2*A*z*dzp(8)       + B*dzp(8) );

end

function diff = test_dC ( A, B, C, Cam, X, z, c1, c2, c3, dC)

psi = 10^(-8);
Apsi = A + psi;
Bpsi = B + psi;

[ a0, a1, a2, a3, a4, a5, a6, a7, a8] = calculate_polynom_cofficients (Apsi, B, C, Cam, X);
p = [ a8, a7, a6, a5, a4, a3, a2, a1, a0];
z_psi = roots(p);
[c1n, c2n, c3n] = calculate_cc_coefficients (Apsi, B, C, Cam, X, z_psi(1) );
abc1 = (c1n - c1)/psi;
abc2 = (c2n - c2)/psi;
abc3 = (c3n - c3)/psi;
diff(1,1) = abc1 - dC(1,1);
diff(2,1) = abc2 - dC(2,1);
diff(3,1) = abc3 - dC(3,1);

[ a0, a1, a2, a3, a4, a5, a6, a7, a8] = calculate_polynom_cofficients (A, Bpsi, C, Cam, X);
p = [ a8, a7, a6, a5, a4, a3, a2, a1, a0];
z_psi = roots(p);
[c1n, c2n, c3n] = calculate_cc_coefficients (A, Bpsi, C, Cam, X, z_psi(1) );
abc1 = (c1n - c1)/psi;
abc2 = (c2n - c2)/psi;
abc3 = (c3n - c3)/psi;
diff(1,2) = abc1 - dC(1,2);

end


