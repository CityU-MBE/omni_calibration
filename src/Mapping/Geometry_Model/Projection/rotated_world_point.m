%% rotated world point
% calculate the 3D world point in the rotated mirror coordinate system
% Input: M   - points in the checkerboard system
%        om  - rodrigues coordinates of the checkerboard points
%        T   - translation vector of the checkerboard points
%        Cam - Camera position
%
% Output:
%   XR      - world point in the rotated mirror coordinate system
%   dXRdom  - derivative of XR with respect to om
%   dXRdT   - derivatove of XR with respecht T
%   dXRdCam - derivatove of XR with respecht Cam
%
%function [ XR, dXRdom, dXRdT, dXRdCam] = rotated_world_point (om, T, Cam, M)
function [ XR, varargout ] = rotated_world_point ( varargin )

if nargin >= 1
    
    if size(varargin,2) == 4
        
        om  = varargin{1};
        T   = varargin{2};
        Cam = varargin{3};
        M   = varargin{4};
                
        % Point in the mirror coordinate system from the checkerboard
        % coordinates
        [X,dXdom,dXdT] = rigid_motion(M,om,T);

        % compute Pre-Rotation 
        % Achtung abfangen falls cx und cy == 0 sind
        [RR, dRR] = compute_RR_new( Cam ); 

        % compute XR in the rotated mirror coordinate system
        XR = RR * X;

        if nargout > 1
            % compute derivatives
            for i = 1 : size(X,2)
                dXRdom{1,i} = RR(1,:) * dXdom ( 3*(i-1)+1 : 3*(i-1)+3 , : );
                dXRdom{2,i} = RR(2,:) * dXdom ( 3*(i-1)+1 : 3*(i-1)+3 , : );
                dXRdom{3,i} = RR(3,:) * dXdom ( 3*(i-1)+1 : 3*(i-1)+3 , : );

                dXRdT{1,i} = (RR(1,:) * dXdT ( 3*(i-1)+1 : 3*(i-1)+3 , : ) )';
                dXRdT{2,i} = (RR(2,:) * dXdT ( 3*(i-1)+1 : 3*(i-1)+3 , : ) )';
                dXRdT{3,i} = (RR(3,:) * dXdT ( 3*(i-1)+1 : 3*(i-1)+3 , : ) )';

                dXRdCam{1,i} = [ [dRR{1,1}(1), dRR{1,2}(1), dRR{1,3}(1)] * X(:,i); [dRR{1,1}(2), dRR{1,2}(2), dRR{1,3}(2)] * X(:,i); [dRR{1,1}(3), dRR{1,2}(3), dRR{1,3}(3)] * X(:,i)];
                dXRdCam{2,i} = [ [dRR{2,1}(1), dRR{2,2}(1), dRR{2,3}(1)] * X(:,i); [dRR{2,1}(2), dRR{2,2}(2), dRR{2,3}(2)] * X(:,i); [dRR{2,1}(3), dRR{2,2}(3), dRR{2,3}(3)] * X(:,i)];
                dXRdCam{3,i} = [ [dRR{3,1}(1), dRR{3,2}(1), dRR{3,3}(1)] * X(:,i); [dRR{3,1}(2), dRR{3,2}(2), dRR{3,3}(2)] * X(:,i); [dRR{3,1}(3), dRR{3,2}(3), dRR{3,3}(3)] * X(:,i)];
            end
            varargout{1} = dXRdom;
            varargout{2} = dXRdT;
            varargout{3} = dXRdCam;
        end
    
    elseif size(varargin,2) == 2
        
        X   = varargin{1};
        Cam = varargin{2};
                
        % Point in the mirror coordinate system from the checkerboard
        % coordinates = X

        % compute Pre-Rotation 
        % Achtung abfangen falls cx und cy == 0 sind
        [RR, dRR] = compute_RR_new( Cam ); 

        % compute XR in the rotated mirror coordinate system
        XR = RR * X;

        if nargout > 1
            % compute derivatives
            for i = 1 : size(X,2)
                dXRdX{1,i} = RR(:,1);
                dXRdX{2,i} = RR(:,2);
                dXRdX{3,i} = RR(:,3);

                dXRdCam{1,i} = [ [dRR{1,1}(1), dRR{1,2}(1), dRR{1,3}(1)] * X(:,i); [dRR{1,1}(2), dRR{1,2}(2), dRR{1,3}(2)] * X(:,i); [dRR{1,1}(3), dRR{1,2}(3), dRR{1,3}(3)] * X(:,i)];
                dXRdCam{2,i} = [ [dRR{2,1}(1), dRR{2,2}(1), dRR{2,3}(1)] * X(:,i); [dRR{2,1}(2), dRR{2,2}(2), dRR{2,3}(2)] * X(:,i); [dRR{2,1}(3), dRR{2,2}(3), dRR{2,3}(3)] * X(:,i)];
                dXRdCam{3,i} = [ [dRR{3,1}(1), dRR{3,2}(1), dRR{3,3}(1)] * X(:,i); [dRR{3,1}(2), dRR{3,2}(2), dRR{3,3}(2)] * X(:,i); [dRR{3,1}(3), dRR{3,2}(3), dRR{3,3}(3)] * X(:,i)];
            end
            
            varargout{1} = dXRdX;
            varargout{2} = dXRdCam;
        end
               
    else
        
        fprintf('Incorrect number of input data.\n');
                
    end
    
        
    
else
    % test derivatives
    M = [0 0 0; 0 100 0; 0 200 0; 0 300 0]';
    %M = [ 20, 10 ; 50, 10; 80, 10];
    om = [0.1, 0.2, 0.15];
    T = [-50;45;10];
    e = 34;
    Cam = [1; 2; -e];    
    R = rodrigues(om);
    Y = R*M + repmat(T,[1 size(M,2)]);
    
    test_derivatives(@rotated_world_point,1e-8,om,T,Cam,M);   
    %test_derivatives(@rotated_world_point,1e-8,Y,Cam,M);  
end

end