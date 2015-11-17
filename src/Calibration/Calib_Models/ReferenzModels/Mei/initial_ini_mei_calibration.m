function [cam, active, Jacob] = initial_ini_mei_calibration ( images, param, active, without_k, omni, info)

if nargin == 3
    without_k = 0;
end

nM = (info.n_sq_x+1)*(info.n_sq_y+1);

if without_k == 1
    
    number_inis = 5;	% number of initial parameter to calibrate for numeric Jacobian
    Jacob = calc_JacobianPattern ( param.calib, number_inis, images, 6, nM);

    for c = 1 : size(images,2)
                
        active.cam{c}.xi       = 1;
        active.cam{c}.kc       = [0 0 0 0 0];
        active.cam{c}.gammac   = [1 1];
        active.cam{c}.cc       = [1 1];
        active.cam{c}.alphac   = 0;
        
        if c == 1
            active.cam{c}.ex_T  = [0 0 0];
            active.cam{c}.ex_om = [0 0 0];
        else        
            active.cam{c}.ex_T  = [1 1 1];
            active.cam{c}.ex_om = [1 1 1]; 
        end
    end
    
else
    number_inis = 9;	% number of initial parameter to calibrate for numeric Jacobian
    Jacob = calc_JacobianPattern ( param.calib, number_inis, images, 6, nM);

    for c = 1 : size(images,2)
        active.cam{c}.xi       = 1;
        active.cam{c}.kc       = [1 1 1 1 0];
        active.cam{c}.gammac   = [1 1];
        active.cam{c}.cc       = [1 1];
        active.cam{c}.alphac   = 0;
        if c == 1
            active.cam{c}.ex_T  = [0 0 0];
            active.cam{c}.ex_om = [0 0 0];
        else        
            active.cam{c}.ex_T  = [1 1 1];
            active.cam{c}.ex_om = [1 1 1]; 
        end
    end
end

% mirror params
a = omni.a;
b = omni.b;
e = sqrt(a^2+b^2);
p = b^2/(2*a);
d = 2*e;

for c = 1 : length(param.cam)
    
    f = param.cam{c}.f;

    gamma_ini = 2*p*f / sqrt(d^2+4*p^2);
    xi_ini = d / sqrt(d^2+4*p^2);

    cam{c}.xi = xi_ini;
    cam{c}.gammac = gamma_ini';
    %cam{c}.gammac(2) = -cam{c}.gammac(1);
    
    % principal point very important for the optimization
    cam{c}.cc = param.cam{c}.c';
    cam{c}.kc = [ 0 0 0 0 0];
    cam{c}.alphac = 0;
    
    cam{c}.ex_T  = param.cam{c}.ex_T;
    cam{c}.ex_om = param.cam{c}.ex_om;
    
    cam{c}.omni = param.cam{c}.omni;


end


