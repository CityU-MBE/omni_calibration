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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Unified projection model for omnidirectional %
%          sensors and jacobian                %
%                                              %
%  Created : 2005                              %
%   Author : Christopher Mei                   %
% Based on : Barreto PhD 2003                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Projects 3D points to the normalised plane
%
%%%%%%%%%%%%%%%%%% Input %%%%%%%%%%%%%%%%%%%%%%%
% X : points to project, 3xN matrix
% xi : mirror parameter
%
%%%%%%%%%%%%%%%%%% Output %%%%%%%%%%%%%%%%%%%%%%
% P : point in the image plane 2xN matrix
% dPdX : differentiation with respect to X
% dPdX : differentiation with respect to xi
%
function [P,dPdX,dPdxi] = spaceToNPlane(X, xi)

%path(path,'/home/cmei/prog_nosave/Matlab/General');

if nargin==0
  disp('Launching test...');
  test;
  return
end

switch nargout
 case 0
 case 1
  P=transform(X,xi);
 case 2
  P=transform(X,xi);
  dPdX = jacobianMirrorFull(X,xi);
 case 3
  P=transform(X,xi);
  dPdX = jacobianMirrorFull(X,xi);
  dPdxi = jacobianMirrorFullXi(X,xi);
 otherwise
  disp('Too many output args.')
end

function test
error=1e-4;

X=randn(3,1);
dX=randn(3,1)*error;

xi = 0.8;
dxi = xi*error;

disp(['Error : ' num2str(error)]);

[P,dPdX,dPdxi]=spaceToNPlane(X,xi);
Pp=spaceToNPlane(X+dX,xi);
Pp2=spaceToNPlane(X,xi+dxi);

n=size(X,2);
P=reshape(P,2*n,1);
Pp=reshape(Pp,2*n,1);
dP=dPdX*dX;
dP2=dPdxi*dxi;

gainP=norm(Pp-P)/norm(Pp-P-dP);
gainP2=norm(Pp2-P)/norm(Pp2-P-dP2);

disp(['Estimate gain in X : 1e' slog10(gainP)]);
disp(['Estimate gain in sxi : 1e' slog10(gainP2)]);

function P=transform(X,xi)

P = (ones(2,1)*(1./(X(3,:)+xi*sqrt(X(1,:).^2+X(2,:).^2+X(3,:).^2)))).*X(1:2,:);

%nb=size(X,2);
%P=zeros(2,nb);
%for col=1:nb
%  x=X(1,col);
%  y=X(2,col);
%  z=X(3,col);
%  denom=1/(z-xi*sqrt(x^2+y^2+z^2))
%  P(1,col)=x*denom;
%  P(2,col)=y*denom;
%end

function dPdX = jacobianMirrorFull(X,xi)
n = size(X,2);
dPdX=zeros(2*n,3);

for i=1:n
  dPdX(2*(i-1)+1:2*i,:)=jacobianMirror(X(:,i),xi);
end

function dPdX = jacobianMirror(X,xi)
x=X(1); y=X(2); z=X(3); r=norm(X);

dPdX=1/(r*(z+xi*r)^2)*...
     [r*z+xi*(y^2+z^2), -xi*x*y, x*(-xi*z-r);...
      -xi*x*y, r*z+xi*(x^2+z^2), y*(-xi*z-r)];


function dPdxi = jacobianMirrorFullXi(X,xi)
norms = sqrt(X(1,:).^2+X(2,:).^2+X(3,:).^2);
dPdxi = -(ones(2,1)*(norms./(X(3,:)+xi*norms).^2)).*X(1:2,:);
dPdxi = dPdxi(:);

%n = size(X,2);
%dPdxi=zeros(2*n,1);
%for i=1:n
%  dPdxi(2*(i-1)+1:2*i,:)=jacobianMirrorXi(X(:,i),xi);
%end
%max(dPdxi-dPdxi2)

%function dPdxi = jacobianMirrorXi(X,xi)
%x=X(1); y=X(2); z=X(3); r=norm(X);

%ddenom=r/(z-xi*r)^2;

%dPdxi=ddenom*[x;y];

function s=slog10(val)
s=num2str(floor(log10(val)));

