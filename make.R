


#load project functions
devtools::load_all()

# make gallery data
data <- make_gallery_data()

# upload models

mod_upload_infos <- upload_models(sites = c("ae", "ib", "su", "ng", "jr"), data)

# make the gallery qmd files
make_gallery(mod_upload_infos)


# render the website
quarto::quarto_render()
