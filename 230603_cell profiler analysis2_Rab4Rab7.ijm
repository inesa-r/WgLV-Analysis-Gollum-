//make sure you have the stacks you need first!
// you will have used
//cell profiler splitting into z.ijm before GOLLUM
//cell profiler assamblying stacks.ijm
// - for the raw data and measuring mean intensities
// now even more automated!

ID = "Rab4Rab7_6"
mask1 = "WgRingsInBoth"
mask2 = "WgRingsRab4Only"
mask3 = "WgRingsRab7Only"
mask4 = "WgRingsNeither"
raw = "RawStack"
pro = "ProcessedStack"

#@ File (label = "Input directory", style = "directory") input
#@ String (label = "File suffix", value = ".tif") suffix
#@ File (label = "Output directory", style = "directory") output

waitForUser("Have you checked all ok?");
CellProfiler();

// *******  CHECK THIS IS OK BEFORE START ******** //
function CellProfiler() {
	processFolder(input);
	selectWindow(ID + "_" + raw);
	//waitForUser("ok?");
	run("Split Channels");
	selectWindow(ID + "_" + pro);
	//waitForUser("ok?");
	run("Split Channels");
	MaskAnalysis(mask1);
	MaskAnalysis(mask2);
	MaskAnalysis(mask3);
	MaskAnalysis(mask4);
	run("Close All");
}

function MaskAnalysis(mask){
	ConvertToMask(ID + "_" + mask);
	//waitForUser("ok?");
	IntensityInROI(mask, "C1-");
	//waitForUser("ok?");
	IntensityInROI(mask, "C2-");
	//waitForUser("ok?");
	
	//specific for 3 channel or more images
	IntensityInROI(mask, "C3-");
	IntensityInROI(mask, "C4-");
	ProfileInROI(mask, "C2-", 40);
	
	clean("ROI Manager");
}


// *******  SMALLER USER DEFINED FUNCTIONS ******** //
              
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
	saveAs("Results", output+ ID + "_"+channel+ConvertedMask+"_RawMeanIntensity.csv");
	run("Close");
}

function ProfileInROI(ConvertedMask, channel, max) { 
	LastROI = roiManager("count");
	if (max < LastROI) {
		step = LastROI / max;
		rstep = round(step);
	} else {
		rstep = 0;
	}
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
			if(indexOf(list[i], mask3) >=0) {
				open(list[i]);
				rename(ID + "_" + mask3);
			} else {
				if(indexOf(list[i], mask1) >=0) {
					open(list[i]);
					rename(ID + "_" + mask1);
				} else {
					if(indexOf(list[i], raw) >=0) {
						open(list[i]);
						rename(ID + "_" + raw);
					} else {
						if(indexOf(list[i], pro) >=0) {
							open(list[i]);
							rename(ID + "_" + pro);
						} else {
							if(indexOf(list[i], mask2) >=0) {
								open(list[i]);
								rename(ID + "_" + mask2);
							} else {
								if(indexOf(list[i], mask4) >=0) {
									open(list[i]);
									rename(ID + "_" + mask4);
								}
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




