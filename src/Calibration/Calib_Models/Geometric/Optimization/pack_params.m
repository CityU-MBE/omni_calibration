function [param_vec, active_vec] = pack_params ( params, active)

[param_vec_all, active_vec] = parameter_vector ( params, active);

param_vec = param_vec_all(logical(active_vec));