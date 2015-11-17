function [ x, y ] = rearrange_corners( x_in, y_in, info )
%Rearrange the corners if wrong sorted

nx = info.n_sq_x+1;
ny = info.n_sq_y+1;

board = 1:nx*ny;

% change axis
board = reshape(board, nx, ny);
board = board';
board = reshape(board, 1, nx*ny);


board = reshape(board, ny, nx);
board2 = zeros(size(board));

% change position along y-axis
for i=0:(nx-1)
   ind = i-nx;
   if ind<1
       ind = nx-i;
   end
   board2(:,i+1) = board(:,ind);
end

board = reshape(board2, 1, nx*ny);

x = x_in(board);
y = y_in(board);

end

