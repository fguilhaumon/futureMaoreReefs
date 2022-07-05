

upload_models <- function(sites = c("ae", "ib", "su", "ng", "jr"), data) {
  
  #sites = c("ae", "ib", "su", "ng", "jr")
  print(data)
  #load site infos
  site_info <- read.csv("data/metadonnees.csv", header = TRUE)
  #root dir
  #sp_type <- read.csv("/data/colonies_stageMateo/overall_sp_sites_mayotte.csv")
  sp_type <- read.csv("data/speciestype.csv")
  base_dir <- "/data/outputs"
  french_site <- read.csv("data/french_site.csv")
  #list dirs in root_dir
  dirs <- list.dirs(base_dir, full.names = FALSE, recursive = FALSE)
  
  #select only sites in site_info
  #site_info$code
  #Add | in site_info$code "or term"
  
  patt <- paste(sites, collapse = "|") 
  #patt <- "ae|ib|su|ng|jr"
  # Choose file wich contains patt
  dirs <- grep(pattern = patt, dirs, value = TRUE) 
  #Load samplings info
  #samplingsfile <- read.csv("samplings.csv", header = TRUE)
  
  #Condition
  dirs <- dirs[1:4] #TODO remove this line for production
  
  
  if (file.exists("gallery/model.RData")) {
    message("Je passe")
    #Load data in mod_urls.RData
    load("gallery/model.RData", envir = globalenv()) 
    #Select files wich are not in mod_urls.RData
    dirs <- dirs[!is.element(dirs, model$d)] 
  }#eo if file.exists
  
  if (length(dirs) == 0){
      message("no new model to upload !")
      return()
  }

  res <- do.call(rbind, lapply(dirs, function(d) {
        #d = "ae1_022022_1"
        # Iteration sur les dirs de outputs (avec regles de selection)
        
        # Find .obj and texture
        obj_path <- grep("model.obj", list.files( paste0(base_dir,"/",d), full.names = TRUE), value = TRUE)
        texture_path <- grep("model.jpg",list.files( paste0(base_dir,"/",d), full.names = TRUE), value = TRUE)
        #add .mtl
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
        type <- subset(sp_type, genus_sp == sp_name)
        type <- type$LHT
        mod_desc_char <- paste0('This ',type, ' coral colony is monitored at the "',site_name_en, '" site of Mayotte')
        # zip des model.obj et .jpeg
        #cherry-pick allows you to zip files with differents paths see relative path's doc
        zip_char <- paste0(d, ".zip")
        zip::zip(zipfile = zip_char, c(obj_path,texture_path), mode = "cherry-pick")
        
        
        # install requests python module
        #reticulate::py_install("requests", pip = TRUE)
        
        #reticulate::source_python("gallery/sketchfab_data_api.py")
        
        #sketch_tok <- readLines("gallery/sketchfab_api_token.txt", n = 1)
        
        #mod_name <- paste0()
        
        #mod_url <- upload(mod_path = reticulate::r_to_py(zip_char),
                          # mod_name = reticulate::r_to_py(sp_name), #TODO update mod_name with site name and colony number
                          # api_token = reticulate::r_to_py(sketch_tok),
                          # mod_desc  = reticulate::r_to_py(mod_desc))
        
        #save url !!!!!!!
        print(zip_char)
        source("gallery/sketchfab_api.R")
        model <- upload_model(mod_path = zip_char, mod_name = sp_name, mod_desc = mod_desc_char, mod_tags = array("corals"))
        unlink(zip_char)
        #write.table(mod_url, file= "data.csv", append = TRUE, sep = "\t", col.names = FALSE)
        
        model <- data.frame(d, model)
        
        # names(resultat) <- names(data)
        
        print(sp_name)
        print(resultat)
        return(resultat)
      
    }))
      
     
    if (file.exists("gallery/model.RData")) {
      model <- rbind(model, res)
    } else {
      model <- res
    }
  
    save(model, file = "gallery/model.RData")
    message("fin de la fonction")
    return()
}#eo upload_models

clean_models <- function() {
  
  mods <- sapply(list_my_models(api_token = reticulate::r_to_py(sketch_tok)), "[[", "uri")

  while(length(mods) != 0) {
    
    for (i in 1:length(mods)) {
    message("deleting model: ", mods[i])
        
      del_model(model_url = reticulate::r_to_py(mods[i]), api_token = reticulate::r_to_py(sketch_tok))
      Sys.sleep(2)
    }
    
    mods <- sapply(list_my_models(api_token = reticulate::r_to_py(sketch_tok)), "[[", "uri")
  }  
  
  
  
}#eo clean_models

