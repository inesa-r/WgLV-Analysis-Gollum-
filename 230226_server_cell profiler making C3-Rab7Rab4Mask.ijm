//you need the processed images in a separate folder!
//alternatively do it when only the processed files are in the
//stack folder
// now even more automated!
// MAKE SURE TO DOUBLE CHECK THAT THE IN IS IN AND THE OUT IS OUT

partID = "Rab4Rab7"
mask2 = "Rab4Mask"
mask3 = "Rab7Mask"
mask1 = "FiltMask"
pro = "ProcessedStack"
otherchannel = "C3-"
c3channel = "C4-"

#@ File (label = "Input directory", style = "directory") input
#@ String (label = "File suffix", value = ".tif") suffix

output = "Y:/home/users/alvarei/empty this into your own dropbox/"

waitForUser("Have you checked all ok?");

for (p = 1; p < 7; p++) {
	//ID = partID + "het_" + p ;
	//CellProfiler();
	//if there is also a set of files with the name deriving from partID
	//you can run this if they are all using the same type of masks
	ID = partID + "_" + p ;
	Rab7Masker(c3channel, mask3);
	Rab7Masker(otherchannel, mask2);
	//doing it for 2 different channels (rab7 and Rab4)
	
	run("Close All");
}


// *******  CHECK THIS IS OK BEFORE START ******** //
function Rab7Masker(maskchannel, mask) {

	processFolder(input);
	
	selectWindow(ID + "_" + pro);
	run("Split Channels");
	
	selectWindow(maskchannel + ID + "_" + pro);
	run("Duplicate...", "duplicate");
	run("Median...", "radius=5 stack");
	//setAutoThreshold("Triangle dark no-reset stack");
	//setOption("BlackBackground", false);
	run("Convert to Mask", "method=Triangle background=Dark calculate stack black create");
	//waitForUser("ok?");
	run("Invert", "stack");
	run("Fill Holes", "stack");
	run("Options...", "iterations=4 count=1 do=Erode stack");
	run("Options...", "iterations=4 count=1 do=Dilate stack");
	//waitForUser("ok?");
	
	saveAs("Tiff", output+File.separator+ID+"Full"+mask);
	rename(ID + "_" + "Full"+mask);
	
	imageCalculator("Min create stack", ID + "_" + mask1, ID + "_" + "Full"+mask);
	saveAs("Tiff", output+File.separator+ID+"WgRingsOut"+mask);
	rename(ID + "_" + "WgRingsOut"+mask);
	
	imageCalculator("Substract create stack", ID + "_" + mask1, ID + "_" + "WgRingsOut"+mask);
	saveAs("Tiff", output+File.separator+ID+"WgRingsIn"+mask);
	rename(ID + "_" + "WgRingsIn"+mask);
	
	selectWindow(ID + "_" + "Full"+mask);
	run("Invert", "stack");
	
	selectWindow(maskchannel + ID + "_" + pro);
	run("8-bit");
	
	run("Merge Channels...", "c1=["+maskchannel + ID + "_" + pro+"] c2=["+ID + "_" + "Full"+mask+"] c3=["+ID + "_" + "WgRingsIn"+mask+"] c4=["+ID + "_" + "WgRingsOut"+mask+"] c5=["+ID + "_" + mask1+"] create");
	saveAs("Tiff", output+File.separator+ID+"CHECK"+mask);
	
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
			if(indexOf(list[i], pro) >=0) {
				open(list[i]);
				rename(ID + "_" + pro);
					} else {
					if(indexOf(list[i], mask1) >=0) {
					open(list[i]);
					rename(ID + "_" + mask1);
						} else {
						print("Not processed or filtered");
						}		
					}
			}else {
			print("Different sample");
			}
	}
}

