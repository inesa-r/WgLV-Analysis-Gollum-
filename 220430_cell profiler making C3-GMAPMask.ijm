//you need the processed images in a separate folder!
//alternatively do it when only the processed files are in the
//stack folder
// now even more automated!

partID = "WT_GMAPss"
mask1 = "GMAPMask"
pro = "ProcessedStack"
wgchannel = "C2-"
c3channel = "C1-"
#@ File (label = "Input directory", style = "directory") input
#@ String (label = "File suffix", value = ".tif") suffix

output = "C:/Users/alvarei/Dropbox (The Francis Crick)/Ines Lab Data/microscope/analysis/dunn school sora ring analysis/GOLLUM/stacks/"

//waitForUser("Have you checked all ok?");

for (p = 1; p < 8; p++) {
	//ID = partID + "het_" + p ;
	//CellProfiler();
	//if there is also a set of files with the name deriving from partID
	//you can run this if they are all using the same type of masks
	ID = partID + "_" + p ;
	C3Masker();
	//ID = partID + "shift30_" + p ;
	//CellProfiler();
	//ID = partID + "shift15_" + p ;
	//CellProfiler();
}


// *******  CHECK THIS IS OK BEFORE START ******** //
function C3Masker() {

	processFolder(input);
	run("Split Channels");
	
	selectWindow(wgchannel + ID + "_" + pro);
	run("Gaussian Blur...", "sigma=1 scaled stack");
	run("Convert to Mask", "method=Yen background=Dark calculate black");
	run("Options...", "iterations=1 count=40 pad do=Erode stack");
	run("Options...", "iterations=1 count=40 do=Dilate stack");
	saveAs("Tiff", output+File.separator+ID+ "DVMask");
	rename(ID + "_" + "DVMask");
	
	selectWindow(c3channel + ID + "_" + pro);
	run("Convert to Mask", "method=Triangle background=Dark stack black create");
	//waitForUser("ok?");
	run("Options...", "iterations=2 count=1 do=Dilate stack");
	run("Options...", "iterations=2 count=1 pad do=Erode stack");
	//waitForUser("ok?");
	saveAs("Tiff", output+File.separator+ID+ "FullC3Mask");
	rename(ID + "_" + "FullC3Mask");
	
	imageCalculator("Min create stack", ID + "_" + "DVMask", ID + "_" + "FullC3Mask");
	saveAs("Tiff", output+File.separator+ID+mask1);
	
	run("Close All");
}

// *******  SMALLER USER DEFINED FUNCTIONS ******** //
              
function clean(a){
	selectWindow(a);
	run("Close");
}
 
function processFolder(input) {
// function to scan folders/subfolders/files to find files with correct suffix
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(indexOf(list[i], ID) >=0){
			open(list[i]);
			rename(ID + "_" + pro); 
		} else {
			print("other");
		}		
	}
}




