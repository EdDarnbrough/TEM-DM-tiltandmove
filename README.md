# Digital Micrograph scripts used for keeping an area of interest under the beam when tilting

All scripts are avialble to use at the users own risk. A more comprehensive website for learning how to use Gatan's DM scripting language is here: http://www.dmscripting.com/
The scripts make two key assumptions: 1 - the x and y axis are perpendicular to one another and each is aligned with one of your tilting directions. 2 - the tilt correction is linear. 

## Current Files:
TitlandCompensateUI - main script to use at the instrument for on the fly correction of region of interest moving during tilting. 
CalibrationShiftAndTilt - script used to automatically calculate the values needed for the TitlandCompensateUI

### Older versions
Stage2ImageAxisRotation - Looks at a set of images contating the same object/region with different stage positions and finds the relative rotation between the image x-y and the stage x-y. 
RotateAllimageTheta - Simple script to apply the found rotation to all images. User can then create RGB images to confirm that now shifts in x or y are consistent. 

