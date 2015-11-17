%function [u , J] = compute_Jacobian_projection (om, T, Cam, A, B, C, omm, k, alpha, f, c, M)
function [U, J] = compute_Jacobian_projection (param, active_vec, images, M)

points = size(M,2);
boards = size(param.board,2);
cams = size(param.cam,2); 

% take only the checkerboards which are active in the the cams (because some images are only active in one of the images)
count_boards = 0;
for n = 1 : size(param.cam)
    count_boards = count_boards + sum(images{1,n}.active_images(1:boards) == 1);
end

boards_length_ges = 0;
boards_length(1) = 0;

if nargout == 1
    
    for c = 1 : cams
    
        corners = 0;
        
        boards_length(c+1) = boards_length_ges + sum(images{1,c}.active_images(1:boards) == 1);
        boards_length_ges = boards_length(c+1);
        
        u = zeros ( 1, 2*points*(boards_length(c+1)-boards_length(c))); 

        for i = 1 : boards
            if (images{1,c}.active_images(i) == 1)

                if c == 1

                    ut = projection_geometric (param.board{i}.om, param.board{i}.T, param.cam{c}.T, param.cam{c}.mir(1), param.cam{c}.mir(2), param.cam{c}.mir(3), ...
                        param.cam{c}.om, param.cam{c}.k, param.cam{c}.alpha, param.cam{c}.f, param.cam{c}.c, M);

                 else

                    [omb,Tb] = compose_motion(param.board{i}.om, param.board{i}.T, param.cam{c}.ex_om, param.cam{c}.ex_T);

                    ut = projection_geometric (omb', Tb, param.cam{c}.T, param.cam{c}.mir(1), param.cam{c}.mir(2), param.cam{c}.mir(3), ...
                        param.cam{c}.om, param.cam{c}.k, param.cam{c}.alpha, param.cam{c}.f, param.cam{c}.c, M);

                end

                for j = 1 : size(ut,2)

                    u ( 2*corners + 1 )          = ut(1,j);
                    u ( 2*corners + 2 )          = ut(2,j);     

                    corners = corners + 1; 
                end
            end
        end
       
        U (1, 2*points*boards_length(c) + 1 : 2*points*boards_length(c+1)) = u;
    end
    
else
    
% init Jacobian
J_all = zeros ( 2*points*count_boards, 19*cams + 6*cams + 6*boards);

for c = 1 : cams
    
    corners = 0;
    dchecker = zeros(2*points*sum(images{1,c}.active_images(1:boards) == 1),6*boards);
    
    boards_length(c+1) = boards_length_ges + sum(images{1,c}.active_images(1:boards) == 1);
    u       = zeros (1, 2*points*(boards_length(c+1)-boards_length(c)));
    dudCam  = zeros (2*points*(boards_length(c+1)-boards_length(c)), 3);
    dudA    = zeros (2*points*(boards_length(c+1)-boards_length(c)), 1);
    dudB    = zeros (2*points*(boards_length(c+1)-boards_length(c)), 1);
    dudC    = zeros (2*points*(boards_length(c+1)-boards_length(c)), 1);
    dudomm  = zeros (2*points*(boards_length(c+1)-boards_length(c)), 3);
    dudk    = zeros (2*points*(boards_length(c+1)-boards_length(c)), 5);
    dudalpha = zeros (2*points*(boards_length(c+1)-boards_length(c)), 1);
    dudf    = zeros (2*points*(boards_length(c+1)-boards_length(c)), 2);
    dudc    = zeros (2*points*(boards_length(c+1)-boards_length(c)), 2);
    dudomex = zeros (2*points*(boards_length(c+1)-boards_length(c)), 3);
    dudTex  = zeros (2*points*(boards_length(c+1)-boards_length(c)), 3);
    
    for i = 1 : boards
        if (images{1,c}.active_images(i) == 1)

            if c == 1
             
                [ut, dutdom, dutdT, dutdCam, dutdA, dutdB, dutdC, dutdomm, dutdk, dutdalpha, dutdf, dutdc]  = ...
                    projection_geometric (param.board{i}.om, param.board{i}.T, param.cam{c}.T, param.cam{c}.mir(1), param.cam{c}.mir(2), param.cam{c}.mir(3), ...
                    param.cam{c}.om, param.cam{c}.k, param.cam{c}.alpha, param.cam{c}.f, param.cam{c}.c, M);

                dombdomex = [0 0 0; 0 0 0; 0 0 0 ];
                dombdTex  = [0 0 0; 0 0 0; 0 0 0 ];

                dTbdomex  = [0 0 0; 0 0 0; 0 0 0 ];
                dTbdTex   = [0 0 0; 0 0 0; 0 0 0 ];

             else

                [omb,Tb,dombdom,dombdT,dombdomex,dombdTex,dTbdom,dTbdT,dTbdomex,dTbdTex] = ...
                    compose_motion(param.board{i}.om, param.board{i}.T, param.cam{c}.ex_om, param.cam{c}.ex_T);

                [ut, dutdomb, dutdTb, dutdCam, dutdA, dutdB, dutdC, dutdomm, dutdk, dutdalpha, dutdf, dutdc]  = ...
                    projection_geometric (omb', Tb, param.cam{c}.T, param.cam{c}.mir(1), param.cam{c}.mir(2), param.cam{c}.mir(3), ...
                    param.cam{c}.om, param.cam{c}.k, param.cam{c}.alpha, param.cam{c}.f, param.cam{c}.c, M);

             end    

             for j = 1 : size(ut,2)

                u ( 2*corners + 1 )          = ut(1,j);
                u ( 2*corners + 2 )          = ut(2,j);     

                dudCam ( 2*corners + 1,:)    = dutdCam{1,j};
                dudCam ( 2*corners + 2,:)    = dutdCam{2,j};

                dudA ( 2*corners + 1,:)      = dutdA{1,j};
                dudA ( 2*corners + 2,:)      = dutdA{2,j};

                dudB ( 2*corners + 1,:)      = dutdB{1,j};
                dudB ( 2*corners + 2,:)      = dutdB{2,j};

                dudC ( 2*corners + 1,:)      = dutdC{1,j};
                dudC ( 2*corners + 2,:)      = dutdC{2,j};

                dudomm ( 2*corners + 1,:)    = dutdomm{1,j};
                dudomm ( 2*corners + 2,:)    = dutdomm{2,j};

                dudk ( 2*corners + 1,:)      = dutdk{1,j};
                dudk ( 2*corners + 2,:)      = dutdk{2,j};

                dudalpha ( 2*corners + 1,:)  = dutdalpha{1,j};
                dudalpha ( 2*corners + 2,:)  = dutdalpha{2,j};

                dudf ( 2*corners + 1,:)      = dutdf{1,j};
                dudf ( 2*corners + 2,:)      = dutdf{2,j};

                dudc ( 2*corners + 1,:)    = dutdc{1,j};
                dudc ( 2*corners + 2,:)    = dutdc{2,j};

                if c == 1

                    dchecker (2*corners + 1, (i-1)*6 + 1 : (i-1)*6 + 3) = dutdom{1,j};
                    dchecker (2*corners + 2, (i-1)*6 + 1 : (i-1)*6 + 3) = dutdom{2,j};
                    dchecker (2*corners + 1, (i-1)*6 + 4 : (i-1)*6 + 6) = dutdT{1,j};
                    dchecker (2*corners + 2, (i-1)*6 + 4 : (i-1)*6 + 6) = dutdT{2,j};

                    % derivative with respect to the extrinsic parameters of the camera
                    dudomex (2*corners + 1,:) = dutdom{1,j} * dombdomex + dutdT{1,j}' * dTbdomex;
                    dudomex (2*corners + 2,:) = dutdom{2,j} * dombdomex + dutdT{2,j}' * dTbdomex;
                    dudTex (2*corners + 1,:)  = dutdom{1,j} * dombdTex  + dutdT{1,j}' * dTbdTex;
                    dudTex (2*corners + 2,:)  = dutdom{2,j} * dombdTex  + dutdT{2,j}' * dTbdTex;

                else

                    % derivates with respect to the extrinsic parameters of the chess boards 
                    dchecker (2*corners + 1, (i-1)*6 + 1 : (i-1)*6 + 3) = dutdomb{1,j} * dombdom + dutdTb{1,j}' * dTbdom;
                    dchecker (2*corners + 2, (i-1)*6 + 1 : (i-1)*6 + 3) = dutdomb{2,j} * dombdom + dutdTb{2,j}' * dTbdom;
                    dchecker (2*corners + 1, (i-1)*6 + 4 : (i-1)*6 + 6) = dutdomb{1,j} * dombdT  + dutdTb{1,j}' * dTbdT;
                    dchecker (2*corners + 2, (i-1)*6 + 4 : (i-1)*6 + 6) = dutdomb{2,j} * dombdT  + dutdTb{2,j}' * dTbdT;

                    % derivative with respect to the extrinsic parameters of the camera
                    dudomex (2*corners + 1,:) = dutdomb{1,j} * dombdomex + dutdTb{1,j}' * dTbdomex;
                    dudomex (2*corners + 2,:) = dutdomb{2,j} * dombdomex + dutdTb{2,j}' * dTbdomex;

                    dudTex (2*corners + 1,:)  = dutdomb{1,j} * dombdTex  + dutdTb{1,j}' * dTbdTex;
                    dudTex (2*corners + 2,:)  = dutdomb{2,j} * dombdTex  + dutdTb{2,j}' * dTbdTex;

                end

                corners = corners + 1;
             end
        end
        
    end
    
    boards_length_ges = boards_length_ges + sum(images{1,c}.active_images(1:boards) == 1);
    %boards_length_ges = boards_length_ges + sum(images{1,c}.active_images(1:1) == 1);
    boards_length(c+1) = boards_length_ges;
    
    U (1, 2*points*boards_length(c) + 1 : 2*points*boards_length(c+1)) = u;
    
    % Jacobian of the intrinsic parameters of all cameras ( 19 * cams)
%     J_all ( 2*points*boards_length - 2*corners+1 : 2*corners, (1:19) + 19*(c-1)) = ....
%         [dudA, dudB, dudC, dudomm, dudCam, dudk, dudalpha, dudf, dudc];
    J_all ( 2*points*boards_length(c) + 1 : 2*points*boards_length(c+1), (1:19) + 19*(c-1)) = ....
        [dudA, dudB, dudC, dudomm, dudCam, dudk, dudalpha, dudf, dudc];

    % Jacobian of the extrinsic parameters of all cameras (6 * cams)
%     J_all ( 2*points*boards_length - 2*corners+1 : 2*corners, 19*cams + (1:6) + 6*(c-1)) = ...
%         [dudomex, dudTex];
    J_all ( 2*points*boards_length(c) + 1 : 2*points*boards_length(c+1), 19*cams + (1:6) + 6*(c-1)) = ...
        [dudTex, dudomex];

    % Jacobian of the checkerboards extrinsic ( 6*boards)
%     J_all ( 2*points*boards_length - 2*corners+1 : 2*corners, 19*cams + 6*cams + (1:6*boards)) = dchecker;
    J_all ( 2*points*boards_length(c) + 1 : 2*points*boards_length(c+1), 19*cams + 6*cams + (1:6*boards)) = dchecker;

    clear u ut;
end

index = 0;
for n = 1 : size(active_vec,2)
   
    if active_vec(n) == 1
        index = index + 1;
    end
    
end

% J = zeros( 2*points*count_boards, index);
%for n = 1 : size(J_all,1)
%     J(n,:) = J_all(n,(logical(active_vec)));
%end
J = J_all(:,(logical(active_vec)));

end

