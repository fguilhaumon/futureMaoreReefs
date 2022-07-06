
make_gallery <- function() {

#load site infos
#site_info <- read.csv("data/metadonnees.csv", header= TRUE)
#library
#library(stringr)
#root dir
#base_dir <- "/data/outputs"

data_uploaded <- read.csv("data/data_uploaded.csv")
french_type_dic <- data.frame(type_en = c("competitive", "stress-tolerant", "generalist", "weedy"),
                              type_fr = c("compétitif", "robuste", "généraliste", "opportuniste"))
french_site <- read.csv("data/french_site.csv")
site_info <- read.csv("data/metadonnees.csv")
#list dirs in root_dir
#dirs <- list.dirs(base_dir, full.names = FALSE, recursive = FALSE)
#sp_type <- read.csv("data/speciestype.csv")
#select only sites in site_info

#Add | in site_info$code "or term"
#patt <- paste(site_info$code, collapse = "|") 
# Choose file wich contains patt
#dirs <- grep(pattern = patt, dirs, value = TRUE) 

#load sampling info
#samplingsfile <- read.csv("samplings.csv", header = TRUE)

col_paths <- list.files("/data/colonies_stageMateo/cap_ecran_colonies", recursive = TRUE, full.names = TRUE)
#load("gallery/model.RData")
#dirs <- dirs[is.element(dirs, mod_urls$d)]
#d= "ae1_022022_1"

res <- apply(data_uploaded,1, function(d) {
  
  #d = "ae1_022022_10"
  # Load model url
  model_url <- gsub("/v3", "", d[5])
  #Split elements
  strings <- strsplit(as.character(d[9]), "_")[[1]] 
  #name columns
  names(strings) <- c("site", "sampling", "colony_number") 
  #Take only code part like "ae"
  
  mois <- c("janvier",	"février",	"mars",	"avril",	"mai", 	"juin",	"juillet",	"août",	"septembre",	"octobre",	"novembre",	"décembre")
  
  month <- as.numeric(substr(strings["sampling"],1,2))
  month_char <- mois[month]
  year <- substr(strings["sampling"],3,6)
  strings["site"] <- substr(strings["site"], 1, 2)
  date <- paste0(month_char,"  ",year)
  #site_name <-  site_info$site[site_info$code == strings["site"]]
 
  #init variables
  #session <- "session1"
  #Find species Name with tag
  
  #sp_name <- subset(data, site == site_name & Name == strings['colony_number'])["species"]
  #sp_name <- sp_name$Espèce
  #sp_name <- model$name
  #Find type with species name
  #type <- subset(sp_type, genus_sp == sp_name)
  #type <- type$LHT
  #type <- model$type
  site_fr <- french_site$type_fr[french_site$type_en == as.character(d[8])]
  type <- french_type_dic$type_fr[french_type_dic$type_en == as.character(d[7])]
  longitude <- subset(site_info, site == site_fr)$longitude
  #longitude <- longitude$longitude
  latitude <- subset(site_info, site == site_fr)$latitude
  #latitude <- latitude$latitude
  #Creating name file and path's file
  qmd_file_name <- paste0(strings["site"],  "_", d[2], "_", d[8], ".qmd")
  qmd_file_path <- paste0("gallery/", strings["site"], "/", qmd_file_name)
  
  #Editing file
  write("---", file = qmd_file_path, append = TRUE)
  #Init variables
  title_char <- paste0('title: "', d[2],'"')
  subtitle_char <- paste0('subtitle: ""')
  description_char <- paste0('description: Cette colonie de corail',type,'est suivi au site "',site_fr,'"')
  image_char <- paste0("image: ", grep(pattern = d[9], col_paths, value = TRUE))
  categories_char <- paste0("categories: ", "[", '"',type, '"', ", ", '"',site_fr, '"',", " ,  "]" )
  write(title_char, file = qmd_file_path, append = TRUE)
  
  write(subtitle_char, file = qmd_file_path, append = TRUE)
  
  write(image_char, file = qmd_file_path, append = TRUE)
  
  write(description_char, file = qmd_file_path, append = TRUE)
  
  write(categories_char, file = qmd_file_path, append = TRUE)
  
  write("---", file = qmd_file_path, append = TRUE)
  write("### Modèle 3D", file = qmd_file_path, append = TRUE)
  write("", file = qmd_file_path, append = TRUE)
  sentence <- paste0("Voici le modèle issu de la deuxième campagne de terrain __Future Maore Reefs__ le ",date)
  write(sentence , file = qmd_file_path, append = TRUE)
  write("",file = qmd_file_path, append = TRUE)
  iframe_char <- paste0('<div class="resp-container"> <iframe class="resp-content title="',d[2],' frameborder="0" allowfullscreen mozallowfullscreen="true" webkitallowfullscreen="true" allow="autoplay; fullscreen; xr-spatial-tracking" xr-spatial-tracking execution-while-out-of-viewport execution-while-not-rendered web-share src="', model_url, 'embed?autostart=1&annotations_visible=0&preload=1&ui_infos=0&ui_inspector=0&ui_watermark_link=0&ui_watermark=0&ui_settings=0"> </iframe> </div>')
  write(iframe_char,file = qmd_file_path, append = TRUE)
  write("### Carte du site", file = qmd_file_path, append = TRUE)

  write("```{r}", file = qmd_file_path, append = TRUE)
  
  write("#| echo: false", file = qmd_file_path, append = TRUE)
  
  write("library(leaflet)", file = qmd_file_path, append = TRUE)
  
  write("m <- leaflet() %>%", file = qmd_file_path, append = TRUE)
  
  write("addTiles() %>% ", file = qmd_file_path, append = TRUE)
  
  linge_char <-  paste0("addMarkers","(","lng=",longitude, ", ", "lat=", latitude,", ","popup=", '"',site_fr,'"', ")")
  write(linge_char, file = qmd_file_path, append = TRUE)
  
  write("m  # Print the map", file = qmd_file_path, append = TRUE)
  
  write("```", file = qmd_file_path, append = TRUE)
  
  
})

}#eo make_gallery

