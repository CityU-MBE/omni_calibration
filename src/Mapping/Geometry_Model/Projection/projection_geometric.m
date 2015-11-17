%% projection_geometric
% Main Projection Function: projects the 3D world point in the image point
% u with the intrinsic parameters
% Input: M     - points in the checkerboard system
%        om    - rodrigues coordinates of the checkerboard points
%        T     - translation vector of the checkerboard points
%        Cam   - Camera position
%        A,B,C - mirror parameters
%        omm   - rodigues coordinates between mirror and camera coordinate
%        system
%        k     - distortion parameters
%        alpha
%        f     - focal length
%        c     - principal point
%
% Output:
%   u           - projected image point
%   dudom       - derivative of u with respect to om
%   dudT        - derivatove of u with respecht T
%   dudCam      - derivatove of u with respecht Cam
%   dudA        - derivatove of u with respecht A
%   dudB        - derivatove of u with respecht B
%   dudC        - derivatove of u with respecht C
%   dudomm      - derivatove of u with respecht omm
%   dudk        - derivatove of u with respecht k
%   dudalpha    - derivatove of u with respecht alpha
%   dudf        - derivatove of u with respecht f
%   dudc        - derivatove of u with respecht c


%function [u, dudom, dudT, dudCam, dudA, dudB, dudC, dudomm, dudk, dudalpha, dudf, dudc]  = projection (om, T, Cam, A, B, C, omm, k, alpha, f, c, M)
function [u, varargout]  = projection_geometric (varargin)
      
if nargin >= 1    
    
    if size(varargin,2) == 12

        om      = varargin{1};
        T       = varargin{2};
        Cam     = varargin{3};
        A       = varargin{4};
        B       = varargin{5};
        C       = varargin{6};
        omm     = varargin{7};
        k       = varargin{8};
        alpha   = varargin{9};
        f       = varargin{10};
        c       = varargin{11};
        M       = varargin{12};
        
        if nargout == 1
            % calculate the 3D point on the mirror surface in the camera coordinate system
            Xc = compute_mirror_point_in_camera (om, T, Cam, A, B, C, omm, M);
        else
            % calculate the 3D point on the mirror surface in the camera coordinate system
            [Xc, dXcdom, dXcdT, dXcdCam, dXcdA, dXcdB, dXcdC, dXcdomm] = compute_mirror_point_in_camera (om, T, Cam, A, B, C, omm, M);
        end
        
        [m,n] = size(Xc);
    
        xx(1,:) = Xc(1,:) ./ Xc(3,:);
        xx(2,:) = Xc(2,:) ./ Xc(3,:);

    
        if nargout > 1 
            dxxdom  = cell(2,n);
            dxxdT   = cell(2,n);
            dxxdCam = cell(2,n);
            dxxdA   = cell(2,n);
            dxxdB   = cell(2,n);
            dxxdC   = cell(2,n);
            dxxdomm = cell(2,n);
            for i = 1 : n
                dxxdom{1,i} = dXcdom{1,i} ./ Xc(3,i) - Xc(1,i) .* dXcdom{3,i} ./ Xc(3,i).^2;
                dxxdom{2,i} = dXcdom{2,i} ./ Xc(3,i) - Xc(2,i) .* dXcdom{3,i} ./ Xc(3,i).^2;

                dxxdT{1,i} = dXcdT{1,i} ./ Xc(3,i) - Xc(1,i) .* dXcdT{3,i} ./ Xc(3,i).^2;
                dxxdT{2,i} = dXcdT{2,i} ./ Xc(3,i) - Xc(2,i) .* dXcdT{3,i} ./ Xc(3,i).^2;

                dxxdCam{1,i} = dXcdCam{1,i} ./ Xc(3,i) - Xc(1,i) .* dXcdCam{3,i} ./ Xc(3,i).^2;
                dxxdCam{2,i} = dXcdCam{2,i} ./ Xc(3,i) - Xc(2,i) .* dXcdCam{3,i} ./ Xc(3,i).^2;

                dxxdA{1,i} = dXcdA{1,i} ./ Xc(3,i) - Xc(1,i) .* dXcdA{3,i} ./ Xc(3,i).^2;
                dxxdA{2,i} = dXcdA{2,i} ./ Xc(3,i) - Xc(2,i) .* dXcdA{3,i} ./ Xc(3,i).^2;

                dxxdB{1,i} = dXcdB{1,i} ./ Xc(3,i) - Xc(1,i) .* dXcdB{3,i} ./ Xc(3,i).^2;
                dxxdB{2,i} = dXcdB{2,i} ./ Xc(3,i) - Xc(2,i) .* dXcdB{3,i} ./ Xc(3,i).^2;

                dxxdC{1,i} = dXcdC{1,i} ./ Xc(3,i) - Xc(1,i) .* dXcdC{3,i} ./ Xc(3,i).^2;
                dxxdC{2,i} = dXcdC{2,i} ./ Xc(3,i) - Xc(2,i) .* dXcdC{3,i} ./ Xc(3,i).^2;

                dxxdomm{1,i} = dXcdomm{1,i} ./ Xc(3,i) - Xc(1,i) .* dXcdomm{3,i} ./ Xc(3,i).^2;
                dxxdomm{2,i} = dXcdomm{2,i} ./ Xc(3,i) - Xc(2,i) .* dXcdomm{3,i} ./ Xc(3,i).^2;
            end
       end
     
        % Add distortion:
        r2 = xx(1,:).^2 + xx(2,:).^2;
        if nargout > 1
            dr2dom  = cell(1,n);
            dr2dT   = cell(1,n);
            dr2dCam = cell(1,n);
            dr2dA   = cell(1,n);
            dr2dB   = cell(1,n);
            dr2dC   = cell(1,n);
            dr2domm = cell(1,n);
            for i = 1 : n
                dr2dom{1,i}     = 2*xx(1,i)' .* dxxdom{1,i}     + 2*xx(2,i)' * dxxdom{2,i};
                dr2dT{1,i}      = 2*xx(1,i)' .* dxxdT{1,i}      + 2*xx(2,i)' * dxxdT{2,i};
                dr2dCam{1,i}    = 2*xx(1,i)' .* dxxdCam{1,i}    + 2*xx(2,i)' * dxxdCam{2,i};
                dr2dA{1,i}      = 2*xx(1,i)' .* dxxdA{1,i}      + 2*xx(2,i)' * dxxdA{2,i};
                dr2dB{1,i}      = 2*xx(1,i)' .* dxxdB{1,i}      + 2*xx(2,i)' * dxxdB{2,i};
                dr2dC{1,i}      = 2*xx(1,i)' .* dxxdC{1,i}      + 2*xx(2,i)' * dxxdC{2,i};
                dr2domm{1,i}    = 2*xx(1,i)' .* dxxdomm{1,i}    + 2*xx(2,i)' * dxxdomm{2,i};
            end
        end

        r4 = r2.^2;
        if nargout > 1
            dr4dom  = cell(1,n);
            dr4dT   = cell(1,n);
            dr4dCam = cell(1,n);
            dr4dA   = cell(1,n);
            dr4dB   = cell(1,n);
            dr4dC   = cell(1,n);
            dr4domm = cell(1,n);
            for i = 1 : n
                dr4dom{1,i}     = 2*r2(:,i)'   .*  dr2dom{1,i};
                dr4dT{1,i}      = 2*r2(:,i)'   .*  dr2dT{1,i};
                dr4dCam{1,i}    = 2*r2(:,i)'   .*  dr2dCam{1,i};
                dr4dA{1,i}      = 2*r2(:,i)'   .*  dr2dA{1,i};
                dr4dB{1,i}      = 2*r2(:,i)'   .*  dr2dB{1,i};
                dr4dC{1,i}      = 2*r2(:,i)'   .*  dr2dC{1,i};
                dr4domm{1,i}    = 2*r2(:,i)'   .*  dr2domm{1,i};
            end
        end
 
        r6 = r2.^3;
        if nargout > 1
            dr6dom  = cell(1,n);
            dr6dT   = cell(1,n);
            dr6dCam = cell(1,n);
            dr6dA   = cell(1,n);
            dr6dB   = cell(1,n);
            dr6dC   = cell(1,n);
            dr6domm = cell(1,n);
            for i = 1 : n
                dr6dom{1,i}  = 3 * r2(:,i)'.^2 .* dr2dom{1,i};
                dr6dT{1,i}   = 3 * r2(:,i)'.^2 .* dr2dT{1,i};
                dr6dCam{1,i} = 3 * r2(:,i)'.^2 .* dr2dCam{1,i};
                dr6dA{1,i}   = 3 * r2(:,i)'.^2 .* dr2dA{1,i};
                dr6dB{1,i}   = 3 * r2(:,i)'.^2 .* dr2dB{1,i};
                dr6dC{1,i}   = 3 * r2(:,i)'.^2 .* dr2dC{1,i};
                dr6domm{1,i} = 3 * r2(:,i)'.^2 .* dr2domm{1,i};
            end
        end

        % Radial distortion:
        cdist = 1 + k(1) * r2 + k(2) * r4 + k(5) * r6;
        if nargout > 1
            dcdistdom  = cell(1,n);
            dcdistdT   = cell(1,n);
            dcdistdCam = cell(1,n);
            dcdistdA   = cell(1,n);
            dcdistdB   = cell(1,n);
            dcdistdC   = cell(1,n);
            dcdistdomm = cell(1,n);
            dcdistdk   = cell(1,n);
            for i = 1 : n
                dcdistdom{1,i}  = k(1) .* dr2dom{1,i}   + k(2) .* dr4dom{1,i}   + k(5) .* dr6dom{1,i};
                dcdistdT{1,i}   = k(1) .* dr2dT{1,i}    + k(2) .* dr4dT{1,i}    + k(5) .* dr6dT{1,i};
                dcdistdCam{1,i} = k(1) .* dr2dCam{1,i}  + k(2) .* dr4dCam{1,i}  + k(5) .* dr6dCam{1,i};
                dcdistdA{1,i}   = k(1) .* dr2dA{1,i}    + k(2) .* dr4dA{1,i}    + k(5) .* dr6dA{1,i};
                dcdistdB{1,i}   = k(1) .* dr2dB{1,i}    + k(2) .* dr4dB{1,i}    + k(5) .* dr6dB{1,i};
                dcdistdC{1,i}   = k(1) .* dr2dC{1,i}    + k(2) .* dr4dC{1,i}    + k(5) .* dr6dC{1,i};
                dcdistdomm{1,i} = k(1) .* dr2domm{1,i}  + k(2) .* dr4domm{1,i}  + k(5) .* dr6domm{1,i};
                dcdistdk{1,i}   = [r2(:,i)' r4(:,i)' 0 0 r6(:,i)'];
            end
        end
   
        xd1 = xx .* (ones(2,1)*cdist);
        if nargout > 1
            dxd1dom  = cell(2,n);
            dxd1dT   = cell(2,n);
            dxd1dCam = cell(2,n);
            dxd1dA   = cell(2,n);
            dxd1dB   = cell(2,n);
            dxd1dC   = cell(2,n);
            dxd1domm = cell(2,n);
            dxd1dk   = cell(2,n);
            for i = 1 : n
                dxd1dom{1,i}  = xx(1,i) .* dcdistdom{1,i}   + cdist(:,i)' .* dxxdom{1,i};
                dxd1dom{2,i}  = xx(2,i) .* dcdistdom{1,i}   + cdist(:,i)' .* dxxdom{2,i};
                dxd1dT{1,i}   = xx(1,i) .* dcdistdT{1,i}    + cdist(:,i)' .* dxxdT{1,i};
                dxd1dT{2,i}   = xx(2,i) .* dcdistdT{1,i}    + cdist(:,i)' .* dxxdT{2,i};
                dxd1dCam{1,i} = xx(1,i) .* dcdistdCam{1,i}  + cdist(:,i)' .* dxxdCam{1,i};
                dxd1dCam{2,i} = xx(2,i) .* dcdistdCam{1,i}  + cdist(:,i)' .* dxxdCam{2,i};
                dxd1dA{1,i}   = xx(1,i) .* dcdistdA{1,i}    + cdist(:,i)' .* dxxdA{1,i};
                dxd1dA{2,i}   = xx(2,i) .* dcdistdA{1,i}    + cdist(:,i)' .* dxxdA{2,i};
                dxd1dB{1,i}   = xx(1,i) .* dcdistdB{1,i}    + cdist(:,i)' .* dxxdB{1,i};
                dxd1dB{2,i}   = xx(2,i) .* dcdistdB{1,i}    + cdist(:,i)' .* dxxdB{2,i};
                dxd1dC{1,i}   = xx(1,i) .* dcdistdC{1,i}    + cdist(:,i)' .* dxxdC{1,i};
                dxd1dC{2,i}   = xx(2,i) .* dcdistdC{1,i}    + cdist(:,i)' .* dxxdC{2,i};
                dxd1domm{1,i} = xx(1,i) .* dcdistdomm{1,i}  + cdist(:,i)' .* dxxdomm{1,i};
                dxd1domm{2,i} = xx(2,i) .* dcdistdomm{1,i}  + cdist(:,i)' .* dxxdomm{2,i};
                dxd1dk{1,i}   = xx(1,i) .* dcdistdk{1,i};
                dxd1dk{2,i}   = xx(2,i) .* dcdistdk{1,i};  
            end
        end

        % tangential distortion:
        a1 = 2.*xx(1,:).*xx(2,:);
        a2 = r2 + 2*xx(1,:).^2;
        a3 = r2 + 2*xx(2,:).^2;

        delta_x = [k(3)*a1 + k(4)*a2 ;  k(3)*a3 + k(4)*a1];       

        aa = (2*k(3)*xx(2,:) + 6*k(4)*xx(1,:))'; % aa is delta_x[1]dx
        bb = (2*k(3)*xx(1,:) + 2*k(4)*xx(2,:))'; % bb is delta_x[2]dx and delta_x[1]dy
        cc = (6*k(3)*xx(2,:) + 2*k(4)*xx(1,:))'; % cc is delta_x[2]dy

        if nargout > 1
            ddelta_xdom  = cell(2,n);
            ddelta_xdT   = cell(2,n);
            ddelta_xdCam = cell(2,n);
            ddelta_xdA   = cell(2,n);
            ddelta_xdB   = cell(2,n);
            ddelta_xdC   = cell(2,n);
            ddelta_xdomm = cell(2,n);
            ddelta_xdk   = cell(2,n);
            for i = 1 : n
                ddelta_xdom{1,i}    = aa(i) .* dxxdom{1,i}     + bb(i) .* dxxdom{2,i};
                ddelta_xdom{2,i}    = bb(i) .* dxxdom{1,i}     + cc(i) .* dxxdom{2,i};
                ddelta_xdT{1,i}     = aa(i) .* dxxdT{1,i}      + bb(i) .* dxxdT{2,i};
                ddelta_xdT{2,i}     = bb(i) .* dxxdT{1,i}      + cc(i) .* dxxdT{2,i};
                ddelta_xdCam{1,i}   = aa(i) .* dxxdCam{1,i}    + bb(i) .* dxxdCam{2,i};
                ddelta_xdCam{2,i}   = bb(i) .* dxxdCam{1,i}    + cc(i) .* dxxdCam{2,i};
                ddelta_xdA{1,i}     = aa(i) .* dxxdA{1,i}      + bb(i) .* dxxdA{2,i};
                ddelta_xdA{2,i}     = bb(i) .* dxxdA{1,i}      + cc(i) .* dxxdA{2,i};
                ddelta_xdB{1,i}     = aa(i) .* dxxdB{1,i}      + bb(i) .* dxxdB{2,i};
                ddelta_xdB{2,i}     = bb(i) .* dxxdB{1,i}      + cc(i) .* dxxdB{2,i};
                ddelta_xdC{1,i}     = aa(i) .* dxxdC{1,i}      + bb(i) .* dxxdC{2,i};
                ddelta_xdC{2,i}     = bb(i) .* dxxdC{1,i}      + cc(i) .* dxxdC{2,i};
                ddelta_xdomm{1,i}   = aa(i) .* dxxdomm{1,i}    + bb(i) .* dxxdomm{2,i};
                ddelta_xdomm{2,i}   = bb(i) .* dxxdomm{1,i}    + cc(i) .* dxxdomm{2,i};
                ddelta_xdk{1,i}     = [ 0 0 a1(:,i)' a2(:,i)' 0];   
                ddelta_xdk{2,i}     = [ 0 0 a3(:,i)' a1(:,i)' 0];
            end
        end

        xd2 = xd1 + delta_x;
        if nargout > 1
            dxd2dom  = cell(2,n);
            dxd2dT   = cell(2,n);
            dxd2dCam = cell(2,n);
            dxd2dA   = cell(2,n);
            dxd2dB   = cell(2,n);
            dxd2dC   = cell(2,n);
            dxd2domm = cell(2,n);
            dxd2dk   = cell(2,n);
            for i = 1 : n
                dxd2dom{1,i}     = dxd1dom{1,i}     + ddelta_xdom{1,i};
                dxd2dom{2,i}     = dxd1dom{2,i}     + ddelta_xdom{2,i};
                dxd2dT{1,i}      = dxd1dT{1,i}      + ddelta_xdT{1,i};
                dxd2dT{2,i}      = dxd1dT{2,i}      + ddelta_xdT{2,i};
                dxd2dCam{1,i}    = dxd1dCam{1,i}    + ddelta_xdCam{1,i};
                dxd2dCam{2,i}    = dxd1dCam{2,i}    + ddelta_xdCam{2,i};
                dxd2dA{1,i}      = dxd1dA{1,i}      + ddelta_xdA{1,i};
                dxd2dA{2,i}      = dxd1dA{2,i}      + ddelta_xdA{2,i};
                dxd2dB{1,i}      = dxd1dB{1,i}      + ddelta_xdB{1,i};
                dxd2dB{2,i}      = dxd1dB{2,i}      + ddelta_xdB{2,i};
                dxd2dC{1,i}      = dxd1dC{1,i}      + ddelta_xdC{1,i};
                dxd2dC{2,i}      = dxd1dC{2,i}      + ddelta_xdC{2,i};
                dxd2domm{1,i}    = dxd1domm{1,i}    + ddelta_xdomm{1,i};
                dxd2domm{2,i}    = dxd1domm{2,i}    + ddelta_xdomm{2,i};
                dxd2dk{1,i}      = dxd1dk{1,i}      + ddelta_xdk{1,i};
                dxd2dk{2,i}      = dxd1dk{2,i}      + ddelta_xdk{2,i};
            end
        end

        % Add Skew:
        xd3 = [xd2(1,:) + alpha*xd2(2,:);xd2(2,:)];
        if nargout > 1
            dxd3dom     = cell(2,n);
            dxd3dT      = cell(2,n);
            dxd3dCam    = cell(2,n);
            dxd3dA      = cell(2,n);
            dxd3dB      = cell(2,n);
            dxd3dC      = cell(2,n);
            dxd3domm    = cell(2,n);
            dxd3dk      = cell(2,n);
            dxd3dalpha  = cell(2,n);
            for i = 1 : n
                dxd3dom{1,i}    = dxd2dom{1,i}  + alpha * dxd2dom{2,i};
                dxd3dom{2,i}    = dxd2dom{2,i};
                dxd3dT{1,i}     = dxd2dT{1,i}   + alpha * dxd2dT{2,i};
                dxd3dT{2,i}     = dxd2dT{2,i};
                dxd3dCam{1,i}   = dxd2dCam{1,i} + alpha * dxd2dCam{2,i};
                dxd3dCam{2,i}   = dxd2dCam{2,i};
                dxd3dA{1,i}     = dxd2dA{1,i}   + alpha * dxd2dA{2,i};
                dxd3dA{2,i}     = dxd2dA{2,i};
                dxd3dB{1,i}     = dxd2dB{1,i}   + alpha * dxd2dB{2,i};
                dxd3dB{2,i}     = dxd2dB{2,i};
                dxd3dC{1,i}     = dxd2dC{1,i}   + alpha * dxd2dC{2,i};
                dxd3dC{2,i}     = dxd2dC{2,i};
                dxd3domm{1,i}   = dxd2domm{1,i} + alpha * dxd2domm{2,i};
                dxd3domm{2,i}   = dxd2domm{2,i};
                dxd3dk{1,i}     = dxd2dk{1,i}   + alpha * dxd2dk{2,i};
                dxd3dk{2,i}     = dxd2dk{2,i};
                dxd3dalpha{1,i} = xd2(2,i);
                dxd3dalpha{2,i} = 0;
            end
        end

        % Pixel coordinates:
        %if length(f)>1,
        u(1,:) = f(1) .* xd3(1,:) +  c(1);
        u(2,:) = f(2) .* xd3(2,:) +  c(2);

        if nargout > 1
            dudom     = cell(2,n);
            dudT      = cell(2,n);
            dudCam    = cell(2,n);
            dudA      = cell(2,n);
            dudB      = cell(2,n);
            dudC      = cell(2,n);
            dudomm    = cell(2,n);
            dudk      = cell(2,n);
            dudalpha  = cell(2,n);
            dudf      = cell(2,n);
            dudc      = cell(2,n);
            for i = 1 : n
                dudom{1,i}      = f(1) .* dxd3dom{1,i};
                dudom{2,i}      = f(2) .* dxd3dom{2,i};
                dudT{1,i}       = f(1) .* dxd3dT{1,i};
                dudT{2,i}       = f(2) .* dxd3dT{2,i};
                dudCam{1,i}     = f(1) .* dxd3dCam{1,i};
                dudCam{2,i}     = f(2) .* dxd3dCam{2,i};
                dudA{1,i}       = f(1) .* dxd3dA{1,i};
                dudA{2,i}       = f(2) .* dxd3dA{2,i};
                dudB{1,i}       = f(1) .* dxd3dB{1,i};
                dudB{2,i}       = f(2) .* dxd3dB{2,i};
                dudC{1,i}       = f(1) .* dxd3dC{1,i};
                dudC{2,i}       = f(2) .* dxd3dC{2,i};
                dudomm{1,i}     = f(1) .* dxd3domm{1,i};
                dudomm{2,i}     = f(2) .* dxd3domm{2,i};
                dudk{1,i}       = f(1) .* dxd3dk{1,i};
                dudk{2,i}       = f(2) .* dxd3dk{2,i};
                dudalpha{1,i}   = f(1) .* dxd3dalpha{1,i};
                dudalpha{2,i}   = f(2) .* dxd3dalpha{2,i};
                dudf{1,i}       = [xd3(1,i); 0];
                dudf{2,i}       = [0; xd3(2,i)];
                dudc{1,i}       = [1;0];
                dudc{2,i}       = [0;1];
            end
            
            varargout{1} = dudom;
            varargout{2} = dudT;
            varargout{3} = dudCam;
            varargout{4} = dudA; 
            varargout{5} = dudB;
            varargout{6} = dudC;
            varargout{7} = dudomm;
            varargout{8} = dudk;
            varargout{9} = dudalpha; 
            varargout{10}= dudf;
            varargout{11}= dudc;
            
        end
    
    elseif size(varargin,2) == 10
        
        X       = varargin{1};
        Cam     = varargin{2};
        A       = varargin{3};
        B       = varargin{4};
        C       = varargin{5};
        omm     = varargin{6};
        k       = varargin{7};
        alpha   = varargin{8};
        f       = varargin{9};
        c       = varargin{10};
        
        if nargout == 1
            % calculate the 3D point on the mirror surface in the camera coordinate system
            Xc = compute_mirror_point_in_camera (X, Cam, A, B, C, omm);
        else
            % calculate the 3D point on the mirror surface in the camera coordinate system
            [Xc, dXcdX, dXcdCam, dXcdA, dXcdB, dXcdC, dXcdomm] = compute_mirror_point_in_camera (X, Cam, A, B, C, omm);
        end
        
        [m,n] = size(Xc);
    
        xx(1,:) = Xc(1,:) ./ Xc(3,:);
        xx(2,:) = Xc(2,:) ./ Xc(3,:);

    
        if nargout > 1 
            dxxdX   = cell(2,n);
            dxxdCam = cell(2,n);
            dxxdA   = cell(2,n);
            dxxdB   = cell(2,n);
            dxxdC   = cell(2,n);
            dxxdomm = cell(2,n);
            for i = 1 : n
                dxxdX{1,i} = dXcdX{1,i} ./ Xc(3,i) - Xc(1,i) .* dXcdX{3,i} ./ Xc(3,i).^2;
                dxxdX{2,i} = dXcdX{2,i} ./ Xc(3,i) - Xc(2,i) .* dXcdX{3,i} ./ Xc(3,i).^2;

                dxxdCam{1,i} = dXcdCam{1,i} ./ Xc(3,i) - Xc(1,i) .* dXcdCam{3,i} ./ Xc(3,i).^2;
                dxxdCam{2,i} = dXcdCam{2,i} ./ Xc(3,i) - Xc(2,i) .* dXcdCam{3,i} ./ Xc(3,i).^2;

                dxxdA{1,i} = dXcdA{1,i} ./ Xc(3,i) - Xc(1,i) .* dXcdA{3,i} ./ Xc(3,i).^2;
                dxxdA{2,i} = dXcdA{2,i} ./ Xc(3,i) - Xc(2,i) .* dXcdA{3,i} ./ Xc(3,i).^2;

                dxxdB{1,i} = dXcdB{1,i} ./ Xc(3,i) - Xc(1,i) .* dXcdB{3,i} ./ Xc(3,i).^2;
                dxxdB{2,i} = dXcdB{2,i} ./ Xc(3,i) - Xc(2,i) .* dXcdB{3,i} ./ Xc(3,i).^2;

                dxxdC{1,i} = dXcdC{1,i} ./ Xc(3,i) - Xc(1,i) .* dXcdC{3,i} ./ Xc(3,i).^2;
                dxxdC{2,i} = dXcdC{2,i} ./ Xc(3,i) - Xc(2,i) .* dXcdC{3,i} ./ Xc(3,i).^2;

                dxxdomm{1,i} = dXcdomm{1,i} ./ Xc(3,i) - Xc(1,i) .* dXcdomm{3,i} ./ Xc(3,i).^2;
                dxxdomm{2,i} = dXcdomm{2,i} ./ Xc(3,i) - Xc(2,i) .* dXcdomm{3,i} ./ Xc(3,i).^2;
            end
       end
     
        % Add distortion:
        r2 = xx(1,:).^2 + xx(2,:).^2;
        if nargout > 1
            dr2dX   = cell(1,n);
            dr2dCam = cell(1,n);
            dr2dA   = cell(1,n);
            dr2dB   = cell(1,n);
            dr2dC   = cell(1,n);
            dr2domm = cell(1,n);
            for i = 1 : n
                dr2dX{1,i}      = 2*xx(1,i)' .* dxxdX{1,i}      + 2*xx(2,i)' * dxxdX{2,i};
                dr2dCam{1,i}    = 2*xx(1,i)' .* dxxdCam{1,i}    + 2*xx(2,i)' * dxxdCam{2,i};
                dr2dA{1,i}      = 2*xx(1,i)' .* dxxdA{1,i}      + 2*xx(2,i)' * dxxdA{2,i};
                dr2dB{1,i}      = 2*xx(1,i)' .* dxxdB{1,i}      + 2*xx(2,i)' * dxxdB{2,i};
                dr2dC{1,i}      = 2*xx(1,i)' .* dxxdC{1,i}      + 2*xx(2,i)' * dxxdC{2,i};
                dr2domm{1,i}    = 2*xx(1,i)' .* dxxdomm{1,i}    + 2*xx(2,i)' * dxxdomm{2,i};
            end
        end

        r4 = r2.^2;
        if nargout > 1
            dr4dX   = cell(1,n);
            dr4dCam = cell(1,n);
            dr4dA   = cell(1,n);
            dr4dB   = cell(1,n);
            dr4dC   = cell(1,n);
            dr4domm = cell(1,n);
            for i = 1 : n
                dr4dX{1,i}      = 2*r2(:,i)'   .*  dr2dX{1,i};
                dr4dCam{1,i}    = 2*r2(:,i)'   .*  dr2dCam{1,i};
                dr4dA{1,i}      = 2*r2(:,i)'   .*  dr2dA{1,i};
                dr4dB{1,i}      = 2*r2(:,i)'   .*  dr2dB{1,i};
                dr4dC{1,i}      = 2*r2(:,i)'   .*  dr2dC{1,i};
                dr4domm{1,i}    = 2*r2(:,i)'   .*  dr2domm{1,i};
            end
        end
 
        r6 = r2.^3;
        if nargout > 1
            dr6dX   = cell(1,n);
            dr6dCam = cell(1,n);
            dr6dA   = cell(1,n);
            dr6dB   = cell(1,n);
            dr6dC   = cell(1,n);
            dr6domm = cell(1,n);
            for i = 1 : n
                dr6dX{1,i}   = 3 * r2(:,i)'.^2 .* dr2dX{1,i};
                dr6dCam{1,i} = 3 * r2(:,i)'.^2 .* dr2dCam{1,i};
                dr6dA{1,i}   = 3 * r2(:,i)'.^2 .* dr2dA{1,i};
                dr6dB{1,i}   = 3 * r2(:,i)'.^2 .* dr2dB{1,i};
                dr6dC{1,i}   = 3 * r2(:,i)'.^2 .* dr2dC{1,i};
                dr6domm{1,i} = 3 * r2(:,i)'.^2 .* dr2domm{1,i};
            end
        end

        % Radial distortion:
        cdist = 1 + k(1) * r2 + k(2) * r4 + k(5) * r6;
        if nargout > 1
            dcdistdX   = cell(1,n);
            dcdistdCam = cell(1,n);
            dcdistdA   = cell(1,n);
            dcdistdB   = cell(1,n);
            dcdistdC   = cell(1,n);
            dcdistdomm = cell(1,n);
            dcdistdk   = cell(1,n);
            for i = 1 : n
                dcdistdX{1,i}   = k(1) .* dr2dX{1,i}    + k(2) .* dr4dX{1,i}    + k(5) .* dr6dX{1,i};
                dcdistdCam{1,i} = k(1) .* dr2dCam{1,i}  + k(2) .* dr4dCam{1,i}  + k(5) .* dr6dCam{1,i};
                dcdistdA{1,i}   = k(1) .* dr2dA{1,i}    + k(2) .* dr4dA{1,i}    + k(5) .* dr6dA{1,i};
                dcdistdB{1,i}   = k(1) .* dr2dB{1,i}    + k(2) .* dr4dB{1,i}    + k(5) .* dr6dB{1,i};
                dcdistdC{1,i}   = k(1) .* dr2dC{1,i}    + k(2) .* dr4dC{1,i}    + k(5) .* dr6dC{1,i};
                dcdistdomm{1,i} = k(1) .* dr2domm{1,i}  + k(2) .* dr4domm{1,i}  + k(5) .* dr6domm{1,i};
                dcdistdk{1,i}   = [r2(:,i)' r4(:,i)' 0 0 r6(:,i)'];
            end
        end
   
        xd1 = xx .* (ones(2,1)*cdist);
        if nargout > 1
            dxd1dX   = cell(2,n);
            dxd1dCam = cell(2,n);
            dxd1dA   = cell(2,n);
            dxd1dB   = cell(2,n);
            dxd1dC   = cell(2,n);
            dxd1domm = cell(2,n);
            dxd1dk   = cell(2,n);
            for i = 1 : n
                dxd1dX{1,i}   = xx(1,i) .* dcdistdX{1,i}    + cdist(:,i)' .* dxxdX{1,i};
                dxd1dX{2,i}   = xx(2,i) .* dcdistdX{1,i}    + cdist(:,i)' .* dxxdX{2,i};
                dxd1dCam{1,i} = xx(1,i) .* dcdistdCam{1,i}  + cdist(:,i)' .* dxxdCam{1,i};
                dxd1dCam{2,i} = xx(2,i) .* dcdistdCam{1,i}  + cdist(:,i)' .* dxxdCam{2,i};
                dxd1dA{1,i}   = xx(1,i) .* dcdistdA{1,i}    + cdist(:,i)' .* dxxdA{1,i};
                dxd1dA{2,i}   = xx(2,i) .* dcdistdA{1,i}    + cdist(:,i)' .* dxxdA{2,i};
                dxd1dB{1,i}   = xx(1,i) .* dcdistdB{1,i}    + cdist(:,i)' .* dxxdB{1,i};
                dxd1dB{2,i}   = xx(2,i) .* dcdistdB{1,i}    + cdist(:,i)' .* dxxdB{2,i};
                dxd1dC{1,i}   = xx(1,i) .* dcdistdC{1,i}    + cdist(:,i)' .* dxxdC{1,i};
                dxd1dC{2,i}   = xx(2,i) .* dcdistdC{1,i}    + cdist(:,i)' .* dxxdC{2,i};
                dxd1domm{1,i} = xx(1,i) .* dcdistdomm{1,i}  + cdist(:,i)' .* dxxdomm{1,i};
                dxd1domm{2,i} = xx(2,i) .* dcdistdomm{1,i}  + cdist(:,i)' .* dxxdomm{2,i};
                dxd1dk{1,i}   = xx(1,i) .* dcdistdk{1,i};
                dxd1dk{2,i}   = xx(2,i) .* dcdistdk{1,i};  
            end
        end

        % tangential distortion:
        a1 = 2.*xx(1,:).*xx(2,:);
        a2 = r2 + 2*xx(1,:).^2;
        a3 = r2 + 2*xx(2,:).^2;

        delta_x = [k(3)*a1 + k(4)*a2 ;  k(3)*a3 + k(4)*a1];       

        aa = (2*k(3)*xx(2,:) + 6*k(4)*xx(1,:))'; % aa is delta_x[1]dx
        bb = (2*k(3)*xx(1,:) + 2*k(4)*xx(2,:))'; % bb is delta_x[2]dx and delta_x[1]dy
        cc = (6*k(3)*xx(2,:) + 2*k(4)*xx(1,:))'; % cc is delta_x[2]dy

        if nargout > 1
            ddelta_xdX   = cell(2,n);
            ddelta_xdCam = cell(2,n);
            ddelta_xdA   = cell(2,n);
            ddelta_xdB   = cell(2,n);
            ddelta_xdC   = cell(2,n);
            ddelta_xdomm = cell(2,n);
            ddelta_xdk   = cell(2,n);
            for i = 1 : n
                ddelta_xdX{1,i}     = aa(i) .* dxxdX{1,i}      + bb(i) .* dxxdX{2,i};
                ddelta_xdX{2,i}     = bb(i) .* dxxdX{1,i}      + cc(i) .* dxxdX{2,i};
                ddelta_xdCam{1,i}   = aa(i) .* dxxdCam{1,i}    + bb(i) .* dxxdCam{2,i};
                ddelta_xdCam{2,i}   = bb(i) .* dxxdCam{1,i}    + cc(i) .* dxxdCam{2,i};
                ddelta_xdA{1,i}     = aa(i) .* dxxdA{1,i}      + bb(i) .* dxxdA{2,i};
                ddelta_xdA{2,i}     = bb(i) .* dxxdA{1,i}      + cc(i) .* dxxdA{2,i};
                ddelta_xdB{1,i}     = aa(i) .* dxxdB{1,i}      + bb(i) .* dxxdB{2,i};
                ddelta_xdB{2,i}     = bb(i) .* dxxdB{1,i}      + cc(i) .* dxxdB{2,i};
                ddelta_xdC{1,i}     = aa(i) .* dxxdC{1,i}      + bb(i) .* dxxdC{2,i};
                ddelta_xdC{2,i}     = bb(i) .* dxxdC{1,i}      + cc(i) .* dxxdC{2,i};
                ddelta_xdomm{1,i}   = aa(i) .* dxxdomm{1,i}    + bb(i) .* dxxdomm{2,i};
                ddelta_xdomm{2,i}   = bb(i) .* dxxdomm{1,i}    + cc(i) .* dxxdomm{2,i};
                ddelta_xdk{1,i}     = [ 0 0 a1(:,i)' a2(:,i)' 0];   
                ddelta_xdk{2,i}     = [ 0 0 a3(:,i)' a1(:,i)' 0];
            end
        end

        xd2 = xd1 + delta_x;
        if nargout > 1
            dxd2dX   = cell(2,n);
            dxd2dCam = cell(2,n);
            dxd2dA   = cell(2,n);
            dxd2dB   = cell(2,n);
            dxd2dC   = cell(2,n);
            dxd2domm = cell(2,n);
            dxd2dk   = cell(2,n);
            for i = 1 : n
                dxd2dX{1,i}      = dxd1dX{1,i}      + ddelta_xdX{1,i};
                dxd2dX{2,i}      = dxd1dX{2,i}      + ddelta_xdX{2,i};
                dxd2dCam{1,i}    = dxd1dCam{1,i}    + ddelta_xdCam{1,i};
                dxd2dCam{2,i}    = dxd1dCam{2,i}    + ddelta_xdCam{2,i};
                dxd2dA{1,i}      = dxd1dA{1,i}      + ddelta_xdA{1,i};
                dxd2dA{2,i}      = dxd1dA{2,i}      + ddelta_xdA{2,i};
                dxd2dB{1,i}      = dxd1dB{1,i}      + ddelta_xdB{1,i};
                dxd2dB{2,i}      = dxd1dB{2,i}      + ddelta_xdB{2,i};
                dxd2dC{1,i}      = dxd1dC{1,i}      + ddelta_xdC{1,i};
                dxd2dC{2,i}      = dxd1dC{2,i}      + ddelta_xdC{2,i};
                dxd2domm{1,i}    = dxd1domm{1,i}    + ddelta_xdomm{1,i};
                dxd2domm{2,i}    = dxd1domm{2,i}    + ddelta_xdomm{2,i};
                dxd2dk{1,i}      = dxd1dk{1,i}      + ddelta_xdk{1,i};
                dxd2dk{2,i}      = dxd1dk{2,i}      + ddelta_xdk{2,i};
            end
        end

        % Add Skew:
        xd3 = [xd2(1,:) + alpha*xd2(2,:);xd2(2,:)];
        if nargout > 1
            dxd3dX      = cell(2,n);
            dxd3dCam    = cell(2,n);
            dxd3dA      = cell(2,n);
            dxd3dB      = cell(2,n);
            dxd3dC      = cell(2,n);
            dxd3domm    = cell(2,n);
            dxd3dk      = cell(2,n);
            dxd3dalpha  = cell(2,n);
            for i = 1 : n
                dxd3dX{1,i}     = dxd2dX{1,i}   + alpha * dxd2dX{2,i};
                dxd3dX{2,i}     = dxd2dX{2,i};
                dxd3dCam{1,i}   = dxd2dCam{1,i} + alpha * dxd2dCam{2,i};
                dxd3dCam{2,i}   = dxd2dCam{2,i};
                dxd3dA{1,i}     = dxd2dA{1,i}   + alpha * dxd2dA{2,i};
                dxd3dA{2,i}     = dxd2dA{2,i};
                dxd3dB{1,i}     = dxd2dB{1,i}   + alpha * dxd2dB{2,i};
                dxd3dB{2,i}     = dxd2dB{2,i};
                dxd3dC{1,i}     = dxd2dC{1,i}   + alpha * dxd2dC{2,i};
                dxd3dC{2,i}     = dxd2dC{2,i};
                dxd3domm{1,i}   = dxd2domm{1,i} + alpha * dxd2domm{2,i};
                dxd3domm{2,i}   = dxd2domm{2,i};
                dxd3dk{1,i}     = dxd2dk{1,i}   + alpha * dxd2dk{2,i};
                dxd3dk{2,i}     = dxd2dk{2,i};
                dxd3dalpha{1,i} = xd2(2,i);
                dxd3dalpha{2,i} = 0;
            end
        end

        % Pixel coordinates:
        %if length(f)>1,
        u(1,:) = f(1) .* xd3(1,:) +  c(1);
        u(2,:) = f(2) .* xd3(2,:) +  c(2);

        if nargout > 1
            dudX      = cell(2,n);
            dudCam    = cell(2,n);
            dudA      = cell(2,n);
            dudB      = cell(2,n);
            dudC      = cell(2,n);
            dudomm    = cell(2,n);
            dudk      = cell(2,n);
            dudalpha  = cell(2,n);
            dudf      = cell(2,n);
            dudc      = cell(2,n);
            for i = 1 : n
                dudX{1,i}       = f(1) .* dxd3dX{1,i};
                dudX{2,i}       = f(2) .* dxd3dX{2,i};
                dudCam{1,i}     = f(1) .* dxd3dCam{1,i};
                dudCam{2,i}     = f(2) .* dxd3dCam{2,i};
                dudA{1,i}       = f(1) .* dxd3dA{1,i};
                dudA{2,i}       = f(2) .* dxd3dA{2,i};
                dudB{1,i}       = f(1) .* dxd3dB{1,i};
                dudB{2,i}       = f(2) .* dxd3dB{2,i};
                dudC{1,i}       = f(1) .* dxd3dC{1,i};
                dudC{2,i}       = f(2) .* dxd3dC{2,i};
                dudomm{1,i}     = f(1) .* dxd3domm{1,i};
                dudomm{2,i}     = f(2) .* dxd3domm{2,i};
                dudk{1,i}       = f(1) .* dxd3dk{1,i};
                dudk{2,i}       = f(2) .* dxd3dk{2,i};
                dudalpha{1,i}   = f(1) .* dxd3dalpha{1,i};
                dudalpha{2,i}   = f(2) .* dxd3dalpha{2,i};
                dudf{1,i}       = [xd3(1,i); 0];
                dudf{2,i}       = [0; xd3(2,i)];
                dudc{1,i}       = [1;0];
                dudc{2,i}       = [0;1];
            end
            
            varargout{1} = dudX;
            varargout{2} = dudCam;
            varargout{3} = dudA; 
            varargout{4} = dudB;
            varargout{5} = dudC;
            varargout{6} = dudomm;
            varargout{7} = dudk;
            varargout{8} = dudalpha; 
            varargout{9} = dudf;
            varargout{10}= dudc;
            
        end
     
    elseif size(varargin,2) == 9
        
        X       = varargin{1};
        Cam     = varargin{2};
        A       = varargin{3};
        B       = varargin{4};
        C       = varargin{5};
        k       = varargin{6};
        alpha   = varargin{7};
        f       = varargin{8};
        c       = varargin{9};
        
        % calculate the 3D point on the mirror surface in the camera coordinate system
        Xc = compute_mirror_point_in_camera (X, Cam, A, B, C);

        [m,n] = size(Xc);
    
        xx(1,:) = Xc(1,:) ./ Xc(3,:);
        xx(2,:) = Xc(2,:) ./ Xc(3,:);

        % Add distortion:
        r2 = xx(1,:).^2 + xx(2,:).^2;
        r4 = r2.^2;
        r6 = r2.^3;

        % Radial distortion:
        cdist = 1 + k(1) * r2 + k(2) * r4 + k(5) * r6;
        xd1 = xx .* (ones(2,1)*cdist);
       
        % tangential distortion:
        a1 = 2.*xx(1,:).*xx(2,:);
        a2 = r2 + 2*xx(1,:).^2;
        a3 = r2 + 2*xx(2,:).^2;
        delta_x = [k(3)*a1 + k(4)*a2 ;  k(3)*a3 + k(4)*a1];       
        xd2 = xd1 + delta_x;
       
        % Add Skew:
        xd3 = [xd2(1,:) + alpha*xd2(2,:);xd2(2,:)];

        % Pixel coordinates:
        %if length(f)>1,
        u(1,:) = f(1) .* xd3(1,:) +  c(1);
        u(2,:) = f(2) .* xd3(2,:) +  c(2); 
        
    else
        
        fprintf('Incorrect number of input data.\n');
                
    end
 


% else
%     u = f * xd3 + repmat([xc;yc],1,size(Xc,2));
%     
%     if nargout > 1
%         dud(:,1:18)  = f  * dxd3d;
%         dud(:,19)    = xd3(:);
%     end
%     
% end

else 
    
%     M = [ 20, 10; 50, 10; 80, 10 ];
%     om = [0.1, 0.2, 0.15];
%     T = [-50;45;10];
%     e = 34;
%     Cam = [1; 2; -e];
%         
%     a = 26.857800;
%     b = 20.848500;
%     A = -b^2/a^2;
%     B = 0;
%     C = -b^2;
%     
%     omm = [0.1, 0.2, 0.3];
%     k = [0.99, .98, .99, 96, 1];
%     alpha = 1;
%     f = [800; 800];
%     c = [512; 512];
    M = [0 0 0; 0 100 0; 0 200 0; 0 300 0]';
	om = [-1.506245004517837   0.069981842997532  -0.103412170166791]
    T = 1.0e+03 * [ -0.082593737150984; -2.790845916802325; 0.584922525941206];
    Cam = [ 4.001000000000000; 0.001000000000000; -34.000020192494006];
    
    A = -0.602571736063402; 
    B = 0;
	C = -4.346599522500001e+02;
    
    f = 1.0e+03 * [1.520178680606621; 1.520178680606621]
    c = [516; 516];
    omm = [ 0 0 0];
    alpha = 1;
    k = [ 0 0 0 0 0];
    
    % test derivatives
    flag = 1;   % Test Flag
    test_derivatives(@projection,1e-8,om,T,Cam,A,B,C,omm,k,alpha,f,c,M)
    
end
