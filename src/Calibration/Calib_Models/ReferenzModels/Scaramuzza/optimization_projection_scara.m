function [x0, resnorm] = optimization_projection_scara (params, M, u_ini, active, images, options, info)

    [xx, active_vec] = pack_params_scara ( params, active);
      
    numCams = params.calib;
    num_cb_params = 6;
    
    disp('Scaramuzza Calibration with limited parameter set...');
    num_intrinsics = 7;
    nM = (info.n_sq_x+1)*(info.n_sq_y+1);
    J = calc_JacobianPattern(numCams,num_intrinsics,images,num_cb_params,nM);
    
    options.JacobPattern = J;

    [x0, resnorm, residual, exitflag, output] = lsqnonlin( @min_func_scara_full, xx, -inf, inf, options, params, M, active, active_vec, images, u_ini);
    
    param = unpack_params_scara (x0, params, active);
    param.calib = params.calib;
    
    disp('Scaramuzza Calibration with full parameter set...');
    for c = 1 : size(images,2)
        active.cam{c}.c        = 1;
        active.cam{c}.d        = 1;
        active.cam{c}.e        = 1;
    end
    [xx, active_vec] = pack_params_scara ( param, active);
    
    num_intrinsics = 10;
    J = calc_JacobianPattern(numCams,num_intrinsics,images,num_cb_params,nM);

    options.JacobPattern = J;
    [x0, resnorm, residual, exitflag, output] = lsqnonlin( @min_func_scara_full, xx, -inf, inf, options, params, M, active, active_vec, images, u_ini);

end

%%%%%% Minimization function for Scaramuzza Calibration
function F = min_func_scara_full (xx, params, M, active, active_vec, images, u_ini)

    param = unpack_params_scara (xx, params, active);
    
    points = size(M,2);
    boards = size(params.board,2);
    boards_length_ges = 0;
    boards_length(1) = 0;

    for c = 1 : params.calib
        
        corners = 0;
        
        for b = 1 : size(params.board,2)
            
            if (images{1,c}.active_images(b) == 1)
                
                if c == 1
                    
                    Mc = rodrigues(param.board{b}.om)*M + repmat(param.board{b}.T,1,size(M,2));
                    m = projection_scaramuzza ( param.cam{c}.ss, param.cam{c}.width, param.cam{c}.height, ...
                        param.cam{c}.c, param.cam{c}.d, param.cam{c}.e, param.cam{c}.xc, param.cam{c}.yc, Mc, params.const );
    
                else
                    
                    [omb,Tb] = compose_motion(param.board{b}.om, param.board{b}.T, param.cam{c}.ex_om, param.cam{c}.ex_T);
                    Mcb = rodrigues(omb)*M + repmat(Tb,1,size(M,2));
                    
                    m = projection_scaramuzza ( param.cam{c}.ss, param.cam{c}.width, param.cam{c}.height, ...
                        param.cam{c}.c, param.cam{c}.d, param.cam{c}.e, param.cam{c}.xc, param.cam{c}.yc, Mcb, params.const );
                end
                
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
