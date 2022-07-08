

#' POST a model to sketchfab.
#'
#' @param mod_path 
#' @param mod_name 
#' @param api_token 
#' @param mod_desc 
#' @param mod_tags 
#' @param mod_cat 
#' @param mod_lic 
#' @param mod_pub 
#' @param mod_ins 
#'
#' @return
#' @export
#'

upload_model <- function(mod_path  = "",
                         mod_name  = "",
                         api_token = readLines("gallery/sketchfab_api_token.txt"),
                         mod_desc  = "",
                         mod_tags  = "",
                         mod_cat   = "",
                         mod_lic   = "by-nc-sa",
                         mod_pub   = TRUE,
                         mod_ins   = TRUE) {
  
  sketchfab_api_url <- "https://api.sketchfab.com/v3"
  model_endpoint <- paste0(sketchfab_api_url,"/models")
  
  cli::cli_h1(paste0("Uploading model '", mod_name, "'"))
  cli::cli_alert(paste0("file: ", basename(mod_path)))
  
  
  data <- list(
    name          = mod_name,
    description   = mod_desc,
    tags          = mod_tags,  # Array of tags,
    categories    = mod_cat,  # Array of categories slugs,
    license       = mod_lic,  # License slug, allow actions to users see by- actions
    private       = 1,  # requires a pro account,
    password      = "",  # requires a pro account,
    isPublished   = mod_pub,  # Model will be on draft instead of published,
    isInspectable = mod_ins,  # Allow 2D view in model inspector
    modelFile     = httr::upload_file(mod_path) # An application/octet-stream connexion to the model file
  )
  
  r <- httr::POST(url = model_endpoint,
                  body = data,
                  encode = "multipart",
                  httr::add_headers(Authorization = paste0("Token ", api_token)))
  
  if (r$status_code != 201) stop("Upload failed with status_code '", r$status_code, "'")
  
  mod_url <- httr::content(r)
  
  cli::cli_alert_success(paste0("Upload successful for ", mod_name, " at ", mod_url$uri))
  
  data.frame(model_path = mod_path, name = mod_name, description = mod_desc, licence = mod_lic, mod_url)
  
}#eo upload_model