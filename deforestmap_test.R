#!/usr/bin/Rscript

# ==============================================================================
# author          :Ghislain Vieilledent
# email           :ghislain.vieilledent@cirad.fr, ghislainv@gmail.com
# web             :https://ghislainv.github.io
# license         :GPLv3
# ==============================================================================

##=========================================================================
## Six decades of deforestation and forest fragmentation in Madagascar
##=========================================================================

## gdal library is needed to run this script
## http://www.gdal.org/

## GRASS GIS 7.2.x is also needed to run this script
## https://grass.osgeo.org/

## Read argument for download
## Set "down" to TRUE if you want to download the sources. Otherwise, the data already provided in the gisdata repository will be used.
arg <- commandArgs(trailingOnly=TRUE)
down <- FALSE
if (length(arg)>0) {
  down <- arg[1]
}

##= Libraries
pkg <- c("broom","sp","rgdal","raster","ggplot2","gridExtra","RColorBrewer",
         "rasterVis","knitr","rmarkdown","rgeos","rgdal","rgrass7")
## broom: to convert map into data-frame with tiny()
## gridExtra: to combine several ggplots
## rasterVis: for gplot()
## rgeos: for crop()
load.pkg <- function(x) {
  if(!require(x, character.only = T)) {
    install.packages(x)
    require(x, character.only = T)
  }
}
loaded <- lapply(pkg,load.pkg)
## Remove useless objects
rm(pkg,load.pkg,loaded)

##=====================================
## Create new grass location in UTM 38S
#dir.create("grassdata")
#system("grass72 -c epsg:32738 grassdata/deforestmap")  # Ignore errors
## Connect R to grass location
initGRASS(gisBase="/usr/local/grass-7.2.0",home=tempdir(), 
          gisDbase="grassdata",
          location="deforestmap",mapset="PERMANENT",
          override=TRUE)


##==========================
## Forest fragmentation
##==========================

## The GRASS Add-on r.forestfrag must be installed
## https://grass.osgeo.org/grass72/manuals/addons/r.forestfrag.html

Year <- c(1953,1973,1990,2000,2010,2014)
system("g.region rast=harper -ap")
system("r.mask --o raster=harper")
for (i in 1:length(Year)) {
  # Message
  cat(paste("Year: ",Year[i],"\n",sep=""))
  # Computation
  if (Year[i]==1973) {  # ! 1975 with 5 (clouds) 
    system(paste0("r.mapcalc --o 'for1973_0 = if(!isnull(for1973) &&& for1973==1, 1, 0)'"))
  }
  else {
    system(paste0("r.mapcalc --o 'for",Year[i],"_0 = if(!isnull(for",Year[i],"), 1, 0)'"))
  }
  system(paste0("r.forestfrag input=for",Year[i],"_0 output=frag",Year[i]," size=7 --overwrite"))
  system(paste0("r.out.gdal --o input=frag",Year[i]," createopt='compress=lzw,predictor=2' type=Byte output=outputs/frag",Year[i],".tif"))
}
system("r.mask -r")

##==========================
## Distance to forest edge
##==========================

Year <- c(1953,1973,1990,2000,2010,2014)
system("g.region rast=harper -ap")
for (i in 1:length(Year)) {
  # Message
  cat(paste("Year: ",Year[i],"\n",sep=""))
  # Computation
  system(paste0("gdal_proximity.py outputs/for",Year[i],".tif outputs/_dist_edge_",Year[i],".tif \\
                -co 'COMPRESS=LZW' -co 'PREDICTOR=2' -values 255 -ot UInt32 -distunits GEO"))
  system(paste0("gdal_translate -a_nodata 0 -co 'COMPRESS=LZW' -co 'PREDICTOR=2' \\
                outputs/_dist_edge_",Year[i],".tif outputs/dist_edge_",Year[i],".tif"))
  file.remove(paste0("outputs/_dist_edge_",Year[i],".tif"))
  system(paste0("r.in.gdal --o input=outputs/dist_edge_",Year[i],".tif output=dist_edge_",Year[i]))
  if (Year[i]==2014) {  # To mask outside Mada for plots
    system("r.mask --o raster=harper")
    system(paste0("r.out.gdal --o input=dist_edge_",Year[i]," createopt='compress=lzw,predictor=2' \\
                  output=outputs/dist_edge_",Year[i],".tif"))
    system("r.mask -r")
  }
}

##========================
## Statistics whole forest
##========================

Res <- 30

#= Deforestation statistics
Year <- c(1953,1973,1990,2000,2010,2014)
defor.df <- data.frame(Year=Year,area=NA,ann.defor=NA,theta=NA)
# Areas
for (i in 1:length(Year)) {
  # Message
  cat(paste("Year: ",Year[i],"\n",sep=""))
  # Computation
  statcell <- system(paste0("r.stats -c for",Year[i]), intern=TRUE)
  ncells <- as.numeric(strsplit(statcell[1],split=" ")[[1]][2])
  defor.df$area[i] <- round(ncells*(as.numeric(Res)^2)/10000)
}
# Annual rates
for (i in 2:length(Year)) {
  theta.prim <- (defor.df$area[i-1]-defor.df$area[i])/defor.df$area[i-1]
  Y <- defor.df$Year[i]-defor.df$Year[i-1]
  defor.df$ann.defor[i] <- round((defor.df$area[i-1]-defor.df$area[i])/Y)
  defor.df$theta[i] <- round(100*(1-(1-theta.prim)^(1/Y)),2)
}
write.table(defor.df,"outputs/defor.txt",row.names=FALSE,sep="\t")

#= Deforestation statistics for comparison
Year <- c(1953,1973,1990,2000,2005,2010,2013)  # Here we add 2005 and 2013
defor.df <- data.frame(Year=Year,area=NA,ann.defor=NA,theta=NA)
# Areas
for (i in 1:length(Year)) {
  # Message
  cat(paste("Year: ",Year[i],"\n",sep=""))
  # Computation
  statcell <- system(paste0("r.stats -c for",Year[i]), intern=TRUE)
  ncells <- as.numeric(strsplit(statcell[1],split=" ")[[1]][2])
  defor.df$area[i] <- round(ncells*(as.numeric(Res)^2)/10000)
}
# Annual rates
for (i in 2:length(Year)) {
  theta.prim <- (defor.df$area[i-1]-defor.df$area[i])/defor.df$area[i-1]
  Y <- defor.df$Year[i]-defor.df$Year[i-1]
  defor.df$ann.defor[i] <- round((defor.df$area[i-1]-defor.df$area[i])/Y)
  defor.df$theta[i] <- round(100*(1-(1-theta.prim)^(1/Y)),2)
}
write.table(defor.df,"outputs/defor_for_comp.txt",row.names=FALSE,sep="\t")

#= Fragmentation statistics
Year <- c(1953,1973,1990,2000,2010,2014)
frag.df <- data.frame(Year=Year,forest=NA,patch=NA,transitional=NA,
                      edge=NA,perforated=NA,interior=NA,undetermined=NA)
# Areas
for (i in 1:length(Year)) {
  # Message
  cat(paste("Year: ",Year[i],"\n",sep=""))
  # Computation
  statcell <- system(paste0("r.stats -c frag",Year[i]), intern=TRUE)
  ncells <- as.numeric(matrix(unlist(strsplit(statcell,split=" ")),ncol=2,byrow=TRUE)[-c(1,8),2])
  frag.df$forest[i] <- round(sum(ncells)*(as.numeric(Res)^2)/10000)
  frag.df[i,c(3:8)] <- round(100*ncells/sum(ncells),2)
}
write.table(frag.df,"outputs/frag.txt",row.names=FALSE,sep="\t")

#= Distance to forest edge statistics
Year <- c(1953,1973,1990,2000,2010,2014)
dist.df <- data.frame(Year=Year,min=NA,max=NA,mean=NA,sd=NA)
# Areas
for (i in 1:length(Year)) {
  # Message
  cat(paste("Year: ",Year[i],"\n",sep=""))
  # Computation
  statcell <- system(paste0("r.univar dist_edge_",Year[i]), intern=TRUE)
  dist.df$min[i] <- unlist(strsplit(statcell[7],split=" "))[2]
  dist.df$max[i] <- unlist(strsplit(statcell[8],split=" "))[2]
  dist.df$mean[i] <- unlist(strsplit(statcell[10],split=" "))[2]
  dist.df$sd[i] <- unlist(strsplit(statcell[12],split=" "))[2]
}
write.table(dist.df,"outputs/dist.txt",row.names=FALSE,sep="\t")

##========================
## Statistics by ecoregion
##========================

# Ecoregions
# system("v.in.ogr --o input=gisdata/vectors layer=madagascar_ecoregion_tenaizy_38s output=ecoregions")
# 1: spiny, 2: mangroves, 3: moist, 4: dry
ecoregion <- c("spiny","mangroves","moist","dry")

# Loop on ecoregions
for (j in 1:length(ecoregion)) {
  # Message
  cat(paste0("Ecoregion: ",ecoregion[j]))
  # Mask
  system(paste0("r.mask --o vector=ecoregions where='ecoregion==",j,"'"))
  # ===========================
  # A. Deforestation statistics
  Year <- c(1953,1973,1990,2000,2010,2014)
  defor.df <- data.frame(Year=Year,area=NA,ann.defor=NA,theta=NA)
  # Areas
  for (i in 1:length(Year)) {
    # Message
    cat(paste0("Year: ",Year[i]))
    # Computation
    statcell <- system(paste0("r.stats -c for",Year[i]), intern=TRUE)
    ncells <- as.numeric(strsplit(statcell[1],split=" ")[[1]][2])
    defor.df$area[i] <- round(ncells*(as.numeric(Res)^2)/10000)
  }
  # Annual rates
  for (i in 2:length(Year)) {
    theta.prim <- (defor.df$area[i-1]-defor.df$area[i])/defor.df$area[i-1]
    Y <- defor.df$Year[i]-defor.df$Year[i-1]
    defor.df$ann.defor[i] <- round((defor.df$area[i-1]-defor.df$area[i])/Y)
    defor.df$theta[i] <- round(100*(1-(1-theta.prim)^(1/Y)),2)
  }
  # Export
  write.table(defor.df,paste0("outputs/defor_",ecoregion[j],".txt"),row.names=FALSE,sep="\t")
  # ==========================================
  # B. Deforestation statistics for comparison
  Year <- c(1953,1973,1990,2000,2005,2010,2013)  # Here we add 2005 and 2013 for comparison
  defor.df <- data.frame(Year=Year,area=NA,ann.defor=NA,theta=NA)
  # Areas
  for (i in 1:length(Year)) {
    # Message
    cat(paste0("Year: ",Year[i]))
    # Computation
    statcell <- system(paste0("r.stats -c for",Year[i]), intern=TRUE)
    ncells <- as.numeric(strsplit(statcell[1],split=" ")[[1]][2])
    defor.df$area[i] <- round(ncells*(as.numeric(Res)^2)/10000)
  }
  # Annual rates
  for (i in 2:length(Year)) {
    theta.prim <- (defor.df$area[i-1]-defor.df$area[i])/defor.df$area[i-1]
    Y <- defor.df$Year[i]-defor.df$Year[i-1]
    defor.df$ann.defor[i] <- round((defor.df$area[i-1]-defor.df$area[i])/Y)
    defor.df$theta[i] <- round(100*(1-(1-theta.prim)^(1/Y)),2)
  }
  # Export
  write.table(defor.df,paste0("outputs/defor_",ecoregion[j],"_for_comp.txt"),row.names=FALSE,sep="\t")
  # # ===========================
  # # B. Fragmentation statistics
  # Year <- c(1953,1973,1990,2000,2010,2014)
  # frag.df <- data.frame(Year=Year,forest=NA,patch=NA,transitional=NA,
  #                       edge=NA,perforated=NA,interior=NA,undetermined=NA)
  # # Areas
  # for (i in 1:length(Year)) {
  #   # Message
  #   cat(paste("Year: ",Year[i],"\n",sep=""))
  #   # Computation
  #   statcell <- system(paste0("r.stats -c frag",Year[i]), intern=TRUE)
  #   ncells <- as.numeric(matrix(unlist(strsplit(statcell,split=" ")),ncol=2,byrow=TRUE)[-c(1,8),2])
  #   frag.df$forest[i] <- round(sum(ncells)*(as.numeric(Res)^2)/10000)
  #   frag.df[i,c(3:8)] <- round(100*ncells/sum(ncells),2)
  # }
  # # =====================================
  # # C. Distance to forest edge statistics
  # Year <- c(1953,1973,1990,2000,2010,2014)
  # dist.df <- data.frame(Year=Year,min=NA,max=NA,mean=NA,sd=NA)
  # # Areas
  # for (i in 1:length(Year)) {
  #   # Message
  #   cat(paste("Year: ",Year[i],"\n",sep=""))
  #   # Computation
  #   statcell <- system(paste0("r.univar dist_edge_",Year[i]), intern=TRUE)
  #   dist.df$min[i] <- unlist(strsplit(statcell[7],split=" "))[2]
  #   dist.df$max[i] <- unlist(strsplit(statcell[8],split=" "))[2]
  #   dist.df$mean[i] <- unlist(strsplit(statcell[10],split=" "))[2]
  #   dist.df$sd[i] <- unlist(strsplit(statcell[12],split=" "))[2]
  # }
  
  #write.table(frag.df,paste0("outputs/frag_",ecoregion[j],".txt"),row.names=FALSE,sep="\t")
  #write.table(dist.df,paste0("outputs/dist_",ecoregion[j],".txt"),row.names=FALSE,sep="\t")
  
  # Remove mask
  system("r.mask -r")
}

##===========================================================================
## End of script
##===========================================================================

