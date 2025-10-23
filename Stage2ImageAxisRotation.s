///////////////
// functions //
///////////////
void CrossCorr(image imageA, image imageB, number &xIS, number &yIS, number &maxval)
{	
	image crosscorrimg:=crosscorrelation(imageA, imageB)
	number posx, posy, centrex, centrey, xsize, ysize

	getsize(imageA, xsize, ysize)
	centrex=xsize/2
	centrey=ysize/2

// Calculate the position of the cross correlation maximum
		
	maxval=max(crosscorrimg, posx,posy)

// Compute the offfsets with respect to imagea and create a dfift corrected image
	number xshift, yshift
	yshift=centrex-posx //results suggest that the x and y of the image are the opposite of the stage
	xshift=centrey-posy

// find image calibration to convert to real units
	string unitstring=imagegetdimensionunitstring(imageA,0)

	number dimension, origin, scale, calibformat

	calibformat=1

	dimension=0 //(note a lineplot has only one dimension, an image 2, a data cube 3)

	ImagegetDimensionCalibration( imageA, dimension, origin, scale,unitstring,calibformat )

	xIS = xshift*scale 
	yIS = yshift*scale
	// okdialog(scale+" "+xshift+" "+yshift)
	// result("\n"+"Image used has a scale of"+scale+" "+unitstring)
	return
} 

void StagePos(image imageA, number &alphaA, number &betaA, number &xA, number &yA, number &zA)
{
	taggroup imgtagsa=imageA.imagegettaggroup()
	//number alphaA, betaA, xA, yA, zA

	string targetalphaa="Microscope Info:Stage Position:Stage Alpha"
	string targetbetaa="Microscope Info:Stage Position:Stage Beta"
	string targetxa="Microscope Info:Stage Position:Stage X"
	string targetya="Microscope Info:Stage Position:Stage Y"
	string targetza="Microscope Info:Stage Position:Stage Z"

	imgtagsa.taggroupgettagasnumber(targetalphaa, alphaA)
	imgtagsa.taggroupgettagasnumber(targetbetaa, betaA)
	imgtagsa.taggroupgettagasnumber(targetxa, xA)
	imgtagsa.taggroupgettagasnumber(targetya, yA)
	imgtagsa.taggroupgettagasnumber(targetza, zA)

}

void StageShifts(image imageA, image imageB, number &alphaSS, number &betaSS, number &xSS, number &ySS, number &zSS, number &alphaA, number &alphaB, number &betaA, number &betaB)
{
	// image A
	number xA, yA, zA
	StagePos(imageA, alphaA, betaA, xA, yA, zA)
	
	// image B
	number xB, yB, zB
	StagePos(imageB, alphaB, betaB, xB, yB, zB)

// Calculate stage shift
	//number alphaSS, betaSS, xSS, ySS, zSS // Stage shift

	alphaSS = alphaA-alphaB //relative change in alpha 
	betaSS  = betaA-betaB //relative change in beta
 	xSS     = xA-xB
	ySS     = yA-yB
	zSS     = zA-zB
}


//////////////////
// main program //
//////////////////

number theta = 0 //assume no strating rotation

// find images to work with //
imagedocument imagedocA, imagedocB //blank window lables
number nodocs=countimagedocuments() // count all image documents, including hidden ones

// Create a text editor window into which to save human readable outputs //
string path="Shift settings"
number top=100, left=100, bottom=400, right=600
documentwindow textwin=NewScriptWindow( path, top, left, bottom, right )

// Create an image to act as an array and save numbers
number spaces = 2*nodocs //spaces needed really is the triangle number of nodocs but I don't know how to code that in DMscript
image dataarray :=realimage("",4,spaces,5)
number counter = 0

// Create all variables for calculations //
number xImSh, yImSh, maxvalue
number alphaSS, betaSS, xSS, ySS, zSS
number alphaA, alphaB, betaA, betaB
number i=0,j 

number CalX=0.1, CalY=0.1 //Image shift is greater than stage

// Loop to compare one image with all others, then the next image with all etc 
// hopefully no redundent calculations 
for(i=0; i<nodocs-1; i++){
for(j=i+1; j<nodocs; j++){
textwin.EditorWindowAddText( "\nLoop :"+i+j) // name the loop for image A and image B

// get windows by number
imagedocA=getimagedocument(i)
imagedocB=getimagedocument(j)
// get images from those windows (image documents) 
image imageA:=imagedocA.imagedocumentgetimage(0)
image imageB:=imagedocB.imagedocumentgetimage(0)


CrossCorr(imageA,imageB, xImSh, yImSh, maxvalue) // Cross Correlation of images for Image shift
//textwin.EditorWindowAddText( "\n"+xImSh+" "+yImSh+" "+maxvalue)  // report values if confidence in CC is important/interesting

StageShifts(imageA, imageB, alphaSS, betaSS, xSS, ySS, zSS, alphaA, alphaB, betaA, betaB) // Stage shifts between the two images


number DiffSX, DiffSY // Look for differences

number r_shift = (xImSh**2 + yImSh**2)**0.5
theta   = atan(xImSh/yImSh)*(180/pi())

if(xSS**2<0.5 && alphaSS**2<0.5 && betaSS**2<0.5) // If the stage shift is only y use to calibrate
{
DiffSY = (ySS**2)**0.5-r_shift*CalY
textwin.EditorWindowAddText("\nDifference in Y after rotate:"+DiffSY+" at "+theta+"degs")
}

if(ySS**2<0.5 && alphaSS**2<0.5 && betaSS**2<0.5) // If the stage shift is only x use to calibrate
{
DiffSX = (xSS**2)**0.5-r_shift*CalX
textwin.EditorWindowAddText("\nDifference in X after rotate:"+DiffSX+" at "+theta+"degs")
}
textwin.EditorWindowAddText( "\n"+"Shifts in positions (3+2) and images (2): "+xSS+" "+ySS+" "+zSS+", "+alphaSS+" "+betaSS+", "+xImSh+" "+yImSh)
number correctX = xImSh-xSS/CalX
number correctY = yImSh-ySS/CalY
textwin.EditorWindowAddText( "\n"+"tilts in positions (2) and images - correction (2): "+alphaSS+" "+betaSS+", "+correctX+" "+correctY)
number correctA = correctY-alphaSS*(-40)
number correctB = correctX-betaSS*(-0)
textwin.EditorWindowAddText( "\n"+"images - double correction (2): "+correctB+" "+correctA)

if(abs(alphaSS)<0.5 && abs(betaSS)<0.5)
{
setpixel(dataarray,counter,0,xSS)
setpixel(dataarray,counter,1,ySS)
setpixel(dataarray,counter,2,xImSh)
setpixel(dataarray,counter,3,yImSh)

number thetaIm = atan(yImSh/xImSh)*(180/pi()) 
number thetaS  = atan(ySS/xSS)*(180/pi())
number rotation = thetaIm-thetaS
if (rotation<0)
{
rotation = 180+rotation
}
setpixel(dataarray,counter,4,rotation)
counter++
//result("\n"+rotation)
}
} // inner loop of images
} // outer loop

showimage(dataarray)
textwin.EditorWindowAddText( "\n"+"looping finsihed")
if(abs(theta)>5)// Try rotate and go again
{
image PosVals :=binaryimage("",spaces,1)
PosVals = tert(dataarray[4,0,5,spaces]>0, 1, 0)
number meanR=mean(dataarray[4,0,5,sum(PosVals)]) //dataarray[top,left,bottom,right] we want the final row

result("\n"+"Consider rotating your images by: "+meanR+" using "+sum(PosVals))
}
beep()