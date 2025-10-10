## for experiments using GOLLUM, this is the put analysis bit having tried to classify
##based on a 3rd channel mask (in this case, Rab7YFP)

#To make it even less painful copy all the folder names into a csv file, then run:
#on windows
#dir <- "C:/Users/inesa/Dropbox (The Francis Crick)/Ines Lab Data/microscope/analysis/dunn school sora ring analysis/GOLLUM/results/"
#on mac
dir <- "/Users/alvarei/Dropbox (The Francis Crick)/Ines Lab Data/microscope/analysis/dunn school sora ring analysis/GOLLUM/results/"
setwd(dir)
names <- read.csv("names.csv", header = T)
experiment <- "NewRab7"

types <- c("FiltMask", "WgRingsInRab7Mask", "WgRingsOutRab7Mask", "RmvdMask")

#these are some extra dataframes to extract the key bits of data you want
ExtractedNumbers.df <- data.frame(matrix(types, ncol=8,nrow=1))
ExtractedDensity.df <- data.frame(matrix(types, ncol=8,nrow=1))
ExtractedWg.df <- data.frame(matrix(types, ncol=8,nrow=1))
ExtractedC1C2.df <- data.frame(matrix(types, ncol=8,nrow=1))
ExtractedC3.df <- data.frame(matrix(types, ncol=8,nrow=1))

ExtractedRawWg.df <- data.frame(matrix(types, ncol=8,nrow=1))
ExtractedRawC1C2.df <- data.frame(matrix(types, ncol=8,nrow=1))
ExtractedRawC3.df <- data.frame(matrix(types, ncol=8,nrow=1))

#in this particular case, I need to switch things up a bit since only 3 channels that i measured all the rings etc, but i am interested
#in the average of channel1 which I later removed (will call it 4/reference from now on)
ExtractedC4.df <- data.frame(matrix(types, ncol=8,nrow=1))

for (n in 1:nrow(names)){
  image <- names[n,3] #because the names happen to be in the 3rd row!

  
### 1) OPEN YOUR FILES
# make sure that the right channel is assigned to the right files
# e.g. for legacy reasons, "C2Mean" refers to the 2nd channel of interest, which may not be C2- in the images you are analysing.

# these are the intensity files for the whole image, before finding the rings
wgMean.df <- read.csv(list.files( pattern = paste(image, "MeanIntensityResults_C2-", sep="")))
C2Mean.df <- read.csv(list.files( pattern = paste(image, "MeanIntensityResults_C1-", sep="")))
C3Mean.df <- read.csv(list.files( pattern = paste(image, "MeanIntensityResults_C3-", sep="")))
Ref.df <- read.csv(list.files( pattern = paste(image, "ReferenceMeanIntensityResults_C4-", sep="")))

# these are the intensity files for the rings --> legacy names: now this is whatever mask is in type 1
FiltRawWg.df <- read.csv(list.files( pattern = paste(image, "_C2-", types[1], "_RawMeanIntensity", sep="")))
FiltRawC2.df <- read.csv(list.files( pattern = paste(image, "_C1-", types[1], "_RawMeanIntensity", sep="")))
FiltRawC3.df <- read.csv(list.files( pattern = paste(image, "_C3-", types[1], "_RawMeanIntensity", sep="")))

# these are the intensity files for the rings INSIDE the classifier compartment mask specified  --> legacy names: now this is whatever mask is in type 2
InRawWg.df <- read.csv(list.files( pattern = paste(image, "_C2-", types[2], "_RawMeanIntensity", sep="")))
InRawC2.df <- read.csv(list.files( pattern = paste(image, "_C1-", types[2], "_RawMeanIntensity", sep="")))
InRawC3.df <- read.csv(list.files( pattern = paste(image, "_C3-", types[2], "_RawMeanIntensity", sep="")))

# these are the intensity files for the rings OUTSIDE the classifier compartment mask specified  --> legacy names: now this is whatever mask is in type 3
OutRawWg.df <- read.csv(list.files( pattern = paste(image, "_C2-", types[3], "_RawMeanIntensity", sep="")))
OutRawC2.df <- read.csv(list.files( pattern = paste(image, "_C1-", types[3], "_RawMeanIntensity", sep="")))
OutRawC3.df <- read.csv(list.files( pattern = paste(image, "_C3-", types[3], "_RawMeanIntensity", sep="")))


################################### FROM HERE YOU PROB DONT WANT TO TOUCH ###################################


#### Modification/intermediate step!!
## when measuring the intensity inside the objects, i have noticed that if there is no object in the slice, then the whole area is selected
## as an object (which would be of size 4702.928 at least on the Dunn School Sora). This needs to be removed.
## I have been doing it manually but it is time to try to optimise it/

FiltRawWg.df <- subset(FiltRawWg.df, Area!=4702.928)
FiltRawC2.df <- subset(FiltRawC2.df, Area!=4702.928)
FiltRawC3.df <- subset(FiltRawC3.df, Area!=4702.928)

InRawWg.df <- subset(InRawWg.df, Area!=4702.928)
InRawC2.df <- subset(InRawC2.df, Area!=4702.928)
InRawC3.df <- subset(InRawC3.df, Area!=4702.928)

OutRawWg.df <- subset(OutRawWg.df, Area!=4702.928)
OutRawC2.df <- subset(OutRawC2.df, Area!=4702.928)
OutRawC3.df <- subset(OutRawC3.df, Area!=4702.928)

## i also want to remove any small objects due to a bit of ring being outside / inside the classifier
#dont remove them for the filtered and removed objects

FiltRawWg.df <- subset(FiltRawWg.df, Area >= 0.09)
FiltRawC2.df <- subset(FiltRawC2.df, Area>= 0.09)
FiltRawC3.df <- subset(FiltRawC3.df, Area>= 0.09)

InRawWg.df <- subset(InRawWg.df, Area >= 0.09)
InRawC2.df <- subset(InRawC2.df, Area>= 0.09)
InRawC3.df <- subset(InRawC3.df, Area>= 0.09)

OutRawWg.df <- subset(OutRawWg.df, Area>= 0.09)
OutRawC2.df <- subset(OutRawC2.df, Area>= 0.09)
OutRawC3.df <- subset(OutRawC3.df, Area>= 0.09)

### 2) CREATE THE TABLE TO PUT THINGS INTO AND COUNT SLICES
#create empty dataframe
Results.df <- data.frame
#slices is a vector containing all the values in wgMean.df[,1], i.e. all the slice numbers
slices <- as.vector(wgMean.df[,1])

#now we make tables where we will be adding our results as we go along,
#depending on whether they are total results
#or results per slices

Totals<-matrix(NA, ncol=8, nrow=max(wgMean.df[,1]))
Objects <- matrix(NA, ncol=3, nrow=max(wgMean.df[,1]))
Area <- matrix(NA, ncol=3, nrow=max(wgMean.df[,1]))
Mean <- matrix(NA, ncol=12, nrow=max(wgMean.df[,1]))

Totals.df <- data.frame(Totals)
Objects.df <- data.frame(Objects)
Area.df <- data.frame(Area)
Mean.df <- data.frame(Mean)


Totals.df[1,1] <- "Total Objects"
Totals.df[3,1] <- "Object Density"
Totals.df[5,1] <- "Area Av, SD, Median"

Totals.df[1,5] <- "Wg Channel Intensity Median and Normalised"
Totals.df[4,5] <- "Other Channel 1/2 Intensity Median and Normalised"
Totals.df[7,5] <- "Channel 3 Intensity Median and Normalised"
Totals.df[10,5] <- "Channel 4/0 Intensity Median Whole Slice"

###3) COUNT THE NUMBER OF OBJECTS

  #in EACH slice
  for (i in slices) { # for each slice number
    Objects.df[i,1] <- sum(FiltRawWg.df[,4] == i) 
    # write in a row of the same number (i) in objects
    #the sum of all the cells in the test .df object where the value of column four (slice) = the slice number i
  }
  
  for (i in slices) {
    Objects.df[i,2] <- sum(InRawWg.df[,4] == i)
  }

  for (i in slices) {
    Objects.df[i,3] <- sum(OutRawWg.df[,4] == i)
  }
  
  #in TOTAL
  #note that this in the previous scripts to put together GOLLUM data used to happen at the end.
  #but since I am cleaning up and anotating this script to put together the classifier data.
  #makes sense to put everything here
  
  max.slices <- max(wgMean.df[,1])
  # i have changed this from the reference being the filtwg in case i run into examples where i dont have any objects in one slice
  
  Totals.df[2,1] <- sum(Objects.df[,1], na.rm = TRUE)
  Totals.df[2,2]  <- sum(Objects.df[,2], na.rm = TRUE)
  Totals.df[2,3]  <- sum(Objects.df[,3], na.rm = TRUE)
  
  #and the object density
  Totals.df[4,1] <- as.numeric(Totals.df[2,1]) / max.slices
  Totals.df[4,2] <- as.numeric(Totals.df[2,2]) / max.slices
  Totals.df[4,3] <- as.numeric(Totals.df[2,3])/ max.slices
  
###4) CALCULATE MEDIAN MEAN (SD) OF AREAS AND INTENTISITIES

## ...sizes
#units are already in micron^2

Totals.df[6,1] <- mean(FiltRawWg.df$Area)
Totals.df[7,1] <- sd(FiltRawWg.df$Area)
Totals.df[8,1] <- median(FiltRawWg.df$Area)

Totals.df[6,2] <- mean(InRawWg.df$Area)
Totals.df[7,2] <- sd(InRawWg.df$Area)
Totals.df[8,2] <- median(InRawWg.df$Area)

Totals.df[6,3] <- mean(OutRawWg.df$Area)
Totals.df[7,3] <- sd(OutRawWg.df$Area)
Totals.df[8,3] <- median(OutRawWg.df$Area)

for (i in slices) {
  
  Area.df[i,1] <- median(FiltRawWg.df$Area[FiltRawWg.df[,4] == i]) 
  Area.df[i,2] <- median(InRawWg.df$Area[InRawWg.df[,4] == i]) 
  Area.df[i,3] <- median(OutRawWg.df$Area[OutRawWg.df[,4] == i]) 
}

## ...Intensity of objects in Wg

Totals.df[2,5] <- median(FiltRawWg.df$Mean)
Totals.df[2,6] <- median(InRawWg.df$Mean)
Totals.df[2,7] <- median(OutRawWg.df$Mean)

Totals.df[3,5] <- median(FiltRawWg.df$Mean, na.rm = TRUE)/median(wgMean.df$Mean, na.rm = TRUE)
Totals.df[3,6] <- median(InRawWg.df$Mean,na.rm = TRUE)/median(wgMean.df$Mean,na.rm = TRUE)
Totals.df[3,7] <- median(OutRawWg.df$Mean, na.rm = TRUE)/median(wgMean.df$Mean, na.rm = TRUE)

for (i in slices) {
  
  Mean.df[i,1] <- median(FiltRawWg.df$Mean[FiltRawWg.df[,4] == i])/median(wgMean.df$Mean, na.rm = TRUE)
  Mean.df[i,2] <- median(InRawWg.df$Mean[InRawWg.df[,4] == i])/median(wgMean.df$Mean, na.rm = TRUE)
  Mean.df[i,3] <- median(OutRawWg.df$Mean[OutRawWg.df[,4] == i])/median(wgMean.df$Mean, na.rm = TRUE) 
}

## ...Intensity of objects in (OTHER PROTEINS) --> note this for legacy reasons says C2 but it isnt

Totals.df[5,5] <- median(FiltRawC2.df$Mean)
Totals.df[5,6] <- median(InRawC2.df$Mean)
Totals.df[5,7] <- median(OutRawC2.df$Mean)

Totals.df[6,5] <- median(FiltRawC2.df$Mean, na.rm = TRUE)/median(C2Mean.df$Mean, na.rm = TRUE)
Totals.df[6,6] <- median(InRawC2.df$Mean,na.rm = TRUE)/median(C2Mean.df$Mean,na.rm = TRUE)
Totals.df[6,7] <- median(OutRawC2.df$Mean, na.rm = TRUE)/median(C2Mean.df$Mean, na.rm = TRUE)

for (i in slices) {
  
  Mean.df[i,4] <- median(FiltRawC2.df$Mean[FiltRawC2.df[,4] == i])/median(C2Mean.df$Mean, na.rm = TRUE) 
  Mean.df[i,5] <- median(InRawC2.df$Mean[InRawC2.df[,4] == i])/median(C2Mean.df$Mean, na.rm = TRUE)
  Mean.df[i,6] <- median(OutRawC2.df$Mean[OutRawC2.df[,4] == i])/median(C2Mean.df$Mean, na.rm = TRUE)
}


## ...Intensity of objects in C3

Totals.df[8,5] <- median(FiltRawC3.df$Mean)
Totals.df[8,6] <- median(InRawC3.df$Mean)
Totals.df[8,7] <- median(OutRawC3.df$Mean)

Totals.df[9,5] <- median(FiltRawC3.df$Mean, na.rm = TRUE)/median(C3Mean.df$Mean, na.rm = TRUE)
Totals.df[9,6] <- median(InRawC3.df$Mean,na.rm = TRUE)/median(C3Mean.df$Mean,na.rm = TRUE)
Totals.df[9,7] <- median(OutRawC3.df$Mean, na.rm = TRUE)/median(C3Mean.df$Mean, na.rm = TRUE)

for (i in slices) {
  
  Mean.df[i,7] <- median(FiltRawC3.df$Mean[FiltRawC3.df[,4] == i])/median(C3Mean.df$Mean, na.rm = TRUE) 
  Mean.df[i,8] <- median(InRawC3.df$Mean[InRawC3.df[,4] == i])/median(C3Mean.df$Mean, na.rm = TRUE)
  Mean.df[i,9] <- median(OutRawC3.df$Mean[OutRawC3.df[,4] == i])/median(C3Mean.df$Mean, na.rm = TRUE) 
}

## ...Intensity of whole slice in C4

Totals.df[12,5] <- median(Ref.df$Mean, na.rm = TRUE)


###5) PUT EVERYTHING TOGETHER

Results.df <- cbind(Totals.df,Objects.df,Area.df,Mean.df,wgMean.df[,3], C2Mean.df[,3], C3Mean.df[,3], Ref.df[,3])

#rename your columns
names(Results.df) [1] <- types[1]
names(Results.df) [2] <- types[2]
names(Results.df) [3] <- types[3]
names(Results.df) [4] <- ""
names(Results.df) [5] <- types[1]
names(Results.df) [6] <- types[2]
names(Results.df) [7] <- types[3]
names(Results.df) [8] <- ""

names(Results.df) [9] <- paste("Number Objects per Slice", types[1], sep="  ")
names(Results.df) [10] <- paste("Number Objects per Slice", types[2], sep="  ")
names(Results.df) [11] <- paste("Number Objects per Slice", types[3], sep="  ")

names(Results.df) [12] <- paste("Median Size per Slice", types[1], sep="  ")
names(Results.df) [13] <- paste("Median Size per Slice", types[2], sep="  ")
names(Results.df) [14] <- paste("Median Size per Slice", types[3], sep="  ")

names(Results.df) [15] <- paste("Median Wg Intensity per Slice", types[1], sep="  ")
names(Results.df) [16] <- paste("Median Wg Intensity per Slice", types[2], sep="  ")
names(Results.df) [17] <- paste("Median Wg Intensity per Slice", types[3], sep="  ")

names(Results.df) [18] <- paste("Median Other C1/2 Intensity per Slice", types[1], sep="  ")
names(Results.df) [19] <- paste("Median Other C1/2 Intensity per Slice", types[2], sep="  ")
names(Results.df) [20] <- paste("Median Other C1/2 Intensity per Slice", types[3], sep="  ")


names(Results.df) [21] <- paste("Median C3 Intensity per Slice", types[1], sep="  ")
names(Results.df) [22] <- paste("Median C3 Intensity per Slice", types[2], sep="  ")
names(Results.df) [23] <- paste("Median C3 Intensity per Slice", types[3], sep="  ")

names(Results.df) [24] <- paste("Median C4 Intensity per Slice", types[1], sep="  ")
names(Results.df) [25] <- paste("Median C4 Intensity per Slice", types[2], sep="  ")


names(Results.df) [27] <- "Overall Wg Intensity"
names(Results.df) [28] <- "Overall Other Ch1/2 Intensity"
names(Results.df) [29] <- "Overall C3 Intensity"
names(Results.df) [30] <- "Overall Ref Intensity"

#to find the brightest slice of the reference channel
mRef <- max(Results.df$"Overall Wg Intensity", na.rm = T) #this finds the max value of the reference intensity column, ignoring NA values
Results.df[which(Results.df[,"Overall Wg Intensity"] == mRef,arr.ind=T),31] <- mRef
#this finds the row of the "Overall Wg Intensity" column that matches the max value, then in the same row but the next column
#it writes the value
names(Results.df) [31] <- "Wg Maxima"

# #the same could be done for wg but it doesnt seem to be as accurate
# mWg <- max(Results.df$"Overall Wg Intensity", na.rm = T)
# Results.df[which(Results.df[,"Overall Wg Intensity"] == mWg,arr.ind=T),29] <- mWg
# names(Results.df) [29] <- "Wg Maxima"

#now to have also the slices on the other side so that you can more quickly rearrange if necessary
Results.df[,32] <- slices
names(Results.df) [32] <- "Slice Number"

#putting together now the results from the totals for all the samples you have
ExtractedNumbers.df <- rbind(ExtractedNumbers.df, Totals.df[2,])
ExtractedDensity.df <- rbind(ExtractedDensity.df, Totals.df[4,])
ExtractedWg.df <- rbind(ExtractedWg.df, Totals.df[3,])
ExtractedC1C2.df <- rbind(ExtractedC1C2.df, Totals.df[6,])
ExtractedC3.df <- rbind(ExtractedC3.df, Totals.df[9,])
ExtractedC4.df <- rbind(ExtractedC4.df, Totals.df[12,])

ExtractedRawWg.df <- rbind(ExtractedRawWg.df, Totals.df[2,])
ExtractedRawC1C2.df <- rbind(ExtractedRawC1C2.df, Totals.df[5,])
ExtractedRawC3.df <- rbind(ExtractedRawC3.df, Totals.df[8,])


#FINALLY, WRITE THE DAMN THINGS
filename <- gsub("  ", "", paste("aGollumFinalResults_", image, types[1], types[2], types[3], ".csv", sep="  "))
write.csv(Results.df, file = filename)

}
ExtractedNumbers.df <- ExtractedNumbers.df[ -c(5:8) ]
filename <- gsub("  ", "", paste("aExtractedNumbers", experiment, types[1], types[2], types[3], ".csv", sep="  "))
write.csv(ExtractedNumbers.df, file = filename)

ExtractedC3.df <- ExtractedC3.df[ -c(1:4) ]
filename <- gsub("  ", "", paste("aExtractedC3", experiment, types[1], types[2], types[3], ".csv", sep="  "))
write.csv(ExtractedC3.df, file = filename)

ExtractedC4.df <- ExtractedC4.df[ -c(1:4) ]
filename <- gsub("  ", "", paste("aExtractedC4", experiment, types[1], types[2], types[3], ".csv", sep="  "))
write.csv(ExtractedC4.df, file = filename)

ExtractedC1C2.df <- ExtractedC1C2.df[ -c(1:4) ]
filename <- gsub("  ", "", paste("aExtractedC1C2", experiment, types[1], types[2], types[3], ".csv", sep="  "))
write.csv(ExtractedC1C2.df, file = filename)

ExtractedWg.df <- ExtractedWg.df[ -c(1:4) ]
filename <- gsub("  ", "", paste("aExtractedWg", experiment, types[1], types[2], types[3], ".csv", sep="  "))
write.csv(ExtractedWg.df, file = filename)

ExtractedDensity.df <- ExtractedDensity.df[ -c(5:8) ]
filename <- gsub("  ", "", paste("aExtractedDensity", experiment, types[1], types[2], types[3], ".csv", sep="  "))
write.csv(ExtractedDensity.df, file = filename)

ExtractedRawC3.df <- ExtractedRawC3.df[ -c(1:4) ]
filename <- gsub("  ", "", paste("aExtractedRawC3", experiment, types[1], types[2], types[3], ".csv", sep="  "))
write.csv(ExtractedRawC3.df, file = filename)

ExtractedRawC1C2.df <- ExtractedRawC1C2.df[ -c(1:4) ]
filename <- gsub("  ", "", paste("aExtractedRawC1C2", experiment, types[1], types[2], types[3], ".csv", sep="  "))
write.csv(ExtractedRawC1C2.df, file = filename)

ExtractedRawWg.df <- ExtractedRawWg.df[ -c(1:4) ]
filename <- gsub("  ", "", paste("aExtractedRawWg", experiment, types[1], types[2], types[3], ".csv", sep="  "))
write.csv(ExtractedRawWg.df, file = filename)

