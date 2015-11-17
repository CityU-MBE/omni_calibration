function cam = mirror_sphere_params ( cam, omni, KS, R, radius, xc, yc)

    e = sqrt(omni.a^2+omni.b^2);
    A = (-omni.b^2/omni.a^2);
    B = 0;
    C = (-omni.b^2);
    omni.e = e;

    cam.mir(1) = A;                                     
    cam.mir(2) = B;                                     
    cam.mir(3) = C;                                     
    cam.T     = [0.000001; 0.000001; -e];               

cam.k     = [0,0,0,0,0]; 
cam.alpha = 0;

cam.om    = [0,0,0];

cam.f         = [ 2*e / R*radius; 2*e / R*radius];
cam.c         = [xc; yc];

cam.omni      = omni;

end
