function [q, dqdp] = projection_centered (centered,p)

if nargin >= 1
    % compute ray from viewpoint to p
    p = p-centered.vp*ones(1,size(p,2));

    % compute angle representation from ray
    [a, dadp] = centered_ray_as_angle(p);

    % map ray to image coordinates
    [q, dqda] = centered_project_ray(centered.param,a);

    for i = 1 : size(p,2)
        dqdp{1,i}(1,:) = dqda{1,i}(1,:) .* dadp{1,i}(1,:) + dqda{1,i}(2,:) .* dadp{2,i}(1,:);
        dqdp{1,i}(2,:) = dqda{1,i}(1,:) .* dadp{1,i}(2,:) + dqda{1,i}(2,:) .* dadp{2,i}(2,:);
        dqdp{1,i}(3,:) = dqda{1,i}(1,:) .* dadp{1,i}(3,:) + dqda{1,i}(2,:) .* dadp{2,i}(3,:);

        dqdp{2,i}(1,:) = dqda{2,i}(1,:) .* dadp{1,i}(1,:) + dqda{2,i}(2,:) .* dadp{2,i}(1,:);
        dqdp{2,i}(2,:) = dqda{2,i}(1,:) .* dadp{1,i}(2,:) + dqda{2,i}(2,:) .* dadp{2,i}(2,:);
        dqdp{2,i}(3,:) = dqda{2,i}(1,:) .* dadp{1,i}(3,:) + dqda{2,i}(2,:) .* dadp{2,i}(3,:);
    end



else
    
    % test derivatives
    load('/home/schoenbein/src/Omni/data/Calibration_240713/calib_0014.mat')
    p = [1;3;5];
    
    test_derivatives(@projection_centered,1e-8,param.cam{1}.centered,p)
    
end
    
end