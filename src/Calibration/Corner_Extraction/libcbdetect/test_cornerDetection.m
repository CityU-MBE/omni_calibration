function test_cornerDetection()

clear all; dbstop error; close all;
disp('==========================');

% add matching + calibration + rectification toolbox
addpath('../matching');

% filename{1} = '/home/geiger/4_Projects/libcalibration/data/miriam/focal/Tele/1/img-20130301-130907-494.png';
% filename{2} = '/home/geiger/4_Projects/libcalibration/data/miriam/focal/Tele/1/img-20130301-131422-812.png';
% filename{3} = '/home/geiger/4_Projects/libcalibration/data/miriam/focal/T_W/1/img-20130301-132958-925.png';
% filename{4} = '/home/geiger/4_Projects/libcalibration/data/miriam/focal/Wide/1/img-20130301-134120-369.png';
% filename{5} = '/home/geiger/4_Projects/libcalibration/data/miriam/focal/Wide/1/img-20130301-134128-674.png';
% filename{6} = '/home/geiger/4_Projects/libcalibration/data/miriam/focal/Wide/1/img-20130301-134138-514.png';
% filename{7} = '/home/geiger/4_Projects/libcalibration/data/miriam/focal/Wide/1/img-20130301-134149-262.png';

root_dir = '/home/geiger/4_Projects/libcalibration/data/miriam';
filename = [];
filename = [filename getFileNames([root_dir '/focal/Tele/3'])];
filename = [filename getFileNames([root_dir '/focal/T_W/3'])];
filename = [filename getFileNames([root_dir '/focal/Wide/3'])];
filename = [filename getFileNames([root_dir '/focal/Tele/1'])];
filename = [filename getFileNames([root_dir '/focal/T_W/1'])];
filename = [filename getFileNames([root_dir '/focal/Wide/1'])];
filename = [filename getFileNames([root_dir '/calib1/hard/images'])];

figure(1),clf,axes('Position',[0 0 1 1]);
for i=1:length(filename)
  
  I = imread(filename{i});
  
  corners = findCorners(I,0.05,1);  
  chessboards = chessboardsFromCorners(corners);
  
  cla; imshow(I); axis tight; hold on;
  %plotCorners(corners,0);
  plotChessboards(chessboards,corners);
  refresh; pause(0.1);
  
  [path,name] = fileparts(filename{i});
  mkdir(sprintf('%s/corners',path));
  export_fig(sprintf('%s/corners/%s.png',path,name));
  save(sprintf('%s/corners/%s.mat',path,name),'corners','chessboards');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function filenames = getFileNames(folder)

files = dir([folder '/*.png']);

filenames = [];
for i=1:length(files)
  filenames{end+1} = [folder '/' files(i).name];
end
