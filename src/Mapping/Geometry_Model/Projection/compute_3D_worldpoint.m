% compute 3d world point
function S = compute_3D_worldpoint ( corners, param, calib)

if isfield(param.cam{1},'centered')
    
    for c = 1 : 2
        
        [theta(:,c), phi(:,c)] = inverse_projection_centered ( param.cam{c}.centered, corners{c}.p');
        
        Xmir(:,:,c) =  rodrigues(param.cam{c}.ex_om)' * [ [0;0;0] - param.cam{c}.ex_T] * ones(1,size(corners{c}.p,1));
        vr(:,:,c) = rodrigues(param.cam{c}.ex_om)' * [ cos(theta(:,c)).*cos(phi(:,c)), sin(theta(:,c)).*cos(phi(:,c)), sin(phi(:,c))]' ;
    
    end
    
    S = triangulation_3d_point ( Xmir, vr);

else
    if calib == 3
        [Xmir, vr] = inverse_projection_mirror ( corners, param);
    elseif calib == 11
        [Xmir, vr] = inverse_projection_scara (corners, param);
    end

    for i = 1 : size(Xmir,2)
        Xmir(:,i,2) = rodrigues(param.cam{2}.ex_om)' * [ Xmir(:,i,2) - param.cam{2}.ex_T];
        vr(:,i,2)   = rodrigues(param.cam{2}.ex_om)' * vr(:,i,2) ;
    end

    S = triangulation_3d_point ( Xmir, vr);
end
