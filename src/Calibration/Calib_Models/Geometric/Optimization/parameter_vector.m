function [param_vec, active_vec] = parameter_vector ( params, active, images)

cam = params.calib; 
board = size(params.board,2);

param_vec = [];
active_vec = [];

for n = 1 : cam
    
    param_vec = [param_vec, params.cam{n}.mir, params.cam{n}.om, params.cam{n}.T', params.cam{n}.k, params.cam{n}.alpha, params.cam{n}.f', params.cam{n}.c'];
    active_vec = [active_vec, active.cam{n}.mir, active.cam{n}.om, active.cam{n}.T, active.cam{n}.k, active.cam{n}.alpha, active.cam{n}.f, active.cam{n}.c]; 
    
end

for n = 1 : cam
    
    param_vec  = [param_vec,  params.cam{n}.ex_T', params.cam{n}.ex_om];
    active_vec = [active_vec, active.cam{n}.ex_T, active.cam{n}.ex_om]; 
    
end


for m = 1 : board

    param_vec   = [param_vec, params.board{m}.om, params.board{m}.T'];
    active_vec  = [active_vec, active.board{m}.om, active.board{m}.T];
             
end