col_dirs <- list.dirs("/data/outputs/", recursive = FALSE)
tableau <- array()

do.call(rbind,lapply(col_dirs, function(i) {
 
  file <- list.files(i, pattern = "model.obj",full.names = TRUE)
 
  fil <- list.files(i, pattern = "model.obj",full.names = FALSE)
  size <- file.size(file)
  
  res <- size/(10**6)
 d<- data.frame(file = fil, size = res ,stringsAsFactors = FALSE)
  
  
 
  
}))


for (i in col_dirs) {
  
  file <- list.files(i, pattern = "model.obj",full.names = TRUE)
  
  fil <- list.files(i, pattern = "model.obj",full.names = FALSE)
  size <- file.size(file)
  
  res <- size/(10**6)
  d<- rbind(d,data.frame(file = fil, size = res ,stringsAsFactors = FALSE)) 
}

for (i in d) {
  ifelse(d["size"] <=50.0,print(d["fil"]),print(""))
}
   

