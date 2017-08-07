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
Dialog.create("Setting");
title = "Enter Basic Information";
width = 512; height = 512;
    Dialog.addNumber("Interval(s)", 1);
    Dialog.addMessage("Please choose the actual time frame");
    Dialog.addChoice("Time Frame:", newArray("Channel", "Slice", "Frame"));
    Dialog.addNumber("Frame Windows:", 90);
    Dialog.show();
		interval = Dialog.getNumber();
		type = Dialog.getChoice();
		FW = Dialog.getNumber();
tf = 1;
if (type == "slice") {
	tf = s;
}
else if (type == "channel") {
	tf = c;
}
else if (type == "frame") {
	tf = f;
}

while (tf <= 1) {
	wt = "Warning";
	msg = "Please choose the actual time frame.";
	waitForUser(wt, msg);
	Dialog.create("Setting");
	title = "Enter Basic Information";
	width = 512; height = 512;
	    Dialog.addNumber("Interval(s)", 1);
	    Dialog.addMessage("Please choose the actual time frame");
	    Dialog.addChoice("Time Frame:", newArray("Channel", "Slice", "Frame"));
	    Dialog.addNumber("Frame Windows:", 90);
	    Dialog.show();
			interval = Dialog.getNumber();
			type = Dialog.getChoice();
			FW = Dialog.getNumber();
	tf = 1;
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

Dialog.create("Setting");
title = "Enter Basic Parameter";
width=512; height=512;
	Dialog.addSlider("Start Frame:", 1, tf - FW, 1);
	Dialog.addChoice("How to save the results:", newArray("same direction as the image", "choose the direction manually")); 
  	Dialog.addMessage("Please choose the measurement");
  	Dialog.addCheckbox("Mean", true);
  	Dialog.addCheckbox("Density", false);
  	Dialog.addCheckbox("Grographic Information", true);
  	Dialog.show();
  		SF = Dialog.getNumber(); //start frame
		direction = Dialog.getChoice();
		MeanCheck = Dialog.getCheckbox();
		RawIntDent = Dialog.getCheckbox();
		GeoCheck = Dialog.getCheckbox();
while (MeanCheck == 0 && RawIntDent == 0) {
	wt = "Warning";
	msg = "Please make sure at leaset choose one measurement.";
	waitForUser(wt, msg);
	Dialog.create("Setting");
	title = "Enter Basic Parameter";
	width=512; height=512;
		Dialog.addSlider("Start Frame:", 1, tf - FW, 1);
		Dialog.addChoice("How to save the results:", newArray("same direction as the image", "choose the direction manually")); 
	  	Dialog.addMessage("Please choose the measurement");
	  	Dialog.addCheckbox("Mean", true);
	  	Dialog.addCheckbox("Density", false);
	  	Dialog.addCheckbox("Grographic Information", true);
	  	Dialog.show();
	  		SF = Dialog.getNumber(); //strat frame
			direction = Dialog.getChoice();
			MeanCheck = Dialog.getCheckbox();
			RawIntDent = Dialog.getCheckbox();
			GeoCheck = Dialog.getCheckbox();
}
EF = SF + FW; //End frame
  //////
 //time lapse measurement of fluoresence intensity.
//////
run("Clear Results");
channel = "Channel"; slice = "Slice"; frame = "Frame";
for (iRoi = 0; iRoi < nRoi; iRoi++) {
	roiManager("select", iRoi);
	for (iS = SF; iS < EF; iS++) {
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
	 head = ""; head = head + "Time(s)";
	for (colhead = 0; colhead < nRoi; colhead++) {
		head = head + "," + "Mean_of_cell" + colhead + "," + "RawIntDent_of_cell" + colhead;
	}
	print(head);
	for (row = 0; row < FW; row++) {
		line = "";
		line = line + row * interval;
		for (cola = 0; cola < nRoi; cola++) {
			indexa = cola * FW + row;
			line = line + "," + getResult("Mean", indexa);
			line = line + "," + getResult("RawIntDen", indexa);
		}
	print(line);
	wait(s/10);
	}
}
else if (MeanCheck == true) {
	 head = ""; head = head + "Time(s)";
	for (colhead = 0; colhead < nRoi; colhead++) {
		head = head + "," + "Mean_of_cell" + colhead;
	}
	print(head);
	for (row = 0; row < FW; row++) {
		line = "";
		line = line + row * interval;
		for (cola = 0; cola < nRoi; cola++) {
			indexa = cola * FW + row;
			line = line + "," + getResult("Mean", indexa);
		}
	print(line);
	wait(s/1000);
	}
}
else if (RawIntDent == true) {
	 head = ""; head = head + "Time(s)";
	for (colhead = 0; colhead < nRoi; colhead++) {
		head = head + "," + "RawIntDent_of_cell" + colhead;
	}
	print(head);
	for (row = 0; row < FW; row++) {
		line = "";
		line = line + row * interval;
		for (cola = 0; cola < nRoi; cola++) {
			indexa = cola * FW + row;
			line = line + "," + getResult("RawIntDen", indexa);
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
	saveAs("Text", dirImage +name + "00" + ".csv"); 
}
else if (direction == dirb) {
	dir = getDirectory("Choose a Directory"); 
	saveAs("Text", dir +name + "00" + ".csv"); 
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
		saveAs("Text", dirImage + name + "01.Shap" + ".csv"); 
	}
	else if (direction == dirb) {
		dir = getDirectory("Choose a Directory"); 
		saveAs("Text", dir + name + "01.Shap" + ".csv"); 
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
		saveAs("Text", dirImage + name + "02.Location" + ".csv"); 
	}
	else if (direction == dirb) {
		dir = getDirectory("Choose a Directory"); 
		saveAs("Text", dir + name + "02.Location" + ".csv"); 
	}
	////////////end/////////////
	run("Clear Results");
	selectWindow("Results");
	run("Close");
	exit();
	}
	else 
	exit();