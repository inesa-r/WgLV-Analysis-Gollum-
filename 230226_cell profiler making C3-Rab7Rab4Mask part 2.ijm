//this should have happened when i made the masks for the Rab7 Rab4 dataset
ID = "Rab4Rab7_6"

#@ String (label = "File suffix", value = ".tif") suffix

output = "/Users/alvarei/Dropbox (The Francis Crick)/Ines Lab Data/microscope/analysis/dunn school sora ring analysis/GOLLUM/results/"

selectWindow(ID+"FullRab4Mask.tif");
run("Invert", "stack");

selectWindow(ID+"FullRab7Mask.tif");
run("Invert", "stack");

//this finds the area that is shared between the two masks and also counts how many stops and how much area they cover
imageCalculator("AND create stack", ID+"FullRab4Mask.tif", ID+"FullRab7Mask.tif");
saveAs("Tiff", output + ID + "FullBothMask");
run("Analyze Particles...", "summarize stack");
saveAs("Results", output + ID + "_summaryBothMasks.csv");
run("Close");
//now apply to the wg ring mask
imageCalculator("Min create stack", ID+"StackFiltMask.tif", ID+"FullBothMask.tif");
saveAs("Tiff", output + ID + "WgRingsInBoth");

//now making a mask that takes all the areas, whether they are covered in Rab4 or Rab7 or both. Because max is always the same i can do
imageCalculator("Max create stack", ID+"FullRab4Mask.tif", ID+"FullRab7Mask.tif");
saveAs("Tiff", output + ID + "FullEitherMask");
//apply to the Wg mask - remove anything that falls in that area
imageCalculator("Substract create stack", ID+"StackFiltMask.tif", ID+"FullEitherMask.tif");
saveAs("Tiff", output + ID + "WgRingsNeither");

//now making the Rab specific ones
imageCalculator("Substract create stack", ID+"FullRab4Mask.tif", ID+"FullBothMask.tif");
saveAs("Tiff", output + ID + "Rab4OnlyMask");
run("Analyze Particles...", "summarize stack");
saveAs("Results", output + ID + "_summaryRab4Mask.csv");
run("Close");
//now apply to the wg ring mask
imageCalculator("Min create stack", ID+"StackFiltMask.tif", ID+"Rab4OnlyMask.tif");
saveAs("Tiff", output + ID + "WgRingsRab4Only");

imageCalculator("Substract create stack", ID+"FullRab7Mask.tif", ID+"FullBothMask.tif");
saveAs("Tiff", output + ID + "Rab7OnlyMask");
run("Analyze Particles...", "summarize stack");
saveAs("Results", output + ID + "_summaryRab7Mask.csv");
run("Close");
//now apply to the wg ring mask
imageCalculator("Min create stack", ID+"StackFiltMask.tif", ID+"Rab7OnlyMask.tif");
saveAs("Tiff", output + ID + "WgRingsRab7Only");