# rs-ws-05-1
# MOC - Data Analysis (T. Nauss, C. Reudenbach)
# Scaling

# Set environment --------------------------------------------------------------
if(Sys.info()["sysname"] == "Windows"){
  source("D:/active/moc/msc-ui/scripts/msc-phygeo-ei/src/functions/set_environment.R")
} else {
  source("/media/permanent/active/moc/msc-ui/scripts/msc-phygeo-ei/src/functions/set_environment.R")
}


# Merge aerial files and write resulting raster to separate file ---------------
aerial_files <- list.files(path_aerial_preprocessed, full.names = TRUE, 
                           pattern = glob2rx("*.tif"))
# muf <- muf_merged(aerial_files, paste0(path_aerial_merged, "ortho_muf.tif"))
muf <- stack(paste0(path_aerial_merged, "ortho_muf.tif"))


# Compute spectral indices -----------------------------------------------------
# idx <- rgbIndices(muf, rgbi = c("GLI", "NGRDI", "TGI", "VVI"))
# projection(idx) <- CRS("+init=epsg:25832")
# writeRaster(idx, paste0(path_aerial_merged, "ortho_muf_", names(idx), ".tif"), 
#                         bylayer = TRUE)
idx <- stack(paste0(path_aerial_merged, "ortho_muf_", c("GLI", "NGRDI", "TGI", "VVI"), ".tif"))


# Compute PCA ------------------------------------------------------------------
# pca <- pca(stack(muf))
# saveRDS(pca, file = paste0(path_rdata, "ortho_muf_pca.RDS"))
# projection(pca$map) <- CRS("+init=epsg:25832")
# writeRaster(pca$map, paste0(path_aerial_merged, "ortho_muf_", names(pca$map), ".tif"), 
#             bylayer = TRUE)
pca <- stack(paste0(path_aerial_merged, "ortho_muf_", c("PC1", "PC2", "PC3"), ".tif"))


# Compute local statistics -----------------------------------------------------
rad <- c(25, 50, 75)

muf_all <- stack(idx, pca)

for(n in names(muf_all)){
  for(r in rad){
    print(paste0("Processing ", n, " ", r))
    otb_local_statistics <- otbLocalStat(x = muf_all[[n]], 
                                         radius = 3,
                                         path_output = path_temp)
    projection(otb_local_statistics) <- CRS("+init=epsg:25832")
    writeRaster(otb_local_statistics, 
                paste0(path_aerial_merged, n, "_r", r, ".tif"))
  }
}




# Filter   indices -----------------------------------------------------
filter("/home/tnauss/Desktop/scripts/aerial_finalmuf_merged.tif", 
       targetpath = dirname("/home/tnauss/Desktop/scripts/"),
         prefix = "aerial_", window = c(21,29,33),
         statistics = c("homogeneity", "contrast", "correlation", "mean"))

