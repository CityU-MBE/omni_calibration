%% compute_mirror_point_in_camera
% calculate the 3D point on the mirror surface in the camera coordinate system
% Input: M     - points in the checkerboard system
%        om    - rodrigues coordinates of the checkerboard points
%        T     - translation vector of the checkerboard points
%        Cam   - Camera position
%        A,B,C - mirror parameters
%        omm   - rodigues coordinates between mirror and camera coordinate
%        system
%
% Output:
%   Xc      - reflected point on the mirror surface in the original mirror coordinate system
%   dXcdom  - derivative of Xc with respect to om
%   dXcdT   - derivative of Xc with respecht T
%   dXcdCam - derivative of Xc with respecht Cam
%   dXcdA   - derivative of Xc with respecht A
%   dXcdB   - derivative of Xc with respecht B
%   dXcdC   - derivative of Xc with respecht C
%   dXcdomm - derivative of Xc with respecht omm

%function [Xc, dXcdom, dXcdT, dXcdCam, dXcdA, dXcdB, dXcdC, dXcdomm] = compute_mirror_point_in_camera (om, T, Cam, A, B, C, omm, M)
function [Xc, varargout] = compute_mirror_point_in_camera (varargin)

if nargin >= 1
    
    if size(varargin,2) == 8
        
        om  = varargin{1};
        T   = varargin{2};
        Cam = varargin{3};
        A   = varargin{4};
        B   = varargin{5};
        C   = varargin{6};
        omm = varargin{7};
        M   = varargin{8};
        m   = size(M,2);

        if nargout > 1
          
            % calculate the 3D point on the mirror surface in the original mirror coordinate system
            [ Xm, dXmdom, dXmdT, dXmdCam, dXmdA, dXmdB, dXmdC] = reflected_mirror_point (om, T, Cam, A, B, C, M);
            [ Xc, dXc1domm, dXcdTm ] = rigid_motion2 (Xm, omm, Cam);
            Rm = rodrigues(omm);
            
            dXcdom  = cell(3,m);
            dXcdT   = cell(3,m);
            dXcdCam = cell(3,m);
            dXcdA   = cell(3,m);
            dXcdB   = cell(3,m);
            dXcdC   = cell(3,m);
            dXcdomm = cell(3,m);
            
            for i = 1 : m
                dXcdom{1,i} = [Rm(1,1), Rm(1,2), Rm(1,3)] * [dXmdom{1,i};dXmdom{2,i}; dXmdom{3,i}];
                dXcdom{2,i} = [Rm(2,1), Rm(2,2), Rm(2,3)] * [dXmdom{1,i};dXmdom{2,i}; dXmdom{3,i}];
                dXcdom{3,i} = [Rm(3,1), Rm(3,2), Rm(3,3)] * [dXmdom{1,i};dXmdom{2,i}; dXmdom{3,i}];

                dXcdT{1,i} = [ [Rm(1,1), Rm(1,2), Rm(1,3)] * [dXmdT{1,i}';dXmdT{2,i}'; dXmdT{3,i}'] ]';
                dXcdT{2,i} = [ [Rm(2,1), Rm(2,2), Rm(2,3)] * [dXmdT{1,i}';dXmdT{2,i}'; dXmdT{3,i}'] ]';
                dXcdT{3,i} = [ [Rm(3,1), Rm(3,2), Rm(3,3)] * [dXmdT{1,i}';dXmdT{2,i}'; dXmdT{3,i}'] ]';

                dXcdCam{1,i} = [ [Rm(1,1), Rm(1,2), Rm(1,3)] * [dXmdCam{1,i}';dXmdCam{2,i}'; dXmdCam{3,i}'] ]' + dXcdTm(1,:,i)';%[1;0;0];
                dXcdCam{2,i} = [ [Rm(2,1), Rm(2,2), Rm(2,3)] * [dXmdCam{1,i}';dXmdCam{2,i}'; dXmdCam{3,i}'] ]' + dXcdTm(2,:,i)';%[0;1;0];
                dXcdCam{3,i} = [ [Rm(3,1), Rm(3,2), Rm(3,3)] * [dXmdCam{1,i}';dXmdCam{2,i}'; dXmdCam{3,i}'] ]' + dXcdTm(3,:,i)';%[0;0;1];

                dXcdA{1,i} = [ Rm(1,1), Rm(1,2), Rm(1,3)] * [dXmdA{1,i}; dXmdA{2,i}; dXmdA{3,i}];
                dXcdA{2,i} = [ Rm(2,1), Rm(2,2), Rm(2,3)] * [dXmdA{1,i}; dXmdA{2,i}; dXmdA{3,i}];
                dXcdA{3,i} = [ Rm(3,1), Rm(3,2), Rm(3,3)] * [dXmdA{1,i}; dXmdA{2,i}; dXmdA{3,i}];

                dXcdB{1,i} = [ Rm(1,1), Rm(1,2), Rm(1,3)] * [dXmdB{1,i}; dXmdB{2,i}; dXmdB{3,i}];
                dXcdB{2,i} = [ Rm(2,1), Rm(2,2), Rm(2,3)] * [dXmdB{1,i}; dXmdB{2,i}; dXmdB{3,i}];
                dXcdB{3,i} = [ Rm(3,1), Rm(3,2), Rm(3,3)] * [dXmdB{1,i}; dXmdB{2,i}; dXmdB{3,i}];

                dXcdC{1,i} = [ Rm(1,1), Rm(1,2), Rm(1,3)] * [dXmdC{1,i}; dXmdC{2,i}; dXmdC{3,i}];
                dXcdC{2,i} = [ Rm(2,1), Rm(2,2), Rm(2,3)] * [dXmdC{1,i}; dXmdC{2,i}; dXmdC{3,i}];
                dXcdC{3,i} = [ Rm(3,1), Rm(3,2), Rm(3,3)] * [dXmdC{1,i}; dXmdC{2,i}; dXmdC{3,i}];

                dXcdomm{1,i} = dXc1domm(1,:,i);
                dXcdomm{2,i} = dXc1domm(2,:,i);
                dXcdomm{3,i} = dXc1domm(3,:,i);
            end
            
            varargout{1} = dXcdom;
            varargout{2} = dXcdT;
            varargout{3} = dXcdCam;
            varargout{4} = dXcdA;
            varargout{5} = dXcdB;
            varargout{6} = dXcdC;
            varargout{7} = dXcdomm;
        else
          
          % calculate the 3D point on the mirror surface in the original mirror coordinate system
          Xm = reflected_mirror_point (om, T, Cam, A, B, C, M);
          Xc  = rigid_motion2 (Xm, omm, Cam);
        end
        
	elseif size(varargin,2) == 6
        
        X   = varargin{1};
        Cam = varargin{2};
        A   = varargin{3};
        B   = varargin{4};
        C   = varargin{5};
        omm = varargin{6};
        m   = size(X,2);
        
        if nargout > 1
          
            % calculate the 3D point on the mirror surface in the original mirror coordinate system
            [ Xm, dXmdX, dXmdCam, dXmdA, dXmdB, dXmdC]  = reflected_mirror_point (X, Cam, A, B, C);
            [ Xc, dXc1domm, dXcdTm ] = rigid_motion2 (Xm, omm, Cam);
            Rm = rodrigues(omm);
            
            dXcdX   = cell(3,m);
            dXcdCam = cell(3,m);
            dXcdA   = cell(3,m);
            dXcdB   = cell(3,m);
            dXcdC   = cell(3,m);
            dXcdomm = cell(3,m);
            
            for i = 1 : m
                dXcdX{1,i} = [ [Rm(1,1), Rm(1,2), Rm(1,3)] * [dXmdX{1,i}';dXmdX{2,i}'; dXmdX{3,i}'] ]';
                dXcdX{2,i} = [ [Rm(2,1), Rm(2,2), Rm(2,3)] * [dXmdX{1,i}';dXmdX{2,i}'; dXmdX{3,i}'] ]';
                dXcdX{3,i} = [ [Rm(3,1), Rm(3,2), Rm(3,3)] * [dXmdX{1,i}';dXmdX{2,i}'; dXmdX{3,i}'] ]';

                dXcdCam{1,i} = [ [Rm(1,1), Rm(1,2), Rm(1,3)] * [dXmdCam{1,i}';dXmdCam{2,i}'; dXmdCam{3,i}'] ]' + dXcdTm(1,:,i)';%[1;0;0];
                dXcdCam{2,i} = [ [Rm(2,1), Rm(2,2), Rm(2,3)] * [dXmdCam{1,i}';dXmdCam{2,i}'; dXmdCam{3,i}'] ]' + dXcdTm(2,:,i)';%[0;1;0];
                dXcdCam{3,i} = [ [Rm(3,1), Rm(3,2), Rm(3,3)] * [dXmdCam{1,i}';dXmdCam{2,i}'; dXmdCam{3,i}'] ]' + dXcdTm(3,:,i)';%[0;0;1];

                dXcdA{1,i} = [ Rm(1,1), Rm(1,2), Rm(1,3)] * [dXmdA{1,i}; dXmdA{2,i}; dXmdA{3,i}];
                dXcdA{2,i} = [ Rm(2,1), Rm(2,2), Rm(2,3)] * [dXmdA{1,i}; dXmdA{2,i}; dXmdA{3,i}];
                dXcdA{3,i} = [ Rm(3,1), Rm(3,2), Rm(3,3)] * [dXmdA{1,i}; dXmdA{2,i}; dXmdA{3,i}];

                dXcdB{1,i} = [ Rm(1,1), Rm(1,2), Rm(1,3)] * [dXmdB{1,i}; dXmdB{2,i}; dXmdB{3,i}];
                dXcdB{2,i} = [ Rm(2,1), Rm(2,2), Rm(2,3)] * [dXmdB{1,i}; dXmdB{2,i}; dXmdB{3,i}];
                dXcdB{3,i} = [ Rm(3,1), Rm(3,2), Rm(3,3)] * [dXmdB{1,i}; dXmdB{2,i}; dXmdB{3,i}];

                dXcdC{1,i} = [ Rm(1,1), Rm(1,2), Rm(1,3)] * [dXmdC{1,i}; dXmdC{2,i}; dXmdC{3,i}];
                dXcdC{2,i} = [ Rm(2,1), Rm(2,2), Rm(2,3)] * [dXmdC{1,i}; dXmdC{2,i}; dXmdC{3,i}];
                dXcdC{3,i} = [ Rm(3,1), Rm(3,2), Rm(3,3)] * [dXmdC{1,i}; dXmdC{2,i}; dXmdC{3,i}];

                dXcdomm{1,i} = dXc1domm(1,:,i);
                dXcdomm{2,i} = dXc1domm(2,:,i);
                dXcdomm{3,i} = dXc1domm(3,:,i);
            end
            
            varargout{1} = dXmdX;
            varargout{2} = dXmdCam;
            varargout{3} = dXmdA;
            varargout{4} = dXmdB;
            varargout{5} = dXmdC;
            varargout{6} = dXcdomm;
        else
          
          % calculate the 3D point on the mirror surface in the original mirror coordinate system
          Xm = reflected_mirror_point (X, Cam, A, B, C);
          Xc = rigid_motion2 (Xm, omm, Cam);
        end
        
    elseif size(varargin,2) == 5
        
        X   = varargin{1};
        Cam = varargin{2};
        A   = varargin{3};
        B   = varargin{4};
        C   = varargin{5};
   
        % calculate the 3D point on the mirror surface in the original mirror coordinate system
        Xm = reflected_mirror_point_SVP (X, A, B, C);
        Xc = rigid_motion2 (Xm, [0 0 0], Cam);
    else    
        fprintf('Incorrect number of input data.\n');      
    end
else 
  
	  % test derivatives
    M = [ 20, 10; 50, 10; 80, 10];
    om = [0.1, 0.2, 0.15];
    T = [-50;45;10];
    e = 34;
    Cam = [1; 2; -e];
        
    a = 26.857800;
    b = 20.848500;
    A = -b^2/a^2;
    B = 0;
    C = -b^2;
    
    omm = [0.1, 0.2, 0.3];
    
    test_derivatives(@compute_mirror_point_in_camera,1e-8,om,T,Cam,A,B,C,omm,M)
    
end