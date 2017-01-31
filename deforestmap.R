##=========================================================================
## Sixty-five years of deforestation and forest fragmentation in Madagascar
## Ghislain Vieilledent <ghislain.vieilledent@cirad.fr>
## January 2017
##=========================================================================

## gdal library is needed to run this script
## http://www.gdal.org/

## GRASS GIS 7.x.x is also needed to run this script
## https://grass.osgeo.org/

## Read argument for download
## Set "down" to TRUE if you want to download the sources. Otherwise, the data already provided in the gisdata repository will be used.
arg <- commandArgs(trailingOnly=TRUE)
down <- FALSE
if (length(arg)>0) {
  down <- arg[1]
}

##= Libraries
pkg <- c("broom","sp","rgdal","raster","ggplot2","gridExtra",
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

##======================================================================
## Download data (263.6 Mo): will have to be done from a Zenodo repository
if (down) {
  d <- "http://bioscenemada.cirad.fr/githubdata/deforestmap/deforestmap_data.zip"
  download.file(url=d,destfile="deforestmap_data.zip",method="wget",quiet=TRUE)
  unzip("deforest_data.zip")
}

##===========================================================
## Create new directories to save figures and new raster data
dir.create("figs")
dir.create("rast")

#= Projection UTM38S (EPSG:32738)

#= Reproject CI map

# Region
Extent <- "298440 7155900 1100820 8682420"
Res <- "30"
nodat <- "0"
proj.s <- "EPSG:32638"
proj.t <- "EPSG:32738"
Input <- "gisdata/rasters/harper/905_dsp_nosea.img"
Output <- "rast/Forest_CI_905_30m.tif"
# gdalwarp
system(paste0("gdalwarp -overwrite -dstnodata ",nodat," -s_srs ",proj.s," -t_srs ",proj.t," -te ",Extent,
             " -tr ",Res," ",Res," -r near -co 'COMPRESS=LZW' -co 'PREDICTOR=2' ",Input," ",Output))

#= Import Forest_CI_905_30m.tif into grass location
system("r.in.gdal --o input=rast/Forest_CI_905_30m.tif output=Forest_CI_905_30m")
# Set region
system("g.region rast=Forest_CI_905_30m -ap")

#= Typology of CI map
system("r.info Forest_CI_905_30m")
system("r.describe Forest_CI_905_30m") 
# * 111 112 115 122 152 155 222 444 555 755 775 777
# 1=forest, 2=nonforest, 5=cloud, 4=water, 7=mangrove

system("r.report Forest_CI_905_30m units=h")

## +-----------------------------------------------------------------------------+
## |                         RASTER MAP CATEGORY REPORT                          |
## |LOCATION: Forest90-00-10_Mada                        Fri Oct 10 09:30:06 2014|
## |-----------------------------------------------------------------------------|
## |          north: 8682420    east: 1100820                                    |
## |REGION    south: 7155900    west:  298440                                    |
## |          res:        30    res:       30                                    |
## |-----------------------------------------------------------------------------|
## |MASK: none                                                                   |
## |-----------------------------------------------------------------------------|
## |MAP: (untitled) (Forest_CI_905_30m in PERMANENT)                             |
## |-----------------------------------------------------------------------------|
## |                      Category Information                       |           |
## |  #|description                                                  |   hectares|
## |-----------------------------------------------------------------------------|
## |111| . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . |  9,059,766|
## |112| . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . |    241,399|
## |115| . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . |    214,753|
## |122| . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . |    791,318|
## |152| . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . |    180,540|
## |155| . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . |     17,862|
## |222| . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . | 47,922,638|
## |444| . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . |    470,196|
## |555| . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . |       9603|
## |755| . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . |        187|
## |775| . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . |         22|
## |777| . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . |    254,977|
## |  *|no data. . . . . . . . . . . . . . . . . . . . . . . . . . . | 63,321,651|
## |-----------------------------------------------------------------------------|
## |TOTAL                                                            |122,484,912|
## +-----------------------------------------------------------------------------+

#====================================================================================
# The objective is to remove clouds (above the moist forest in the year 2000).
# To do so, we will use the tree cover map by Hansen et al. using a threshold of 75\%

#= Mosaic with gdalbuildvrt
Input <- "gisdata/rasters/hansen/treecover2000/*.tif"
Output <- "rast/treecover2000.vrt"
system(paste0("gdalbuildvrt -overwrite ",Output," ",Input))
#= Resample with gdalwrap
# Region
Extent <- "298440 7155900 1100820 8682420"
Res <- "30"
nodat <- "None"
proj.s <- "EPSG:4326"
proj.t <- "EPSG:32738"
otype <- "Byte"
Input <- "rast/treecover2000.vrt"
Output <- "rast/treecover2000.tif"
# gdalwarp
system(paste0("gdalwarp -overwrite -ot ",otype," -dstnodata ",nodat," -s_srs ",proj.s," -t_srs ",proj.t," -te ",Extent,
             " -tr ",Res," ",Res," -r bilinear -co 'COMPRESS=LZW' -co 'PREDICTOR=2' ",Input," ",Output))
#= Import treecover2000_38S.tif into grass location
system("r.in.gdal --o input=rast/treecover2000.tif output=tc2000")

#= Forest in 2000
# Integrating classes of forest in 2000 (111, 112, 115, 775 and 777) and uncertainties (152, 155, 555 and 755)
system("r.mapcalc 'for2000_temp = if(Forest_CI_905_30m==111 || Forest_CI_905_30m==112 || Forest_CI_905_30m==115 || \\
       Forest_CI_905_30m==775 || Forest_CI_905_30m==777 || Forest_CI_905_30m==152 || Forest_CI_905_30m==155 || \\
       Forest_CI_905_30m==555 || Forest_CI_905_30m==755, 1, null())'")
# Replace uncertainties using Hansen tree cover and a threshold of 75\%
system("r.mapcalc --o 'for2000 = if((Forest_CI_905_30m==152 || Forest_CI_905_30m==155 || \\
       Forest_CI_905_30m==555 || Forest_CI_905_30m==755) && tc2000<75 , null(), for2000_temp)'")
system("r.stats -c for2000_temp")
#1 110878983
#* 1250064481
system("r.stats -c for2000")
#1 109763775
#* 1251179689
system("g.remove -f type=raster name=for2000_temp")

#= lossyear Hansen
#= Mosaic with gdalbuildvrt
Input <- "gisdata/rasters/hansen/lossyear/*E.tif"
Output <-"rast/lossyear.vrt"
system(paste("gdalbuildvrt -overwrite ",Output," ",Input,sep=""))
#= Resample with gdalwrap
# Region
Extent <- "298440 7155900 1100820 8682420"
Res <- "30"
nodat <- "None"
proj.s <- "EPSG:4326"
proj.t <- "EPSG:32738"
otype <- "Byte"
Input <- "rast/lossyear.vrt"
Output <- "rast/lossyear.tif"
# gdalwarp
system(paste0("gdalwarp -overwrite -ot ",otype," -dstnodata ",nodat," -s_srs ",proj.s," -t_srs ",proj.t," -te ",Extent,
             " -tr ",Res," ",Res," -r near -co 'COMPRESS=LZW' -co 'PREDICTOR=2' ",Input," ",Output))
#= Import lossyear.tif into grass location
system("r.in.gdal --o input=rast/lossyear.tif output=lossyear")
system("r.describe lossyear")
# * 1-14

## RESTART PROOFREADING FROM HERE

#= Forest in 2001-2014
for (i in 1:14) {
  # Message
  cat(paste("Year: ",i,"\n",sep=""))
  # Computation
  system(paste0("r.mapcalc --o 'defor = if(lossyear>0 && lossyear<=",i,",1,null())'"))
  if (i <= 9) {
    system(paste0("r.mapcalc --o 'for200",i," = if(!isnull(defor),null(),for2000)'"))
  }
  else {
    system(paste0("r.mapcalc --o 'for20",i," = if(!isnull(defor),null(),for2000)'"))
  }
}

#= Export forest2010
system("r.out.gdal --o input=for2014 createopt='compress=lzw,predictor=2' type='Byte' output='rast/for2014.tif'")
system("r.out.gdal --o input=for2010 createopt='compress=lzw,predictor=2' type='Byte' output='rast/for2010.tif'")
system("r.out.gdal --o input=for2005 createopt='compress=lzw,predictor=2' type='Byte' output='rast/for2005.tif'")
system("r.out.gdal --o input=for2000 createopt='compress=lzw,predictor=2' type='Byte' output='rast/for2000.tif'")

##= Compute fordefor2010. For test of function .sample() in  Python deforestprob module
system("r.mapcalc --o 'fordefor2010 = if(isnull(for2010_30m) && for2000_30m == 1, 0, for2010_30m)'")
system("echo '1 26:152:80 \n 0 red' | r.colors fordefor2010 rules=-")
system(paste("r.out.gdal --o input=fordefor2010 createopt='compress=lzw,predictor=2' type='Byte' output='",gis.path("Forest_CI/fordefor2010.tif"),"'",sep=""))

#= Deforestation statistics
defor.df <- data.frame(Year=2000:2014,ncells=NA,area=NA,theta=NA)
Year <- as.character(2000:2014)
for (i in 1:length(Year)) {
  # Message
  cat(paste("Year: ",i,"\n",sep=""))
  # Computation
  statcell <- system(paste("r.stats -c for",Year[i],"_30m",sep=""), intern=TRUE)
  defor.df$ncells[i] <- as.numeric(strsplit(statcell[1],split=" ")[[1]][2])
  defor.df$area[i] <- round(defor.df$ncells[i]*(as.numeric(Res)^2)/10000)
}
for (i in 2:length(Year)) {
  defor.df$theta[i] <- round(100*(defor.df$area[i-1]-defor.df$area[i])/defor.df$area[i-1],2)  
}
write.table(defor.df,"defor.df.30m.txt",row.names=FALSE,sep="\t")

#====================================================================================
# Forest in 1990

#= Integrating classes of forest in 1990 (111, 112, 122, 115, 152, 155, 755, 775 and 777) and uncertainties (555)
system("r.mapcalc --o 'for1990_temp = if(Forest_CI_905_30m==111 || Forest_CI_905_30m==112 || Forest_CI_905_30m==122 || \\
       Forest_CI_905_30m==115 || Forest_CI_905_30m==152 || Forest_CI_905_30m==155 || Forest_CI_905_30m==755 || \\
       Forest_CI_905_30m==775 || Forest_CI_905_30m==777 || Forest_CI_905_30m==555,1,null())'")

# How many ha of uncertainties ?
# 9603 ha of 555 in Forest_CI_905_30m

#= Removing uncertainties (555) using land-cover in 2000
system("r.mapcalc --o 'for1990_30m = if(Forest_CI_905_30m==555 && isnull(for2000_30m), null(), for1990_temp)'")
system("r.stats -c for1990_temp") # 1 119671405
system("r.stats -c for1990_30m") # 1 119582639
system("g.remove -f type=raster name=for1990_temp")

#= Export
system(paste("r.out.gdal --o input=for1990_30m createopt='compress=lzw,predictor=2' type='Byte' output='",gis.path("Forest_CI/for1990_30m.tif"),"'",sep=""))

#====================================================================================
# Forest c.1973

#= Import forest map for the year 1973
system(paste("r.in.gdal --o input=",gis.path("Forest_c1973/for1973_38s.tif")," output=for1973cloud",sep=""))

#= Corrections from for1990_30m
system("r.mapcalc --o 'for1973_30m = if(!isnull(for1990_30m), for1990_30m, for1973cloud)'")

#= Combine mangrove (7) and forest (1)
system("r.mapcalc --o 'for1973_30m = if(for1973_30m==7, 1, for1973_30m)'")

#= Deforestation rate 1973-1990
system("r.stats -c for1973_30m")
## 1 158236269
## 5 36850880
## * 1165856315

system("r.stats -c for1990_30m")
## 1 119582639
## * 1241360825

theta.prim <- (158236269-119582639)/158236269
Y <- 1990-1973 
theta <- 1-(1-theta.prim)^(1/Y) # 1.6 %.yr-1 (ok, in line with Harper et al. 2007)

#= Export
system(paste("r.out.gdal --o input=for1973_30m createopt='compress=lzw,predictor=2' type='Byte' output='",gis.path("Forest_CI/for1973_30m.tif"),"'",sep=""))

#====================================================================================
# Reproject c.1953

# Region
Extent <- "298440 7155900 1100820 8682420"
Res <- "30"
nodat <- "0"
otype <- "Byte"
proj.s <- "EPSG:32638"
proj.t <- "EPSG:32738"
Input <- gis.path("Forest_1950s/madagascar_1950_4bit.img")
Output <- gis.path("Forest_CI/for1953_orig_30m.tif")
# gdalwarp
system(paste("gdalwarp -ot ",otype," -dstnodata ",nodat," -s_srs ",proj.s," -t_srs ",proj.t," -te ",Extent,
             " -tr ",Res," ",Res," -r near -overwrite ",Input," ",Output,sep=""))

#= Import for1953_orig_30m.tif into grass location
system(paste("r.in.gdal --o input=",gis.path("Forest_CI/for1953_orig_30m.tif")," output=for1953_orig_30m",sep=""))
system("r.info for1953_orig_30m")
system("r.stats -c for1953_orig_30m")

#= Corrections from for1973_30m
system("r.mapcalc --o 'for1953_30m = if(!isnull(for1973_30m) &&& (for1973_30m==1 || for1973_30m==7), 1, for1953_orig_30m)'")
system("r.mapcalc --o 'for1953_30m = if(for1953_30m!=1,null(),1)'")
system("r.stats -c for1953_30m")
## 1 225792265
## * 1135151199

#= Export
system(paste("r.out.gdal --o input=for1953_30m createopt='compress=lzw,predictor=2' type='Byte' output='",gis.path("Forest_CI/for1953_30m.tif"),"'",sep=""))

#====================================================================================
# Export images

#= Colors
system("echo '1 26:152:80' | r.colors for1953_30m rules=-")
# system("echo '1 26:152:80 \n 5 grey \n 7 blue' | r.colors for1973_30m rules=-")
system("echo '1 26:152:80 \n 5 white' | r.colors for1973_30m rules=-")
system("echo '1 26:152:80' | r.colors for1990_30m rules=-")
system("echo '1 26:152:80' | r.colors for2000_30m rules=-")
system("echo '1 26:152:80' | r.colors for2010_30m rules=-")
system("echo '1 26:152:80' | r.colors for2014_30m rules=-")

#= PNG
system("g.region res=1000")
system("r.out.png input=for1953_30m output=./for1953.png")
system("r.out.png input=for1973_30m output=./for1973.png")
system("r.out.png input=for1990_30m output=./for1990.png")
system("r.out.png input=for2000_30m output=./for2000.png")
system("r.out.png input=for2010_30m output=./for2010.png")
system("r.out.png input=for2014_30m output=./for2014.png")

#= Label and convert to gif
system("convert -pointsize 72 -gravity North -draw \"text 0,0 '1953'\" for1953.png for1953.gif")
system("convert -pointsize 72 -gravity North -draw \"text 0,0 '1973'\" for1973.png for1973.gif")
system("convert -pointsize 72 -gravity North -draw \"text 0,0 '1990'\" for1990.png for1990.gif")
system("convert -pointsize 72 -gravity North -draw \"text 0,0 '2000'\" for2000.png for2000.gif")
system("convert -pointsize 72 -gravity North -draw \"text 0,0 '2010'\" for2010.png for2010.gif")
system("convert -pointsize 72 -gravity North -draw \"text 0,0 '2014'\" for2014.png for2014.gif")
## system("rm *.png")

#= Animated gif
system("convert -delay 100 -loop 0 *.gif defor_Mada.gif")
#= See also OpenShot app for movie and transition effects

##========================
## Save objects
# load("menabe.rda")
save(list=ls(all.names=TRUE),file="deforestmap.rda")

##========================
## Knit the document

## Set knitr chunk default options
opts_chunk$set(echo=FALSE, cache=FALSE,
               results="hide", warning=FALSE,
               message=FALSE, highlight=TRUE,
               fig.show="hide", size="small",
               tidy=FALSE)

## Knit and translate to html and pdf
dir.create("report")
## Main document
render("deforestmap.Rmd",output_dir="report") # html output
## Cover letter
render("coverletter.md",output_format=c("pdf_document"),output_dir="report") # pdf output
#render("deforestmap.Rmd",output_format=c("html_document","pdf_document","word_document"),output_dir="report")

##===========================================================================
## End of script
##===========================================================================

