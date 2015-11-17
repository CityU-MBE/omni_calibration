function param = unpack_params (xx, params, active)

ind = 1;

for cam = 1 : params.calib %size(active.cam,2)
    
    for i = 1 : size(active.cam{cam}.mir,2)
        if active.cam{cam}.mir(i) == 1 
           param.cam{cam}.mir(i) = xx(ind); 
           ind = ind + 1;
        else
           param.cam{cam}.mir(i) = params.cam{cam}.mir(i);
        end 
    end
    
    for i = 1 : size(active.cam{cam}.om,2)
        if active.cam{cam}.om(i) == 1 
           param.cam{cam}.om(i) = xx(ind); 
           ind = ind + 1;
        else
           param.cam{cam}.om(i) = params.cam{cam}.om(i);
        end 
    end
    
    for i = 1 : size(active.cam{cam}.T,2)
        if active.cam{cam}.T(i) == 1 
           param.cam{cam}.T(i,1) = xx(ind); 
           ind = ind + 1;
        else
           param.cam{cam}.T(i,1) = params.cam{cam}.T(i,1);
        end 
    end
    
    for i = 1 : size(active.cam{cam}.k,2)
        if active.cam{cam}.k(i) == 1 
           param.cam{cam}.k(i) = xx(ind); 
           ind = ind + 1;
        else
           param.cam{cam}.k(i) = params.cam{cam}.k(i);
        end 
    end
    
    for i = 1 : size(active.cam{cam}.alpha,2)
        if active.cam{cam}.alpha(i) == 1 
           param.cam{cam}.alpha(i) = xx(ind); 
           ind = ind + 1;
        else
           param.cam{cam}.alpha(i) = params.cam{cam}.alpha(i);
        end 
    end
    
    for i = 1 : size(active.cam{cam}.f,2)
        if active.cam{cam}.f(i) == 1 
           param.cam{cam}.f(i,1) = xx(ind); 
           ind = ind + 1;
        else
           param.cam{cam}.f(i,1) = params.cam{cam}.f(i,1);
        end 
    end
    
    for i = 1 : size(active.cam{cam}.c,2)
        if active.cam{cam}.c(i) == 1 
           param.cam{cam}.c(i,1) = xx(ind); 
           ind = ind + 1;
        else
           param.cam{cam}.c(i,1) = params.cam{cam}.c(i,1);
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

