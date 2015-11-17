function [dist,rot] = minimumCornerDistance(chessboard_ref,chessboard_tar,corners_ref,corners_tar,A,b)

if nargin==4
  A = eye(2);
  b = [0 0];
end  

% init distance
dist = inf;
rot  = 0;

% for all rotations do (i=1 => no rotation)
for i=1:4
  p_ref = corners_ref.p(chessboard_ref(:),:);
  p_tar = corners_tar.p(chessboard_tar(:),:)*A + ones(length(chessboard_tar(:)),1)*b;
  
  % check if chessboards have same size
  if size(chessboard_ref,1) == size(chessboard_tar,1) && ...
     size(chessboard_ref,2) == size(chessboard_tar,2)
    
    % compute mean distance, and save, if better than before
    dist_ = p_ref-p_tar;
    dist_ = mean(sqrt(dist_(:,1).^2+dist_(:,2).^2));
    if dist_<dist
      dist = dist_;
      rot  = i;
    end
  end

  % rotate target chessboard clockwise
  chessboard_tar = chessboard_tar(end:-1:1,:)';
end
