function [cam, active] = initial_scara_calibration_new ( grid, images, param, active)

uMax = param.const; 

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

function [err,ss] = getSS(s_xc,s_yc,taylor_order)
    % least square initialization of first three phi-params 
    uc = u - s_xc;
    vc = v - s_yc;
    r_ = sqrt(uc.^2+vc.^2);
    r = r_/uMax;
    H = ones(length(uc),taylor_order+1);
    for n=1:taylor_order
        H(:,n+1) = r.^n;
    end
    [~,PHI,~] = cart2sph(PW(1,:),PW(2,:),PW(3,:));
    y = (r'.*tan(PHI))';
    ss = H\y;
    
    err = H*ss-y;
end

for c = 1 : param.calib
    
    % extrinsics �bernehmen
    cam{c}.ex_T  = param.cam{c}.ex_T;
    cam{c}.ex_om = param.cam{c}.ex_om;
    
    grid{1,c}.ima_proc = [];
	for i = 1 : size(images{1,1}.active_images,2)
        if images{1,c}.active_images(i) == 1
            grid{1,c}.ima_proc = [grid{1,c}.ima_proc, i];
        end
	end
    
	s_xc = param.cam{c}.c(1);
	s_yc = param.cam{c}.c(2);
    taylor_order = 4;
       
    % get corners
    cb_active = images{1,c}.active_images;
    cb_idx = find(cb_active);
    num_cb = length(cb_idx);
        
    % get board world points
    nM = 7*5;
    PW = zeros(3,num_cb*nM);
    M = [grid{1,c}.Xt';grid{1,c}.Yt';zeros(size(grid{1,c}.Xt))'];
    u = zeros(1,num_cb)';
    v = zeros(1,num_cb)';
    for i=1:num_cb
        board = cb_idx(i);
        [om,T] = compose_motion(param.board{board}.om, param.board{board}.T, cam{c}.ex_om, cam{c}.ex_T);
        R = rodrigues(om);
        PW(:,(1:nM)+(i-1)*nM) = R*M + repmat(T,1,nM);
        u((1:nM)+(i-1)*nM) = grid{1,c}.Xp_abs(:,1,board);
        v((1:nM)+(i-1)*nM) = grid{1,c}.Yp_abs(:,1,board);
    end
    
    [~,ss] = getSS(s_xc,s_yc,taylor_order);
        
    cam{c}.ss = ss;
    cam{c}.xc = s_xc;
    cam{c}.yc = s_yc;
    cam{c}.c  = 1;
    cam{c}.d  = 0;
    cam{c}.e  = 0; 
    cam{c}.width = images{1,c}.nx;
    cam{c}.height = images{1,c}.ny;
    cam{c}.taylor_order = taylor_order;
        
end

end