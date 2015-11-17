# Omnidirectional Calibration Toolbox

This is a calibration toolbox for omnidirectional cameras which can be used with MATLAB.
The most common omnidirectional camera models can be used for calibration and the toolbox has good corner extraction capabilities even for quite distorted omnidirectional images.

The toolbox is based on [LIBOMNICAL](http://www.cvlibs.net/projects/omnicam/) [1].

This toolbox fixes some bugs, adds some additional features and was mainly used and tested with the Mei model. 
Therefore the other model implementations need probably some bug fixes too and everybody is welcome to contribute!

The idea is to have a *general omnidirectional calibration toolbox* for all the common models and a platform for future model implementations.


### Camera Models

This toolbox incorporates the following models:

* Mei Model [2]
* Central Model (KIT) [1]
* Geometric Model (KIT) [1]
* Scaramuzza Model* [3]
* Geyer Model* [4]

\* There may be some bugs with these models. Please help to improve this toolbox.


### Reference Papers

**[1]** Miriam Schoenbein and Tobias Strauss and Andreas Geiger, **Calibrating and Centering Quasi-Central Catadioptric Cameras**, *ICRA*, 2014

**[2]** J. P. Barreto and H. Araujo, **Geometric properties of central catadioptric line images and their application in calibration**, *PAMI, vol. 27, no. 8, pp. 1327-1333*, 2005

**[3]** D. Scaramuzza and A. Martinelli, **A toolbox for easily calibrating omnidirectional cameras**, *IROS*, 2006

**[4]** C. Geyer and K. Daniilidis, **Paracatadioptric camera calibration**, *PAMI, vol. 24, no. 5, pp. 687-695*, 2002.


# 1. Installation

1. Adapt the path in the file **_init.m_**
2. Run `init` in MATLAB
3. Run `make` (only necessary for models from [1])


# 2. Calibration

1. Adapt the configuration file **_config.m_**
2. For calibration with new images: clear *grid.mat* and *images.mat* in the *data* directory
3. Run `start_omnical` in the MATLAB command window and follow the instructions


# 3. Output

* Calibration parameters in: 
  - calib\_####.mat in *data/calibration_name*
  - For Mei Model also saved in *Result\_Mei\_###.txt* and printed on the screen
* Reprojection Error in: 
  - data/calibration_name/Method_method/Repro_Error.mat*
* Visualizations:
  - Reprojection Error for all checkerboards:
    *data/calibration_name/Method_method/Repro\_Error\_Cam.png*
  - Reprojected (magenta) and extracted corners (green) in the images:
        *data/calibration_name/Methodmethod/Result\_Img\_0000\_01.png*
  - 3D Calibration Pattern Position:
        *data/\calibration\_name/Method\_\method/3D\_Checkerboards.png*


# 4. Projection

Use the calibration to project a 3D world point to a 2D image point with *reprojection.m*: 

`u = reprojection ( param, X, method, cams)`

* `u`   - 2D image point
* `param`   - calibration result (load the results from the data folder first)
* `X`   - 3D world point
* `method`  - projection and calibration method
* `cams`    - number for which cam the points are projected


# Licence

This is free software; you can redistribute it and/or modify it under the
terms of the GNU General Public License as published by the Free Software
Foundation; either version 3 of the License, or any later version.

This software is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this software; if not, write to the Free Software Foundation, Inc., 51 Franklin
Street, Fifth Floor, Boston, MA 02110-1301, USA 
