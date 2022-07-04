# Increase capacity
options(max.print = 2000)



upload_models <- function() {
  
  #load site infos
  site_info <- read.csv("data/metadonnees.csv", header = TRUE)
  #root dir
  base_dir <- "/data/outputs"
  
  #list dirs in root_dir
  dirs <- list.dirs(base_dir, full.names = FALSE, recursive = FALSE)
  
  #select only sites in site_info
  #site_info$code
  #Add | in site_info$code "or term"
  patt <- paste(site_info$code, collapse = "|") 
  patt <- "ae|ib|su|ng|jr"
  # Choose file wich contains patt
  dirs <- grep(pattern = patt, dirs, value = TRUE) 
  #Load samplings info
  samplingsfile <- read.csv("samplings.csv", header = TRUE)
  
  #Condition
  dirs <- dirs[1:15] #TODO remove this line for production
  
  
  if (file.exists("gallery/mod_urls.RData")) {
    #Load data in mod_urls.RData
    load("gallery/mod_urls.RData") #TODO change obj name to mod_urls
    #Select files wich are not in mod_urls.RData
    dirs <- dirs[!is.element(dirs, mod_urls$d)] #TODO replace "data" with "mod_urls"
  }#eo if file.exists
  
  if (length(dirs) == 0){
      message("no new model to upload !")
      return()
  }

  res <- do.call(rbind, lapply(dirs, function(d) {
        #d = "ae1_022022_9"
        # Iteration sur les dirs de outputs (avec regles de selection)
        
        # Find .obj and texture
        obj_path <- grep("model.obj", list.files( paste0(base_dir,"/",d), full.names = TRUE), value = TRUE)
        texture_path <- grep("model.jpg",list.files( paste0(base_dir,"/",d), full.names = TRUE), value = TRUE)
        
        #Split elements
        strings <- strsplit(d, "_")[[1]] 
        #name columns
        names(strings) <- c("site", "sampling", "colony_number") 
        #Take only code part like "ae"
        strings["site"] <- substr(strings["site"], 1, 2) 
        site_name <-  site_info$site[site_info$code == strings["site"]]
        sp_name <- subset(samplingsfile, Site == site_name & Name == strings['colony_number'])["Espèce"]
        sp_name <- sp_name$Espèce
        
        
        # zip des model.obj et .jpeg
        #cherry-pick allows you to zip files with differents paths see relative path's doc
        zip_char <- paste0(d, ".zip")
        zip::zip(zipfile = zip_char, c(obj_path,texture_path), mode = "cherry-pick")
        
        
        # install requests python module
        #reticulate::py_install("requests", pip = TRUE)
        
        reticulate::source_python("gallery/sketchfab_data_api.py")
        
        sketch_tok <- readLines("gallery/sketchfab_api_token.txt", n = 1)
        
        #mod_name <- paste0()
        
        mod_url <- upload(mod_path = reticulate::r_to_py(zip_char),
                          mod_name = reticulate::r_to_py(sp_name), #TODO update mod_name with site name and colony number
                          api_token = reticulate::r_to_py(sketch_tok) )
        
        #save url !!!!!!!
        
        unlink(zip_char)
        #write.table(mod_url, file= "data.csv", append = TRUE, sep = "\t", col.names = FALSE)
        
        resultat <- data.frame(d, mod_url)
        
        # names(resultat) <- names(data)
        
        print(sp_name)
        print(resultat)
        return(resultat)
      
    }))
      
     
    if (file.exists("gallery/mod_urls.RData")) {
      mod_urls <- rbind(mod_urls, res)
    } else {
      mod_urls <- res
    }
  
    save(mod_urls, file = "gallery/mod_urls.RData")

    return(mod_urls)
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

