

make_gallery_data <- function() {
  ####
  #making data contains species name, site name, tag
  # base_dir = "/data/fmr_data/meta_data"
  # data      <- lapply(list.files(base_dir, full.names = TRUE, recursive = FALSE),read.csv)
  # colnames(data[[2]]) <- c( "date" ,    "site",     "name",     "x",        "y",        "z",        "species",  "observer", "note")
  # data      <- do.call(rbind, data)
  # # Find and replace
  # data$name <- gsub("Tag ","tag_", data$name)
  # #Select row with tag
  # data      <- data[grep("tag_",data$name),]
  # data$name <- gsub("tag_","",data$name)
  # data$date <- substr(data$date, 1, 10)
  # #Change date format
  # data$date <- strftime(strptime(data$date, "%m/%d/%Y", tz = "UTC"),"%d/%m/%Y")
  # #Put species name in right format
  # data$species <- stringr::str_to_sentence(data$species)
  # 
  # write.csv(data, file = "data/data.csv", row.names = FALSE)
  ####
  #read data with species site, name
  data <- read.csv("data/data.csv")
  # read data site with code of model files, species type and dictionary
  site_info <- read.csv("data/metadonnees.csv", header = TRUE)
  #root dir
  #sp_type <- read.csv("/data/colonies_stageMateo/overall_sp_sites_mayotte.csv")
  sp_type <- read.csv("data/speciestype.csv")
  base_dir <- "/data/outputs"
  #
  french_site <- read.csv("data/french_site.csv")
  #list dirs in root_dir
  dirs <- list.dirs(base_dir, full.names = FALSE, recursive = FALSE)
  
  #select only sites to upload
  
  #Add | in sites "or term"
  sites = c("ae", "ib", "su", "ng", "jr")
  patt <- paste(sites, collapse = "|") 
  #patt <- "ae|ib|su|ng|jr"
  # Choose file wich contains patt
  dirs <- grep(pattern = patt, dirs, value = TRUE) 
  #there is not ng_022022_2 in data/data.csv
  dirs <- dirs[dirs!= "ng_022022_2"]
  ####
  if (file.exists("data/data_uploaded.csv")){
    data_uploaded <- read.csv("data/data_uploaded.csv")
    dirs <- dirs[!is.element(dirs, data_uploaded$file)] 
    message("oui ce if marche")
  }
  #list meta_data files
  res <- do.call(rbind, lapply(dirs, function(d) {
    #d = "ae1_022022_1"

    
    # Find .obj and texture
    model_path <- paste0("/data/outputs/",d)
    
    obj_path <- grep("model.obj", list.files( paste0("/data/outputs/",d), full.names = TRUE), value = TRUE) # TODO Put in upload models find the path with the model_path above
    texture_path <- grep("model.jpg",list.files( paste0("/data/outputs/",d), full.names = TRUE), value = TRUE)
    # TODO add .mtl
    #Split elements
    strings <- strsplit(d, "_")[[1]] 
    #name columns
    names(strings) <- c("site", "sampling", "colony_number") 
    #take only code part like "ae"
    strings["site"] <- substr(strings["site"], 1, 2) 
    #site name to have the specie name
    site_name <-  site_info$site[site_info$code == strings["site"]]
    #site name in english data is in english
    site_name_en <- french_site$type_en[french_site$type_fr == site_name]
    sp_name <- subset(data, site == site_name_en & name == strings['colony_number'])["species"]
    sp_name <- sp_name$species
    if (sp_name == "Acropora.Sp"){
      message("acropora")
      type <- "competitive"
    }
    if (sp_name == "Favia.Sp"){
      message("favia")
      type <- "stress-tolerant"
    }
    if((sp_name != "Acropora.Sp")&(sp_name != "Favia.Sp")){
      type <- subset(sp_type, genus_sp == sp_name)
      type <- type$LHT
    }
    
    
    mod_desc_char <- paste0('This ',type, ' coral colony is monitored at the "',site_name_en, '" site of Mayotte')
    message(d)
    message(length(d))
    message(length(model_path))
    message(sp_name)
    message(length(site_name_en))
    message(type)
    message(length(mod_desc_char))
    
    return(data.frame(d, model_path, sp_name, site_name_en, type, mod_desc_char))
  }))
  return(res)
  write.csv(res, file = "data/model_upload_data.csv", row.names = FALSE)
  }
  
  
  
  
  

