# Increase capacity
options(max.print=2000)
#load site infos
site_info <- read.csv("data/metadonnees.csv", header= TRUE)
#library
#library(stringr)
#root dir
base_dir <- "/data/outputs"

#list dirs in root_dir
dirs <- list.dirs(base_dir, full.names = FALSE, recursive = FALSE)

#select only sites in site_info

#Add | in site_info$code "or term"
patt <- paste(site_info$code, collapse = "|") 
# Choose file wich contains patt
dirs <- grep(pattern = patt, dirs, value = TRUE) 

#load sampling info
# read.csv("/data/outputs/sp_type.csv") 
sp_type <- read.csv(paste0(base_dir, "/", "sp_type.csv"), header= TRUE)
#Select files wich contain fmr
samp_files <- grep("fmr", list.files(base_dir, pattern = "csv", full.names = TRUE), value = TRUE) 
#lapply function return list
samps <- lapply(samp_files, read.csv) 
#Put col on right place
samps[[3]][3] <- samps[[3]][4] 
samps[[2]][3] <- samps[[2]][4]

#Rename site
samps[[4]]$Site <- gsub("Aéroport_P1","Aeroport",samps[[4]]$Site)
samps[[4]]$Site <- gsub("Surprise_P2","Surprise",samps[[4]]$Site)  
samps[[2]]$Site <- gsub("sakouli","Sakouli",samps[[2]]$Site)
#lapply(samps, ncol)

samplings <- do.call(rbind, samps)

#cleaning
samplings$Site <- gsub("é", "e", samplings$Site)
samplings$Site <- gsub("'", "", samplings$Site)
samplings$Name <- gsub("Tag ","tag_", samplings$Name)
samplings <- samplings[substr(samplings$Name,1,4) == "tag_",] #keep only colonies
samplings$Name <- gsub("tag_","", samplings$Name)
samplings$Espèce <- tolower(samplings$Espèce)
sp_type$genus_sp <- tolower(sp_type$genus_sp)



col_paths <- list.files("/data/colonies_stageMateo/cap_ecran_colonies", recursive = TRUE, full.names = TRUE)


res <- lapply(dirs, function(d) {
  # Iteration sur les dirs de outputs (avec regle s de selection)
  #d = dirs[1:6]  
  # Find .obj and texture
  obj_path <-   grep("model.obj",list.files( paste0(base_dir,"/",dirs[1]), full.names = TRUE), value= TRUE)
  texture_path <-   grep("model.jpg",list.files( paste0(base_dir,"/",dirs[1]), full.names = TRUE), value= TRUE)
  #Split elements
  strings <- strsplit(d, "_")[[1]] 
  #name columns
  names(strings) <- c("site", "sampling", "colony_number") 
  #Take only code part like "ae"
  strings["site"] <- substr(strings["site"], 1, 2) 
  
  site_name <-  site_info$site[site_info$code == strings["site"]]
  
  
  
  #init variables
  session <- "session1"
  #Find species Name with tag
  
  sp_name <- subset(samplings, Site == site_name & Name == strings['colony_number'])["Espèce"]
  sp_name <- sp_name$Espèce
  sp_name_maj <- stringr::str_to_title(sp_name)
  #Find type with species name
  type <- subset(sp_type, genus_sp == sp_name)
  type <- type$LHT

  
# zip des model.obj et .jpeg
#cherry-pick allows you to zip files with differents paths see relative path's doc
  zip_char <- paste0(d,".zip")
  obj <- list.dirs(d, full.names = FALSE, recursive = FALSE)
  zip::zip(zipfile = zip_char ,c(obj_path,texture_path), mode = "cherry-pick")
  
  
# install requests python module
#reticulate::py_install("requests", pip = TRUE)


  reticulate::source_python("gallery/sketchfab_data_api.py")

  sketch_tok <- readLines("gallery/sketchfab_api_token.txt", n = 1)

  mod_url <- upload(mod_path = reticulate::r_to_py(zip_char),
                  mod_name = reticulate::r_to_py(sp_name_maj),
                  api_token = reticulate::r_to_py(sketch_tok) )

#save url !!!!!!!


  
 unlink(zip_char)
 #write.table(mod_url, file= "data.csv", append = TRUE, sep = "\t", col.names = FALSE)
 return(mod_url)
})

save(res, file = "gallery/mod_urls.RData")