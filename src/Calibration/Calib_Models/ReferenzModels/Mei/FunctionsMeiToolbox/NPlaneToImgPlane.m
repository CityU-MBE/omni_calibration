% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation, version 2.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software Foundation,
% Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                   %
% Calculates the perspective projection function    %
% (generalised projection matrix) and its jacobian  %
%                                                   %
%   Created : 2005                                  %
%    Author : Christopher Mei                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% Projects points from the normalised plane
% to the image plane
%

% Input:
%   X : points on the normalised image plane (after distortion) 2xN
%   V : 5 camera parameters (alpha,gamma1,gamma2,c1,c2)
%
% Output :
%   P : points on the image plane 2xN
%   dPdV,dPdX : jacobians with respect to the input variables
%
function [P,dPdV,dPdX] = NPlaneToImgPlane(X, V)

if nargin==0
  disp('Launching test...');
  test;
  return
end

alpha=V(1);gamma1=V(2);gamma2=V(3);c1=V(4);c2=V(5);

switch nargout
 case 0
 case 1
  P=transform(X,alpha,gamma1,gamma2,c1,c2);
 case 2
  P=transform(X,alpha,gamma1,gamma2,c1,c2);
  dPdV = jacobianVProjectionFull(X,alpha,gamma1,gamma2,c1,c2);
 case 3
  P=transform(X,alpha,gamma1,gamma2,c1,c2);
  dPdV = jacobianVProjectionFull(X,alpha,gamma1,gamma2,c1,c2);
  dPdX = jacobianXProjectionFull(X,alpha,gamma1,gamma2,c1,c2);
 otherwise
  disp('Too many output args.')
end

function test
error=1e-4;
disp(['Error : 1e' slog10(error)]);

%%% Values %%%
X=randn(2,1);
dX=randn(2,1)*error;

V = randn(5,1);
dV=V*error;

[P,dPdV,dPdX]=NPlaneToImgPlane(X,V);

%%% Test derivation in V %%%
Pp=NPlaneToImgPlane(X,V+dV);

gainP=norm(Pp-P)/norm(Pp-P-dPdV*dV);
disp(['Estimated gain in V : 1e' slog10(gainP)]);

%%% Test derivation in X %%%
Pp=NPlaneToImgPlane(X+dX,V);

dP=dPdX*dX;

gainP=norm(Pp-P)/norm(Pp-P-dP);
disp(['Estimated gain in X : 1e' slog10(gainP)]);

function P=transform(X,alpha,gamma1,gamma2,c1,c2)
P = [gamma1*(X(1,:)+alpha*X(2,:))+c1;
     gamma2*X(2,:)+c2];

function dPdV = jacobianVProjectionFull(X,alpha,gamma1,gamma2,c1,c2)
[m,n] = size(X);
dPdV=zeros(2*n,5);

for i=1:n
  dPdV(2*(i-1)+1:2*i,:)=jacobianVProjection(X(:,i),alpha,gamma1,gamma2,c1,c2);
end

function dPdX = jacobianXProjectionFull(X,alpha,gamma1,gamma2,c1,c2)
[m,n] = size(X);
dPdX=zeros(2*n,2);

for i=1:n
  dPdX(2*(i-1)+1:2*i,:)=jacobianXProjection(X(:,i),alpha,gamma1,gamma2,c1,c2);
end

function dPdV = jacobianVProjection(X,alpha,gamma1,gamma2,c1,c2)
x=X(1); y=X(2);

dPdV=[gamma1*y,x+alpha*y,0,1,0;
      0,0,y,0,1];

function dPdX = jacobianXProjection(X,alpha,gamma1,gamma2,c1,c2)
dPdX=[gamma1,gamma1*alpha;
      0,gamma2];

function s=slog10(val)
s=num2str(floor(log10(val)));
