
function [corners,chessboards] = sort_corners(corners,chessboards,xc,yc)


%figure(2);
%imagesc(images.I{1,3}); colormap('gray'); hold on;
%plot(corners{1,n}.p(chessboards{1,n}{1,1}(1,1),1),corners{1,n}.p(chessboards{1,n}{1,1}(1,1),2),'r*');

max_x = size(chessboards,2);
max_y = size(chessboards,1);

%plot(corners{1,n}.p(chessboards{1,n}{1,1}(1,max_x),1),corners{1,n}.p(chessboards{1,n}{1,1}(1,max_x),2),'g*');
%plot(corners{1,n}.p(chessboards{1,n}{1,1}(max_y,1),1),corners{1,n}.p(chessboards{1,n}{1,1}(max_y,1),2),'m*');

sel = find_origin (corners.p,chessboards,max_x,max_y,xc,yc);


ct= [];
c2= [];

%starts from (5,7)
if sel==3
for j=1:max_x
    for i=1:max_y
        new_corners_2.p( (j-1)*max_y + i,:) = corners.p(chessboards((max_y+1)-i,(max_x+1)-j),:);
        ct=[ct;(j-1)*max_y + i];
    end
    c2=[c2,ct];ct=[];
end
end

%starts from (5,1)
if sel==4;
for j=1:max_y
    for i=1:max_x
        new_corners_2.p( (j-1)*max_x + i,:) = corners.p(chessboards((max_y+1)-j,i),:);
        ct=[ct;(j-1)*max_x + i];
    end
    c2=[c2,ct];ct=[];
end
end

%starts from (1,1)
if sel ==1
for j=1:max_x
    for i=1:max_y
        new_corners_2.p( (j-1)*max_y + i,:) = corners.p(chessboards(i,j),:);
        ct=[ct;(j-1)*max_y + i];
    end
    c2=[c2,ct];ct=[];
end
end

%starts from (1,7)
if sel == 2
for j=1:max_y
    for i=1:max_x
        new_corners_2.p( (j-1)*max_x + i,:) = corners.p(chessboards(j,(max_x+1)-i),:);
        ct=[ct;(j-1)*max_x + i];
    end
    c2=[c2,ct];ct=[];
end
end

corners.p=new_corners_2.p;
chessboards=c2;

end
