%% rotated_reflected_mirror_point
% calculate the 3D point on the mirror surface in the rotated mirror coordinate system
% Input: M     - points in the checkerboard system
%        om    - rodrigues coordinates of the checkerboard points
%        T     - translation vector of the checkerboard points
%        Cam   - Camera position
%        A,B,C - mirror parameters
%
% Output:
%   XmR      - reflected point on the mirror surface in the rotated mirror coordinate system
%   dXmRdom  - derivative of XmR with respect to om
%   dXmRdT   - derivatove of XmR with respecht T
%   dXmRdCam - derivatove of XmR with respecht Cam
%   dXmRdA   - derivatove of XmR with respecht A
%   dXmRdB   - derivatove of XmR with respecht B
%   dXmRdC   - derivatove of XmR with respecht C

%function [ XmR, dXmRdom, dXmRdT, dXmdCam, dXmRdA, dXmRdB, dXmRdC] = rotated_reflected_mirror_point (om, T, Cam, A, B, C, M)
function [ XmR, varargout] = rotated_reflected_mirror_point ( varargin )

if nargin >= 1
    
    if size(varargin,2) == 7
        
        om  = varargin{1};
        T   = varargin{2};
        Cam = varargin{3};
        A   = varargin{4};
        B   = varargin{5};
        C   = varargin{6};
        M   = varargin{7};
        
        if nargout == 1
        
            % calculate the 3D world point in the rotated mirror coordinate system
            XR = rotated_world_point (om, T, Cam, M);

            % calculate the camera position in the rotated mirror coordinate system
            CamR = rotated_camera_position (Cam);

            % Compute the the reflected points on the mirror surface from the 3D world point
            for i = 1 : size(XR,2)
                XmR(:,i) = Mapping_AFP (XR(:,i), CamR, A, B, C);
            end

        else

            % calculate the 3D world point in the rotated mirror coordinate system
            [ XR, dXRdom, dXRdT, dXRdCam] = rotated_world_point (om, T, Cam, M);

            % calculate the camera position in the rotated mirror coordinate system
            [ CamR, dCamRdCam ] = rotated_camera_position (Cam);

            % Compute the the reflected points on the mirror surface from the 3D world point
            for i = 1 : size(XR,2)
                [XmR(:,i), dXmRdXR(:,i), dXmRdCamR(:,i), dXmRdA(:,i), dXmRdB(:,i), dXmRdC(:,i) ] = Mapping_AFP (XR(:,i), CamR, A, B, C);
            end

        end
        
        % compute derivatives   
        if nargout > 1
        
            for i = 1 : size(XR,2)
        
                dXmRdom{1,i} = [ dXmRdXR{1,i}(1)*dXRdom{1,i}(1) + dXmRdXR{1,i}(2)*dXRdom{2,i}(1) + dXmRdXR{1,i}(3)*dXRdom{3,i}(1) , ...
                                 dXmRdXR{1,i}(1)*dXRdom{1,i}(2) + dXmRdXR{1,i}(2)*dXRdom{2,i}(2) + dXmRdXR{1,i}(3)*dXRdom{3,i}(2), ...
                                 dXmRdXR{1,i}(1)*dXRdom{1,i}(3) + dXmRdXR{1,i}(2)*dXRdom{2,i}(3) + dXmRdXR{1,i}(3)*dXRdom{3,i}(3) ];
                dXmRdom{2,i} = [ dXmRdXR{2,i}(1)*dXRdom{1,i}(1) + dXmRdXR{2,i}(2)*dXRdom{2,i}(1) + dXmRdXR{2,i}(3)*dXRdom{3,i}(1) , ...
                                 dXmRdXR{2,i}(1)*dXRdom{1,i}(2) + dXmRdXR{2,i}(2)*dXRdom{2,i}(2) + dXmRdXR{2,i}(3)*dXRdom{3,i}(2) , ...
                                 dXmRdXR{2,i}(1)*dXRdom{1,i}(3) + dXmRdXR{2,i}(2)*dXRdom{2,i}(3) + dXmRdXR{2,i}(3)*dXRdom{3,i}(3) ];
                dXmRdom{3,i} = [ dXmRdXR{3,i}(1)*dXRdom{1,i}(1) + dXmRdXR{3,i}(2)*dXRdom{2,i}(1) + dXmRdXR{3,i}(3)*dXRdom{3,i}(1) , ...
                                 dXmRdXR{3,i}(1)*dXRdom{1,i}(2) + dXmRdXR{3,i}(2)*dXRdom{2,i}(2) + dXmRdXR{3,i}(3)*dXRdom{3,i}(2) , ...
                                 dXmRdXR{3,i}(1)*dXRdom{1,i}(3) + dXmRdXR{3,i}(2)*dXRdom{2,i}(3) + dXmRdXR{3,i}(3)*dXRdom{3,i}(3) ];

                dXmRdT{1,i} = [ dXmRdXR{1,i}(1)*dXRdT{1,i}(1) + dXmRdXR{1,i}(2)*dXRdT{2,i}(1) + dXmRdXR{1,i}(3)*dXRdT{3,i}(1); ...
                                dXmRdXR{1,i}(1)*dXRdT{1,i}(2) + dXmRdXR{1,i}(2)*dXRdT{2,i}(2) + dXmRdXR{1,i}(3)*dXRdT{3,i}(2); ...
                                dXmRdXR{1,i}(1)*dXRdT{1,i}(3) + dXmRdXR{1,i}(2)*dXRdT{2,i}(3) + dXmRdXR{1,i}(3)*dXRdT{3,i}(3) ];
                dXmRdT{2,i} = [ dXmRdXR{2,i}(1)*dXRdT{1,i}(1) + dXmRdXR{2,i}(2)*dXRdT{2,i}(1) + dXmRdXR{2,i}(3)*dXRdT{3,i}(1); ...
                                dXmRdXR{2,i}(1)*dXRdT{1,i}(2) + dXmRdXR{2,i}(2)*dXRdT{2,i}(2) + dXmRdXR{2,i}(3)*dXRdT{3,i}(2); ...
                                dXmRdXR{2,i}(1)*dXRdT{1,i}(3) + dXmRdXR{2,i}(2)*dXRdT{2,i}(3) + dXmRdXR{2,i}(3)*dXRdT{3,i}(3) ];
                dXmRdT{3,i} = [ dXmRdXR{3,i}(1)*dXRdT{1,i}(1) + dXmRdXR{3,i}(2)*dXRdT{2,i}(1) + dXmRdXR{3,i}(3)*dXRdT{3,i}(1); ...
                                dXmRdXR{3,i}(1)*dXRdT{1,i}(2) + dXmRdXR{3,i}(2)*dXRdT{2,i}(2) + dXmRdXR{3,i}(3)*dXRdT{3,i}(2); ...
                                dXmRdXR{3,i}(1)*dXRdT{1,i}(3) + dXmRdXR{3,i}(2)*dXRdT{2,i}(3) + dXmRdXR{3,i}(3)*dXRdT{3,i}(3) ];

                dXmdCam{1,i} = [ dXmRdXR{1,i}(1)    *dXRdCam{1,i}(1)    + dXmRdXR{1,i}(2)   *dXRdCam{2,i}(1)    + dXmRdXR{1,i}(3)   *dXRdCam{3,i}(1) + ...
                                 dXmRdCamR{1,i}(1)  *dCamRdCam{1,1}(1)  + dXmRdCamR{1,i}(2) *dCamRdCam{2,1}(1)  + dXmRdCamR{1,i}(3) *dCamRdCam{3,1}(1); ...
                                 dXmRdXR{1,i}(1)    *dXRdCam{1,i}(2)    + dXmRdXR{1,i}(2)   *dXRdCam{2,i}(2)    + dXmRdXR{1,i}(3)   *dXRdCam{3,i}(2) + ...
                                 dXmRdCamR{1,i}(1)  *dCamRdCam{1,1}(2)  + dXmRdCamR{1,i}(2) *dCamRdCam{2,1}(2)  + dXmRdCamR{1,i}(3) *dCamRdCam{3,1}(2); ...
                                 dXmRdXR{1,i}(1)    *dXRdCam{1,i}(3)    + dXmRdXR{1,i}(2)   *dXRdCam{2,i}(3)    + dXmRdXR{1,i}(3)   *dXRdCam{3,i}(3) + ...
                                 dXmRdCamR{1,i}(1)  *dCamRdCam{1,1}(3)  + dXmRdCamR{1,i}(2) *dCamRdCam{2,1}(3)  + dXmRdCamR{1,i}(3) *dCamRdCam{3,1}(3)];

                dXmdCam{2,i} = [ dXmRdXR{2,i}(1)    *dXRdCam{1,i}(1)    + dXmRdXR{2,i}(2)   *dXRdCam{2,i}(1)    + dXmRdXR{2,i}(3)   *dXRdCam{3,i}(1) + ...
                                 dXmRdCamR{2,i}(1)  *dCamRdCam{1,1}(1)  + dXmRdCamR{2,i}(2) *dCamRdCam{2,1}(1)  + dXmRdCamR{2,i}(3) *dCamRdCam{3,1}(1); ...
                                 dXmRdXR{2,i}(1)    *dXRdCam{1,i}(2)    + dXmRdXR{2,i}(2)   *dXRdCam{2,i}(2)    + dXmRdXR{2,i}(3)   *dXRdCam{3,i}(2) + ...
                                 dXmRdCamR{2,i}(1)  *dCamRdCam{1,1}(2)  + dXmRdCamR{2,i}(2) *dCamRdCam{2,1}(2)  + dXmRdCamR{2,i}(3) *dCamRdCam{3,1}(2); ...
                                 dXmRdXR{2,i}(1)    *dXRdCam{1,i}(3)    + dXmRdXR{2,i}(2)   *dXRdCam{2,i}(3)    + dXmRdXR{2,i}(3)   *dXRdCam{3,i}(3) + ...
                                 dXmRdCamR{2,i}(1)  *dCamRdCam{1,1}(3)  + dXmRdCamR{2,i}(2) *dCamRdCam{2,1}(3)  + dXmRdCamR{2,i}(3) *dCamRdCam{3,1}(3) ];

                dXmdCam{3,i} = [ dXmRdXR{3,i}(1)    *dXRdCam{1,i}(1)    + dXmRdXR{3,i}(2)   *dXRdCam{2,i}(1)    + dXmRdXR{3,i}(3)   *dXRdCam{3,i}(1) + ...
                                 dXmRdCamR{3,i}(1)  *dCamRdCam{1,1}(1)  + dXmRdCamR{3,i}(2) *dCamRdCam{2,1}(1)  + dXmRdCamR{3,i}(3) *dCamRdCam{3,1}(1); ...
                                 dXmRdXR{3,i}(1)    *dXRdCam{1,i}(2)    + dXmRdXR{3,i}(2)   *dXRdCam{2,i}(2)    + dXmRdXR{3,i}(3)   *dXRdCam{3,i}(2) + ...
                                 dXmRdCamR{3,i}(1)  *dCamRdCam{1,1}(2)  + dXmRdCamR{3,i}(2) *dCamRdCam{2,1}(2)  + dXmRdCamR{3,i}(3) *dCamRdCam{3,1}(2); ...
                                 dXmRdXR{3,i}(1)    *dXRdCam{1,i}(3)    + dXmRdXR{3,i}(2)   *dXRdCam{2,i}(3)    + dXmRdXR{3,i}(3)   *dXRdCam{3,i}(3) + ...
                                 dXmRdCamR{3,i}(1)  *dCamRdCam{1,1}(3)  + dXmRdCamR{3,i}(2) *dCamRdCam{2,1}(3)  + dXmRdCamR{3,i}(3) *dCamRdCam{3,1}(3) ];


                dXmdA{1,i} = dXmRdA(1,i);
                dXmdA{2,i} = dXmRdA(2,i);
                dXmdA{3,i} = dXmRdA(3,i);

                dXmdB{1,i} = dXmRdB(1,i);
                dXmdB{2,i} = dXmRdB(2,i);
                dXmdB{3,i} = dXmRdB(3,i);

                dXmdC{1,i} = dXmRdC(1,i);
                dXmdC{2,i} = dXmRdC(2,i);
                dXmdC{3,i} = dXmRdC(3,i);
            end
            
            varargout{1} = dXmRdom;
            varargout{2} = dXmRdT;
            varargout{3} = dXmdCam;
            varargout{4} = dXmRdA;
            varargout{5} = dXmRdB;
            varargout{6} = dXmRdC;
            
        end
	
    elseif size(varargin,2) == 5
        
        X   = varargin{1};
        Cam = varargin{2};
        A   = varargin{3};
        B   = varargin{4};
        C   = varargin{5};
        
        if nargout == 1
        
            % calculate the 3D world point in the rotated mirror coordinate system
            XR = rotated_world_point (X, Cam);

            % calculate the camera position in the rotated mirror coordinate system
            CamR = rotated_camera_position (Cam);

            % Compute the the reflected points on the mirror surface from the 3D world point
            for i = 1 : size(XR,2)
                XmR(:,i) = Mapping_AFP (XR(:,i), CamR, A, B, C);
            end

        else

            % calculate the 3D world point in the rotated mirror coordinate system
            [ XR, dXRdX, dXRdCam] = rotated_world_point (X, Cam);

            % calculate the camera position in the rotated mirror coordinate system
            [ CamR, dCamRdCam ] = rotated_camera_position (Cam);

            % Compute the the reflected points on the mirror surface from the 3D world point
            for i = 1 : size(XR,2)
                [XmR(:,i), dXmRdXR(:,i), dXmRdCamR(:,i), dXmRdA(:,i), dXmRdB(:,i), dXmRdC(:,i) ] = Mapping_AFP (XR(:,i), CamR, A, B, C);
            end

        end
        
         % compute derivatives    
        if nargout > 1
        
            for i = 1 : size(XR,2)
        
                dXmRdX{1,i}  = [ dXmRdXR{1,i}(1)    *dXRdX{1,i}(1) + dXmRdXR{1,i}(2) *dXRdX{2,i}(1) + dXmRdXR{1,i}(3)   *dXRdX{3,i}(1) ; ...
                                 dXmRdXR{1,i}(1)    *dXRdX{1,i}(2) + dXmRdXR{1,i}(2) *dXRdX{2,i}(2) + dXmRdXR{1,i}(3)   *dXRdX{3,i}(2); ...
                                 dXmRdXR{1,i}(1)    *dXRdX{1,i}(3) + dXmRdXR{1,i}(2) *dXRdX{2,i}(3) + dXmRdXR{1,i}(3)   *dXRdX{3,i}(3) ];
                dXmRdX{2,i}  = [ dXmRdXR{2,i}(1)    *dXRdX{1,i}(1) + dXmRdXR{2,i}(2) *dXRdX{2,i}(1) + dXmRdXR{2,i}(3)   *dXRdX{3,i}(1) ; ...
                                 dXmRdXR{2,i}(1)    *dXRdX{1,i}(2) + dXmRdXR{2,i}(2) *dXRdX{2,i}(2) + dXmRdXR{2,i}(3)   *dXRdX{3,i}(2) ; ...
                                 dXmRdXR{2,i}(1)    *dXRdX{1,i}(3) + dXmRdXR{2,i}(2) *dXRdX{2,i}(3) + dXmRdXR{2,i}(3)   *dXRdX{3,i}(3) ];
                dXmRdX{3,i}  = [ dXmRdXR{3,i}(1)    *dXRdX{1,i}(1) + dXmRdXR{3,i}(2) *dXRdX{2,i}(1) + dXmRdXR{3,i}(3)   *dXRdX{3,i}(1) ; ...
                                 dXmRdXR{3,i}(1)    *dXRdX{1,i}(2) + dXmRdXR{3,i}(2) *dXRdX{2,i}(2) + dXmRdXR{3,i}(3)   *dXRdX{3,i}(2) ; ...
                                 dXmRdXR{3,i}(1)    *dXRdX{1,i}(3) + dXmRdXR{3,i}(2) *dXRdX{2,i}(3) + dXmRdXR{3,i}(3)   *dXRdX{3,i}(3) ];

                dXmdCam{1,i} = [ dXmRdXR{1,i}(1)    *dXRdCam{1,i}(1)    + dXmRdXR{1,i}(2)   *dXRdCam{2,i}(1)    + dXmRdXR{1,i}(3)   *dXRdCam{3,i}(1) + ...
                                 dXmRdCamR{1,i}(1)  *dCamRdCam{1,1}(1)  + dXmRdCamR{1,i}(2) *dCamRdCam{2,1}(1)  + dXmRdCamR{1,i}(3) *dCamRdCam{3,1}(1); ...
                                 dXmRdXR{1,i}(1)    *dXRdCam{1,i}(2)    + dXmRdXR{1,i}(2)   *dXRdCam{2,i}(2)    + dXmRdXR{1,i}(3)   *dXRdCam{3,i}(2) + ...
                                 dXmRdCamR{1,i}(1)  *dCamRdCam{1,1}(2)  + dXmRdCamR{1,i}(2) *dCamRdCam{2,1}(2)  + dXmRdCamR{1,i}(3) *dCamRdCam{3,1}(2); ...
                                 dXmRdXR{1,i}(1)    *dXRdCam{1,i}(3)    + dXmRdXR{1,i}(2)   *dXRdCam{2,i}(3)    + dXmRdXR{1,i}(3)   *dXRdCam{3,i}(3) + ...
                                 dXmRdCamR{1,i}(1)  *dCamRdCam{1,1}(3)  + dXmRdCamR{1,i}(2) *dCamRdCam{2,1}(3)  + dXmRdCamR{1,i}(3) *dCamRdCam{3,1}(3)];

                dXmdCam{2,i} = [ dXmRdXR{2,i}(1)    *dXRdCam{1,i}(1)    + dXmRdXR{2,i}(2)   *dXRdCam{2,i}(1)    + dXmRdXR{2,i}(3)   *dXRdCam{3,i}(1) + ...
                                 dXmRdCamR{2,i}(1)  *dCamRdCam{1,1}(1)  + dXmRdCamR{2,i}(2) *dCamRdCam{2,1}(1)  + dXmRdCamR{2,i}(3) *dCamRdCam{3,1}(1); ...
                                 dXmRdXR{2,i}(1)    *dXRdCam{1,i}(2)    + dXmRdXR{2,i}(2)   *dXRdCam{2,i}(2)    + dXmRdXR{2,i}(3)   *dXRdCam{3,i}(2) + ...
                                 dXmRdCamR{2,i}(1)  *dCamRdCam{1,1}(2)  + dXmRdCamR{2,i}(2) *dCamRdCam{2,1}(2)  + dXmRdCamR{2,i}(3) *dCamRdCam{3,1}(2); ...
                                 dXmRdXR{2,i}(1)    *dXRdCam{1,i}(3)    + dXmRdXR{2,i}(2)   *dXRdCam{2,i}(3)    + dXmRdXR{2,i}(3)   *dXRdCam{3,i}(3) + ...
                                 dXmRdCamR{2,i}(1)  *dCamRdCam{1,1}(3)  + dXmRdCamR{2,i}(2) *dCamRdCam{2,1}(3)  + dXmRdCamR{2,i}(3) *dCamRdCam{3,1}(3) ];

                dXmdCam{3,i} = [ dXmRdXR{3,i}(1)    *dXRdCam{1,i}(1)    + dXmRdXR{3,i}(2)   *dXRdCam{2,i}(1)    + dXmRdXR{3,i}(3)   *dXRdCam{3,i}(1) + ...
                                 dXmRdCamR{3,i}(1)  *dCamRdCam{1,1}(1)  + dXmRdCamR{3,i}(2) *dCamRdCam{2,1}(1)  + dXmRdCamR{3,i}(3) *dCamRdCam{3,1}(1); ...
                                 dXmRdXR{3,i}(1)    *dXRdCam{1,i}(2)    + dXmRdXR{3,i}(2)   *dXRdCam{2,i}(2)    + dXmRdXR{3,i}(3)   *dXRdCam{3,i}(2) + ...
                                 dXmRdCamR{3,i}(1)  *dCamRdCam{1,1}(2)  + dXmRdCamR{3,i}(2) *dCamRdCam{2,1}(2)  + dXmRdCamR{3,i}(3) *dCamRdCam{3,1}(2); ...
                                 dXmRdXR{3,i}(1)    *dXRdCam{1,i}(3)    + dXmRdXR{3,i}(2)   *dXRdCam{2,i}(3)    + dXmRdXR{3,i}(3)   *dXRdCam{3,i}(3) + ...
                                 dXmRdCamR{3,i}(1)  *dCamRdCam{1,1}(3)  + dXmRdCamR{3,i}(2) *dCamRdCam{2,1}(3)  + dXmRdCamR{3,i}(3) *dCamRdCam{3,1}(3) ];


                dXmdA{1,i} = dXmRdA(1,i);
                dXmdA{2,i} = dXmRdA(2,i);
                dXmdA{3,i} = dXmRdA(3,i);

                dXmdB{1,i} = dXmRdB(1,i);
                dXmdB{2,i} = dXmRdB(2,i);
                dXmdB{3,i} = dXmRdB(3,i);

                dXmdC{1,i} = dXmRdC(1,i);
                dXmdC{2,i} = dXmRdC(2,i);
                dXmdC{3,i} = dXmRdC(3,i);
            end
            
            varargout{1} = dXmRdX;
            varargout{2} = dXmdCam;
            varargout{3} = dXmRdA;
            varargout{4} = dXmRdB;
            varargout{5} = dXmRdC;
            
        end
    
	else
        
        fprintf('Incorrect number of input data.\n');
                
    end
                    
else
    
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
    
    R = rodrigues(om);
    Y = R*M + repmat(T,[1 size(M,2)]);
    
    % test derivatives
    test_derivatives(@rotated_reflected_mirror_point,1e-8,om,T,Cam,A,B,C,M);  
    %test_derivatives(@rotated_reflected_mirror_point,1e-8,Y,Cam,A,B,C);  
end

end

