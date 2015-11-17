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

function corners = findCorners(img,tau,refine_corners)

% find corners at two scales
corners1 = findCornersInImage(img,tau,refine_corners);
corners2 = findCornersInImage(imresize(img,0.5),tau,refine_corners);

% add corners from scale 1
corners.p  = corners1.p;
corners.r  = corners1.r;
corners.v1 = corners1.v1;
corners.v2 = corners1.v2;
corners.score = corners1.score;

% add missing corners from scale 2
corners2.p = corners2.p*2;
for i=1:size(corners2.p,1)
  n = size(corners.p,1);
  d = ones(n,1)*corners2.p(i,:)-corners.p;
  d = sqrt(d(:,1).*d(:,1)+d(:,2).*d(:,2));
  if min(d)>5
    corners.p  = [corners.p;  corners2.p(i,:) ];
    corners.r  = [corners.r;  corners2.r(i,:) ];
    corners.v1 = [corners.v1; corners2.v1(i,:)];
    corners.v2 = [corners.v2; corners2.v2(i,:)];
    corners.score = [corners.score; corners2.score(i,:)];
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function corners = findCornersInImage(img,tau,refine_corners)

% convert to double grayscale image
img = im2double(img);
if length(size(img))==3
  img = rgb2gray(img);
end

% normalize image and calculate gradients
[img,img_du,img_dv,img_angle,img_weight] = imageNormalizationAndGradients(img);

% templates and scales
tprops = [0 pi/2; pi/4 -pi/4; 0 pi/4; 0 -pi/4; pi/4 pi/2; -pi/4 pi/2; -3*pi/8 3*pi/8; -pi/8 pi/8; -pi/8 -3*pi/8; pi/8 3*pi/8];
radius = [4 6 10];

fprintf('Filtering image (%d x %d) ... ',size(img,2),size(img,1));

% for all scales do
corners.p = [];
for r=radius

  % filter image
  img_corners = zeros(size(img));
  for i=1:size(tprops,1)

    % create correlation template
    template = createCorrelationPatch(tprops(i,1),tprops(i,2),r);

    % filter image with current template
    if 0
      img_corners_a1 = conv2(img,template.a1,'same');
      img_corners_a2 = conv2(img,template.a2,'same');
      img_corners_b1 = conv2(img,template.b1,'same');
      img_corners_b2 = conv2(img,template.b2,'same');
    else
      img_corners_a1 = convMex(img,template.a1);
      img_corners_a2 = convMex(img,template.a2);
      img_corners_b1 = convMex(img,template.b1);
      img_corners_b2 = convMex(img,template.b2);
    end

    % compute mean
    img_corners_mu = (img_corners_a1+img_corners_a2+img_corners_b1+img_corners_b2)/4;

    % case 1: a=white, b=black
    img_corners_a = min(img_corners_a1-img_corners_mu,img_corners_a2-img_corners_mu);
    img_corners_b = min(img_corners_mu-img_corners_b1,img_corners_mu-img_corners_b2);
    img_corners_1 = min(img_corners_a,img_corners_b);

    % case 2: b=white, a=black
    img_corners_a = min(img_corners_mu-img_corners_a1,img_corners_mu-img_corners_a2);
    img_corners_b = min(img_corners_b1-img_corners_mu,img_corners_b2-img_corners_mu);
    img_corners_2 = min(img_corners_a,img_corners_b);

    % combine both
    img_corners = max(img_corners,max(img_corners_1,img_corners_2));
  end
  corners_p = nonMaximumSuppressionMex(img_corners,1,tau,5);
  corners.p = [corners.p; corners_p r*ones(size(corners_p,1),1)];
end

if size(corners.p,1)==0
  return;
end
corners.r = corners.p(:,4);
corners.p = corners.p(:,1:2);
fprintf('%d\n',length(corners.r));

% pre-filter corners according to zero crossings
fprintf('Filtering corners (%d x %d) ... ',size(img,2),size(img,1));
corners = filterCorners(img,img_angle,img_weight,corners,radius);
fprintf('%d\n',length(corners.r));

if 0
  figure,clf,axes('Position',[0 0 1 1]);
  imshow(img); axis tight; hold on;
  plotCorners(corners,1);
  keyboard;
end

% subpixel refinement
if refine_corners
  fprintf('Refining corners (%d x %d) ... ',size(img,2),size(img,1));
  corners = refineCorners(img_du,img_dv,img_angle,img_weight,corners,radius);
  fprintf('%d\n',length(corners.r));
end

if 0
  figure,clf,axes('Position',[0 0 1 1]);
  imshow(img); axis tight; hold on;
  plotCorners(corners,1);
  keyboard;
end

% score corners
fprintf('Scoring corners (%d x %d) ... ',size(img,2),size(img,1));
corners = scoreCorners(img,img_angle,img_weight,corners,radius);

% remove low scoring corners
corners = removeLowScoringCorners(corners,tau);

if 0
  figure,clf,axes('Position',[0 0 1 1]);
  imshow(img); axis tight; hold on;
  plotCorners(corners,1);
  keyboard;
end

% non maximum suppression
idx = nonMaximumSuppressionSparse(corners.p,corners.score,3,size(img));
corners.p(idx,:)   = [];
corners.r(idx)     = [];
corners.v1(idx,:)  = [];
corners.v2(idx,:)  = [];
corners.score(idx) = [];

fprintf('%d\n',length(corners.r));

% normalize direction of v's and make p's zero-based
corners = normalizeCoordinateSystemsZeroBased(corners);
