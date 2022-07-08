


#load project functions
devtools::load_all()

# make gallery data
make_gallery_data()

# upload models
upload_models(data = read.csv("outputs/make_gallery_data/model_upload_data.csv")[1:3,])

# make the gallery qmd files
make_gallery(data_uploaded = read.csv("outputs/upload_models/data_uploaded.csv")[1:3,])

# render the website
quarto::quarto_render()
