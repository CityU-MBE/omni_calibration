function param = unpack_params_mei (xx, params, active)

ind = 1;

for cam = 1 : params.calib 
    
    for i = 1 : size(active.cam{cam}.xi,2)
        if active.cam{cam}.xi(i) == 1 
           param.cam{cam}.xi(i) = xx(ind); 
           ind = ind + 1;
        else
           param.cam{cam}.xi(i) = params.cam{cam}.xi(i);
        end 
    end
    
    for i = 1 : size(active.cam{cam}.kc,2)
        if active.cam{cam}.kc(i) == 1 
           param.cam{cam}.kc(i) = xx(ind); 
           ind = ind + 1;
        else
           param.cam{cam}.kc(i) = params.cam{cam}.kc(i);
        end 
    end
    
    for i = 1 : size(active.cam{cam}.alphac,2)
        if active.cam{cam}.alphac(i) == 1 
           param.cam{cam}.alphac(i,1) = xx(ind); 
           ind = ind + 1;
        else
           param.cam{cam}.alphac(i,1) = params.cam{cam}.alphac(i,1);
        end 
    end
    
    for i = 1 : size(active.cam{cam}.gammac,2)
        if active.cam{cam}.gammac(i) == 1 
           param.cam{cam}.gammac(i) = xx(ind); 
           ind = ind + 1;
        else
           param.cam{cam}.gammac(i) = params.cam{cam}.gammac(i);
        end 
    end
    
    for i = 1 : size(active.cam{cam}.cc,2)
        if active.cam{cam}.cc(i) == 1 
           param.cam{cam}.cc(i) = xx(ind); 
           ind = ind + 1;
        else
           param.cam{cam}.cc(i) = params.cam{cam}.cc(i);
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

