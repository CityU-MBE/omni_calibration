function [x0, resnorm] = optimization_projection (params, M, u_ini, active, images, options)

    [xx, active_vec] = pack_params ( params, active);
    
    [x0, resnorm, residual, exitflag, output] = lsqnonlin( @min_func, xx, -inf, inf, options, params, M, active, active_vec, images, u_ini);

end

%%%%%% Minimization function
%function [F, J] = min_func (xx, params, M, active, active_vec, images, u_ini)  % for optimization with Jacobian
function [F] = min_func (xx, params, M, active, active_vec, images, u_ini)

    param = unpack_params (xx, params, active);

    %[u, J] = compute_Jacobian_projection (param, active_vec, images, M); % for optimization with Jacobian
    u = compute_Jacobian_projection (param, active_vec, images, M);
    
    F = u' - u_ini;
    
end


