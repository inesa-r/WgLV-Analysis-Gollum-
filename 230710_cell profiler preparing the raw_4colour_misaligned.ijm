// step 2 after GOLLUM

partID = "newWT"

//select the number of channels you have. nomenclature is historic
wgchannel = "C2-"
refchannel = "C1-"
otherchannel1 = "C3-"
otherchannel2 = "C4-"


#@ File (label = "Input directory", style = "directory") input
#@String(label = "File suffix", value = ".vsi") suffix
//this is important because it allows you to open as a .vsi

output = "/Users/alvarei/Dropbox (The Francis Crick)/Ines Lab Data/microscope/analysis/dunn school sora ring analysis/GOLLUM/results/"

// for some reason it doesnt cycle, but at least you only need to change the number
for (p = 2; p < 12; p++) {
	image = partID + "_" + p ;
	ID2 = "_Ci647_" + p + ".vsi" ;
	processFolder(input);
}
/*
p = 0;
image = partID + "_" + p ;
ID2 = "_Ci647.vsi" ;
processFolder(input);
*/

function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (x = 0; x < list.length; x++) {
		if(indexOf(list[x], ID2) >=0) {
							if(endsWith(list[x], suffix))
					name = File.getNameWithoutExtension(list[x]);
					print(name);
					file = input+"/_"+name+"_/stack1/frame_t_0.ets";
					prepareRaw(file);
		}else {
			print("Other");
		}
}
}

function prepareRaw(file) {	
run("Bio-Formats Importer", "open=file");

//waitForUser("have you set correct names for channels?");
titleA = getTitle();

//open and correct misalignment
selectWindow(titleA);
run("Split Channels");

c1t = "C1-"+titleA;
c2t = "C2-"+titleA;
c3t = "C3-"+titleA;
c4t = "C4-"+titleA;

selectWindow(c1t);
run("Slice Remover", "first=1 last=1 increment=1");

selectWindow(c2t);
n = nSlices;
run("Slice Remover", "first=n last=n increment=1");

selectWindow(c3t);
run("Slice Remover", "first=1 last=1 increment=1");

selectWindow(c4t);
run("Slice Remover", "first=1 last=1 increment=1");

run("Set Measurements...", "area mean stack limit redirect=None decimal=3");
selectWindow(wgchannel + titleA);
setAutoThreshold("Otsu dark");
//waitForUser("ok?")
for (i = 1; i <= nSlices; i++) { 
    setSlice(i);
	run("Measure");
}    
selectWindow("Results");
saveAs("Results", output + image + "MeanIntensityResults_" + wgchannel + ".csv");
close("Results");

selectWindow(otherchannel1 + titleA);
setAutoThreshold("Otsu dark");
//waitForUser("ok?")
for (i = 1; i <= nSlices; i++) { 
    setSlice(i);
	run("Measure");
}    
selectWindow("Results");
saveAs("Results", output + image + "MeanIntensityResults_" + otherchannel1 + ".csv");
close("Results");

////////// REF Channel - use the first one if it is truly a ref 
///////				- use the second one if it is working as an additional channel

selectWindow(refchannel + titleA);
//waitForUser("ok?")
run("Select All");
//setAutoThreshold("Otsu dark");
for (i = 1; i <= nSlices; i++) { 
    setSlice(i);
	run("Measure");
}    
selectWindow("Results");
saveAs("Results", output + image + "ReferenceMeanIntensityResults_" + refchannel + ".csv");
close("Results");


selectWindow(otherchannel2 + titleA);
setAutoThreshold("Otsu dark");
//waitForUser("ok?")
for (i = 1; i <= nSlices; i++) { 
    setSlice(i);
	run("Measure");
}    
selectWindow("Results");
saveAs("Results", output + image + "ReferenceMeanIntensityResults_" + otherchannel2 + ".csv");
close("Results");


//////////// FINAL OUTPUT
//////Again depending on how many channels you have you may need to include more or less
///// images in your merge:

// OPTION FOR 2

/* run("Merge Channels...", "c1=["+wgchannel + titleA+"] c2=["+otherchannel1 + titleA+"] create");
saveAs("Tiff", output+File.separator+image + "_RawStack");
*/

/*
// OPTION FOR 3
run("Merge Channels...", "c1=["+refchannel + titleA+"] c2=["+wgchannel + titleA+"] c3=["+otherchannel1 + titleA+"] create");
saveAs("Tiff", output+File.separator+image + "_RawStack");
*/

run("Merge Channels...", "c1=["+wgchannel + titleA+"] c2=["+otherchannel1 + titleA+"] c3=["+otherchannel2 + titleA+"] create");
saveAs("Tiff", output+File.separator+image + "_RawStack");

/*
// OPTION FOR 4
run("Merge Channels...", "c1=["+otherchannel1 + titleA+"] c2=["+wgchannel + titleA+"] c3=["+otherchannel2 + titleA+"] c4=["+refchannel + titleA+"] create");
saveAs("Tiff", output+File.separator+image + "_RawStack");
*/
run("Close All");
}