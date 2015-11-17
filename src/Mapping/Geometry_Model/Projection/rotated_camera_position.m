%% rotated camera point
% calculate the camera position in the rotated mirror coordinate system
%
% Input: 
%   Cam - Camera position
% Output:
%   CamR        - camera position in the rotated mirror coordinate system
%   dCamRdCam   _ derivative of CamR with respect to Cam
%
function [ CamR, dCamRdCam] = rotated_camera_position (Cam)

if nargin == 1

    % compute Pre-Rotation % Achtung abfangen falls cx und cy == 0 sind
    [RR, dRR] = compute_RR_new( Cam ); 

    CamR    = RR * Cam;

    dCamRdCam{1,1} = [ [dRR{1,1}(1), dRR{1,2}(1), dRR{1,3}(1)] * Cam + RR(1,1); [dRR{1,1}(2), dRR{1,2}(2), dRR{1,3}(2)] * Cam + RR(1,2); [dRR{1,1}(3), dRR{1,2}(3), dRR{1,3}(3)] * Cam + RR(1,3)];
    dCamRdCam{2,1} = [ [dRR{2,1}(1), dRR{2,2}(1), dRR{2,3}(1)] * Cam + RR(2,1); [dRR{2,1}(2), dRR{2,2}(2), dRR{2,3}(2)] * Cam + RR(2,2); [dRR{2,1}(3), dRR{2,2}(3), dRR{2,3}(3)] * Cam + RR(2,3)];
	dCamRdCam{3,1} = [ [dRR{3,1}(1), dRR{3,2}(1), dRR{3,3}(1)] * Cam + RR(3,1); [dRR{3,1}(2), dRR{3,2}(2), dRR{3,3}(2)] * Cam + RR(3,2); [dRR{3,1}(3), dRR{3,2}(3), dRR{3,3}(3)] * Cam + RR(3,3)];

else
	% test derivatives
    e = 34;
    Cam = [1; 2; -e];
    
    test_derivatives(@rotated_camera_position,1e-8,Cam);
end

end