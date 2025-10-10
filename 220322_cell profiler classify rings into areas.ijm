//this is to classify the rings from the GOLLUM output into areas
//away from the DV boundary (roughly 2 cells each)
//make sure you have the stacks you need first!
// you will have used
//211130_cell profiler preparing the raw before GOLLUM
//211126_cell profiler assamblying stacks.ijm

partID = "shibire18away_"
wgchannel = "C2-"
mask2 = "RmvdMask"
mask1 = "FiltMask"
raw = "RawStack"

#@ File (label = "Input directory", style = "directory") input
#@ String (label = "File suffix", value = ".tif") suffix
#@ File (label = "Output directory", style = "directory") output

waitForUser("wg channel ok?");

for (p = 1; p < 7; p++) {
ID = partID + p ;
processFolder(input);


selectWindow(ID + "_" + raw);
run("Split Channels");
selectWindow(wgchannel + ID + "_" + raw);
run("Gaussian Blur...", "sigma=1 scaled stack");
run("Convert to Mask", "method=Yen background=Dark calculate black");
run("Options...", "iterations=40 count=1 pad do=Erode stack");
run("Options...", "iterations=40 count=1 do=Dilate stack");
rename(wgchannel + ID + "_" + "area" + 0);
//waitForUser("ok?");
//this gives you the first slice

for (i = 0; i < 5; i++) {
	x = i + 1;
	selectWindow(wgchannel + ID + "_" + "area" + i);
	run("Duplicate...", "title=duplicate");
	rename(wgchannel + ID + "_" + "area" +x);
	run("Options...", "iterations=40 count=1 pad do=Erode stack");
	run("Options...", "iterations=40 count=1 pad do=Erode stack");
	run("Options...", "iterations=40 count=1 pad do=Erode stack");
}
//waitForUser("ok?");
//this should give you for extra files named area1 to area4, which are the zones away from the DV boundary

newmasks(mask1);
newmasks(mask2);

run("Set Measurements...", "area stack limit redirect=None decimal=3");

for (a = 0; a < 6; a++) {
selectWindow(wgchannel + ID + "_" + "area" +a);
setAutoThreshold("Default dark");
//waitForUser("ok?")
	for (i = 1; i <= nSlices; i++) { 
    setSlice(i);
	run("Measure");
	}    
selectWindow("Results");
saveAs("Results", output + ID + "_AreaResults_" + a + ".csv");
close("Results");
run("Close");
}

close("*");

}

// *******  USER DEFINED FUNCTIONS ******** //

function newmasks(mask) {
	imageCalculator("Min create stack", ID + "_" + mask, wgchannel + ID + "_" + "area" +0);
	saveAs("Tiff", output+File.separator+ID+mask + "Area0");

	for (i = 0; i < 5; i++) {
		x = i +1;
		imageCalculator("Subtract create stack", ID + "_" + mask, wgchannel + ID + "_" + "area" +i);
		rename(ID + "_" + mask +"Area"+x);
		imageCalculator("Min create stack", ID + "_" + mask +"Area"+x, wgchannel + ID + "_" + "area" +x);
		saveAs("Tiff", output+File.separator+ID+mask + "Area" + x);
	}

	imageCalculator("Subtract create stack", ID + "_" + mask, wgchannel + ID + "_" + "area" +4);
	saveAs("Tiff", output+File.separator+ID+mask + "Area5");
}

function processFolder(input) {
// function to scan folders/subfolders/files to find files with correct suffix
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(indexOf(list[i], ID) >=0){
			open(list[i]);
			if(indexOf(list[i], mask2) >=0) {
				rename(ID + "_" + mask2);
			} else {
				if(indexOf(list[i], mask1) >=0) {
				rename(ID + "_" + mask1);
				} else {
					if(indexOf(list[i], raw) >=0) {
						rename(ID + "_" + raw);
					} else {
					print("other");
					}
				}		
			}
		}
	}
}