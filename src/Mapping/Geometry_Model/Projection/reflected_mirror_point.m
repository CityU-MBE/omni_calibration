%% reflected_mirror_point
% calculate the 3D point on the mirror surface in the original mirror coordinate system
% Input: M     - points in the checkerboard system
%        om    - rodrigues coordinates of the checkerboard points
%        T     - translation vector of the checkerboard points
%        Cam   - Camera position
%        A,B,C - mirror parameters
%
% Output:
%   Xm      - reflected point on the mirror surface in the original mirror coordinate system
%   dXmdom  - derivative of Xm with respect to om
%   dXmdT   - derivatove of Xm with respecht T
%   dXmdCam - derivatove of Xm with respecht Cam
%   dXmdA   - derivatove of Xm with respecht A
%   dXmdB   - derivatove of Xm with respecht B
%   dXmdC   - derivatove of Xm with respecht C

%function [Xm, dXmdom, dXmdT, dXmdCam, dXmdA, dXmdB, dXmdC]  = reflected_mirror_point (om, T, Cam, A, B, C, M)
function [Xm, varargout]  = reflected_mirror_point (varargin)

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
            
            % calculate the 3D point on the mirror surface in the rotated mirror coordinate system
            XmR = rotated_reflected_mirror_point (om, T, Cam, A, B, C, M);
        
        else
            
            % calculate the 3D point on the mirror surface in the rotated mirror coordinate system
            [ XmR, dXmRdom, dXmRdT, dXmRdCam, dXmRdA, dXmRdB, dXmRdC] = rotated_reflected_mirror_point (om, T, Cam, A, B, C, M);
        
        end

         % compute Pre-Rotation % Achtung abfangen falls cx und cy == 0 sind
        [RR, dRR] = compute_RR_new( Cam ); 

        % Point on the mirror surface in the original mirror coordinate system (m = (mx, my, mz) 
        Xm = RR' * XmR;

        % Derivatives
        if nargout > 1
            for i = 1 : size(Xm,2)
                dXmdom{1,i} = [ RR(1,1), RR(2,1), RR(3,1)] * [dXmRdom{1,i};dXmRdom{2,i}; dXmRdom{3,i}];
                dXmdom{2,i} = [ RR(1,2), RR(2,2), RR(3,2)] * [dXmRdom{1,i};dXmRdom{2,i}; dXmRdom{3,i}];
                dXmdom{3,i} = [ RR(1,3), RR(2,3), RR(3,3)] * [dXmRdom{1,i};dXmRdom{2,i}; dXmRdom{3,i}];

                dXmdT{1,i} = [ [ RR(1,1), RR(2,1), RR(3,1)] * [dXmRdT{1,i}';dXmRdT{2,i}'; dXmRdT{3,i}'] ]';
                dXmdT{2,i} = [ [ RR(1,2), RR(2,2), RR(3,2)] * [dXmRdT{1,i}';dXmRdT{2,i}'; dXmRdT{3,i}'] ]';
                dXmdT{3,i} = [ [ RR(1,3), RR(2,3), RR(3,3)] * [dXmRdT{1,i}';dXmRdT{2,i}'; dXmRdT{3,i}'] ]';

                dXmdCam{1,i} = [dRR{1,1}, dRR{2,1}, dRR{3,1}] * XmR(:,i) +  [ [ RR(1,1), RR(2,1), RR(3,1)] * [dXmRdCam{1,i}';dXmRdCam{2,i}'; dXmRdCam{3,i}'] ]' ; 
                dXmdCam{2,i} = [dRR{1,2}, dRR{2,2}, dRR{3,2}] * XmR(:,i) +  [ [ RR(1,2), RR(2,2), RR(3,2)] * [dXmRdCam{1,i}';dXmRdCam{2,i}'; dXmRdCam{3,i}'] ]' ; 
                dXmdCam{3,i} = [dRR{1,3}, dRR{2,3}, dRR{3,3}] * XmR(:,i) +  [ [ RR(1,3), RR(2,3), RR(3,3)] * [dXmRdCam{1,i}';dXmRdCam{2,i}'; dXmRdCam{3,i}'] ]' ; 

                dXmdA{1,i} = [ RR(1,1), RR(2,1), RR(3,1)] * [dXmRdA{1,i}; dXmRdA{2,i}; dXmRdA{3,i}];
                dXmdA{2,i} = [ RR(1,2), RR(2,2), RR(3,2)] * [dXmRdA{1,i}; dXmRdA{2,i}; dXmRdA{3,i}];
                dXmdA{3,i} = [ RR(1,3), RR(2,3), RR(3,3)] * [dXmRdA{1,i}; dXmRdA{2,i}; dXmRdA{3,i}];

                dXmdB{1,i} = [ RR(1,1), RR(2,1), RR(3,1)] * [dXmRdB{1,i}; dXmRdB{2,i}; dXmRdB{3,i}];
                dXmdB{2,i} = [ RR(1,2), RR(2,2), RR(3,2)] * [dXmRdB{1,i}; dXmRdB{2,i}; dXmRdB{3,i}];
                dXmdB{3,i} = [ RR(1,3), RR(2,3), RR(3,3)] * [dXmRdB{1,i}; dXmRdB{2,i}; dXmRdB{3,i}];

                dXmdC{1,i} = [ RR(1,1), RR(2,1), RR(3,1)] * [dXmRdC{1,i}; dXmRdC{2,i}; dXmRdC{3,i}];
                dXmdC{2,i} = [ RR(1,2), RR(2,2), RR(3,2)] * [dXmRdC{1,i}; dXmRdC{2,i}; dXmRdC{3,i}];
                dXmdC{3,i} = [ RR(1,3), RR(2,3), RR(3,3)] * [dXmRdC{1,i}; dXmRdC{2,i}; dXmRdC{3,i}];
            end
            
            varargout{1} = dXmdom;
            varargout{2} = dXmdT;
            varargout{3} = dXmdCam;
            varargout{4} = dXmdA;
            varargout{5} = dXmdB;
            varargout{6} = dXmdC;
            
        end
   
	elseif size(varargin,2) == 5
        
        X   = varargin{1};
        Cam = varargin{2};
        A   = varargin{3};
        B   = varargin{4};
        C   = varargin{5};
        
        if nargout == 1
            
            % calculate the 3D point on the mirror surface in the rotated mirror coordinate system
            XmR = rotated_reflected_mirror_point (X, Cam, A, B, C);
        
        else
            
            % calculate the 3D point on the mirror surface in the rotated mirror coordinate system
            [ XmR, dXmRdX, dXmRdCam, dXmRdA, dXmRdB, dXmRdC] = rotated_reflected_mirror_point (X, Cam, A, B, C);
        
        end

         % compute Pre-Rotation % Achtung abfangen falls cx und cy == 0 sind
        [RR, dRR] = compute_RR_new( Cam ); 

        % Point on the mirror surface in the original mirror coordinate system (m = (mx, my, mz) 
        Xm = RR' * XmR;

        % Derivatives
        if nargout > 1
            for i = 1 : size(Xm,2)
                dXmdX{1,i} = [ [ RR(1,1), RR(2,1), RR(3,1)] * [dXmRdX{1,i}';dXmRdX{2,i}'; dXmRdX{3,i}'] ]';
                dXmdX{2,i} = [ [ RR(1,2), RR(2,2), RR(3,2)] * [dXmRdX{1,i}';dXmRdX{2,i}'; dXmRdX{3,i}'] ]';
                dXmdX{3,i} = [ [ RR(1,3), RR(2,3), RR(3,3)] * [dXmRdX{1,i}';dXmRdX{2,i}'; dXmRdX{3,i}'] ]';

                dXmdCam{1,i} = [dRR{1,1}, dRR{2,1}, dRR{3,1}] * XmR(:,i) +  [ [ RR(1,1), RR(2,1), RR(3,1)] * [dXmRdCam{1,i}';dXmRdCam{2,i}'; dXmRdCam{3,i}'] ]' ; 
                dXmdCam{2,i} = [dRR{1,2}, dRR{2,2}, dRR{3,2}] * XmR(:,i) +  [ [ RR(1,2), RR(2,2), RR(3,2)] * [dXmRdCam{1,i}';dXmRdCam{2,i}'; dXmRdCam{3,i}'] ]' ; 
                dXmdCam{3,i} = [dRR{1,3}, dRR{2,3}, dRR{3,3}] * XmR(:,i) +  [ [ RR(1,3), RR(2,3), RR(3,3)] * [dXmRdCam{1,i}';dXmRdCam{2,i}'; dXmRdCam{3,i}'] ]' ; 

                dXmdA{1,i} = [ RR(1,1), RR(2,1), RR(3,1)] * [dXmRdA{1,i}; dXmRdA{2,i}; dXmRdA{3,i}];
                dXmdA{2,i} = [ RR(1,2), RR(2,2), RR(3,2)] * [dXmRdA{1,i}; dXmRdA{2,i}; dXmRdA{3,i}];
                dXmdA{3,i} = [ RR(1,3), RR(2,3), RR(3,3)] * [dXmRdA{1,i}; dXmRdA{2,i}; dXmRdA{3,i}];

                dXmdB{1,i} = [ RR(1,1), RR(2,1), RR(3,1)] * [dXmRdB{1,i}; dXmRdB{2,i}; dXmRdB{3,i}];
                dXmdB{2,i} = [ RR(1,2), RR(2,2), RR(3,2)] * [dXmRdB{1,i}; dXmRdB{2,i}; dXmRdB{3,i}];
                dXmdB{3,i} = [ RR(1,3), RR(2,3), RR(3,3)] * [dXmRdB{1,i}; dXmRdB{2,i}; dXmRdB{3,i}];

                dXmdC{1,i} = [ RR(1,1), RR(2,1), RR(3,1)] * [dXmRdC{1,i}; dXmRdC{2,i}; dXmRdC{3,i}];
                dXmdC{2,i} = [ RR(1,2), RR(2,2), RR(3,2)] * [dXmRdC{1,i}; dXmRdC{2,i}; dXmRdC{3,i}];
                dXmdC{3,i} = [ RR(1,3), RR(2,3), RR(3,3)] * [dXmRdC{1,i}; dXmRdC{2,i}; dXmRdC{3,i}];
            end
            
            varargout{1} = dXmdX;
            varargout{2} = dXmdCam;
            varargout{3} = dXmdA;
            varargout{4} = dXmdB;
            varargout{5} = dXmdC;
            
        end
        
    else
        
        fprintf('Incorrect number of input data.\n');
                
    end
        
    
    
%     dudx = RR * [1;0;0];    % [ Cam(2) /  sqrt( Cam(1)^2 + Cam(2)^2 ) ; - Cam(1) /  sqrt( Cam(1)^2 + Cam(2)^2 ); 0];
%     dvdy = RR * [0;1;0];    % [ Cam(1) /  sqrt( Cam(1)^2 + Cam(2)^2 ) ;   Cam(2) /  sqrt( Cam(1)^2 + Cam(2)^2 ); 0];
%     dwdz = RR * [0;0;1];    % [ 0; 0; 1];
% %    ddydcy = Cam(2) /  sqrt( Cam(1)^2 + Cam(2)^2 ); %% Achtung noch falsch !!!
% %    ddydcy = Cam(2) / (sqrt(Cam(1)^2 + Cam(2)^2)) - 2*Cam(2)*Cam(1)^2 / (Cam(1)^2 + Cam(2)^2)^2 *(Cam(1)^2 + Cam(2)^2 )^(-1) - ...
% %        2*Cam(2)^3 / (Cam(1)^2 + Cam(2)^2)^2 ;
% %    ddzdcz = 1
%     ddydcy = RR * [0;1;0] + dRR(:,:,4) * [Cam(1); Cam(2); Cam(3)];
%     ddzdcz = RR * [0;0;1] + dRR(:,:,5) * [Cam(1); Cam(2); Cam(3)];
% 
%     if ( Cam(1) == 0 && Cam(2) == 0 )
%         dudx = 1;
%         dvdy = 1;
%         ddydcy = 1;
%     end
% 
%     dmdA = RR' * [dmrd(1,1); dmrd(2,1); dmrd(3,1)];
%     dmdB = RR' * [dmrd(1,2); dmrd(2,2); dmrd(3,2)];
%     dmdC = RR' * [dmrd(1,3); dmrd(2,3); dmrd(3,3)];
% 
%     dmdx = RR' * ([dmrd(1,6); dmrd(1,6); dmrd(1,6)] .* dudx);
%     dmdy = RR' * [dmrd(1,7); dmrd(1,7); dmrd(1,7)] * dvdy;
%     dmdz = RR' * [dmrd(1,8); dmrd(1,8); dmrd(1,8)] * dwdz;
% 
%     dmdcx = dRR(:,:,4) * mirR;
%     dmdcy = dRR(:,:,5) * mirR + RR' * [dmrd(1,4); dmrd(1,4); dmrd(1,4)] * ddydcy;
%     dmdcz = RR' * [dmrd(1,5); dmrd(1,5); dmrd(1,5)] * ddzdcz;
    
else 
    
    M = [ 20; 50; 80];
    om = [0.1, 0.2, 0.15];
    T = [-50;45;10];
    e = 34;
    Cam = [1; 2; -e];
        
    a = 26.857800;
    b = 20.848500;
    A = -b^2/a^2;
    B = 0;
    C = -b^2;
    
    % test derivatives
    test_derivatives(@reflected_mirror_point,1e-8,om,T,Cam,A,B,C,M)
    
end