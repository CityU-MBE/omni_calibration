% Initial calibration
% compute the initial position of the ceckerboards with homograpy
%
% Input: 
% - grid: chessboard coners in the image
% - images
% - active: array with active parameters
% - params: initial values from config
% Output:
% - board: R and t of the checkerboards
%
% M.Schoenbein

function [params] = initial_ex_calibration (grid, images, active, params, M )

for c = 1 : params.calib
    
    omni = params.cam{c}.omni;
   
	for b = 1 : size(grid{1,c}.Xp_abs,3)

        if active.numberboards(b) == 1
        
            if images{1,c}.active_images(b) == 1

                ue = grid{1,c}.Xp_abs(:,:,b);
                ve = grid{1,c}.Yp_abs(:,:,b);

                % calculate Homography 
                [om1, T1, H] = compute_omni_Homography ([ue,ve]', M, omni, params.cam{c}.f, ...
                    params.cam{c}.c(1), params.cam{c}.c(2));
                om1 = om1';

                cam_board{c}.om(:,b) = om1;
                cam_board{c}.T(:,b) = T1;     
                
            end    
        end
    end  
end

%% Initialise Cam Extrinsics
T = zeros(3,1);
om =zeros(1,3);
ind = 1;

for c = 1 : params.calib
    
    if c == 1 
        params.cam{c}.ex_om = zeros(1,3);
        params.cam{c}.ex_T = zeros(3,1);
    
    else
    
        for b = 1 : size(grid{1,c}.Xp_abs,3)
    
            if (images{1,c-1}.active_images(b) == 1) && (images{1,c}.active_images(b) == 1)
                
                H1 = [rodrigues(cam_board{c-1}.om(:,b)), cam_board{c-1}.T(:,b); 0,0,0,1];
                H2 = [rodrigues(cam_board{c}.om(:,b)),   cam_board{c}.T(:,b);   0,0,0,1];
                
                H = H2 * H1^(-1);
                
                T(:,ind) = H(1:3,4);
                om(ind,:) = [rodrigues(H(1:3,1:3))'];
            
                ind = ind + 1;
            end
            
        end
        
        params.cam{c}.ex_T = mean(T')';
        params.cam{c}.ex_om = mean(om);
             
    end
end
            
for b = 1 : size(grid{1,c}.Xp_abs,3)
    
    %for c = 1 : params.calib
        
        if active.numberboards(b) == 1
        
            if images{1}.active_images(b) == 1 

                params.board{b}.om = cam_board{1}.om(:,b)';
                params.board{b}.T  = cam_board{1}.T(:,b);

            else

                % compute extrinsics in the world coordinate system
                Rex = rodrigues(params.cam{c}.ex_om);
                Rex_t = Rex';
                om_ex_t = rodrigues(Rex_t);
                T_ex = - Rex_t * params.cam{c}.ex_T;
                [om_w,T_w,] = compose_motion(cam_board{2}.om(:,b), cam_board{2}.T(:,b), om_ex_t, T_ex);

                params.board{b}.om = om_w';
                params.board{b}.T  = T_w;
            
            end
    
        else

            params.board{b}.om = [ 0 0 0];
            params.board{b}.T  = [0; 0; 0];
            
        end
    end
end
