//make sure you have the stacks you need first!
// you will have used
//211130_cell profiler splitting into z.ijm before GOLLUM
//211126_cell profiler assamblying stacks.ijm
// - for the raw data and measuring mean intensities

partID = "WT_GMAPss"

//mask2 = "RmvdMask649"
//mask1 = "FiltMask649"
mask2 = "RmvdMask"
mask1 = "FiltMask"
mask3 = "GMAPMask"

raw = "RawStack"
pro = "ProcessedStack"
#@ File (label = "Input directory", style = "directory") input
#@ String (label = "File suffix", value = ".tif") suffix
#@ File (label = "Output directory", style = "directory") output


for (p = 1; p < 7; p++) {
	//ID = partID + "het_" + p ;
	//CellProfiler();
	//if there is also a set of files with the name deriving from partID
	//you can run this if they are all using the same type of masks
	ID = partID + "_" + p ;
	CellProfiler();
	//ID = partID + "shift30_" + p ;
	//CellProfiler();
	//ID = partID + "shift15_" + p ;
	//CellProfiler();
}

function CellProfiler() {
	processFolder(input);
selectWindow(ID + "_" + raw);
//waitForUser("ok?");
run("Split Channels");
selectWindow(ID + "_" + pro);
//waitForUser("ok?");
run("Split Channels");


ConvertToMask(ID + "_" + mask1);
//waitForUser("ok?");
IntensityInROI(mask1, "C1-");
//waitForUser("ok?");
IntensityInROI(mask1, "C2-");
//waitForUser("ok?");
IntensityInROI(mask1, "C3-");
//waitForUser("ok?");
//ProfileInROI(mask1, "C1-", 40);
//waitForUser("ok?");
ProfileInROI(mask1, "C2-", 40);

clean("ROI Manager");

ConvertToMask(ID + "_" + mask2);
//waitForUser("ok?");
IntensityInROI(mask2, "C1-");
IntensityInROI(mask2, "C2-");
IntensityInROI(mask2, "C3-");
//ProfileInROI(mask2, "C1-", 40);
//waitForUser("ok?");
ProfileInROI(mask2, "C2-", 40);

clean("ROI Manager");


selectWindow(ID + "_" + mask3);
run("Set Scale...", "distance=0 unit=pixel");
ConvertToMask(ID + "_" + mask3);
//waitForUser("ok?");
IntensityInROI(mask3, "C1-");
IntensityInROI(mask3, "C2-");
IntensityInROI(mask3, "C3-");
//ProfileInROI(mask3, "C1-", 40);
//waitForUser("ok?");
//ProfileInROI(mask3, "C2-", 40);


//specific for 3 channel or more images


clean("ROI Manager");

run("Close All");

}

// *******  OTHER USER DEFINED FUNCTIONS ******** //
   
function clean(a){
	selectWindow(a);
	run("Close");
}
//Function to close a selected window

function ConvertToMask(MaskToConvert) { 
	selectWindow(MaskToConvert);
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=Default background=Default calculate");
	run("Analyze Particles...", "size=1-4000 add stack");
}
// selects a mask image/stack from cellprofiler, makes it into a proper mask, puts the objects as ROIs

function IntensityInROI(ConvertedMask, channel) { 
	run("Set Measurements...", "area mean stack limit redirect=None decimal=3");
	selectWindow(channel +ID + "_" + raw);
	roiManager("Measure");
	selectWindow("Results");
	saveAs("Results", output+ID + "_"+channel+ConvertedMask+"_RawMeanIntensity.csv");
	run("Close");
}

function ProfileInROI(ConvertedMask, channel, max) { 
	LastROI = roiManager("count");
	step = LastROI / max;
	rstep = round(step);
	print(rstep);
	selectWindow(channel +ID + "_" + pro);
	for (n = 0;n<LastROI;n++) {
		roiManager("Select", n);
		run("Radial Profile", "x y radius=15");
		waitForUser( "Pause","Press List Button");
		selectWindow("Plot Values");
		saveAs("Results", output+ID + "_"+channel+ConvertedMask+"PlotValues"+n+".xls");
		run("Close");   
		selectWindow("Radial Profile Plot");
		run("Close");
		wait(50);
		n = n + rstep;
		}
}
//makes ROI of the radius indicated (I calculated for the wing rings)
//because too many of them and you need to manually click, only do 1 radial profile every X ROIs
//once 20 radial profiles have been done (or whatever you set as max), move to the next thing.
 
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
						if(indexOf(list[i], pro) >=0) {
							rename(ID + "_" + pro);
						} else {
							if(indexOf(list[i], mask3) >=0) {
							rename(ID + "_" + mask3);
						} else {
							print("weird");
							close();
						}
						}
					}
				}
			}
		} else {
			print("other");
		}		
	}
}




