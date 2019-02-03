   //////
  //get basic information of this image 
 //tf: time frame; s: slices; c: channels; f: frames;
//////
run("Properties...", "unit=pixel pixel_width=1 pixel_height=1 voxel_depth=1.0000000");
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
    Dialog.addNumber("Frame Window size:", 90);
    Dialog.addCheckbox("Ratiometric?", true);
    Dialog.show();
		interval = Dialog.getNumber();
		FW = Dialog.getNumber();
		Ratiometric = Dialog.getCheckbox();
tf = f;

Dialog.create("Setting");
title = "Enter Basic Parameter";
width=512; height=512;
	Dialog.addSlider("Start Frame:", 1, tf - FW + 1, 1);
	Dialog.addChoice("How to save the results:", newArray("same directory as the image", "choose the directory manually")); 
	Dialog.addNumber("Channel number in numberator", 1);
	Dialog.addNumber("Channel number in denominator", 2);
  	Dialog.addMessage("Please choose the measurement");
  	Dialog.addCheckbox("Mean", true);
  	Dialog.addCheckbox("Density", false);
  	Dialog.addCheckbox("Grographic Information", true);
  	Dialog.show();
  		SF = Dialog.getNumber(); //start frame
		directory = Dialog.getChoice();
		numberator = Dialog.getNumber();
		denominator = Dialog.getNumber();
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
		Dialog.addChoice("How to save the results:", newArray("same directory as the image", "choose the directory manually")); 
	  	Dialog.addMessage("Please choose the measurement");
	  	Dialog.addCheckbox("Mean", true);
	  	Dialog.addCheckbox("Density", false);
	  	Dialog.addCheckbox("Grographic Information", true);
	  	Dialog.show();
	  		SF = Dialog.getNumber(); //strat frame
			directory = Dialog.getChoice();
			MeanCheck = Dialog.getCheckbox();
			RawIntDent = Dialog.getCheckbox();
			GeoCheck = Dialog.getCheckbox();
}
EF = SF + FW; //EF:End frame; FW:Frame Window
  //////
 //time lapse measurement of fluoresence intensity.
//////
run("Clear Results");
channel = "Channel"; slice = "Slice"; frame = "Frame";
if (Ratiometric == true) {
	for (iRoi = 0; iRoi < nRoi; iRoi++) {
		roiManager("select", iRoi);
		for (iS = SF; iS < EF; iS++) {
			Stack.setFrame(iS);
			Stack.setChannel(numberator);
			wait(0);
			run("Measure");
			wait(0);
			Stack.setChannel(denominator);
			wait(0);
			run("Measure");
			wait(0);
		}
	}
	  //////
	 //rearrange the results to the Result Table
	//////
	print("\\Clear");
	if (MeanCheck == true && RawIntDent == true) {
		head = ""; head = head + "Time(s)";
		for (colhead = 0; colhead <nRoi; colhead++) {
			head = head + "," + "Mean_of_cell" + colhead + "," + "RawIntDent_of_cell" + colhead;
		}
		print(head);
		for (row = 0; row < FW; row++) {
			line = "";
			line = line + row * interval;
			for (cola = 0; cola < nRoi; cola++) {
				indexa = (cola * FW * 2) + (row * 2); //index for taking the numberator
				indexb = (cola * FW * 2) + (row * 2) + 1; //index for taking the denominator
				result1 = getResult("Mean", indexa) / getResult("Mean", indexb); //Mean result
				result2 = getResult("RawIntDen", indexa) / getResult("RawIntDen", indexb); //Raw Intensity Density result
				line = line + "," + result1;
				line = line + "," + result2;
			}
			print(line);
			wait(0);
		}
	} else if (MeanCheck == true) {
				head = ""; head = head + "Time(s)";
		for (colhead = 0; colhead <nRoi; colhead++) {
			head = head + "," + "Mean_of_cell" + colhead;
		}
		print(head);
		for (row = 0; row < FW; row++) {
			line = "";
			line = line + row * interval;
			for (cola = 0; cola < nRoi; cola++) {
				indexa = (cola * FW * 2) + (row * 2); //index for taking the numberator
				indexb = (cola * FW * 2) + (row * 2) + 1; //index for taking the denominator
				result1 = getResult("Mean", indexa) / getResult("Mean", indexb); //Mean result
				line = line + "," + result1;
			}
			print(line);
			wait(0);
		}
	} else if (RawIntDent == true) {
				head = ""; head = head + "Time(s)";
		for (colhead = 0; colhead <nRoi; colhead++) {
			head = head + "," + "RawIntDent_of_cell" + colhead;
		}
		print(head);
		for (row = 0; row < FW; row++) {
			line = "";
			line = line + row * interval;
			for (cola = 0; cola < nRoi; cola++) {
				indexa = (cola * FW * 2) + (row * 2); //index for taking the numberator
				indexb = (cola * FW * 2) + (row * 2) + 1; //index for taking the denominator
				result2 = getResult("RawIntDen", indexa) / getResult("RawIntDen", indexb); //Raw Intensity Density result
				line = line + "," + result2;
			}
			print(line);
			wait(0);
		}
	}
	  //////
	 //save the results as a .csv format file.
	//////
	dira = "same directory as the image";   //directory option a
	dirb = "choose the directory manually"; //directory option b
	selectWindow("Log");
	if (directory == dira) {
		saveAs("Text", dirImage + name + "00" + ".csv");
	} else if ( directory == dirb) {
		dir = getDirectory("Choose a Directory");
		saveAs("Text", dir + name + "00" + ".csv");
	}
	print("\\Clear");
	run("Clear Results");
	selectWindow("Log");
	run("Close");
	selectWindow("Results");
	run("Close");
	////// Non-Ratiometeric below //////
} else if (Ratiometric == false) {
		for (iRoi = 0; iRoi < nRoi; iRoi++) {
		roiManager("select", iRoi);
		for (iS = SF; iS < EF; iS++) { // iS:inside Selection
			wait(0);
			Stack.setFrame(iS);
			wait(0);
			run("Measure");
			wait(0);
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
			wait(0);
		}
	} else if (MeanCheck == true) {
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
			wait(0);
		}
	} else if (RawIntDent == true) {
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
			wait(0);
		}
	}
	  //////
	 //save the results as a .csv format file.
	//////
	dira = "same directory as the image";   //directory option a
	dirb = "choose the directory manually"; //directory option b
	selectWindow("Log");
	if (directory == dira) {
		saveAs("Text", dirImage + name + "00" + ".csv");
	} else if ( directory == dirb) {
		dir = getDirectory("Choose a Directory");
		saveAs("Text", dir + name + "00" + ".csv");
	}
	print("\\Clear");
	run("Clear Results");
	selectWindow("Log");
	run("Close");
	selectWindow("Results");
	run("Close");
}

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
	wait(0);
	if (directory == dira) {
		saveAs("Text", dirImage + name + "01.Shap" + ".csv"); 
	}
	else if (directory == dirb) {
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
		wait(0);
		run("Measure");
		wait(0);
		x2 = Array.concat(x2, getResult("XM"));
		y2 = Array.concat(y2, getResult("YM"));
		id2 = Array.concat(id2, iRoi);
	}
	Array.show(id2, x2, y2);
	wait(0);
	if (directory == dira) {
		saveAs("Text", dirImage + name + "02.Location" + ".csv"); 
	}
	else if (directory == dirb) {
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