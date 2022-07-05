

make_gallery_data <- function() {
  
  #list meta_data files
  base_dir = "/data/fmr_data"
  file <- list.dirs(base_dir, full.names = TRUE, recursive = FALSE)
  data  <- lapply(file, function(){
    
    
    
  })
  gg <- read.csv("/data/fmr_data/meta_data/fmr_jollyroger_23022022.csv")
  
  dates <- sapply(strsplit(gg$date, " "), "[[", 1)
  as.Date(dates)
  
  
  
  
}