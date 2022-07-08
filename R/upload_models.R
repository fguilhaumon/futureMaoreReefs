

upload_models <- function(data) {
  
  #data = read.csv("outputs/make_gallery_data/model_upload_data.csv")[1:5,]
  
  out_dir <- "outputs/upload_models"
  
  

  if (file.exists(file.path(out_dir, "data_uploaded.csv"))){
    data_uploaded <- read.csv(file.path(out_dir, "data_uploaded.csv"))
    data <- data[!(data$d %in% data_uploaded$d),]
  }else{
    dir.create(out_dir, showWarnings = FALSE)
  }
  
  
  
  res <- do.call(rbind, apply(data, 1, function(d) {
        #d = data[4,]
        # Iteration sur les dirs de outputs (avec regles de selection)
        # Find .obj and texture
    
        obj_path <- grep("model.obj", list.files(d["model_path"], full.names = TRUE), value = TRUE)
        texture_path <- grep("model.jpg", list.files(d["model_path"], full.names = TRUE), value = TRUE)
        mtl_path <- grep("model.mtl", list.files(d["model_path"], full.names = TRUE), value = TRUE)
        
        #cherry-pick allows you to zip files with differents paths see relative path's doc
        zip_char <- file.path(out_dir ,paste0(d["d"], ".zip"))
        zip::zip(zipfile = zip_char, c(obj_path, texture_path, mtl_path), mode = "cherry-pick")
       
        model_uploaded <- upload_model(mod_path = zip_char, mod_name = d["sp_name"], mod_desc = d["mod_desc_char_en"], mod_tags = c("corals"))
        unlink(zip_char)
        
        return(model_uploaded)
      
    }))
      
    res <- data.frame(data, licence = res$licence, uri = res$uri, uid = res$uid)
  
     
    if (file.exists(file.path(out_dir, "data_uploaded.csv"))) {
      res <- rbind(data_uploaded, res)
    }
  
    write.csv(res, file.path(out_dir, "data_uploaded.csv"), row.names = FALSE)

    invisible(res)
  
    
}#eo upload_models

clean_models <- function() {
  
  reticulate::source_python("gallery/sketchfab_data_api.py")
  
  sketch_tok <- readLines("gallery/sketchfab_api_token.txt", n= 1)
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

