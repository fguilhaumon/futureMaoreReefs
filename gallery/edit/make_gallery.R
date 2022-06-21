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
  
  #d = dirs[6]  
  
  #Split elements
  strings <- strsplit(d, "_")[[1]] 
  #name columns
  names(strings) <- c("site", "sampling", "colony_number") 
  #Take only code part like "ae"
  strings["site"] <- substr(strings["site"], 1, 2) 
  
  site_name <-  site_info$site[site_info$code == strings["site"]]
  
  #qmd !!!!
  
  # ---
  # title: "Type d'espèce"
  # subtitle: "Localisation de l'espèce ex : Ile blanche"
  # image: cover/cover.jpg
  # author: "Joseph"
  # description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum tincidunt nisi sapien, id ornare ligula fringilla at. In eget lacus eros. In quis laoreet magna. Duis suscipit mollis porta. In hac habitasse platea dictumst. Morbi in tempor orci. Fusce augue purus, gravida et felis quis, tincidunt finibus erat."
  # date: 05/06/2022
  # categories : ["Competitif","Ngouja","Session1"]
  # reading-time: true
  # ---
  
  #init variables
  session <- "session1"
  #Find species Name with tag
  
  sp_name <- subset(samplings, Site == site_name & Name == strings['colony_number'])["Espèce"]
  sp_name <- sp_name$Espèce
  sp_name_maj <- stringr::str_to_title(sp_name)
  #Find type with species name
  type <- subset(sp_type, genus_sp == sp_name)
  type <- type$LHT
  longitude <- subset(site_info, site == site_name)$longitude
  #longitude <- longitude$longitude
  latitude <- subset(site_info, site == site_name)$latitude
  #latitude <- latitude$latitude
  #Creating name file and path's file
  qmd_file_name <- paste0(strings["site"], "_", session, "_", sp_name, "_", type, ".qmd")
  qmd_file_path <- paste0("gallery/", strings["site"], "/", qmd_file_name)
  
  #Editing file
  write("---", file = qmd_file_path, append = TRUE)
  #Init variables
  title_char <- paste0('title: "', sp_name_maj, '"')
  subtitle_char <- paste0('subtitle: "', "sous titre", '"')
  image_char <- paste0("image: ", grep(d, col_paths, value = TRUE))
  description_char <- "description: Lorem Ipsum"
  categories_char <- paste0("categories: ", "[", '"',type, '"', ", ", '"',site_name, '"',", " , '"',session,'"', "]" )
  write(title_char, file = qmd_file_path, append = TRUE)
  
  write(subtitle_char, file = qmd_file_path, append = TRUE)
  
  write(image_char, file = qmd_file_path, append = TRUE)
  
  write(description_char, file = qmd_file_path, append = TRUE)
  
  write(categories_char, file = qmd_file_path, append = TRUE)
  
  write("---", file = qmd_file_path, append = TRUE)
  write("<", file = qmd_file_path, append = TRUE)
  iframe_char <- paste("allowfullscreen"," width=","640","height=","480","loading=",'"',"lazy",'"',"frameborder=","0","src=","https://p3d.in/e/G0Eog","alt=","Image 3D corail","file = ",qmd_file_path,"append = TRUE")
  write(iframe_char,file = qmd_file_path, append = TRUE)
  write(">",file = qmd_file_path, append = TRUE)

  write("```{r}", file = qmd_file_path, append = TRUE)
  
  write("#| echo: false", file = qmd_file_path, append = TRUE)
  
  write("library(leaflet)", file = qmd_file_path, append = TRUE)
  
  write("m <- leaflet() %>%", file = qmd_file_path, append = TRUE)
  
  write("addTiles() %>% ", file = qmd_file_path, append = TRUE)
  
  linge_char <-  paste0("addMarkers","(","lng=",longitude, ", ", "lat=", latitude,", ","popup=", '"',site_name,'"', ")")
  write(linge_char, file = qmd_file_path, append = TRUE)
  
  write("m  # Print the map", file = qmd_file_path, append = TRUE)
  
  write("```", file = qmd_file_path, append = TRUE)
  
  
})

