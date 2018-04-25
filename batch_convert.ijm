getDimensions(width, height, channels, slices, frames);
Dialog.create("Setting");
title = "Enter Basic Information";
width = 512; height = 512;
    Dialog.addString("order", "xyztc");
    Dialog.addString("channels", channels);
    Dialog.addString("slices", slices);
    Dialog.addString("frames", frames);
    Dialog.show();
		order = Dialog.getString();
		channels = Dialog.getString();
		slices = Dialog.getString();
		frames = Dialog.getString();
setting = "order="+ order + " channels="+ channels + " slices="+ slices +" frames="+ frames +" display=Composite"
run("Stack to Hyperstack...", setting);
Stack.setChannel(1) 
run("Green"); 

Stack.setChannel(2) 
run("Red"); 

Stack.setChannel(3) 
run("Grays"); 
run("Save");