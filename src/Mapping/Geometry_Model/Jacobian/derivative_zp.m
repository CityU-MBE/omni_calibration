function dz = derivative_zp (A, B, C, Cam, X, Xm, p)

% Achtung:
% poly = a8*x^8 + a7*x^7 + a6*x^6 + a5*x^5 + a4*x^4 + a3*x^3 + a2*x^2 +
% a1*x + a0
% p = [a8, a7, a6, a5, a4, a3, a2, a1, a0]
% aus Mex kommt aber a = [ a0, a1, a2, a3, a4, a5, a6, a7, a8]
% UND
%
% da = [da0 da1 da2 da3 da4 da5 da6 da7 da8]
% da8 = da(:,9)
% da0 = da(:,1)

% Derivative of zp
da = DerivativeMexFloat([A, B, C, Cam(2), Cam(3), X(1), X(2), X(3)]);
%da = DerivativeMex([A, B, C, Cam(2), Cam(3), X(1), X(2), X(3)]);

%test_da (p, da, A, B, C, Cam, X) 

% Derivation of zp with respect to A; B; C; dy; dz; u; v; w;
dzp_dA = derivate_of_root_function  (da, p, 1, Xm(3));
dzp_dB = derivate_of_root_function  (da, p, 2, Xm(3));
dzp_dC = derivate_of_root_function  (da, p, 3, Xm(3));
dzp_ddy = derivate_of_root_function (da, p, 4, Xm(3));
dzp_ddz = derivate_of_root_function (da, p, 5, Xm(3));
dzp_du = derivate_of_root_function  (da, p, 6, Xm(3));
dzp_dv = derivate_of_root_function  (da, p, 7, Xm(3));
dzp_dw = derivate_of_root_function  (da, p, 8, Xm(3));

dz = [dzp_dA, dzp_dB, dzp_dC, dzp_ddy, dzp_ddz, dzp_du, dzp_dv, dzp_dw];

end

% compute derivative of z
function [df] = derivate_of_root_function (da, a, ind, z)

    %da_u = [da8_u; da7_u; da6_u; da5_u; da4_u; da3_u; da2_u; da1_u; da0_u];
    da_u = [da(ind,9),da(ind,8),da(ind,7),da(ind,6),da(ind,5),da(ind,4),da(ind,3),da(ind,2),da(ind,1)];

    %f = a8*z^8 + a7*z^7 + a6*z^6 + a5*z^5 + a4*z^4 + a3*z^3 + a2*z^2 + a1*z + a0;
    df = ( da_u(1)*z^8 + da_u(2)*z^7 + da_u(3)*z^6 + da_u(4)*z^5 + da_u(5)*z^4 + da_u(6)*z^3 + da_u(7)*z^2 + da_u(8)*z + da_u(9) ) / ...
        ( 8*a(1)*z^7 + 7*a(2)*z^6 + 6*a(3)*z^5 + 5*a(4)*z^4 + 4*a(5)*z^3 + 3*a(6)*z^2 + 2*a(7)*z + a(8) );
    
end

function test_da (p, da, A, B, C, Cam, X) 

psi = 10^(-8);
Apsi  = A + psi;
Bpsi  = B + psi;
Cpsi  = C + psi;
dypsi = Cam(2) + psi;
dzpsi = Cam(3) + psi;
upsi  = X(1) + psi;
vpsi  = X(2) + psi;
wpsi  = X(3) + psi;

a = CalculatePolynomialCoefficientsMex([Apsi, B, C, Cam(2), Cam(3), X(1), X(2), X(3)]);
q = a(end:-1:1);
for i = 1:9
    ddA(1,i) = (p(i)-q(i))/(10^(-8))
    diffA(1,i) = ddA(1,i) + da(1,10-i)
end

a = CalculatePolynomialCoefficientsMex([A, Bpsi, C, Cam(2), Cam(3), X(1), X(2), X(3)]);
q = a(end:-1:1);
for i = 1:9
    ddB(1,i) = (p(i)-q(i))/(10^(-8))
    diffB(1,i) = ddB(1,i) + da(2,10-i)
end

a = CalculatePolynomialCoefficientsMex([A, B, Cpsi, Cam(2), Cam(3), X(1), X(2), X(3)]);
q = a(end:-1:1);
for i = 1:9
    ddC(1,i) = (p(i)-q(i))/(10^(-8))
    diffC(1,i) = ddC(1,i) + da(3,10-i)
end

a = CalculatePolynomialCoefficientsMex([A, B, C, dypsi, Cam(3), X(1), X(2), X(3)]);
q = a(end:-1:1);
for i = 1:9
    dddy(1,i) = (p(i)-q(i))/(10^(-8))
    diffdy(1,i) = dddy(1,i) + da(4,10-i)
end

a = CalculatePolynomialCoefficientsMex([A, B, C, Cam(2), dzpsi, X(1), X(2), X(3)]);
q = a(end:-1:1);
for i = 1:9
    dddz(1,i) = (p(i)-q(i))/(10^(-8))
    diffdz(1,i) = dddz(1,i) + da(5,10-i)
end

a = CalculatePolynomialCoefficientsMex([A, B, C, Cam(2), Cam(3), upsi, X(2), X(3)]);
q = a(end:-1:1);
for i = 1:9
    ddu(1,i) = (p(i)-q(i))/(10^(-8))
    diffu(1,i) = ddu(1,i) + da(6,10-i)
end

a = CalculatePolynomialCoefficientsMex([A, B, C, Cam(2), Cam(3), X(1), vpsi, X(3)]);
q = a(end:-1:1);
for i = 1:9
    ddv(1,i) = (p(i)-q(i))/(10^(-8))
    diffv(1,i) = ddv(1,i) + da(7,10-i)
end

a = CalculatePolynomialCoefficientsMex([A, B, C, Cam(2), Cam(3), X(1), X(2), wpsi]);
q = a(end:-1:1);
for i = 1:9
    ddw(1,i) = (p(i)-q(i))/(10^(-8))
    diffw(1,i) = ddw(1,i) + da(8,10-i)
end

end