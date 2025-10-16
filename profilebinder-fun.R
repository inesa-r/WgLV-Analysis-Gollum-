#after the profiles, to put them all together and copy directly onto prism.

profileBinder <- function(Mask) {
  file.list <- list.files(path = dir, pattern = Mask, recursive = T, include.dirs = F) ## this scans for all the files including the subfolders
  file.list
  #read all the files you have selected
  
  Intensitydf <- data.frame()
  Holddf <- data.frame()
  
  ALLfiles <- lapply(file.list,function(i){
    read.csv(i, header=TRUE)
  })
  
  #create dataframe from the first file
  
  Holddf <- as.data.frame(ALLfiles[1])
  Intensitydf <- (Holddf[,1:3])
  
  # then add all the relevant columns from the other files
  for (i in 2:length(file.list)) {
    Holddf <- as.data.frame(ALLfiles[i])
    Intensitydf <- cbind(Intensitydf,Holddf[,3])
  }
  
  # remove the rest of the data that is not interesting
  x <- length(file.list) + 2
  
  Intensitydf <- subset(Intensitydf[28:49,3:x])
  
  # rename and write
  names(Intensitydf) <- file.list
  
  filename <- gsub("  ", "", paste(Mask, "ALLRadialProfiles.csv", sep="  "))
  write.csv(Intensitydf, file = filename)
  
}