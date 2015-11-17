function [params, active, Jacob] = initial_scara_calibration ( grid, images, params, active, info)

number_inis = 7;	% number of initial parameter to calibrate for numeric Jacobian
nM = (info.n_sq_x+1)*(info.n_sq_y+1);
Jacob = calc_JacobianPattern ( params.calib, number_inis, images, 6, nM);


for c = 1 : size(images,2)
    active.cam{c}.ss       = [ 1 1 1 1 1];
    active.cam{c}.xc       = 1;
    active.cam{c}.yc       = 1;
    active.cam{c}.c        = 0;
    active.cam{c}.d        = 0;
    active.cam{c}.e        = 0;
    active.cam{c}.width    = 0;
    active.cam{c}.height   = 0;
    active.cam{c}.taylor_order = 0;
    
    if c == 1
        active.cam{c}.ex_T  = [0 0 0];
        active.cam{c}.ex_om = [0 0 0];
    else        
        active.cam{c}.ex_T  = [1 1 1];
        active.cam{c}.ex_om = [1 1 1]; 
    end
    
end

for c = 1 : params.calib
    
    grid{1,c}.ima_proc = [];
	for i = 1 : size(images{1,1}.active_images,2)
        if images{1,c}.active_images(i) == 1
            grid{1,c}.ima_proc = [grid{1,c}.ima_proc, i];
        end
	end
    
	s_xc = images{1,c}.nx/2;
	s_yc = images{1,c}.ny/2;
    taylor_order = 4;
    
	[RRfin,ss] = calibrate( grid{1,c}.Xt, grid{1,c}.Yt, grid{1,c}.Xp_abs, grid{1,c}.Yp_abs, ...
        s_xc, s_yc, taylor_order, grid{1,c}.ima_proc );
    
    params.cam{c}.ss = ss;
    params.cam{c}.xc = s_xc;
    params.cam{c}.yc = s_yc;
    params.cam{c}.c  = 1;
    params.cam{c}.d  = 0;
    params.cam{c}.e  = 0; 
    params.cam{c}.width = images{1,c}.nx;
    params.cam{c}.height = images{1,c}.ny;
    params.cam{c}.taylor_order = taylor_order;
    
    [ocam_model] = find_center_calibration(params, grid, c)
    
    params.cam{c}.ss = ocam_model{1,c}.ss;
    params.cam{c}.xc = ocam_model{1,c}.xc;
    params.cam{c}.yc = ocam_model{1,c}.yc;
    
    RR{1,c}.RRfin = ocam_model{1,c}.RRfin;
end

for i = 1 : size(images{1,1}.active_images,2)
        if (images{1,1}.active_images(i) == 1 )
            
            R       = RR{1,1}.RRfin(:,:,i);
            R(:,3)  = cross(R(:,1),R(:,2));
            om      = rodrigues(R);
            T       = RR{1,1}.RRfin(:,3,i);
            
            params.board{i}.om = om';
            params.board{i}.T  = T;
            
        elseif ( params.calib == 2 && images{1,2}.active_images(i) == 1 )
            R       = RR{1,2}.RRfin(:,:,i);
            R(:,3)  = cross(R(:,1),R(:,2));
            om      = rodrigues(R);
            T       = RR{1,2}.RRfin(:,3,i);
            
            % compute extrinsics in the world coordinate system
            Rex     = rodrigues(params.cam{2}.ex_om);
            Rex_t   = Rex';
            om_ex_t = rodrigues(Rex_t);
            T_ex    = - Rex_t * params.cam{2}.ex_T;
            [om_w,T_w,] = compose_motion(om, T, om_ex_t, T_ex);

            params.board{i}.om = om_w';
            params.board{i}.T  = T_w;

        else
            
            params.board{i}.om = [ 0 0 0];
            params.board{i}.T  = [0; 0; 0];
            
        end
end
      