function param = unpack_params_scara (xx, params, active)

ind = 1;

for cam = 1 : params.calib %size(active.cam,2)
    
    for i = 1 : size(active.cam{cam}.ss,2)
        if active.cam{cam}.ss(i) == 1 
           param.cam{cam}.ss(i) = xx(ind); 
           ind = ind + 1;
        else
           param.cam{cam}.ss(i) = params.cam{cam}.ss(i);
        end 
    end
    param.cam{cam}.ss = param.cam{cam}.ss';
        
    for i = 1 : size(active.cam{cam}.xc,2)
        if active.cam{cam}.xc(i) == 1 
           param.cam{cam}.xc(i) = xx(ind); 
           ind = ind + 1;
        else
           param.cam{cam}.xc(i) = params.cam{cam}.xc(i);
        end 
    end
    
    for i = 1 : size(active.cam{cam}.yc,2)
        if active.cam{cam}.yc(i) == 1 
           param.cam{cam}.yc(i,1) = xx(ind); 
           ind = ind + 1;
        else
           param.cam{cam}.yc(i,1) = params.cam{cam}.yc(i,1);
        end 
    end
    
    for i = 1 : size(active.cam{cam}.c,2)
        if active.cam{cam}.c(i) == 1 
           param.cam{cam}.c(i) = xx(ind); 
           ind = ind + 1;
        else
           param.cam{cam}.c(i) = params.cam{cam}.c(i);
        end 
    end
    
    for i = 1 : size(active.cam{cam}.d,2)
        if active.cam{cam}.d(i) == 1 
           param.cam{cam}.d(i) = xx(ind); 
           ind = ind + 1;
        else
           param.cam{cam}.d(i) = params.cam{cam}.d(i);
        end 
    end
    
    for i = 1 : size(active.cam{cam}.e,2)
        if active.cam{cam}.e(i) == 1 
           param.cam{cam}.e(i,1) = xx(ind); 
           ind = ind + 1;
        else
           param.cam{cam}.e(i,1) = params.cam{cam}.e(i,1);
        end 
    end
    
    for i = 1 : size(active.cam{cam}.width,2)
        if active.cam{cam}.width(i) == 1 
           param.cam{cam}.width(i,1) = xx(ind); 
           ind = ind + 1;
        else
           param.cam{cam}.width(i,1) = params.cam{cam}.width(i,1);
        end 
    end
    
    for i = 1 : size(active.cam{cam}.height,2)
        if active.cam{cam}.height(i) == 1 
           param.cam{cam}.height(i,1) = xx(ind); 
           ind = ind + 1;
        else
           param.cam{cam}.height(i,1) = params.cam{cam}.height(i,1);
        end 
    end
    
    for i = 1 : size(active.cam{cam}.ex_T,2)
        if active.cam{cam}.ex_T(i) == 1 
           param.cam{cam}.ex_T(i,1) = xx(ind); 
           ind = ind + 1;
        else
           param.cam{cam}.ex_T(i,1) = params.cam{cam}.ex_T(i,1);
        end 
    end
    
    for i = 1 : size(active.cam{cam}.ex_om,2)
        if active.cam{cam}.ex_om(i) == 1 
           param.cam{cam}.ex_om(i) = xx(ind); 
           ind = ind + 1;
        else
           param.cam{cam}.ex_om(i) = params.cam{cam}.ex_om(i);
        end 
    end
    
    
end

for board = 1 : size(active.board,2)
    
    for i = 1 : size(active.board{board}.om,2) 
        if active.board{board}.om(i) == 1
            param.board{board}.om(i) = xx(ind);
            ind = ind + 1;
        else
            param.board{board}.om(i) = params.board{board}.om(i);
        end
    end
    
    for i = 1 : size(active.board{board}.T,2) 
        if active.board{board}.T(i) == 1
            param.board{board}.T(i,1) = xx(ind);
            ind = ind + 1;
        else
            param.board{board}.T(i,1) = params.board{board}.T(i,1);
        end
    end
end

