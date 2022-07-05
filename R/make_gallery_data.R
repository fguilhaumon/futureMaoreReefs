

make_gallery_data <- function() {
  
  #list meta_data files
  base_dir = "/data/fmr_data/meta_data"
  data      <- lapply(list.files(base_dir, full.names = TRUE, recursive = FALSE),read.csv)
  colnames(data[[2]]) <- c( "date" ,    "site",     "name",     "x",        "y",        "z",        "species",  "observer", "note")
  data      <- do.call(rbind, data)
  # Find and replace
  data$name <- gsub("Tag ","tag_", data$name)
  #Select row with tag
  data      <- data[grep("tag_",data$name),]
  data$date <- substr(data$date, 1, 10)
  #Change date format
  data$date <- strftime(strptime(data$date, "%m/%d/%Y", tz = "UTC"),"%d/%m/%Y")
  dates <- sapply(strsplit(gg$date, " "), "[[", 1)
  as.Date(dates)
  
  
  
  
}