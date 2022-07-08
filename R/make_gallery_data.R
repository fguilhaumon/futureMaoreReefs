

make_gallery_data <- function(sites = c("ae", "ib", "su", "ng", "jr")) {
  ####
  out_dir <- "outputs/make_gallery_data"
  if (!dir.exists("outputs/make_gallery_data")){
    base_dir <- "/data/fmr_data/meta_data"
    data      <- lapply(list.files(base_dir, full.names = TRUE, recursive = FALSE), read.csv)
    data      <- do.call(rbind, data)
    #Select row with tag
    data      <- data[grep("tag_",data$name),]
    data$id <- gsub("tag_","",data$name)
    data$date <- substr(data$date, 1, 10)
    #Change date format
    data$date <- strftime(strptime(data$date, "%m/%d/%Y", tz = "UTC"),"%d/%m/%Y")
    #Put species name in right format
    data$species <- stringr::str_to_sentence(data$species)
    data$site_id <- substr(data$site, 1, 2)
    data$site_id[data$site_id == "il"] <- "ib"
    data$site_id[data$site_id == "jo"] <- "jr"
    data$site_id[data$site_id == "ai"] <- "ae"
    
    data$species[data$species == "Ac. Sp"] <- "Acropora sp."
    data$species[data$species == "Pori. cylind."] <- "Porites cylindrica"
    data$species[grepl("/", data$species)] <- sapply(data$species[grepl("/", data$species)], function(x) strsplit(x, split = "/")[[1]][1])
    
    dir.create("outputs", showWarnings = FALSE)
    
    dir.create(out_dir, showWarnings = FALSE)
    
    write.csv(data, file = file.path(out_dir, "field_data.csv"), row.names = FALSE)
    
  }
  #making filed meta data contains species name, site name, tag ...
  
  # read data site with code of model files, species type and dictionary
  site_info <- read.csv("data/site_metadata.csv", header = TRUE)
  species_type <- read.csv("data/species_type.csv", header = TRUE)
  
  #list dirs in root_dir
  dirs <- list.dirs("/data/outputs", full.names = FALSE, recursive = FALSE)
  
  #select only sites to upload
  patt <- paste(sites, collapse = "|") 
  #patt <- "ae|ib|su|ng|jr"
  # Choose file wich contains patt
  dirs <- grep(pattern = patt, dirs, value = TRUE)
  
  #there is not ng_022022_2 in data/data.csv
  dirs <- dirs[dirs != "ng_022022_2"]
  
  ####
  if (file.exists("outputs/upload_models/data_uploaded.csv")){
    data_uploaded <- read.csv("outputs/upload_models/data_uploaded.csv")
    dirs <- dirs[!is.element(dirs, data_uploaded$d)] 
    
    model_upload_data <- read.csv(file.path(out_dir, "model_upload_data.csv"))
    data <- read.csv("outputs/make_gallery_data/field_data.csv")
  }
  
  #list meta_data files
  res <- do.call(rbind, lapply(dirs, function(d) {
    #d = "ae1_022022_1"

    # Find .obj and texture
    model_path <- paste0("/data/outputs/", d)
    
    # obj_path <- grep("model.obj", list.files(model_path, full.names = TRUE), value = TRUE) # TODO Put in upload models find the path with the model_path above
    # texture_path <- grep("model.jpg", list.files(model_path, full.names = TRUE), value = TRUE)
    # mtl_path <- grep("model.mtl", list.files(model_path, full.names = TRUE), value = TRUE)
    
    #Split elements
    strings <- strsplit(d, "_")[[1]]
    #name columns
    names(strings) <- c("site", "sampling", "colony_number") 
    #take only code part like "ae"
    strings["site"] <- substr(strings["site"], 1, 2) 

    #site name to have the specie name
    site_name_fr <- site_info$site_fr[site_info$site_id == strings["site"]]
    #site name in english data is in english
    site_name_en <- site_info$site_en[site_info$site_id == strings["site"]]
    
    sp_name <- subset(data, site_id == strings["site"] & id == strings["colony_number"])[, "species"]
    
    if (sp_name == "Acropora sp."){
      message("Acropora sp. gets the competitive type")
      type <- "competitive"
    }
    
    if (sp_name == "Favia sp."){
      message("Favia sp. gets the stress-tolerant type")
      type <- "stress-tolerant"
    }
    
    if(!(sp_name %in% c("Acropora sp.", "Favia sp."))){
      type <- subset(species_type, genus_sp == sp_name)$LHT
    }
    
    
    type_dic <- data.frame(type_en = c("competitive", "stress-tolerant", "generalist", "weedy"),
                                  type_fr = c("compétitif", "robuste", "généraliste", "opportuniste"))
    
    mod_desc_char_en <- paste0('This ',type, ' coral colony is monitored at the "', site_name_en, '" site of Mayotte')
    mod_desc_char_fr <- paste0('Cette colonie corallienne de type ', type_dic$type_fr[type_dic$type_en == type], ' est suivie au site "', site_name_fr, '"')
    
    return(data.frame(d, model_path, sp_name, site_id =  strings["site"], type, mod_desc_char_en, mod_desc_char_fr))
  }))
  
  if (file.exists("outputs/make_gallery_data/model_upload_data.csv")){
    #res <- rbind(model_upload_data, res)
    message(length(res$d))
    
    res <- rbind(model_upload_data,res[!(res$d %in% model_upload_data$d)])
    message(!(res$d %in% model_upload_data$d))
    message((res$d %in% model_upload_data$d))
    message(res[!(res$d %in% model_upload_data$d)])
    message(res[!(res$d %in% model_upload_data$d),])
    message(length(res$d))
    
  }
  
  write.csv(res, file = file.path(out_dir, "model_upload_data.csv"), row.names = FALSE)
  
  invisible(res)
  
}
  
  
  
  
  

