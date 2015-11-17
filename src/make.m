% Meta make file
opts = init;

% path for the first make file
p = [opts.root_dir,'/src'];
path = [p, '/Mapping/Geometry_Model/Projection/Mex'];    

cd(path);

make;

% path for the second make file
path = [p, '/Mapping/Centered_Model'];
cd(path)

make;

cd(p);
