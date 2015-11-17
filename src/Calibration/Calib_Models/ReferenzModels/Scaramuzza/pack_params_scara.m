function [param_vec, active_vec] = pack_params_scara ( params, active)

    [param_vec_all, active_vec] = parameter_vector_scara ( params, active);

    param_vec = param_vec_all(logical(active_vec));

end


function [param_vec, active_vec] = parameter_vector_scara ( params, active)

cam = params.calib; %%size(params.cam,2);
board = size(params.board,2);

param_vec = [];
active_vec = [];

for n = 1 : cam
    
    param_vec = [param_vec,   params.cam{n}.ss', params.cam{n}.xc, params.cam{n}.yc, params.cam{n}.c, params.cam{n}.d, params.cam{n}.e, params.cam{n}.width, params.cam{n}.height];
    active_vec = [active_vec, active.cam{n}.ss, active.cam{n}.xc, active.cam{n}.yc, active.cam{n}.c, active.cam{n}.d, active.cam{n}.e, active.cam{n}.width, active.cam{n}.height]; 
    
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