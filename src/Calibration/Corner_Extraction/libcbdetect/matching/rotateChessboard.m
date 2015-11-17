function chessboard = rotateChessboard(chessboard,rotation)

% rotate chessboard clockwise
for i=2:rotation
  chessboard = chessboard(end:-1:1,:)';
end
