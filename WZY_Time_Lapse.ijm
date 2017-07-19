   //////
  //get basic information of this image 
 //tf: time frame; s: slices; c: channels; f: frames;
//////
run("Properties...", "channels=1 slices=100 frames=1 unit=pixel pixel_width=1 pixel_height=1 voxel_depth=1.0000000");
name = getInfo("image.filename"); dirImage = getInfo("image.directory");
getDimensions(width, height, channels, slices, frames); nRoi = roiManager("count");
c = channels; s = slices; f = frames;
   //////
  ///set measurements.
 //////
run("Set Measurements...", "area mean standard min center integrated median redirect=None decimal=6");
roiManager("show all with labels");
   //////
  //pop up a dialog to set up.
 //and test those parameters that get from dialog.
//////
set= newArray(0, 0, 0, 0, 0);
set = myDialog(); 
tf = 1;
interval = set[0]; 
type = set[1]; 
direction = set[2]; 
MeanCheck = set[3]; 
RawIntDent = set[4];
GeoCheck = set[5];
if (type == "slice") {
	tf = s;
}
else if (type == "channel") {
	tf = c;
}
else if (type == "frame") {
	tf = f;
}
while ((MeanCheck == 0 && RawIntDent == 0) || tf <= 1) {
	wt = "Warning";
	msg = "Please make sure at leaset choose one measurement,\n and make sure this is a time lapse image.";
	waitForUser(wt, msg);
	Dialog.create("Setting");
	title = "Enter Basic Parameter";
  	width=512; height=512;
  	  Dialog.addNumber("Interval(s)", 1);
  	  Dialog.addMessage("Please choose the actual time frame");
  	  Dialog.addChoice("Time Frame:", newArray("Channel", "Slice", "Frame"));
  	  Dialog.addChoice("How to save the results:", newArray("same direction as the image", "choose the direction manually")); 
  	  Dialog.addMessage("Please choose the measurement");
  	  Dialog.addCheckbox("Mean", true);
  	  Dialog.addCheckbox("Density", true);
  	  Dialog.addCheckbox("Grographic Information", true);
  	  Dialog.show();
		interval = Dialog.getNumber();
		type = Dialog.getChoice();
		direction = Dialog.getChoice();
		MeanCheck = Dialog.getCheckbox();
		RawIntDent = Dialog.getCheckbox();
		GeoCheck = Dialog.getCheckbox();
	if (type == "slice") {
		tf = s;
	}
	else if (type == "channel") {
		tf = c;
	}
	else if (type == "frame") {
		tf = f;
	}
}
  //////
 //time lapse measurement of fluoresence intensity.
//////
run("Clear Results");
channel = "Channel"; slice = "Slice"; frame = "Frame";
for (iRoi = 0; iRoi < nRoi; iRoi++) {
	roiManager("select", iRoi);
	for (iS = 1; iS < tf+1; iS++) {
			wait(s/100);
			setSlice(iS);
			run("Measure");
		}
}
  //////
 //rearrange the result to the Result Table
//////
print("\\Clear");
if (MeanCheck == true && RawIntDent == true) {
	 head = ""; head = head + "Time(s)" + ",";
	for (colhead = 0; colhead < nRoi; colhead++) {
		head = head + "Mean_of_cell" + colhead + "," + "RawIntDent_of_cell" + colhead + ",";
	}
	print(head);
	for (row = 0; row < tf; row++) {
		line = "";
		line = line + row * interval + ",";
		for (cola = 0; cola < nRoi; cola++) {
			indexa = cola * 100 + row;
			line = line + getResult("Mean", indexa) + ",";
			line = line + getResult("RawIntDen", indexa) + ",";
		}
	print(line);
	wait(s/10);
	}
}
else if (MeanCheck == true) {
	 head = ""; head = head + "Time(s)" + ",";
	for (colhead = 0; colhead < nRoi; colhead++) {
		head = head + "Mean_of_cell" + colhead + ",";
	}
	print(head);
	for (row = 0; row < tf; row++) {
		line = "";
		line = line + row * interval + ",";
		for (cola = 0; cola < nRoi; cola++) {
			indexa = cola * 100 + row;
			line = line + getResult("Mean", indexa) + ",";
		}
	print(line);
	wait(s/1000);
	}
}
else if (RawIntDent == true) {
	 head = ""; head = head + "Time(s)" + ",";
	for (colhead = 0; colhead < nRoi; colhead++) {
		head = head + "RawIntDent_of_cell" + colhead + ",";
	}
	print(head);
	for (row = 0; row < tf; row++) {
		line = "";
		line = line + row * interval + ",";
		for (cola = 0; cola < nRoi; cola++) {
			indexa = cola * 100 + row;
			line = line + getResult("RawIntDen", indexa) + ",";
		}
	print(line);
	wait(s/1000);
	}
}
  //////
 //save the results as a .csv format file.
//////
	dira = "same direction as the image";
	dirb = "choose the direction manually";
selectWindow("Log");
if (direction == dira) {
	saveAs("Text", dirImage +name + ".csv"); 
}
else if (direction == dirb) {
	dir = getDirectory("Choose a Directory"); 
	saveAs("Text", dir +name + ".csv"); 
}
print("\\Clear");
run("Clear Results");
selectWindow("Log");
run("Close");
selectWindow("Results");
run("Close");

////////////////////////////////////// Geographic Information ///////////////////////////////////////////
if (GeoCheck == true){
	x = newArray();
	y = newArray();
	id = newArray();
	for (iRoi = 0; iRoi < nRoi; iRoi++) {
		roiManager("select", iRoi);
		Roi.getCoordinates(xpoints, ypoints);
		x = Array.concat(x, xpoints);
		y = Array.concat(y, ypoints);
		le = lengthOf(xpoints);
		for(ln = 0; ln < le; ln++){
			id = Array.concat(id, iRoi);
			}
	}
	Array.show(id, x, y);
	wait(100);
	if (direction == dira) {
		saveAs("Text", dirImage + name + "Geo" + ".csv"); 
	}
	else if (direction == dirb) {
		dir = getDirectory("Choose a Directory"); 
		saveAs("Text", dir + name + "Geo" + ".csv"); 
	}	
	////////////////////////////// location /////////////////////////////
	x2 = newArray();
	y2 = newArray();
	id2 = newArray();
	for (iRoi = 0; iRoi < nRoi; iRoi++) {
		roiManager("select", iRoi);
		run("Clear Results");
		wait(50);
		run("Measure");
		wait(50);
		x2 = Array.concat(x2, getResult("XM"));
		y2 = Array.concat(y2, getResult("YM"));
		id2 = Array.concat(id2, iRoi);
	}
	Array.show(id2, x2, y2);
	wait(100);
	if (direction == dira) {
		saveAs("Text", dirImage + name + "Loc" + ".csv"); 
	}
	else if (direction == dirb) {
		dir = getDirectory("Choose a Directory"); 
		saveAs("Text", dir + name + "Loc" + ".csv"); 
	}
	////////////end/////////////
	run("Clear Results");
	selectWindow("Results");
	run("Close");
	exit();
	}
	else 
	exit();
	
////////////////////////////////////// Functions ///////////////////////////////////////////
  //////
 //define a dialog function.
//////
function myDialog() {
	Dialog.create("Setting");
	title = "Enter Basic Parameter";
  	width=512; height=512;
  	  Dialog.addNumber("Interval(s)", 1);
  	  Dialog.addMessage("Please choose the actual time frame");
  	  Dialog.addChoice("Time Frame:", newArray("Channel", "Slice", "Frame"));
  	  Dialog.addChoice("How to save the results:", newArray("same direction as the image", "choose the direction manually")); 
  	  Dialog.addMessage("Please choose the measurement");
  	  Dialog.addCheckbox("Mean", true);
  	  Dialog.addCheckbox("Density", true);
  	  Dialog.addCheckbox("Grographic Information", true);
  	  Dialog.show();
		interval = Dialog.getNumber();
		type = Dialog.getChoice();
		direction = Dialog.getChoice();
		MeanCheck = Dialog.getCheckbox();
		RawIntDent = Dialog.getCheckbox();
		GeoCheck = Dialog.getCheckbox();
		cout = newArray(interval, type, direction, MeanCheck, RawIntDent, GeoCheck)
	return cout;
}
