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
site_info$code
#Add | in site_info$code "or term"
patt <- paste(site_info$code, collapse = "|") 
patt <- "ae|ib|su|ng|jr"
# Choose file wich contains patt
dirs <- grep(pattern = patt, dirs, value = TRUE) 

#load sampling info
# read.csv("/data/outputs/sp_type.csv") 
sp_type <- read.csv(paste0(base_dir, "/", "sp_type.csv"), header= TRUE)
#Select files wich contain fmr
# samp_files <- grep("fmr", list.files(base_dir, pattern = "csv", full.names = TRUE), value = TRUE) 
# #lapply function return list
# samps <- lapply(samp_files, read.csv) 
# #Put col on right place
# samps[[3]][3] <- samps[[3]][4] 
# samps[[2]][3] <- samps[[2]][4]
# 
# #Rename site
# samps[[4]]$Site <- gsub("Aéroport_P1","Aeroport",samps[[4]]$Site)
# samps[[4]]$Site <- gsub("Surprise_P2","Surprise",samps[[4]]$Site)  
# samps[[2]]$Site <- gsub("sakouli","Sakouli",samps[[2]]$Site)
# #lapply(samps, ncol)
# 
# samplings <- do.call(rbind, samps)
# 
# #cleaning
# samplings$Site <- gsub("é", "e", samplings$Site)
# samplings$Site <- gsub("'", "", samplings$Site)
# samplings$Name <- gsub("Tag ","tag_", samplings$Name)
# samplings <- samplings[substr(samplings$Name,1,4) == "tag_",] #keep only colonies
# samplings$Name <- gsub("tag_","", samplings$Name)
# samplings$Espèce <- str_to_sentence(samplings$Espèce)
# sp_type$genus_sp <- str_to_sentence(sp_type$genus_sp)
# samplings <- drop_na(samplings)

samplingsfile <- read.csv("samplings.csv", header = TRUE)
if (file.exists("data.csv")) {
  data <- read.csv("data.csv")
  dirs<- dirs[!is.element(dirs,data$id)]
  data <- load("gallery/mod_urls.RData")
}
#d = dirs[1:6]
iteration = dirs[1:4]
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

  sketch_tok <- read.table("gallery/sketchfab_api_token.txt")[1,1]

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
