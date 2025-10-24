// Ed Darnbrough 
// version:0, Oct 2025.

///////////////
// functions //
///////////////
void alphapress(object self, number increment)
{
number CalA=dlggetvalue(self.lookupelement("yfield"))
number xSS=0, ySS=0
number x = 0//emgetstagex()
number y = 0//emgetstagey()

result("\n you are here: x "+x+",y "+y)
number alpha = 0//emgetstagealpha()
number beta = 0//emgetstagebeta()
result("\t your tilt is: a"+alpha+" b "+beta)

//emsetstagealpha(alpha+increment)

//delay(300)

number newalpha = alpha+increment//emgetstagealpha()
result("\t new a: "+newalpha)
number difference = newalpha-alpha
result(" difference "+difference)
ySS = difference*CalA
//delay(300)
//emsetstagey(y+difference*CalA)

result("\n"+"Tilted beta:"+increment+" and shifted: x"+xSS+" y"+ySS)
Beep()
return
 }
 
void betapress(object self, number increment)
{
number CalB=dlggetvalue(self.lookupelement("xfield"))
number xSS=0, ySS=0
number x = 0//emgetstagex()
number y = 0//emgetstagey()

result("\n you are here: x "+x+",y "+y)
number alpha = 0//emgetstagealpha()
number beta = 0//emgetstagebeta()
result("\t your tilt is: a"+alpha+" b "+beta)

//emsetstagealpha(alpha+increment)

//delay(300)

number newbeta = beta+increment//emgetstagebeta()
result("\t new b: "+newbeta)
number difference = newbeta-beta
result(" difference "+difference)
xSS = difference*CalB
//delay(300)
//emsetstagex(x+difference*CalB)

result("\n"+"Tilted alpha:"+increment+" and shifted: x"+xSS+" y"+ySS)
Beep()
return
 }
 
/////////////////
// UI creation //
/////////////////
// the class createbuttondialog is of the type user interface frame, and responds to interaction the dialog
class CreateButtonDialog : uiframe

{

 //these are the response when the button is pressed

 void Abuttonresponse(object self)
{
number increment=dlggetvalue(self.lookupelement("incfield"))
alphapress(self, increment)
}

 void AMbuttonresponse(object self)
{
number increment=-dlggetvalue(self.lookupelement("incfield"))//negative here is the only change from above
alphapress(self,increment)
}

 void Bbuttonresponse(object self)
{
number increment=dlggetvalue(self.lookupelement("incfield"))
betapress(self, increment)
}

 void BMbuttonresponse(object self)
{
number increment=-dlggetvalue(self.lookupelement("incfield"))//negative here is the only change from above
betapress(self, increment)
}

// this function creates a taggroup containing the dialog elements:
// a box within which the buttons are present.
taggroup MakeDialog(object self)
{
TagGroup dialog_items;
TagGroup dialog = DLGCreateDialog("Example Dialog", dialog_items)

// Creates a box in the dialog which surrounds the buttons
taggroup box_items
taggroup box=dlgcreatebox(" Movement ", box_items)
box.dlgexternalpadding(5,5)
box.dlginternalpadding(25,25)

// Creates the buttons
TagGroup AlphaButton = DLGCreatePushButton("Alpha", "Abuttonresponse")
alphabutton.dlgexternalpadding(11,10)
TagGroup AlphaMButton = DLGCreatePushButton("-Alpha", "AMbuttonresponse")
alphambutton.dlgexternalpadding(10,10)
box_items.dlgaddelement(alphabutton)
box_items.dlgaddelement(alphambutton)
TagGroup BetaButton = DLGCreatePushButton("Beta", "Bbuttonresponse")
Betabutton.dlgexternalpadding(11,10)
TagGroup BetaMButton = DLGCreatePushButton("-Beta", "BMbuttonresponse")
Betambutton.dlgexternalpadding(10,10)
box_items.dlgaddelement(Betabutton)
box_items.dlgaddelement(Betambutton)
// Creates the increment value box
taggroup inclabel=dlgcreatelabel("Increment in degrees")
taggroup incfield=dlgcreaterealfield(1,10,3).dlgidentifier("incfield").dlgenabled(1)
taggroup incgroup=dlggroupitems(inclabel, incfield).dlgtablelayout(1,2,0)
box_items.dlgaddelement(incgroup)

dialog_items.dlgaddelement(box) //adds box to the dialog window

// Create a new box for the calibration values
taggroup calibrationbox_items
taggroup calibration=dlgcreatebox("  Calibrations \circ > \mu m  ", calibrationbox_items)
calibration.dlgexternalpadding(5,5)
calibration.dlginternalpadding(25,25)

// Creates the value boxes 
taggroup xlabel=dlgcreatelabel("Stage x")
taggroup xfield=dlgcreaterealfield(3.56,10,3).dlgidentifier("xfield").dlgenabled(1) //value taken from offline calibration
taggroup xgroup=dlggroupitems(xlabel, xfield).dlgtablelayout(1,2,0)
taggroup ylabel=dlgcreatelabel("Stage y")
taggroup yfield=dlgcreaterealfield(0.02,10,3).dlgidentifier("yfield").dlgenabled(1) //value taken from offline calibration
taggroup ygroup=dlggroupitems(ylabel, yfield).dlgtablelayout(1,2,0)
taggroup allcolumnsgroup=dlggroupitems(xgroup, ygroup).dlgtablelayout(3,1,0)

calibration.dlgaddelement(allcolumnsgroup) 

dialog_items.dlgaddelement(calibration) //adds calibration box to the dialog window



return dialog
}


// The constructor this calls the makedialog() function and displays it
createbuttondialog(object self)
{
// Construct the dialog
self.init( self.makeDialog() );
self.display("Tilt and shift")
result("\nConstructor called.")
}

// The destructor is called when the object (the dialog) is closed
~createbuttondialog(object self)
{
result("\nDestructor called - bye!")
}
}

// allocates the above function which puts it all together
alloc(createbuttondialog)
