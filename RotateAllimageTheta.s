///////////////
// functions //
///////////////

void GetStagePos(image source, image new)
{
// get all metadata
taggroup sourceMeta = imagegettaggroup(source)
taggroup newMeta = imagegettaggroup(new)
// copy metadata
taggroupcopytagsfrom(newMeta,sourceMeta)
}

//////////////////
// main program //
//////////////////

number rotation = -26.55  //user in put here

number nodocs=countimagedocuments() // count all image documents, including hidden ones
imagedocument imagedoc
number i=0
for(i=0; i<(2*nodocs)-1; i++){
// get windows by number
imagedoc=getimagedocument(i)

// get images from those windows (image documents) 
image front:=imagedoc.imagedocumentgetimage(0)
string title=imagedoc.imagedocumentgetname()

number rotangle=rotation/(180/pi()) // angle needs to be in rads
image rotimg=rotate(front,rotangle)

// Display the rotated image and add an ROI based on the calculated vertices
showimage(rotimg)
setname(rotimg, "R&C"+title) //Shortened title to help reading when tiled windows

// Add stage positions from orginal to the new image
GetStagePos(front, rotimg)
i++ // New image documents go on top so we have an extra increment

} // close loop through orginial images