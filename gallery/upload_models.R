# Increase capacity
options(max.print=2000)
#load site infos
site_info <- read.csv("data/metadonnees.csv", header= TRUE)
#root dir
base_dir <- "/data/outputs"

#list dirs in root_dir
dirs <- list.dirs(base_dir, full.names = FALSE, recursive = FALSE)

#select only sites in site_info
site_info$code
#Add | in site_info$code "or term"
patt <- paste(site_info$code, collapse = "|") 
patt <- "ae|ib|su|ng|jr"
# Choose file wich contains patt
dirs <- grep(pattern = patt, dirs, value = TRUE) 
#Load samplings info
samplingsfile <- read.csv("samplings.csv", header = TRUE)

#Condition
iteration = dirs[1:12]
if (file.exists("gallery/mod_urls.RData")) {
  #Load data in mod_urls.RData
  load("gallery/mod_urls.RData")
  #Select files wich are not in mod_urls.RData
  iteration<- iteration[!is.element(iteration,data$d)]
  if (length(iteration)==0){
    print("lol")
    
  }
  else {
      print("1er else")
      new_res<- do.call(rbind,res <- lapply(iteration, function(d) {
        # Iteration sur les dirs de outputs (avec regles de selection)
        
        
        # Find .obj and texture
        obj_path <-   grep("model.obj",list.files( paste0(base_dir,"/",d), full.names = TRUE), value= TRUE)
        texture_path <-   grep("model.jpg",list.files( paste0(base_dir,"/",d), full.names = TRUE), value= TRUE)
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
        zip_char <- paste0(d,".zip")
        zip::zip(zipfile = zip_char ,c(obj_path,texture_path), mode = "cherry-pick")
        
        
        # install requests python module
        #reticulate::py_install("requests", pip = TRUE)
        
        
        reticulate::source_python("gallery/sketchfab_data_api.py")
        
        sketch_tok <- readLines("gallery/sketchfab_api_token.txt", n = 1)
        
        mod_url <- upload(mod_path = reticulate::r_to_py(zip_char),
                          mod_name = reticulate::r_to_py(sp_name),
                          api_token = reticulate::r_to_py(sketch_tok) )
        
        #save url !!!!!!!
        
        
        
        unlink(zip_char)
        #write.table(mod_url, file= "data.csv", append = TRUE, sep = "\t", col.names = FALSE)
        
        resultat <- data.frame(d,mod_url)
        
        # names(resultat) <- names(data)
        
        
        print(sp_name)
        print(resultat)
        return(resultat)
      
    }))
    data <- rbind(data,new_res)
    save(data, file = "gallery/mod_urls.RData")
  }
 
} else {
  print("2eme else")
  new_res<- do.call(rbind,res <- lapply(iteration, function(d) {
    # Iteration sur les dirs de outputs (avec regles de selection)
    
    
    # Find .obj and texture
    obj_path <-   grep("model.obj",list.files( paste0(base_dir,"/",d), full.names = TRUE), value= TRUE)
    texture_path <-   grep("model.jpg",list.files( paste0(base_dir,"/",d), full.names = TRUE), value= TRUE)
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
    zip_char <- paste0(d,".zip")
    zip::zip(zipfile = zip_char ,c(obj_path,texture_path), mode = "cherry-pick")
    
    
    # install requests python module
    #reticulate::py_install("requests", pip = TRUE)
    
    
    reticulate::source_python("gallery/sketchfab_data_api.py")
    
    sketch_tok <- readLines("gallery/sketchfab_api_token.txt", n = 1)
    
    mod_url <- upload(mod_path = reticulate::r_to_py(zip_char),
                      mod_name = reticulate::r_to_py(sp_name),
                      api_token = reticulate::r_to_py(sketch_tok) )
    
    #save url !!!!!!!
    
    
    
    unlink(zip_char)
    #write.table(mod_url, file= "data.csv", append = TRUE, sep = "\t", col.names = FALSE)
    
    resultat <- data.frame(d,mod_url)
    
    # names(resultat) <- names(data)
    
    
    print(sp_name)
    return(resultat)
    
  }))
  data <- rbind(data,new_res)
  save(data, file = "gallery/mod_urls.RData")
}



