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

function corners_out = filterCorners(img,img_angle,img_weight,corners_in,radius)

width  = size(img,2);
height = size(img,1);

n = 32;
angles = linspace(0,2*pi,n);
circle = [cos(angles)' sin(angles)'];

weight_mask = weightMask(radius);

corners_out.p = [];
corners_out.r = [];

for i=1:size(corners_in.p,1)
  
  % extract circle locations
  u = round(corners_in.p(i,1));
  v = round(corners_in.p(i,2));
  p = corners_in.p(i,:);
  r = corners_in.r(i,:);
  q = round(ones(n,1)*p+0.75*r*circle);
  
  % image circle => centered vector
  c = img(sub2ind(size(img),q(:,2),q(:,1)))';
  c = c-min(c)-(max(c)-min(c))/2;
  
  % count number of zero-crossings
  num_crossings = 0;
  for j1=1:n
    j2 = mod(j1,n)+1;
    if xor(c(j1)>0,c(j2)>0)
      num_crossings = num_crossings+1;
    end
  end
  
  img_sub = img(max(v-r,1):min(v+r,height),max(u-r,1):min(u+r,width));
  img_angle_sub = img_angle(max(v-r,1):min(v+r,height),max(u-r,1):min(u+r,width));
  img_weight_sub = img_weight(max(v-r,1):min(v+r,height),max(u-r,1):min(u+r,width));
  img_weight_sub = img_weight_sub .* weight_mask{r};
  img_weight_sub(img_weight_sub<0.5*max(img_weight_sub(:))) = 0;
  
  % convert images to vectors
  vec_angle  = img_angle_sub(:);
  vec_weight = img_weight_sub(:);

  % convert angles from normals to directions
  vec_angle = vec_angle+pi/2;
  vec_angle(vec_angle>pi) = vec_angle(vec_angle>pi)-pi;

  % create histogram
  angle_hist = zeros(1,n);
  for i=1:length(vec_angle)
    bin = max(min(floor(vec_angle(i)/(pi/n)),n-1),0)+1;
    angle_hist(bin) = angle_hist(bin)+vec_weight(i);
  end
  
  [modes,angle_hist_smoothed] = findModesMeanShift(angle_hist,1.5);
  num_modes = length(find(modes(:,2)>0.5*modes(1,2)));
  
  if num_crossings==4 && num_modes==2
    corners_out.p = [corners_out.p; p];
    corners_out.r = [corners_out.r; r];
  end
end


