

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

upload_model <- function(mod_path ,
                         mod_name ,
                         api_token = readLines("gallery/sketchfab_api_token.txt"),
                         mod_desc = "",
                         mod_tags = "",
                         mod_cat = "",
                         mod_lic = "by-nc-sa",
                         mod_pub = FALSE,
                         mod_ins = TRUE) {

  sketchfab_api_url <- "https://api.sketchfab.com/v3"
  model_endpoint <- paste0(sketchfab_api_url,"/models")

  data <- list(
    name = mod_name,
    description = mod_desc,
    tags = mod_tags,  # Array of tags,
    categories = mod_cat,  # Array of categories slugs,
    license = mod_lic,  # License slug, allow actions to users see by- actions
    private = 1,  # requires a pro account,
    password = "",  # requires a pro account,
    isPublished = mod_pub,  # Model will be on draft instead of published,
    isInspectable = mod_ins,  # Allow 2D view in model inspector
    modelFile = httr::upload_file(mod_path)
  )

  message("Uploading...")

  files <- list(modelFile = mod_path)
  payload <- get_request_payload(data = reticulate::r_to_py(data), files = files, api_token = api_token)


  req <- httr2::request(model_endpoint) |>
         httr2::req_headers("Authorization" = paste0("Token ", api_token)) |>
         httr2::req_body_json(payload[c("files", "data")])

  resp <- req |> httr2::req_perform()

  r <- httr::POST(url = model_endpoint,
             body = jsonify::to_json(data),
             encode = "raw",
             httr::add_headers(Authorization = paste0("Token ", api_token)))



  # with open(model_file, 'rb') as file_:
  #   files = {'modelFile': file_}
  # payload = get_request_payload(data=data, files=files, api_token = api_token)
  #
  # try:
  #   response = requests.post(model_endpoint, **payload)
  # except RequestException as exc:
  #   print(f'An error occured: {exc}')
  # return


}#eo upload_model