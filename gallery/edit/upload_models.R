

# install requests python module
#reticulate::py_install("requests", pip = TRUE)


reticulate::source_python("gallery/sketchfab_data_api.py")

sketch_tok <- read.table("gallery/sketchfab_api_token.txt")[1,1]

mod_url <- upload(mod_path = reticulate::r_to_py("/data/outputs/ib_022022_12/ib_022022_12_model.zip"),
                  mod_name = reticulate::r_to_py("Platygyra daedalea"),
                  api_token = reticulate::r_to_py(sketch_tok) )



# Iteration sur les dirs de outputs (avec regle s de selection)

# zip des model.obj et .jpeg

# get the name

#uplod

#save url !!!!!!!





save(monObj, file = "gallery/mod_urls.RData")