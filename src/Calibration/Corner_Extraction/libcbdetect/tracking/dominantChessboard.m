function chessboards = dominantChessboard(chessboards)

chessboard = [];
for i=1:length(chessboards)
  if numel(chessboards{i})>numel(chessboard)
    chessboard = chessboards{i};
  end
end

chessboards = [];
chessboards{1} = chessboard;
