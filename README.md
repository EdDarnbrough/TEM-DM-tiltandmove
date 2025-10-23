# Digital Micrograph scripts used for keeping an area of interest under the beam when tilting

All scripts are avialble to use at the users own risk. A more comprehensive website for learning how to use Gatan's DM scripting language is here: http://www.dmscripting.com/

## Current Files:
1. Looks at a set of images contating the same object/region with different stage positions and finds the relative rotation between the image x-y and the stage x-y. 
2. Simple script to apply the found rotation to all images. User can then create RGB images to confirm that now shifts in x or y are consistent. 



## Future Files:
a. file to find relationship between stage shift and pixel shifts
b. an automated way to collect the images required for this calibration proceedure
c. simple scripts to tilt and apply stage shift correction
d. UI wrapper for tilting
