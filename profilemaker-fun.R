##profilemaker function to simplify the GOLLUMputtogether script
##date: 16/3/2022


profilemaker <- function(Mask) {
  #create empty dataframes
  Intensitydf <- data.frame()
  Intensityeven <- data.frame()
  
  #the key! converts your list to a dataframe
  Intensitydf <- as.data.frame(ALLfiles)
  col_even <- seq_len(ncol(Intensitydf)) %% 2
  Intensityeven <- Intensitydf[,col_even == 0]
  Intensitydf2 <- cbind(Intensitydf[,1],Intensityeven)
  
  #normalization!
  ncol=ncol(Intensitydf2)
  
  for (i in 2:ncol) {
    m <- max(Intensitydf2[,i], na.rm = TRUE)
    Intensitydf2[13,i] <- m
    
    for (x in 1:11) {
      ##11 because that should always be the number of rows originally from profiles
      Intensitydf2[x+15,i] <- Intensitydf2[x,i]/Intensitydf2[13,i]
      }
    }
  
  #averaging normalised values (ignoring column one)
  for (x in 16:26) {
    Intensitydf2[x+23,2] <- rowMeans(Intensitydf2[x,2:ncol], na.rm = T)
    }
  
  #and now we invert! create a "test" vector and then place the values back where they should go
  test <- as.vector(Intensitydf2[39:49,2])
  for (z in 1:11) {
    Intensitydf2[39-z,2] <- test[z]
    }
  
  filename <- gsub("  ", "", paste(Mask, image, "RadialProfiles.csv", sep="  "))
  print(filename) #this can be skipped to make it run faster, but it helps identify any problems when running batch mode
  write.csv(Intensitydf2, file = filename)
}