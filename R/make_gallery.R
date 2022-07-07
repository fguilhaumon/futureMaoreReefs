
make_gallery <- function(data_uploaded) {

  #data_uploaded = read.csv("outputs/upload_models/data_uploaded.csv")
  col_paths <- list.files("/data/colonies_stageMateo/cap_ecran_colonies", recursive = TRUE, full.names = TRUE)
  site_info <- read.csv("data/site_metadata.csv", header = TRUE)
  
  type_dic <- data.frame(type_en = c("competitive", "stress-tolerant", "generalist", "weedy"),
                         type_fr = c("compétitif", "robuste", "généraliste", "opportuniste"))
  
  
  res <- apply(data_uploaded, 1, function(d) {
    
    #d = data_uploaded[1,]
    # Load model url
    #initiating variables
    name <- d["sp_name"]
    description <- d["mod_desc_char_fr"]
    type <- as.character(d["type"])
    site <- as.character(d["site_id"])  #TODO replace !!!!!! d["site_id"]
    file <- d["d"]
    model_url <- gsub("/v3", "", d["uri"])
    #Split elements
    strings <- strsplit(as.character(file), "_")[[1]] 
    #name columns
    names(strings) <- c("site", "sampling", "colony_number") 
    #Take only code part like "ae"
    
    mois <- c("janvier",	"février",	"mars",	"avril",	"mai", 	"juin",	"juillet",	"août",	"septembre",	"octobre",	"novembre",	"décembre")
    
    month <- as.numeric(substr(strings["sampling"],1,2))
    month_char <- mois[month]
    year <- substr(strings["sampling"],3,6)
    #strings["site"] <- substr(strings["site"], 1, 2)
    date <- paste0(month_char," ",year)
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
    site_fr <- site_info$site_fr[site_info$site_id == site]
    type_fr <- type_dic$type_fr[type_dic$type_en == type]
    longitude <- subset(site_info, site_id == site)$longitude
    #longitude <- longitude$longitude
    latitude <- subset(site_info, site_id == site)$latitude
    #latitude <- latitude$latitude
    #Creating name file and path's file
    qmd_file_name <- paste0(site,  "_", gsub(" ", "-", name), ".qmd")
    qmd_file_path <- paste0("gallery/", site, "/", qmd_file_name)
    
    dir.create(file.path("gallery", site), showWarnings = FALSE)
    
    
    #Editing file
    
    #Init variables
    title_char <- paste0('title: "', name,'"')
    subtitle_char <- paste0('subtitle: ""')
    description_char <- paste0('description: Cette colonie de corail',type,'est suivi au site "',site_fr,'"')
    image_char <- paste0("image: ", grep(pattern = paste0(as.character(d["d"]), ".jpg"), col_paths, value = TRUE))
    categories_char <- paste0('categories: [ "',type,'", ','"',site_fr, '"]' )
    iframe_char <- paste0('<div class="resp-container"> <iframe class="resp-content title="',name,' frameborder="0" allowfullscreen mozallowfullscreen="true" webkitallowfullscreen="true" allow="autoplay; fullscreen; xr-spatial-tracking" xr-spatial-tracking execution-while-out-of-viewport execution-while-not-rendered web-share src="', model_url, 'embed?autostart=1&annotations_visible=0&preload=1&ui_infos=0&ui_inspector=0&ui_watermark_link=0&ui_watermark=0&ui_settings=0"> </iframe> </div>')
    sentence <- paste0("Voici le modèle issu de la deuxième campagne de terrain __Future Maore Reefs__ le ",date)
    map_char <-  paste0("addMarkers","(","lng=",longitude, ", ", "lat=", latitude,", ","popup=", '"',site_fr,'"', ")")
    #Writing file
    
    append_to_qmd <- function(char) {
      write(char, file = qmd_file_path, append = TRUE)
    }
    
    append_to_qmd("---")
    append_to_qmd(title_char)
    
    append_to_qmd(subtitle_char)
    
    append_to_qmd(image_char)
    
    append_to_qmd(description_char)
    
    append_to_qmd(categories_char)
    
    append_to_qmd("---")
    append_to_qmd("### Modèle 3D")
    append_to_qmd("")
    
    append_to_qmd(sentence)
    append_to_qmd("")
    
    append_to_qmd(iframe_char)
    
    append_to_qmd("### Carte du site")
  
    append_to_qmd("```{r}")
    
    append_to_qmd("#| echo: false")
    
    append_to_qmd("library(leaflet)")
    
    append_to_qmd("m <- leaflet() %>%")
    
    append_to_qmd("addTiles() %>% ")
    
    append_to_qmd(map_char)
    
    append_to_qmd("m  # Print the map")
    
    append_to_qmd("```")
    append_to_qmd("")
    
    return(qmd_file_path)
    
  })
  
  return(res)

}#eo make_gallery

