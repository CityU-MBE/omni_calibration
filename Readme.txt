README LIBOMNICAL
Calibration Toolbox of one or more catadioptric cameras in Matlab

%%%%%%%%%%%%%%%%%%%%%%%%% LICENSE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Author: Miriam Schönbein
        Institute of Measurement and Control Systems (MRT)
        Karlsruhe Institute of Technology (KIT), Germany

This is free software; you can redistribute it and/or modify it under the
terms of the GNU General Public License as published by the Free Software
Foundation; either version 3 of the License, or any later version.

This software is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this software; if not, write to the Free Software Foundation, Inc., 51 Franklin
Street, Fifth Floor, Boston, MA 02110-1301, USA 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%% CITATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
If you find this software useful, please cite:

@INPROCEEDINGS{Schoenbein2014ICRA,
  author = {Miriam Schoenbein and Tobias Strauss and Andreas Geiger},
  title = {Calibrating and Centering Quasi-Central Catadioptric Cameras},
  booktitle = {International Conference on Robotics and Automation (ICRA)},
  year = {2014}
} 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%% DESCRIPTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LIBOMNICAL provides a MATLAB Toolbox to calibrate central and slightly non-central catadioptric cameras and catadioptric stereo setups. This is a reference implementation of the centered projection model presented in Calibrating and Centering Quasi-Central Catadioptric Cameras (ICRA 2014) as well as a number of central reference models. The calibration consists of an automatic corner extraction stage, a minimization part and the visualization of the calibration results. The toolbox contains demo images to run a quick demo calibration of a slightly non-central catadioptric stereo camera setup, where the corners of the images are already extracted. After installation of the library the calibration runs using a single command as described in the next section. All results are saved to a calibration folder. Besides the calibration result, the folder will contain the calibration images with the detected and estimated checkerboard positions, a visualization of the reprojection error for all checkerboards of each camera and the reconstructed 3D positions of the calibration patterns. 
The toolbox includes the reference calibration function from Scaramuzza et. al. [1], Mei & Rives [2] as well as the forward projection model from Agrawal et. al. [3].

References:
[1] Scaramuzza and Martinelli, A toolbox for easily calibrating omnidirectional cameras, IROS 2006
[2] Mei and Rives, Single view point omnidirectional camera calibration from planar grids, ICRA 2007
[3] Agrawal, Taguchi, and Ramalingam, Beyond alhazen’s problem: Analytical projection model for non-central catadioptric cameras with quadric mirrors, CVPR 2011


%%%%%%%%%%%%%%%%%%%%%%%%% INSTALLATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
1. Change path names:
	- root_dir = toobox folder and 
	- opencv_lib_dir 
	- and for Windows opencv_inc_dir and opencv_version
   in "init.m"
2. Run "init.m" in root_dir/src 
3. Run "make.m" in root_dir/src/ - takes some minutes

Note for Windows: Maybe dll files must be copied to the folder.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%% RUN CALIBRATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
1. Change path_name in "init.m" (already necessary for the installation)
2. Change parameters in "config.m" (Image folder / type of calibration / Output etc.)
   !Not neccessary for demo calibration (which has already extracted checkerboards)!
3. Run "init.m" in root_dir/src 
4. Run "omni_calibration.m"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%% PROJECTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Use calibration to project a 3D world point to a 2D image point
with "reprojection.m": 
u = reprojection ( param, X, method, cams)
u 	- 2D image point;
param 	- calibration result;
X 	- 3D world point;
method 	- projection and calibration method;
cams 	- number for which cam the points are projected.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%% DEMO STEREO CALIBRATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Images in: data/DemoImages
<calibration_name>: Calibration_040914
with already extracted checkerboard corners in images.mat and grid.mat.
Delete images.mat and grid.mat to test the corner extraction with the demo images.

NOTE: Optimization takes up to half an hour depending on the calibration method.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OUTPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Calibration parameters in: 
	calib_####.mat in data/<calibration_name>
Reprojection Error in: 
	data/<calibration_name>/Method_<method>/Repro_Error.mat
Visualizations:
	Reprojection Error for all checkerboards:
		data/<calibration_name>/Method_<method>/Repro_Error_Cam.png
	Reprojected (magenta) and extracted corners (green) in the images:
		data/<calibration_name>/Method_<method>/Result_Img_0000_01.png
	3D Calibration Pattern Position:
		data/<calibration_name>/Method_<method>/3D_Checkerboards.png

NOTE: For Methode 14 (Centered Model) the reprojection error of the 
checkerboards is not shown, since it is not relevant to evaluate the 
calibration result.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%% NEW CALIBRATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Before starting the calibration with other checkerboard images, clear "grid.mat" and "images.mat" in the data folder and change the parameters and path/calibration names in config.m!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%% METHOD DESCRIPTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
1-10: Geometric Model
11: Scaramuzza Model with normalization and geometric initialization
12: Mei Model with geometric initialization
14: Centered Model (need a geometric calibration as input)
16: Mei Model without distortions (Geyer)
17: Scaramuzza Model with original initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
