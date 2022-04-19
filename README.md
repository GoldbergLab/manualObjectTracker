# manualObjectTracker

manualObjectTracker is a MATLAB GUI for manually tracking objects in videos, for generating training sets for machine learning algorithms.

manualObjectTracker was developed with and for MATLAB R2017a. It has been tested fairly thoroughly in R2019a. Use it with other versions of MATLAB at your own risk.

## Installation

1. Download all files or clone the repository
2. Download or clone the [MATLAB-utils](https://github.com/GoldbergLab/MATLAB-utils) repository
3. Add both this repository and MATLAB-utils to your MATLAB path.
4. Open MATLAB
5. In the command window, type ```manualObjectTracker```
6. Off you go.

## Using generateRandomManualTrackingListGUI

1. Open MATLAB
2. In the command window, type ```generateRandomManualTrackingListGUI```
3. Uncheck 'Weighted Randomization' (this was built for in-lab data), unless using our Labview behavior code. 
3. Add directories containing videos as specified under 'List directories...' window
4. List video extensions to specify video file types that the frames should be drawn from (default - .avi)
5. Enter regex if you'd like to filter videos by a specifier in the name of the video. (default - use all videos [.*])
6. Specify total number of frames to pick from the pool of videos (default - 100).
7. Specify a directory to save video clips and annotation file.  
8. Enter a clip radius (number of frames on either side of selected frame; default - 3). This is helpful in manualObjectTracker if the tongue outline in the selected frame is difficult to identify.  

## Usage

See the [User Manual](Documentation/UserManual.md)

## Contributing
Contact Brian Kardon at bmk27 (at) cornell (dot) edu

## License
[MIT](https://choosealicense.com/licenses/mit/)
