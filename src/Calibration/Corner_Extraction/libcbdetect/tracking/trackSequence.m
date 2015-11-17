function trackSequence(img_dir,raw_data,tau,plot,step)

if plot
  mkdir([img_dir '/plot']);
  figure('Position',[50 50 640 640],'visible','off'); clf;
  axes('Position',[0 0 1 1]);
end

% get list of images and detected corners
files_img = dir([img_dir '/*.png']);
files_mat = dir([img_dir '/*.mat']);

% find last computed corner file to start from
i=1;
if ~isempty(files_mat)
  for j=1:length(files_img)
    if strcmp(files_mat(end).name(1:end-4),files_img(j).name(1:end-4))
      load([img_dir '/' files_mat(end).name],'corners','chessboards');
      i=j+1;
      break;
    end
  end
end

% track corners as long as unprocessed files exist
while i<=length(files_img)

  img = loadImage(img_dir,files_img,i,raw_data);
  corners_ = cell(1);
  fprintf('Tracking: %s\n',files_img(i).name);
  
  if i>1
    img_prev = loadImage(img_dir,files_img,i-1,raw_data);
    [corners_{1},chessboards_] = trackCorners(img(:,:,1),img_prev(:,:,1),corners{1},chessboards,tau,1);
  end
  
  % find corners from scratch if first frame or tracking failed
  while isempty(corners_{1})
    
    if i>1
      i = min(i+step,length(files_img));
      img = loadImage(img_dir,files_img,i,raw_data);
    end
    
    % detect corners
    fprintf('Detecting: %s\n',files_img(i).name);
    corners_{1} = findCorners(img(:,:,1),0.01,1);
    
    % find chessboard
    chessboards_ = chessboardsFromCorners(corners_{1});
    chessboards_ = dominantChessboard(chessboards_);

    % remove all corners not indexed by any chessboard
    [corners_{1},chessboards_] = reduceCornersToChessboards(corners_{1},chessboards_);
    
    % invalidate if detected chessboard size is wrong and find best rotation
    if i>1
      if numel(chessboards_{1})~=numel(chessboards{1})
        corners_ = cell(1);
        chessboards_ = [];
      else
        [dist,rot] = minimumCornerDistance(chessboards{1},chessboards_{1},corners{1},corners_{1});
        chessboards_{1} = rotateChessboard(chessboards_{1},rot);
      end
    end
  end
  
  % refine corners in other color channels  
  for j=2:size(img,3)
    [corners_{j}] = trackCorners(img(:,:,j),img(:,:,1),corners_{1},0,tau,0);
  end
   
  % plot corners
  if plot
    cla; imshow(img); hold on;
    plotChessboards(chessboards_,corners_{1});
    export_fig(sprintf('%s/plot/%s',img_dir,files_img(i).name));
  end
  
  % save corners
  corners = corners_; chessboards = chessboards_;
  save([img_dir '/' files_img(i).name(1:end-4) '.mat'],'corners','chessboards');
  i=i+1;
end
