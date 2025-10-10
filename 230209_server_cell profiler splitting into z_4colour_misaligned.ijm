//for cell profiler use, when the channels are slightly offset in z
//note offset can change between sessions! always double check a set
// but in this case, i manually set the offset at the microscope to be
//C1 = 0, C2 = +0.4, C3 = +0.2, C4 = 0


partID = "Rab4Rab7"
//choose one or the other!
step = "ProcessedStack"

#@ File (label = "Input directory", style = "directory") input
#@String(label = "File suffix", value = ".vsi") suffix
//this is important because it allows you to open as a .vsi

output = "Y:/home/users/alvarei/empty this into your own dropbox/"

for (p = 6; p < 7; p++) {
	ID = partID + "_" + p ;
	ID2 = "0" + p + "_5MLE.vsi.vsi" ;
	processFolder(input);
}

function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (x = 0; x < list.length; x++) {
		if(indexOf(list[x], ID2) >=0) {
			if(endsWith(list[x], suffix))
				name = File.getNameWithoutExtension(list[x]);
				print(name);
				file = input+"/_"+name+"_/stack1/frame_t_0.ets";
				alignVSI(file);
		}else {
			print("Other");
		}
}


function alignVSI(file) {	
	run("Bio-Formats Importer", "open=file");
title = getTitle();

c1t = "C1-"+title;
c2t = "C2-"+title;
c3t = "C3-"+title;
c4t = "C4-"+title;

run("Split Channels");
selectWindow(c1t);
run("Slice Remover", "first=1 last=1 increment=1");

selectWindow(c2t);
run("Slice Remover", "first=1 last=1 increment=1");

selectWindow(c3t);
n = nSlices;
run("Slice Remover", "first=n last=n increment=1");

selectWindow(c4t);
run("Slice Remover", "first=1 last=1 increment=1");


run("Merge Channels...", "c1=["+c1t+"] c2=["+c2t+"] c3=["+c3t+"] c4=["+c4t+"] create");

saveAs("Tiff", output+File.separator+ID + "_" +step);
title = getTitle();

c1t = "C1-"+title;
c2t = "C2-"+title;
c3t = "C3-"+title;
c4t = "C4-"+title;

run("Split Channels");
run("Merge Channels...", "c2=["+c2t+"] c3=["+c3t+"] create");

for (i = 1; i <= nSlices; i++) { 
    setSlice(i);
    run("Reduce Dimensionality...", "channels keep");
    title = getTitle;
    if (i < 100) {
    	if (i < 10) {
    		saveAs("Tiff", output+File.separator+"C2-"+ID +"_"+ step + "_slice00" + i + ".tif");
    	} else {
    	saveAs("Tiff", output+File.separator+"C2-"+ID + "_"+ step + "_slice0" + i + ".tif");
    	}
    } else {
    saveAs("Tiff", output+File.separator+"C2-"+ID + "_"+ step + "_slice" + i + ".tif");
    }
    close();
    i = i+1;
}    

close();
close();
close();
}

//this saves it as a 2 colour channel (even though it say C2-) and the slice number = the slice of channel 1 (hence it jumps by two);
//it also saves the original stack for later use
