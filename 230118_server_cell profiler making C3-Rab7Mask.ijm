//you need the processed images in a separate folder!
//alternatively do it when only the processed files are in the
//stack folder
// now even more automated!
// MAKE SURE TO DOUBLE CHECK THAT THE IN IS IN AND THE OUT IS OUT

partID = "Rab7Dlp"
mask2 = "Rab7Mask"
mask1 = "FiltMask"
pro = "ProcessedStack"
c3channel = "C1-"

#@ File (label = "Input directory", style = "directory") input
#@ String (label = "File suffix", value = ".tif") suffix

output = "Y:/home/users/alvarei/empty this into your own dropbox/"

waitForUser("Have you checked all ok?");

for (p = 4; p < 7; p++) {
	//ID = partID + "het_" + p ;
	//CellProfiler();
	//if there is also a set of files with the name deriving from partID
	//you can run this if they are all using the same type of masks
	ID = partID + "_" + p ;
	Rab7Masker();
	//ID = partID + "shift30_" + p ;
	//CellProfiler();
	//ID = partID + "shift15_" + p ;
	//CellProfiler();
}


// *******  CHECK THIS IS OK BEFORE START ******** //
function Rab7Masker() {

	processFolder(input);
	
	selectWindow(ID + "_" + pro);
	run("Split Channels");
	
	selectWindow(c3channel + ID + "_" + pro);
	run("Duplicate...", "duplicate");
	run("Median...", "radius=5 stack");
	run("Convert to Mask", "method=Triangle background=Dark calculate stack black create");
	//waitForUser("ok?");
	run("Invert", "stack");
	run("Fill Holes", "stack");
	run("Options...", "iterations=4 count=1 do=Erode stack");
	run("Options...", "iterations=12 count=1 do=Dilate stack");
	//waitForUser("ok?");
	
	saveAs("Tiff", output+File.separator+ID+"Full"+mask2);
	rename(ID + "_" + "Full"+mask2);
	
	imageCalculator("Min create stack", ID + "_" + mask1, ID + "_" + "Full"+mask2);
	saveAs("Tiff", output+File.separator+ID+"WgRingsOut"+mask2);
	rename(ID + "_" + "WgRingsOut"+mask2);
		//note this should give you the stuff inside the organelle mask you are applying, but for some reason is doing
		//the opposite and giving me the stuff outside - this is why we always double check the final output
	
	imageCalculator("Substract create stack", ID + "_" + mask1, ID + "_" + "WgRingsOut"+mask2);
	saveAs("Tiff", output+File.separator+ID+"WgRingsIn"+mask2);
	rename(ID + "_" + "WgRingsIn"+mask2);
	
	selectWindow(ID + "_" + "Full"+mask2);
	run("Invert", "stack");
	
	selectWindow(c3channel + ID + "_" + pro);
	run("8-bit");
	
	run("Merge Channels...", "c1=["+c3channel + ID + "_" + pro+"] c2=["+ID + "_" + "Full"+mask2+"] c3=["+ID + "_" + "WgRingsIn"+mask2+"] c4=["+ID + "_" + "WgRingsOut"+mask2+"] c5=["+ID + "_" + mask1+"] create");
	saveAs("Tiff", output+File.separator+ID+"CHECK"+mask2);
	
	//waitForUser("ok?");
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

