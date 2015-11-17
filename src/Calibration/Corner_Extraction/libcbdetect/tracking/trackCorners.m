function [corners_,chessboards_] = trackCorners(img,img_prev,corners,chessboards,tau,large_displacement)

rt = 10; % radius template
if large_displacement % radius search area
  rs = 100;
else
  rs = 15;
end
radius = [4 6 10];

% pad previous image to capture all possible template areas
img2_prev = zeros(size(img_prev)+2*rt);
img2_prev(rt+(1:size(img_prev,1)),rt+(1:size(img_prev,2))) = img_prev;

% pad current image to capture all possible search areas
img2 = zeros(size(img)+2*rs);
img2(rs+(1:size(img,1)),rs+(1:size(img,2))) = img;

if 0
  figure,imshow(img_prev),hold on;
  plotCorners(corners,0);
  keyboard;
end

% for all corners do
p = []; s = [];
for i=1:size(corners.p,1)

  % correlate
  pt = round(corners.p(i,:))+1; % 1-based index
  if isfield(corners,'vel')
    ps = round(pt+corners.vel(i,:));  
  else
    ps = pt;
  end
  T = img2_prev(rt+(pt(2)-rt:pt(2)+rt),rt+(pt(1)-rt:pt(1)+rt));
  S = img2(rs+(ps(2)-rs:ps(2)+rs),rs+(ps(1)-rs:ps(1)+rs));
  C = normxcorr2(T,S);

  % crop correlation window to true size
  m1 = floor((size(C,1)-(size(S,1)-size(T,1)))/2);
  m2 = floor((size(C,2)-(size(S,2)-size(T,2)))/2);
  C  = C(m1+1:end-m1,m2+1:end-m2);
  
  % non-maxima suppression
  if large_displacement
    maxima = nonMaximumSuppressionMex(C,5,0.7,0);
  else
    [row,col] = find(C==max(C(:)),1,'first');
    maxima = [col row C(row,col)];
  end

  % add maxima
  if size(maxima,1)>0
    p = [p; ones(size(maxima,1),1)*ps+maxima(:,1:2)-(rs-rt+1)];
    s = [s; maxima(:,3)];
  end
end

if large_displacement
  idx = nonMaximumSuppressionSparse(p,s,5,size(img));
  p(idx,:) = [];
end
corners_.p = p;

if 0
  figure,imshow(img),hold on;
  plotCorners(corners_,1);
  keyboard;
end

% normalize image and calculate gradients
[img,img_du,img_dv,img_angle,img_weight] = imageNormalizationAndGradients(img);

% large displacements
if large_displacement

  % try to refine corners for each possible corner size
  % (the size might change during tracking)
  corners_r_all = [];
  for i=1:length(radius)

    % create local working copy
    corners_r = corners_;
    corners_r.r(1:size(corners_.p,1),1) = radius(i);

    % sub-pixel refinement
    corners_r = refineCorners(img_du,img_dv,img_angle,img_weight,corners_r,radius,1);

    % score corners
    corners_r = scoreCorners(img,img_angle,img_weight,corners_r,radius);
    
    % add to list
    if i==1
      corners_r_all = corners_r;
    else
      corners_r_all.p = [corners_r_all.p; corners_r.p];
      corners_r_all.r = [corners_r_all.r; corners_r.r];
      corners_r_all.v1 = [corners_r_all.v1; corners_r.v1];
      corners_r_all.v2 = [corners_r_all.v2; corners_r.v2];
      corners_r_all.score = [corners_r_all.score; corners_r.score];
    end
  end

  % remove doublettes
  idx = nonMaximumSuppressionSparse(corners_r_all.p,corners_r_all.score,5,size(img));
  corners_r_all.p(idx,:) = [];
  corners_r_all.r(idx,:) = [];
  corners_r_all.v1(idx,:) = [];
  corners_r_all.v2(idx,:) = [];
  corners_r_all.score(idx,:) = [];

  % remove bad corners
  corners_ = removeLowScoringCorners(corners_r_all,tau);

  % normalize direction of v's and make p's zero-based
  corners_ = normalizeCoordinateSystemsZeroBased(corners_);

  % find chessboard
  chessboards_ = chessboardsFromCorners(corners_);
  chessboards_ = dominantChessboard(chessboards_);

  % remove all corners not indexed by any chessboard
  [corners_,chessboards_] = reduceCornersToChessboards(corners_,chessboards_);

  % check if detected chessboard has correct size (same as previous)
  if ~all(size(chessboards_{1})==size(chessboards{1}))
    corners_ = [];
    chessboards_ = [];
    return;
  end

  % find best rotation wrt. previous detection
  % (works only with 1 chessboard detection so far, no matching)
  [dist,rot] = minimumCornerDistance(chessboards{1},chessboards_{1},corners,corners_);
  chessboards_{1} = rotateChessboard(chessboards_{1},rot);
  
% small displacements
else
  
  % copy radius + score from previous corners
  corners_.r = corners.r;
  corners_.score = corners.score;

  % sub-pixel refinement
  corners_ = refineCorners(img_du,img_dv,img_angle,img_weight,corners_,radius,1); 
  
  % make corners zero-based
  corners_.p = corners_.p-1;
end

if 0
  figure,imshow(img),hold on;
  plotChessboards(chessboards_,corners_);
  keyboard;
end
