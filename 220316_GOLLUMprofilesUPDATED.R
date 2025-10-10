## for experiments using GOLLUM.

#To make it even less painful copy all the folder names into a csv file, then run:
setwd("/Users/alvarei/Dropbox (The Francis Crick)/Ines Lab Data/microscope/analysis/dunn school sora ring analysis/GOLLUM/profiles/")
names <- read.csv("names.csv", header = T)

channel <- "C2-"

for (n in 1:nrow(names)){
image <- names[n,3] #because the names happen to be in the 3rd row!

#the rest will be automated ---> IF YOU HAVE DIFFERENT TYPES OF MASKS, GO DOWN TO THE END!

#####1) FUNCTION CALLING
## this is a new version of the profile making script which uses a profilemaking function described in a different script.
# it includes calculating the average of all the profiles and mirroing that
#because this is in the macro folder, we need load that function first.
source("/Users/alvarei/Dropbox (The Francis Crick)/Ines Lab Data/microscope/macros/profilemaker-fun.R")
source("/Users/alvarei/Dropbox (The Francis Crick)/Ines Lab Data/microscope/macros/profilebinder-fun.R")

library(readxl)
library(dplyr)

####2) SETTING DIRECTORY
#paste function puts together strings but there needs to have some sort of separator,
#so we use a value that is not going to be present in anything else and then we remove it with gsub
#in this case the value is space-space

dir <- gsub("  ", "", paste("/Users/alvarei/Dropbox (The Francis Crick)/Ines Lab Data/microscope/analysis/dunn school sora ring analysis/GOLLUM/profiles/",
                            image, sep="  "))
setwd(dir)

### 3) READ & APPLY
# first the Filtered profiles, then the Removed, then anything else (turned ON in principle)

file.list <- list.files(pattern = paste(channel, "FiltMask", sep=""))
file.list
#read all the files you have selected
ALLfiles <- lapply(file.list,function(i){
  read.table(i, header=TRUE)
})
profilemaker(paste(channel, "FiltMask", sep=""))

### and now repeat for the removed objects

file.list <- list.files(pattern = paste(channel, "RmvdMask", sep=""))
file.list
ALLfiles <- lapply(file.list,function(i){
  read.table(i, header=TRUE)
})
profilemaker(paste(channel, "RmvdMask", sep=""))

###OTHERS

 # file.list <- list.files(pattern = "RadialFC2Mask")
 # file.list
 # ALLfiles <- lapply(file.list,function(i){
 #   read.table(i, header=TRUE)
 # })
 # profilemaker("RadialFC2Mask")
 # 
 # file.list <- list.files(pattern = "NotinC2Mask")
 # file.list
 # ALLfiles <- lapply(file.list,function(i){
 #   read.table(i, header=TRUE)
 # })
 # profilemaker("NotinC2Mask")

}

### 4) PUT TOGETHER ALL THE PROFILES!

dir <- "/Users/alvarei/Dropbox (The Francis Crick)/Ines Lab Data/microscope/analysis/dunn school sora ring analysis/GOLLUM/profiles/"
setwd(dir)

Mask <- paste(channel, "FiltMask.+RadialProfiles", sep="")
profileBinder(Mask)
Mask <- paste(channel, "RmvdMask.+RadialProfiles", sep="")
profileBinder(Mask)