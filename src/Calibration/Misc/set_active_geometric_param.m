% Load all active parameters and the Jacobian Pattern
% Input:
% - images
% - method = calibration method
% - params = initial params from config
% Output:
% - active = array with active and non active parameters (boards and cams
% (for method 1-10))
% - Jcaob = Jacobian pattern

function [ active, Jacob ] = set_active_geometric_param (images, method, params, active, info)

if (method <= 10)  
    
    hyperbol=2; % only with coordinate system 2
    [active, Jacob] = load_calib_model ( images, method, hyperbol, params, active, info );

else
    
    Jacob = 0;
    
end


end

%%%%%%%%%%% Calibration Profils %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  1:  Calib A     - SVP Model
%%%  2:  Calib A1    - SVP Model        with k1 - k4
%%%  3:  Calib B     - without A B C
%%%  4:  Calib B1    - without A B C    with k1 - k4
%%%  5:  Calib B2    - without A B C    with k1 k2
%%%  6:  Calib C     - without T3   
%%%  7:  Calib C1    - without T3       with k1 - k4
%%%  8:  Calib C2    - without T3       with k1 k2
%%%  9:  Calib D     - all              without k
%%% 10:  Calib D     - all + k1 - k4
%%% 11:  Scaramuzza Calibration
%%% 12:  Mei Calibration

function [active, Jacob] = load_calib_model ( images, method, hyperbol, params, active, info )

nM = (info.n_sq_x+1)*(info.n_sq_y+1);

%%% Calib A - SVP Model
if method == 1

    number_inis = 4;	% number of initial parameter to calibrate for numeric Jacobian
    Jacob = calc_JacobianPattern ( params.calib, number_inis, images, 6, nM);

    for i = 1 : size(images,2)
        
         active.cam{i}.mir   = [0 0 0];
         active.cam{i}.om    = [0 0 0];
         active.cam{i}.T     = [0 0 0];
         active.cam{i}.k     = [0 0 0 0 0];
         active.cam{i}.alpha = 0;
         active.cam{i}.f     = [1 1];
         active.cam{i}.c     = [1 1];
        
         if i == 1
            active.cam{i}.ex_T  = [0 0 0];
            active.cam{i}.ex_om = [0 0 0]; 
         else
            active.cam{i}.ex_T  = [1 1 1];
            active.cam{i}.ex_om = [1 1 1];
         end
    end
end

%%% Calib A1 - SVP Model with k1 - k4
if method == 2

    number_inis = 8;	% number of initial parameter to calibrate for numeric Jacobian
    Jacob = calc_JacobianPattern ( params.calib, number_inis, images, 6, nM);

    for i = 1 : size(images,2)
        
        active.cam{i}.mir   = [0 0 0];
        active.cam{i}.om    = [0 0 0];
        active.cam{i}.T     = [0 0 0];
        active.cam{i}.k     = [1 1 1 1 0];
        active.cam{i}.alpha = 0;
        active.cam{i}.f     = [1 1];
        active.cam{i}.c     = [1 1];
        
        if i == 1
            active.cam{i}.ex_T  = [0 0 0];
            active.cam{i}.ex_om = [0 0 0]; 
        else
            active.cam{i}.ex_T  = [1 1 1];
            active.cam{i}.ex_om = [1 1 1];
        end
    end
end

%%% Calib B - without A B C
if method == 3

    number_inis = 9;	% number of initial parameter to calibrate for numeric Jacobian
    Jacob = calc_JacobianPattern ( params.calib, number_inis, images, 6, nM);

    for i = 1 : size(images,2)
        
        active.cam{i}.mir   = [0 0 0];
        active.cam{i}.om    = [1 1 0];
        active.cam{i}.T     = [1 1 1];
        active.cam{i}.k     = [0 0 0 0 0];
        active.cam{i}.alpha = 0;
        active.cam{i}.f     = [1 1];
        active.cam{i}.c     = [1 1];
        
        if i == 1
            active.cam{i}.ex_T  = [0 0 0];
            active.cam{i}.ex_om = [0 0 0]; 
        else
            active.cam{i}.ex_T  = [1 1 1];
            active.cam{i}.ex_om = [1 1 1];
        end
    end
end

%%% Calib B1    - without A B C    with k1 - k4
if method == 4

    number_inis = 13;	% number of initial parameter to calibrate for numeric Jacobian
    Jacob = calc_JacobianPattern ( params.calib, number_inis, images, 6, nM);

    for i = 1 : size(images,2)
        
        active.cam{i}.mir   = [0 0 0];
        active.cam{i}.om    = [1 1 0];
        active.cam{i}.T     = [1 1 1];
        active.cam{i}.k     = [1 1 1 1 0];
        active.cam{i}.alpha = 0;
        active.cam{i}.f     = [1 1];
        active.cam{i}.c     = [1 1];

        if i == 1
            active.cam{i}.ex_T  = [0 0 0];
            active.cam{i}.ex_om = [0 0 0]; 
        else
            active.cam{i}.ex_T  = [1 1 1];
            active.cam{i}.ex_om = [1 1 1];
        end
    end
end

%%% Calib B2    - without A B C    with k1 k2
if method == 5

    number_inis = 11;	% number of initial parameter to calibrate for numeric Jacobian
    Jacob = calc_JacobianPattern ( params.calib, number_inis, images, 6, nM);

    for i = 1 : size(images,2)
        
        active.cam{i}.mir   = [0 0 0];
        active.cam{i}.om    = [1 1 0];
        active.cam{i}.T     = [1 1 1];
        active.cam{i}.k     = [1 1 0 0 0];
        active.cam{i}.alpha = 0;
        active.cam{i}.f     = [1 1];
        active.cam{i}.c     = [1 1];
        
        if i == 1
            active.cam{i}.ex_T  = [0 0 0];
            active.cam{i}.ex_om = [0 0 0]; 
        else
            active.cam{i}.ex_T  = [1 1 1];
            active.cam{i}.ex_om = [1 1 1];
        end
    end
end

%%% Calib C     - without T3  
if method == 6

    number_inis = 10;	% number of initial parameter to calibrate for numeric Jacobian
    Jacob = calc_JacobianPattern ( params.calib, number_inis, images, 6, nM);

    for i = 1 : size(images,2)
        active.cam{i}.om    = [1 1 0];
        active.cam{i}.T     = [1 1 0];
        active.cam{i}.k     = [0 0 0 0 0];
        active.cam{i}.alpha = 0;
        active.cam{i}.f     = [1 1];
        active.cam{i}.c     = [1 1];
        if i == 1
            if hyperbol == 1
                active.cam{i}.mir   = [1 1 0];
            elseif hyperbol == 2
                active.cam{i}.mir   = [1 0 1];
            end
            active.cam{i}.ex_T  = [0 0 0];
            active.cam{i}.ex_om = [0 0 0]; 
        else
            if hyperbol == 1
                active.cam{i}.mir   = [1 1 0];
            elseif hyperbol == 2
                active.cam{i}.mir   = [1 0 1];
            end
            active.cam{i}.ex_T  = [1 1 1];
            active.cam{i}.ex_om = [1 1 1];
        end
    end
end

%%% Calib C1    - without T3       with k1 - k4
if method == 7

   number_inis = 14;	% number of initial parameter to calibrate for numeric Jacobian
    Jacob = calc_JacobianPattern ( params.calib, number_inis, images, 6, nM);

    for i = 1 : size(images,2)
        
        active.cam{i}.om    = [1 1 0];
        active.cam{i}.T     = [1 1 0];
        active.cam{i}.k     = [1 1 1 1 0];
        active.cam{i}.alpha = 0;
        active.cam{i}.f     = [1 1];
        active.cam{i}.c     = [1 1];
        
        if i == 1
            if hyperbol == 1
                active.cam{i}.mir   = [1 1 0];
            elseif hyperbol == 2
                active.cam{i}.mir   = [1 0 1];
            end
            active.cam{i}.ex_T  = [0 0 0];
            active.cam{i}.ex_om = [0 0 0]; 
        else
            if hyperbol == 1
                active.cam{i}.mir   = [1 1 0];
            elseif hyperbol == 2
                active.cam{i}.mir   = [1 0 1];
            end
            active.cam{i}.ex_T  = [1 1 1];
            active.cam{i}.ex_om = [1 1 1];
        end
    end
end

%%% Calib C1    - without T3       with k1 k2
if method == 8

    number_inis = 12;	% number of initial parameter to calibrate for numeric Jacobian
    Jacob = calc_JacobianPattern ( params.calib, number_inis, images, 6, nM);

    for i = 1 : size(images,2)
        
         active.cam{i}.om    = [1 1 0];
         active.cam{i}.T     = [1 1 0];
         active.cam{i}.k     = [1 1 0 0 0];
         active.cam{i}.alpha = 0;
         active.cam{i}.f     = [1 1];
         active.cam{i}.c     = [1 1];
        
        if i == 1
            if hyperbol == 1
                active.cam{i}.mir   = [1 1 0];
            elseif hyperbol == 2
                active.cam{i}.mir   = [1 0 1];
            end
            active.cam{i}.ex_T  = [0 0 0];
            active.cam{i}.ex_om = [0 0 0]; 
        else
            if hyperbol == 1
                active.cam{i}.mir   = [1 1 0];
            elseif hyperbol == 2
                active.cam{i}.mir   = [1 0 1];
            end
            active.cam{i}.ex_T  = [1 1 1];
            active.cam{i}.ex_om = [1 1 1];
        end
    end
end

%%% Calib D     - all without k
if method == 9

    number_inis = 11;	% number of initial parameter to calibrate for numeric Jacobian
    Jacob = calc_JacobianPattern ( params.calib, number_inis, images, 6, nM);

    for i = 1 : size(images,2)
        
        active.cam{i}.om    = [1 1 0];
        active.cam{i}.T     = [1 1 1];
        active.cam{i}.k     = [0 0 0 0 0];
        active.cam{i}.alpha = 0;
        active.cam{i}.f     = [1 1];
        active.cam{i}.c     = [1 1];
        
        if i == 1            
            if hyperbol == 1
                active.cam{i}.mir   = [1 1 0];
            elseif hyperbol == 2
                active.cam{i}.mir   = [1 0 1];
            end
            active.cam{i}.ex_T  = [0 0 0];
            active.cam{i}.ex_om = [0 0 0]; 
        else
            if hyperbol == 1
                active.cam{i}.mir   = [1 1 0];
            elseif hyperbol == 2
                active.cam{i}.mir   = [1 0 1];
            end
            active.cam{i}.ex_T  = [1 1 1];
            active.cam{i}.ex_om = [1 1 1];
        end
    end
end

%%% Calib D     - all + k1 - k4
if method == 10

    number_inis = 15;	% number of initial parameter to calibrate for numeric Jacobian
    Jacob = calc_JacobianPattern ( params.calib, number_inis, images, 6, nM);

    for i = 1 : size(images,2)
        
        active.cam{i}.om    = [1 1 0];
        active.cam{i}.T     = [1 1 1];
        active.cam{i}.k     = [1 1 1 1 0];
        active.cam{i}.alpha = 0;
        active.cam{i}.f     = [1 1];
        active.cam{i}.c     = [1 1];
            
        if i == 1
            if hyperbol == 1
                active.cam{i}.mir   = [1 1 0];
            elseif hyperbol == 2
                active.cam{i}.mir   = [1 0 1];
            end
            active.cam{i}.ex_T  = [0 0 0];
            active.cam{i}.ex_om = [0 0 0]; 
        else
            if hyperbol == 1
                active.cam{i}.mir   = [1 1 0];
            elseif hyperbol == 2
                active.cam{i}.mir   = [1 0 1];
            end
            active.cam{i}.ex_T  = [1 1 1];
            active.cam{i}.ex_om = [1 1 1];
        end
    end
end

end
