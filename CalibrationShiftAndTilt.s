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

void GetStagePos(image source, image new)
{
// get all metadata
taggroup sourceMeta = imagegettaggroup(source)
taggroup newMeta = imagegettaggroup(new)
// copy metadata
taggroupcopytagsfrom(newMeta,sourceMeta)
}

void ImageVsStageShifts(image dataarray)
{
// find images to work with //
imagedocument imagedocA, imagedocB //blank window lables
number nodocs=countimagedocuments() // count all image documents, including hidden ones

// Create an image to act as an array and save numbers
number spaces = 2*nodocs //spaces needed really is the triangle number of nodocs but I don't know how to code that in DMscript

number counter = 0
// Create all variables for calculations //
number xImSh, yImSh, maxvalue
number alphaSS, betaSS, xSS, ySS, zSS
number alphaA, alphaB, betaA, betaB
number i=0,j 

// Loop to compare one image with all others, then the next image with all etc 
// hopefully no redundent calculations 
for(i=0; i<nodocs-1; i++){
for(j=i+1; j<nodocs; j++){

// get windows by number
imagedocA=getimagedocument(i)
imagedocB=getimagedocument(j)
// get images from those windows (image documents) 
image imageA:=imagedocA.imagedocumentgetimage(0)
image imageB:=imagedocB.imagedocumentgetimage(0)

CrossCorr(imageA,imageB, xImSh, yImSh, maxvalue) // Cross Correlation of images for Image shift

StageShifts(imageA, imageB, alphaSS, betaSS, xSS, ySS, zSS, alphaA, alphaB, betaA, betaB) // Stage shifts between the two images

if(abs(alphaSS)<0.5 && abs(betaSS)<0.5)
{
//result("\n"+"Shift only detected, saving data . . .")
//save data
setpixel(dataarray,counter,0,xSS)
setpixel(dataarray,counter,1,ySS)
setpixel(dataarray,counter,2,xImSh)
setpixel(dataarray,counter,3,yImSh)
//calculate axis orientation
number thetaIm = atan(yImSh/xImSh)*(180/pi()) 
number thetaS  = atan(ySS/xSS)*(180/pi())
number rotation = thetaIm-thetaS
if (rotation<0)
{
rotation = 180+rotation
}
//save relative rotation
setpixel(dataarray,counter,4,rotation)
counter++
}
else
{
//save data
setpixel(dataarray,counter,0,alphaSS)
setpixel(dataarray,counter,1,betaSS)
setpixel(dataarray,counter,2,xImSh)
setpixel(dataarray,counter,3,yImSh)
//calculate axis orientation
number thetaIm = atan(yImSh/xImSh)*(180/pi()) 
number thetaS  = atan(betaSS/alphaSS)*(180/pi())
number rotation = thetaIm-thetaS
if (rotation<0)
{
rotation = 180+rotation
}
//save relative rotation
setpixel(dataarray,counter,4,rotation)
counter++

}

} // inner loop of images
} // outer loop
}

//*************************************************************************//
//*************************************************************************//

//////////////////
// main program //
//////////////////

// Starting values
//number StartX = emgetstagex()
//number StartY = emgetstagey()
number row, col
//number camID=CameraGetActiveCameraID()

//## stage move and image collect ##//
for (row=-1;row<2;row++)
{
	//emsetstagey(StartY+row)
	for (col=-1;col<2;col++)
	{
	//emsetstagex(StartX+col)
	//image img := CameraAcquire(camID)
	image img =realimage("",4, 512, 512) //dummy images to test when not connected to a microscope
	showimage(img)
	setname(img, "Cal Aq:"+row+" "+col)
	//delay(300) //delays are in 60th of a second
	}
}
result("\n"+"Finished shift image collection")

//## calculate rotation ##// 

number spaces = 36 //36 is the triangle number of the amount of images (9) as every image is to be paired. 5 and 10 during set up
number nodocs=countimagedocuments()
if (nodocs!=9) {
okdialog("The wrong number of images are open. Please close all and start script again. \n This will now fail.")
}
image dataarray :=realimage("",4,spaces,5)
ImageVsStageShifts(dataarray)
//showimage(dataarray)
number meanR=mean(dataarray[4,0,5,spaces]) //dataarray[top,left,bottom,right] we want the final row
//Assume rotation required
result("\n"+"Consider rotating your images by: "+meanR+" using "+spaces)


//## apply rotation to images ##//
imagedocument imagedoc
number i=0
for(i=0; i<nodocs; i++){
// get windows by number
imagedoc=getimagedocument(i)

// get images from those windows (image documents) 
image front:=imagedoc.imagedocumentgetimage(0)
string title=imagedoc.imagedocumentgetname()

number rotangle=-meanR/(180/pi())
image rotimg=rotate(front,rotangle)

// Display the rotated image
showimage(rotimg)
setname(rotimg, "R&C"+title) //Shortened title to help reading when tiled windows

// Add stage positions from orginal to the new image
GetStagePos(front, rotimg)
imagedocumentclose(imagedoc,0) //close orginal 
} // close loop through orginial images


//## find stage to image calibration from rotated images ##//
image dataarrayR :=realimage("",4,spaces,5)
ImageVsStageShifts(dataarrayR)
showimage(dataarrayR)
image BI = binaryimage("",spaces,1)
BI = tert(dataarrayR[0,0,1,spaces]>0.5 || dataarrayR[0,0,1,spaces]<-0.5,1,0)
image simple = BI*dataarrayR[0,0,1,spaces] //ignore stage shifts that should be 0
number CalX = sum(simple/(0.0001+dataarrayR[2,0,3,spaces]))/sum(BI)
BI = tert(dataarrayR[1,0,2,spaces]>0.5 || dataarrayR[1,0,2,spaces]<-0.5,1,0)
simple = BI*dataarrayR[1,0,2,spaces]
number CalY = sum(simple/(0.0001+dataarrayR[3,0,4,spaces]))/sum(BI)
result("\n"+sum(BI)+"vs"+spaces)
result("\n"+"Stage Shift Calibration complete: x"+CalX+" y"+CalY)


// Clear workspace // 
nodocs=countimagedocuments()
for(i=nodocs-1; i>-1; i--){
imagedoc=getimagedocument(i)
imagedocumentclose(imagedoc,0) //close all images
}

//## use stage to image calibration to allow for tilt to image calibration 

// Starting values
//number StartA = emgetstagealpha()
//number StartB = emgetstagebeta()
//number row, col
//number camID=CameraGetActiveCameraID()

//## stage tilt and image collect ##//
for (row=-1;row<2;row++)
{
	//emsetstagebeta(StartB+row)
	for (col=-1;col<2;col++)
	{
	//emsetstagealpha(StartA+col)
	//image img := CameraAcquire(camID)
	//image img =realimage("",4, 512, 512) //dummy images to test when not connected to a microscope
	showimage(img)
	setname(img, "Cal Aq:"+row+" "+col)
	//delay(300) //delays are in 60th of a second
	}
}
result("\n"+"Finished tilt image collection")

// remove any shift due to stage movement 
// NB as you have just collected these images the satge shifts should be 0 but just incase 

i=4 //assuming collected as above this should be the 5th image where tilt is 0 0
imagedocA=getimagedocument(i) //main image to align to
image imageA:=imagedocA.imagedocumentgetimage(0)
for(j=i+1; j<(2*nodocs)-1; j++){
// get window by number
imagedocB=getimagedocument(j)

// get images from that window (image documents) 
image imageB:=imagedocB.imagedocumentgetimage(0)
string title=imagedocB.imagedocumentgetname()

StageShifts(imageA, imageB, alphaSS, betaSS, xSS, ySS, zSS, alphaA, alphaB, betaA, betaB) // Stage shifts between the two images

number ImgCorrectionX = xSS/CalX 
number ImgCorrectionY = ySS/CalY 
image shiftimg:=imageclone(imageB)
shiftimg=warp(imageB, icol+ImgCorrectionY, irow+ImgCorrectionX)

showimage(shiftimg)
setname(shiftimg, "S"+title) //S for shifted
j++
imagedocumentclose(imagedocB,0) //close orginal
} // loop of images comparing to the first

//now any image shifts are a result of the tilting

image dataarrayT :=realimage("",4,spaces,5)
ImageVsStageShifts(dataarrayT)
showimage(dataarrayT)
BI = binaryimage("",spaces,1)
BI = tert(dataarrayT[0,0,1,spaces]>0.5 || dataarrayT[0,0,1,spaces]<-0.5,1,0)
simple = BI*dataarrayT[0,0,1,spaces] //ignore stage shifts that should be 0
number CalA = sum(simple/(0.0001+dataarrayT[3,0,4,spaces]))/sum(BI) //alpha shift causing y
BI = tert(dataarrayT[1,0,2,spaces]>0.5 || dataarrayT[1,0,2,spaces]<-0.5,1,0)
simple = BI*dataarrayT[1,0,2,spaces]
number CalB = sum(simple/(0.0001+dataarrayT[2,0,3,spaces]))/sum(BI) //beta shift causing x
result("\n"+sum(BI)+"vs"+spaces)
result("\n"+"Stage Tilt Calibration complete: x"+CalA+" y"+CalB)

//## give user the tilt to stage calibration
// assuming that alpha tilt only changes x and beta tilt only changes y
// to get a stage shift to correct a tilt i.e. Imx and Imy =0

number StageCorrectionX = -(CalY/CalA)
number StageCorrectionY = -(CalX/CalB)

result("\n"+"Tilt to stage correction is: "+StageCorrectionX+"x "+StageCorrectionY+"y")
