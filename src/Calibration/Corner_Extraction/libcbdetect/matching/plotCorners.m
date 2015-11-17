% Copyright 2012. All rights reserved.
% Author: Andreas Geiger
%         Institute of Measurement and Control Systems (MRT)
%         Karlsruhe Institute of Technology (KIT), Germany

% This is free software; you can redistribute it and/or modify it under the
% terms of the GNU General Public License as published by the Free Software
% Foundation; either version 3 of the License, or any later version.

% This software is distributed in the hope that it will be useful, but WITHOUT ANY
% WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
% PARTICULAR PURPOSE. See the GNU General Public License for more details.

% You should have received a copy of the GNU General Public License along with
% this software; if not, write to the Free Software Foundation, Inc., 51 Franklin
% Street, Fifth Floor, Boston, MA 02110-1301, USA 

function plotCorners(corners,base)

lw = 2;

if nargin<2
  base = 1;
end

% convert to 1-based index
if base==0
  corners.p = corners.p+1;
end

hold on;
for i=1:size(corners.p,1)
  if ~isfield(corners,'v1') || ~isfield(corners,'v2')
    plot(corners.p(i,1),corners.p(i,2),'+r','MarkerSize',10,'LineWidth',lw);
  else
    l1 = ones(2,1)*corners.p(i,:)+30*[-corners.v1(i,:);+corners.v1(i,:)];
    l2 = ones(2,1)*corners.p(i,:)+30*[-corners.v2(i,:);+corners.v2(i,:)];
    plot(l1(:,1),l1(:,2),'-r','LineWidth',lw);
    plot(l2(:,1),l2(:,2),'-r','LineWidth',lw);
  end
  text(corners.p(i,1)+0.1*randn,corners.p(i,2)+0.1*randn,num2str(i,'%d'),'HorizontalAlignment','center','color','g');
end
