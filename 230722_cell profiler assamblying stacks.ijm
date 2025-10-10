//modified to make it more automated!

partID = "DEAD"

#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output

for (p = 0; p < 12; p++) {
ID = partID + "_" + p ;
processAssemble(input, "FiltMask");
processAssemble(input, "RmvdMask");
/*ID = "old" + partID + "_" + p ;
processAssemble(input, "FiltMask");
processAssemble(input, "RmvdMask");
*/
}

////Within a certain area
//step = "RadialFC2Mask"

////Different channels to identify rings
//step = "FiltMask649"
//step = "FiltMaskWg"
//step = "FiltMask488"
//step = "RmvdMask649"
//step = "RmvdMaskWg"
//step = "RmvdMask488"


// function to scan folders/subfolders/files to find files with correct suffix
function processAssemble(input, step) {
	suffix = step + ".tiff" ;
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			if(indexOf(list[i], ID) >=0)
					open(list[i]);
	}

run("Images to Stack", "name=Stack title=[] use");
title = getTitle();

saveAs("Tiff", output+ID+title+step);
run("Close All");

}