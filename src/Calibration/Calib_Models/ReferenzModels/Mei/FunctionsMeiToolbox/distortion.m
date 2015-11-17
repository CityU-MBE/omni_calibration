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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                 %
%     Calculates the distortion function          %
%               and its jacobian                  %
%                                                 %
%   Created : 2005                                %
%    Author : Christopher Mei                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [P,dPdK,dPdX] = distortion(X, K)

if nargin==0
  disp('Launching test...');
  test;
  return
end

k1=K(1);k2=K(2);k3=K(3);k4=K(4);k5=K(5);

switch nargout
 case 0
 case 1
  P=transform(X,k1,k2,k3,k4,k5);
 case 2
  P=transform(X,k1,k2,k3,k4,k5);
  dPdK = jacobianKDistortionFull(X,k1,k2,k3,k4,k5);
 case 3
  P=transform(X,k1,k2,k3,k4,k5);
  dPdK = jacobianKDistortionFull(X,k1,k2,k3,k4,k5);
  dPdX = jacobianXDistortionFull(X,k1,k2,k3,k4,k5);
 otherwise
  disp('Too many output args.')
end

function test
error=1e-4;
disp(['Error : 1e' slog10(error)]);

%%% Values %%%
X=10*randn(2,1);
dX=10*randn(2,1)*error;

K=10*randn(5,1);
dK=10*randn(5,1)*error;

[P,dPdK,dPdX]=distortion(X,K);

%%% Test derivation in K %%%
Pp=distortion(X,K+dK);
dP=dPdK*dK;

gainP=norm(Pp-P)/norm(Pp-P-dP);
disp(['Estimate gain in K : 1e' slog10(gainP)]);

%%% Test derivation in X %%%
Pp=distortion(X+dX,K);
dP=dPdX*dX;

gainP=norm(Pp-P)/norm(Pp-P-dP);
disp(['Estimate gain in X : 1e' slog10(gainP)]);

function P=transform(X,k1,k2,k3,k4,k5)
nb=size(X);
nb=nb(2);

P=zeros(2,nb);

% for col=1:nb
%   x=X(1,col);
%   y=X(2,col);
%   r2=x^2+y^2;
%   radDist= 1 + k1*r2 + k2*r2^2 + k5*r2^3;
%   P(1,col)=x*radDist + 2*k3*x*y + k4*(r2+2*x^2);
%   P(2,col)=y*radDist + k3*(r2+2*y^2) + 2*k4*x*y;
% end

% Miri geändert
x = X(1,:);
y = X(2,:);
r2 = x.^2 + y.^2;
radDist = 1 + k1*r2 + k2*r2.^2 + k5*r2.^3;
P(1,:)=x.*radDist + 2*k3.*x.*y + k4*(r2+2.*x.^2);
P(2,:)=y.*radDist + k3*(r2+2.*y.^2) + 2*k4.*x.*y;


function dPdK = jacobianKDistortionFull(X,k1,k2,k3,k4,k5)
[m,n] = size(X);
dPdK=zeros(2*n,5);

for i=1:n
  dPdK(2*(i-1)+1:2*i,:)=jacobianKDistortion(X(:,i),k1,k2,k3,k4,k5);
end

function dPdX = jacobianXDistortionFull(X,k1,k2,k3,k4,k5)
[m,n] = size(X);
dPdX=zeros(2*n,2);

for i=1:n
  dPdX(2*(i-1)+1:2*i,:)=jacobianXDistortion(X(:,i),k1,k2,k3,k4,k5);
end

function dPdK = jacobianKDistortion(X,k1,k2,k3,k4,k5)
x=X(1); y=X(2); r2=x^2+y^2;

dPdK=[x*r2, x*r2^2, 2*x*y, r2+2*x^2, x*r2^3;
      y*r2, y*r2^2, r2+2*y^2, 2*x*y, y*r2^3];

function dPdX = jacobianXDistortion(X,k1,k2,k3,k4,k5)
x=X(1); y=X(2); r2=x^2+y^2;

l= k1*2*x*y + k2*4*r2*x*y + k3*2*x + k4*2*y + k5*6*r2^2*x*y;

dPdX=[1 + k1*(r2+2*x^2) + k2*r2*(r2+4*x^2) + k3*2*y + k4*6*x + k5*r2^2*(r2+6*x^2), l;
      l, 1 + k1*(r2+2*y^2) + k2*r2*(r2+4*y^2) + k3*6*y + k4*2*x + k5*r2^2*(r2+6*y^2)];
      
function s=slog10(val)
s=num2str(floor(log10(val)));
