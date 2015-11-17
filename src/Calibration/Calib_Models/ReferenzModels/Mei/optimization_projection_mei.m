% Optimization using the Calibration Model of Mei

function [x0, resnorm] = optimization_projection_mei (params, M, u_ini, active, images, options)

    [xx, active_vec] = pack_params_mei ( params, active);
    
    % define bounds
    lower_bound = -inf*ones(size(xx));
    upper_bound = inf*ones(size(xx));
    % set bounds for parameter xi: 0 <= xi <= 1
    lower_bound(1) = 0;
    upper_bound(1) = 1;
      
    [x0, resnorm, residual, exitflag, output] = lsqnonlin( @min_func_mei, xx, lower_bound, upper_bound, options, params, M, active, active_vec, images, u_ini);

end

%%%%%% Minimization function for Mei Calibration
function F = min_func_mei (xx, params, M, active, active_vec, images, u_ini)

    param = unpack_params_mei (xx, params, active);
    
    points = size(M,2);
    boards = size(params.board,2);
    boards_length_ges = 0;
    boards_length(1) = 0;

    for c = 1 : params.calib
        
        corners = 0;
        
        for b = 1 : size(params.board,2)
            
            if (images{1,c}.active_images(b) == 1)
                
                [om,T] = compose_motion(param.board{b}.om, param.board{b}.T, param.cam{c}.ex_om, param.cam{c}.ex_T);
                    
                V = rodrigues(om)*M + repmat(T,1,size(M,2));
%                V = [-1 0 0; 0 -1 0; 0 0 1] *V;
                m = projection_mei ( param.cam{c}.xi, param.cam{c}.kc, param.cam{c}.alphac, param.cam{c}.gammac, param.cam{c}.cc, V);
                
                for j = 1 : size(m,2)

                        ut ( 2*corners + 1 )          = m(1,j);
                        ut ( 2*corners + 2 )          = m(2,j);     

                        corners = corners + 1; 
                end
                
            end
            
        end
        
        boards_length_ges = boards_length_ges + sum(images{1,c}.active_images(1:boards) == 1);
        boards_length(c+1) = boards_length_ges;
        u (1, 2*points*boards_length(c) + 1 : 2*points*boards_length(c+1)) = ut;
        
        clear ut;
        
    end

    F = u' - u_ini;

end
