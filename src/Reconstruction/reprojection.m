% Reprojection function: map 3D point to a 2D point
% Input: 
%   - param: calibration parameter
%   - X: 3D points
%   - method: calibration method
%   - cams: number or vector for which camera we compute the image points
% Output:
%   - 2D image points
%
% M. Schönbein 2014

function [u] = reprojection ( param, X, method, cams)

u = zeros ( 1, 2*size(cams,2)*size(X,2));
corners = 0;

for c = cams 
    
	XR =rigid_motion(X,param.cam{c}.ex_om,param.cam{c}.ex_T); 
    
    switch method
        case 1 
        
            ut = projection_geometric ( XR, param.cam{c}.T, param.cam{c}.mir(1), param.cam{c}.mir(2), param.cam{c}.mir(3), ...
                param.cam{c}.om, param.cam{c}.k, param.cam{c}.alpha, param.cam{c}.f, param.cam{c}.c);
            utr = reshape(ut, 1, size(ut,2)*2);

        case { 2, 3, 4, 5, 6, 7, 8, 9, 10 } % Geometric Calibration 

            ut = projection_geometric ( XR, param.cam{c}.T, param.cam{c}.mir(1), param.cam{c}.mir(2), param.cam{c}.mir(3), ...
                param.cam{c}.om, param.cam{c}.k, param.cam{c}.alpha, param.cam{c}.f, param.cam{c}.c);
            utr = reshape(ut, 1, size(ut,2)*2);
            
        case { 11, 15, 17, 18} % Scaramuzza Calibration

            ut = projection_scaramuzza ( param.cam{c}.ss, param.cam{c}.width, param.cam{c}.height, param.cam{c}.c, ...
                param.cam{c}.d, param.cam{c}.e, param.cam{c}.xc, param.cam{c}.yc, XR, param.const);
            utr = reshape(ut, 1, size(ut,2)*2);

        case {12, 16} % Mei Calibration

            ut = projection_mei ( param.cam{c}.xi, param.cam{c}.kc, param.cam{c}.alphac, param.cam{c}.gammac, ...
                param.cam{c}.cc, XR);
            utr = reshape(ut, 1, size(ut,2)*2);

        case 14 % Centered Calibration

            %[ut, dudX] = projection_centered(param.cam{c}.centered,XR);
            ut = projection_centered_mex( XR, param.cam{c}.centered.vp, param.cam{c}.centered.param);
            utr = reshape(ut, 1, size(ut,2)*2);
            
            
            

        otherwise 
        printf('WARNING: No Valid calibration Method\n');
    end


    
    u(corners + 1 : corners + size(utr,2)) = utr;
    corners = corners + size(utr,2); 

end

