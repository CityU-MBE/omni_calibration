function img = loadImage(img_dir,files_img,idx,raw_data)

img = im2double(imread([img_dir '/' files_img(idx).name]));
if raw_data
  img = demosaicing(img);
end
