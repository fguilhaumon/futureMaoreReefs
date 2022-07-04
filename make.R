


#load project functions
devtools::load_all()


# upload models
mod_urls <- upload_models()

# make the gallery qmd files
make_gallery()


# render the website
quarto::quarto_render()