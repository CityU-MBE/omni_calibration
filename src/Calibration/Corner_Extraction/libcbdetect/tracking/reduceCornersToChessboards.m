function [corners,chessboards] = reduceCornersToChessboards(corners,chessboards)

active = zeros(1,size(corners.p,1));
for i=1:length(chessboards)
  for m=1:size(chessboards{i},1)
    for n=1:size(chessboards{i},2)
      active(chessboards{i}(m,n)) = 1;
    end
  end
end

% get indices of indexed corners
idx = find(active);

% remove non-indexed corners
corners.p  = corners.p(idx,:);
corners.r  = corners.r(idx);
corners.v1 = corners.v1(idx,:);
corners.v2 = corners.v2(idx,:);
corners.score = corners.score(idx);

% update chessboard indices
for i=1:length(chessboards)
  for m=1:size(chessboards{i},1)
    for n=1:size(chessboards{i},2)
      chessboards{i}(m,n) = find(idx==chessboards{i}(m,n));
    end
  end
end
