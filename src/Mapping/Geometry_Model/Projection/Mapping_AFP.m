%% Mapping_AFP
% Compute the the reflected points on the mirror surface from the 3D world
% point
% Input: XR    - rotated world point
%        CamR  - rotated camera position
%        A,B,C - mirror parameters
%
% Output:
%   mirR     - point on the mirror surface in the rotated mirror coordinate system
%   dmrdXR   - derivative of mirR with respect to XR
%   dmrdCamR - derivatove of mirR with respect to CamR
%   dmrdA    - derivatove of mirR with respect to A
%   dmrdB    - derivatove of mirR with respect to B
%   dmrdC    - derivatove of mirR with respect to C


function [mirR, dmrdXR, dmrdCamR, dmrdA, dmrdB, dmrdC ] = Mapping_AFP (XR, CamR, A, B, C)

if nargin == 5
    
    % Calculate the coefficients of the polynom for z
    EE = [CamR(2), CamR(3) , XR(1), XR(2), XR(3), A , B , C]'; 
    p = MexComputeForwardProjection8Sols(EE)';                 

    z_mir = roots(p);
    
    mirR = mirror_point_mir(z_mir,A,B,C,CamR,XR);                         

    if nargout > 1
        
        [mirR,ind] = mirror_point_mir(z_mir,A,B,C,CamR,XR);

        % Compute Derivative of the reflecting mirror point (dmR = (dxp, dyp, dzp)
        % with respect to A; B; C; dy; dz; u; v; w;
        [dmrX, dmrY, dmrZ] = Jacobian_polynom (XR, CamR, A, B, C, mirR, p, ind);

        dmrdXR{1,1} = dmrX(6:8)';
        dmrdXR{2,1} = dmrY(6:8)';
        dmrdXR{3,1} = dmrZ(6:8)';

        dmrdCamR{1,1} = [0, dmrX(4), dmrX(5)]';
        dmrdCamR{2,1} = [0, dmrY(4), dmrY(5)]';
        dmrdCamR{3,1} = [0, dmrZ(4), dmrZ(5)]';
        
        dmrdA{1,1} = dmrX(1);
        dmrdA{2,1} = dmrY(1);
        dmrdA{3,1} = dmrZ(1);

        dmrdB{1,1} = dmrX(2);
        dmrdB{2,1} = dmrY(2);
        dmrdB{3,1} = dmrZ(2);

        dmrdC{1,1} = dmrX(3);
        dmrdC{2,1} = dmrY(3);
        dmrdC{3,1} = dmrZ(3);

    end
     
else
    
    M = [ 20; 50; 80];
    om = [0.1, 0.2, 0.15];
    T = [-5000;4500;1000];
    e = 34;
    %Cam = [1; 2; -e];
    Cam = [0; 0; -e];
    
    X = rigid_motion(M,om,T);
    RR = compute_RR_new(Cam);
    Xr = RR * X;
    Xr = [1;1;1];
    CamR = RR * Cam;
    
    a = 26.857800;
    b = 20.848500;
    A = -b^2/a^2;
    B = 10;
    C = -b^2;
            
    % test derivatives
    test_derivatives(@Mapping_AFP,1e-8,Xr,CamR,A,B,C);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




