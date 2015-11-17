function [Xmir, vr] = inverse_projection_mirror ( corners, param)

for c = 1 : 2%size(param.cam,2)    
	% compute point on the image
    xx(:,:,c) = inverse_projection ( corners{1,c}.p', param.cam{c}.f, param.cam{c}.c);
    
    for i = 1 : size(corners{1,c}.p,1)
        if corners{1,1}.p(i,1) ~= 0 && corners{1,2}.p(i,1) ~= 0
            % Point on the mirror surface Xmir and direction vector vr 
            [ Xmir1(:,i,c), Xmir2(:,i,c), V(:,i,c), C(:,i,c) ] = inverse_mirror_point (xx(:,i,c), param.cam{c}.om, param.cam{c}.T, param.cam{c}.mir);

            % Normal Vector on the Mirror Surface
            n  = [ Xmir2(1,i,c); Xmir2(2,i,c); param.cam{c}.mir(1)*Xmir2(3,i,c) + param.cam{c}.mir(2) / 2 ];
            % Ray from image point to the mirror 
            vi = [ Xmir2(1,i,c) - C(1,i,c); Xmir2(2,i,c)-C(2,i,c); Xmir2(3,i,c)-C(3,i,c)]; % is equal to V
            % reflecting ray from mirror to world 
            vr(:,i,c) = vi - 2*n * (transpose(vi)*n) / (transpose(n)*n);
        end
    end
end

Xmir = Xmir2;