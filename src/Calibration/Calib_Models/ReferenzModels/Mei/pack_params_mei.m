function [param_vec, active_vec] = pack_params_mei ( params, active)

    [param_vec_all, active_vec] = parameter_vector_mei ( params, active);

    param_vec = param_vec_all(logical(active_vec));

end


function [param_vec, active_vec] = parameter_vector_mei ( params, active)

cam = params.calib; %%size(params.cam,2);
board = size(params.board,2);

param_vec = [];
active_vec = [];

for n = 1 : cam
    
    param_vec = [param_vec,   params.cam{n}.xi, params.cam{n}.kc, params.cam{n}.alphac, params.cam{n}.gammac, params.cam{n}.cc];
    active_vec = [active_vec, active.cam{n}.xi, active.cam{n}.kc, active.cam{n}.alphac, active.cam{n}.gammac, active.cam{n}.cc]; 
    
end

for n = 1 : cam
    
    param_vec  = [param_vec,  params.cam{n}.ex_T', params.cam{n}.ex_om];
    active_vec = [active_vec, active.cam{n}.ex_T, active.cam{n}.ex_om]; 
    
end


for m = 1 : board

    param_vec   = [param_vec,  params.board{m}.om, params.board{m}.T'];
    active_vec  = [active_vec, active.board{m}.om,  active.board{m}.T];
             
end

end