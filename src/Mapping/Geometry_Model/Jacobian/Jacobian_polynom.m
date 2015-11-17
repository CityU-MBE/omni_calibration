function [dxp, dyp, dzp] = Jacobian_polynom (X, Cam, A, B, C, Xm, p, ind)
 
%[Xm, p] = Mapping_AFP (X, Cam, A, B, C, f, xc, yc);

dzp = derivative_zp (A, B, C, Cam, X, Xm, p);
dzp = -dzp;

dyp = calculate_derivative_abcMex ([ A, B, C, Cam(2), Cam(3), X(1), X(2), X(3), Xm(3), dzp(1), dzp(2), dzp(3), dzp(4), dzp(5), dzp(6), dzp(7), dzp(8), ind(1)]);
dxp = derivative_xp (A, B, C, Xm(2), Xm(3), dzp, dyp, ind(2), X, Cam);

%[diff, diffR] = test_Jacobian_A ( A, B, C, Cam, X, Xm, dxp, dyp, dzp);

end

%%%%% TEST %%%%%%
function [diff, diffR] = test_Jacobian_A ( A, B, C, Cam, X, Xm, dxp, dyp, dzp)

	psi = 10^(-6);
    
    %% Vgl Ableitung nach A
    Apsi = A + psi;
    XmA = Mapping_AFP (X, Cam, Apsi, B, C);
    
    abz = (XmA(3) - Xm(3))/psi;
    diff(1,1) = abz - dzp(1);
    diffR(1,1) = (abz - dzp(1)) / dzp(1);

    aby = (XmA(2) - Xm(2))/psi;
    diff(1,2) = aby - dyp(1);
    diffR(1,2) = (aby - dyp(1)) / dyp(1);

    abx = (XmA(1) - Xm(1))/psi;
    diff(1,3) = abx - dxp(1);
    diffR(1,3) = (abx - dxp(1)) / dxp(1);

    %% Vgl Ableitung nach B
    Bpsi = B + psi;
    XmB = Mapping_AFP (X, Cam, A, Bpsi, C);
    
    abz = (XmB(3) - Xm(3))/psi;
    diff(2,1) = abz - dzp(2);
    diffR(2,1) = (abz - dzp(2)) / dzp(2);

    aby = (XmB(2) - Xm(2))/psi;
    diff(2,2) = aby - dyp(2);
    diffR(2,2) = (aby - dyp(2)) / dyp(2);

    abx = (XmB(1) - Xm(1))/psi;
    diff(2,3) = abx - dxp(2);
    diffR(2,3) = (abx - dxp(2)) / dxp(2);
    
    %% Vgl Ableitung nach C
    Cpsi = C + psi;
    XmC = Mapping_AFP (X, Cam, A, B, Cpsi);
    
    abz = (XmC(3) - Xm(3))/psi;
    diff(3,1) = abz - dzp(3);
    diffR(3,1) = (abz - dzp(3)) / dzp(3);

    aby = (XmC(2) - Xm(2))/psi;
    diff(3,2) = aby - dyp(3);
    diffR(3,2) = (aby - dyp(3)) / dyp(3);

    abx = (XmC(1) - Xm(1))/psi;
    diff(3,3) = abx - dxp(3);
    diffR(3,3) = (abx - dxp(3)) / dxp(3);
    
    %% Vgl Ableitung nach dy
    dypsi = Cam(2) + psi;
    Xmdy = Mapping_AFP (X, [0;dypsi;Cam(3)], A, B, C);
    
    abz = (Xmdy(3) - Xm(3))/psi;
    diff(4,1) = abz - dzp(4);
    diffR(4,1) = (abz - dzp(4)) / dzp(4);

    aby = (Xmdy(2) - Xm(2))/psi;
    diff(4,2) = aby - dyp(4);
    diffR(4,2) = (aby - dyp(4)) / dyp(4);
    
    abx = (Xmdy(1) - Xm(1))/psi;
    diff(4,3) = abx - dxp(4);
    diffR(4,3) = (abx - dxp(4)) / dxp(4);

    %% Vgl Ableitung nach dz
    dzpsi = Cam(3) + psi;
    Xmdz = Mapping_AFP (X, [0;Cam(2);dzpsi], A, B, C);
    
    abz = (Xmdz(3) - Xm(3))/psi;
    diff(5,1) = abz - dzp(5);
    diffR(5,1) = (abz - dzp(5)) / dzp(5);

    aby = (Xmdz(2) - Xm(2))/psi;
    diff(5,2) = aby - dyp(5);
    diffR(5,2) = (aby - dyp(5)) / dyp(5);

    abx = (Xmdz(1) - Xm(1))/psi;
    diff(5,3) = abx - dxp(5);
    diffR(5,3) = (abx - dxp(5)) / dxp(5);
    
    %% Vgl Ableitung nach u
    upsi = X(1) + psi;
    Xmu = Mapping_AFP ([upsi;X(2);X(3)], Cam, A, B, C);
    
    abz = (Xmu(3) - Xm(3))/psi;
    diff(6,1) = abz - dzp(6);
    diffR(6,1) = (abz - dzp(6)) / dzp(6);

    aby = (Xmu(2) - Xm(2))/psi;
    diff(6,2) = aby - dyp(6);
    diffR(6,2) = (aby - dyp(6)) / dyp(6);

    abx = (Xmu(1) - Xm(1))/psi;
    diff(6,3) = abx - dxp(6);
    diffR(6,3) = (abx - dxp(6)) / dxp(6);

    %% Vgl Ableitung nach v
    vpsi = X(2) + psi;
    Xmv = Mapping_AFP ([X(1);vpsi;X(3)], Cam, A, B, C);
    
    abz = (Xmv(3) - Xm(3))/psi;
    diff(7,1) = abz - dzp(7);
    diffR(7,1) = (abz - dzp(7)) / dzp(7);

    aby = (Xmv(2) - Xm(2))/psi;
    diff(7,2) = aby - dyp(7);
    diffR(7,2) = (aby - dyp(7)) / dyp(7);

    abx = (Xmv(1) - Xm(1))/psi;
    diff(7,3) = abx - dxp(7);
    diffR(7,3) = (abx - dxp(7)) / dxp(7);

    %% Vgl Ableitung nach w
    wpsi = X(3) + psi;
    Xmw = Mapping_AFP ([X(1);X(2);wpsi], Cam, A, B, C);
    
    abz = (Xmw(3) - Xm(3))/psi;
    diff(8,1) = abz - dzp(8);
    diffR(8,1) = (abz - dzp(8)) / dzp(8);

    aby = (Xmw(2) - Xm(2))/psi;
    diff(8,2) = aby - dyp(8);
    diffR(8,2) = (aby - dyp(8)) / dyp(8);

    abx = (Xmw(1) - Xm(1))/psi;
    diff(8,3) = abx - dxp(8);
    diffR(8,3) = (abx - dxp(8)) / dxp(8);
% 
% figure(3);
% hold on;
% plot(abs(diff),'r-');

end
