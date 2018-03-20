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

##= Libraries
pkg <- c("broom","sp","rgdal","raster","ggplot2","gridExtra","RColorBrewer",
         "dataverse",
         "rasterVis","knitr","rmarkdown","kableExtra","rgeos","rgdal","rgrass7")
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
## Name of objects to save
SavedObjects <- c()

##=====================================
## Create new grass location in UTM 38S
#dir.create("grassdata")
#system("grass72 -c epsg:32738 grassdata/deforestmap")  # Ignore errors

## Connect R to grass location
## Make sure that /usr/lib/grass72/lib is in your PATH in RStudio
## On Linux, find the path to GRASS GIS with: $ grass72 --config path
## It should be somethin like: "/usr/lib/grass72"
## On Windows, find the path to GRASS GIS with: C:\>grass72.bat --config path
## If you use OSGeo4W, it should be: "C:\OSGeo4W\apps\grass\grass-7.2"
Sys.setenv(LD_LIBRARY_PATH=paste("/usr/lib/grass72/lib", Sys.getenv("LD_LIBRARY_PATH"),sep=":"))

## Initialize GRASS
initGRASS(gisBase="/usr/lib/grass72",home=tempdir(), 
          gisDbase="grassdata",
          location="deforestmap",mapset="PERMANENT",
          override=TRUE)

##==================================================================
## Download data from Cirad Dataverse: http://dx.doi.org/10.18167/DVN1/2FP7LR
down <- FALSE
if (down) {
  library(dataverse)
  Sys.setenv("DATAVERSE_SERVER"="dataverse.cirad.fr")
  dataverse::get_dataset("doi:10.18167/DVN1/2FP7LR")
  f <- dataverse::get_file(file="gisdata.zip",
                           dataset="doi:10.18167/DVN1/2FP7LR")
  writeBin(f, "gisdata.zip")
  unzip("gisdata.zip", exdir="gisdata")
}

##===========================================================
## Create new directories to save outputs
dir.create("outputs")

#= Projection UTM38S (EPSG:32738)

#= Reproject Harper 1990-2000-2005 map

# Region
Extent <- "298440 7155900 1100820 8682420"
Res <- "30"
nodat <- "0"
proj.s <- "EPSG:32638"
proj.t <- "EPSG:32738"
Input <- "gisdata/rasters/harper/905_dsp_nosea.img"
Output <- "outputs/harper.tif"
# gdalwarp
system(paste0("gdalwarp -overwrite -dstnodata ",nodat," -s_srs ",proj.s," -t_srs ",proj.t," -te ",Extent,
             " -tr ",Res," ",Res," -r near -co 'COMPRESS=LZW' -co 'PREDICTOR=2' ",Input," ",Output))

#= Import harper into grass location
system("r.in.gdal --o input=outputs/harper.tif output=harper")
# Set region
system("g.region rast=harper -ap")

#= Typology of harper map 1990-2000-2005
system("r.info harper")
system("r.describe harper")
# * 111 112 115 122 152 155 222 444 555 755 775 777
# 1=forest, 2=nonforest, 5=cloud, 4=water, 7=mangrove

system("r.report --o harper units=h output='outputs/report_harper.txt'")

## +-----------------------------------------------------------------------------+
## |                         RASTER MAP CATEGORY REPORT                          |
## |LOCATION: deforestmap                                Wed Mar  1 09:22:04 2017|
## |-----------------------------------------------------------------------------|
## |          north: 8682420    east: 1100820                                    |
## |REGION    south: 7155900    west:  298440                                    |
## |          res:        30    res:       30                                    |
## |-----------------------------------------------------------------------------|
## |MASK: none                                                                   |
## |-----------------------------------------------------------------------------|
## |MAP: (untitled) (harper in PERMANENT)                             |
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
# Report on clouds

#= Whole forest
# Import the GRASS report into R
#r <- readLines("outputs/report_harper.txt")
#r <- r[-c(1:15,28:31)]
#writeLines(r, "outputs/report_harper.txt")
report.harper <- read.table(file="outputs/report_harper.txt", sep="|", header=FALSE)
report.harper <- report.harper[,c(2,4)]
names(report.harper) <- c("code", "area")
report.harper$area <- as.numeric(gsub(pattern=",", replacement="", report.harper$area))

# Hectares of cloud in 2000 Harper map
ha.cloud.2000 <- sum(report.harper$area[report.harper$code %in% c(152, 155, 555, 755)]) # 208192 ha
SavedObjects <- c(SavedObjects, "ha.cloud.2000")

#= By ecoregion
# 1: spiny, 2: mangroves, 3: moist, 4: dry
# Rasterize ecoregions
Extent <- "298440 7155900 1100820 8682420"
Res <- "30"
nodat <- "255"
Input <- "gisdata/vectors/madagascar_ecoregion_tenaizy_38s.shp"
Output <- "outputs/ecoregion.tif"
# gdalwarp
system(paste0("gdal_rasterize -a 'ecoregion' -ot Byte -a_nodata 255 -te ",Extent,
              " -tr ",Res," ",Res," -co 'COMPRESS=LZW' -co 'PREDICTOR=2' ",Input," ",Output))
# Import into grass
system("r.in.gdal --o input=outputs/ecoregion.tif output=ecoregion")
# Cross-tabulation table
system("r.report --o map=ecoregion,harper units=h output='outputs/report_harper_ecoregion.txt'")

# Moist ecoregions
# Import the GRASS report into R
#r <- readLines("outputs/report_harper_ecoregion.txt")
#r <- r[c(47:57)] # select outputs for the moist ecoregion
#writeLines(r, "outputs/report_harper_ecoregion.txt")
report.harper.moist <- read.table(file="outputs/report_harper_ecoregion.txt", sep="|", header=FALSE)
report.harper.moist <- report.harper.moist[,c(3,5)]
names(report.harper.moist) <- c("code", "area")
report.harper.moist$area <- as.numeric(gsub(pattern=",", replacement="", report.harper.moist$area))

# Hectares of cloud in 2000 Harper map fr moist ecoregion
ha.cloud.2000.moist <- sum(report.harper.moist$area[report.harper.moist$code %in% c(152, 155, 555, 755)]) # 182650 ha
perc.cloud.moist <- 100*ha.cloud.2000.moist/ha.cloud.2000 # 88%
SavedObjects <- c(SavedObjects, "ha.cloud.2000.moist", "perc.cloud.moist")

##========================
## Histogram of tree cover
##========================

# Moist forest 2000 in Harper
system("r.mapcalc --o 'for2000_Harper_moist = if((harper==111 || harper==112 || harper==115 || \\
       harper==775 || harper==777) && ecoregion==3, 1, null())'")
system("r.mask --o raster=for2000_Harper_moist")
system("r.mapcalc --o 'tc2000_moist = tc2000'")
system("r.mask -r")
hist_tc2000_moist <- system("r.stats -c input=tc2000_moist nsteps=100", intern=TRUE)
df_tc2000_moist <- data.frame(matrix(unlist(strsplit(hist_tc2000_moist, " ")), ncol=2, byrow=TRUE))
df_tc2000_moist <- df_tc2000_moist[-c(101),]
names(df_tc2000_moist) <- c("tc","npix")
df_tc2000_moist$npix <- as.numeric(as.character(df_tc2000_moist$npix))
df_tc2000_moist$tc <- as.numeric(as.character(df_tc2000_moist$tc))
df_tc2000_moist$nha <- df_tc2000_moist$npix*30*30/10000
df_tc2000_moist$freq <- 100*df_tc2000_moist$npix/sum(df_tc2000_moist$npix)
# Cumulative proportion
for (i in 100:1) {
  df_tc2000_moist$cum_prop[i] <- 100*sum(df_tc2000_moist$npix[100:i])/sum(df_tc2000_moist$npix)
}
write.table(df_tc2000_moist, file="outputs/df_tc2000_moist.txt", sep="\t", row.names=FALSE)
# How much moist forest has a TC over 75%
prop_tc75 <- round(df_tc2000_moist$cum_prop[df_tc2000_moist$tc==75]) # 90%
prop_tc70 <- round(df_tc2000_moist$cum_prop[df_tc2000_moist$tc==70]) # 92%

# Plot pdf
pdf("outputs/tc_threshold_moist.pdf", width=8, height=8)
par(mar=c(5,4,2,1),cex=1.4)
plot(df_tc2000_moist$tc,df_tc2000_moist$cum_prop, type="l",
     lwd=2,
     xlab="Tree cover (%)",
     ylab="Percentage of moist forest",
     ylim=c(0,100), axes=FALSE)
axis(1, at=seq(0,100,25), labels=seq(0,100,25))
axis(2, at=seq(0,100,10), labels=seq(0,100,10))
abline(v=75, lty=2)
abline(h=90, lty=2)
dev.off()

#======================================================================================================
# The objective is to remove clouds in the year 2000 (which are mainly located above the moist forest).
# To do so, we will use the tree cover map by Hansen et al. using a threshold of 75\%

#= Mosaic with gdalbuildvrt
Input <- "gisdata/rasters/hansen/treecover2000/*.tif"
Output <- "outputs/treecover2000.vrt"
system(paste0("gdalbuildvrt -overwrite ",Output," ",Input))
#= Resample with gdalwrap
# Region
Extent <- "298440 7155900 1100820 8682420"
Res <- "30"
nodat <- "None"
proj.s <- "EPSG:4326"
proj.t <- "EPSG:32738"
otype <- "Byte"
Input <- "outputs/treecover2000.vrt"
Output <- "outputs/treecover2000.tif"
# gdalwarp
system(paste0("gdalwarp -overwrite -ot ",otype," -dstnodata ",nodat," -s_srs ",proj.s," -t_srs ",proj.t," -te ",Extent,
             " -tr ",Res," ",Res," -r bilinear -co 'COMPRESS=LZW' -co 'PREDICTOR=2' ",Input," ",Output))
#= Import treecover2000.tif into grass location
system("r.in.gdal --o input=outputs/treecover2000.tif output=tc2000")

#= Forest in 2000
# Integrating classes of forest in 2000 (111, 112, 115, 775 and 777) and uncertainties (152, 155, 555 and 755)
system("r.mapcalc 'for2000_temp = if(harper==111 || harper==112 || harper==115 || \\
       harper==775 || harper==777 || harper==152 || harper==155 || \\
       harper==555 || harper==755, 1, null())'")

# Replace uncertainties using Hansen tree cover and a threshold of 75\%
system("r.mapcalc --o 'for2000 = if((harper==152 || harper==155 || \\
       harper==555 || harper==755) && tc2000<75 , null(), for2000_temp)'")
#system("r.stats -c for2000_temp")
#1 110878983
#* 1250064481
#system("r.stats -c for2000")
#1 109763775
#* 1251179689
system("g.remove -f type=raster name=for2000_temp")

#= lossyear Hansen
#= Mosaic with gdalbuildvrt
Input <- "gisdata/rasters/hansen/lossyear/*.tif"
Output <-"outputs/lossyear.vrt"
system(paste("gdalbuildvrt -overwrite ",Output," ",Input,sep=""))
#= Resample with gdalwrap
# Region
Extent <- "298440 7155900 1100820 8682420"
Res <- "30"
nodat <- "None"
proj.s <- "EPSG:4326"
proj.t <- "EPSG:32738"
otype <- "Byte"
Input <- "outputs/lossyear.vrt"
Output <- "outputs/lossyear.tif"
# gdalwarp
system(paste0("gdalwarp -overwrite -ot ",otype," -dstnodata ",nodat," -s_srs ",proj.s," -t_srs ",proj.t," -te ",Extent,
             " -tr ",Res," ",Res," -r near -co 'COMPRESS=LZW' -co 'PREDICTOR=2' ",Input," ",Output))
#= Import lossyear.tif into grass location
system("r.in.gdal --o input=outputs/lossyear.tif output=lossyear")
#system("r.describe lossyear")
# * 1-14

#= Forest in year 2001-2014 ("at the end of the year", since 1 in lossyear is deforestation in 2001)
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

#====================================================================================
# Forest in 1990

#= Integrating classes of forest in 1990 (111, 112, 122, 115, 152, 155, 755, 775 and 777) and uncertainties (555)
system("r.mapcalc --o 'for1990_temp = if(harper==111 || harper==112 || harper==122 || \\
       harper==115 || harper==152 || harper==155 || harper==755 || \\
       harper==775 || harper==777, 1, if(harper==555, 5, null()))'")
system("r.stats -c for1990_temp")

#= If forest in 2000, then forest in 1990
system("r.mapcalc --o 'for1990_temp = if(!isnull(for2000) &&& for1990_temp==5, 1, for1990_temp)'")

#= How many ha of remaining clouds in harper for the year 1990
stats.residual <- system("r.stats -c for1990_temp", intern=TRUE) # "1 119582689"  "5 88716"      "* 1241272059"
df.stats.residual <- data.frame(matrix(as.numeric(unlist(strsplit(stats.residual," "))), ncol=2, byrow=TRUE))
names(df.stats.residual) <- c("class","ncells")
df.stats.residual$area <- round(df.stats.residual$ncells*30*30/10000)
residual.clouds.1990 <- df.stats.residual$area[df.stats.residual$class==5 & !is.na(df.stats.residual$class)]
SavedObjects <- c(SavedObjects, "residual.clouds.1990")

#= Removing remaining uncertainties (5) using forest-cover in 2000
system("r.mapcalc --o 'for1990 = if(for1990_temp==5, for2000, for1990_temp)'")
system("r.stats -c for1990") # 1 119582689 * 1241360775, all clouds were reclassified as non-forest
# system("g.remove -f type=raster name=for1990_temp")

#= Export
system("r.out.gdal --o input=for1990 createopt='compress=lzw,predictor=2' type=Byte output=outputs/for1990.tif")

#====================================================================================
# Forest c.1973

#= Reproject
Extent <- "298440 7155900 1100820 8682420"
Res <- "30"
nodat <- "0"
proj.s <- "EPSG:32638"
proj.t <- "EPSG:32738"
Input <- "gisdata/rasters/harper/for1973.tif"
Output <- "outputs/harper1973.tif"
# gdalwarp
system(paste0("gdalwarp -overwrite -dstnodata ",nodat," -s_srs ",proj.s," -t_srs ",proj.t," -te ",Extent,
              " -tr ",Res," ",Res," -r near -co 'COMPRESS=LZW' -co 'PREDICTOR=2' ",Input," ",Output))

#= Import forest map for the year 1973
system("r.in.gdal --o input=outputs/harper1973.tif output=harper1973")

#= Corrections from for1990
system("r.mapcalc --o 'for1973 = if(!isnull(for1990), for1990, harper1973)'")

#= Combine mangrove (7) and forest (1)
system("r.mapcalc --o 'for1973 = if(for1973==7, 1, for1973)'")

#= Cloud cover on for1973
stats.1973 <- system("r.stats -c for1973", intern=TRUE)
df.stats.1973 <- data.frame(matrix(as.numeric(unlist(strsplit(stats.1973," "))), ncol=2, byrow=TRUE))
names(df.stats.1973) <- c("class","ncells")
df.stats.1973$area <- round(df.stats.1973$ncells*30*30/10000)
cloud.1973 <- df.stats.1973$area[df.stats.1973$class==5 & !is.na(df.stats.1973$class)]
SavedObjects <- c(SavedObjects, "cloud.1973")

#= Export
system("r.out.gdal --o input=for1973 createopt='compress=lzw,predictor=2' type=Byte output=outputs/for1973.tif")

#= We rename for1973 (with cloud class 5) as for1973_5
#= for1973 will be without clouds
system("g.rename raster=for1973,for1973_5")
system("r.mapcalc --o 'for1973 = if(!isnull(for1973_5) &&& for1973_5==1, 1, null())'")

#====================================================================================
# Reproject c.1953

#= Reproject
Extent <- "298440 7155900 1100820 8682420"
Res <- "30"
nodat <- "0"
proj.s <- "EPSG:32638"
proj.t <- "EPSG:32738"
Input <- "gisdata/rasters/harper/madagascar_1950_4bit.img"
Output <- "outputs/harper1953.tif"
# gdalwarp
system(paste0("gdalwarp -overwrite -dstnodata ",nodat," -s_srs ",proj.s," -t_srs ",proj.t," -te ",Extent,
              " -tr ",Res," ",Res," -r near -co 'COMPRESS=LZW' -co 'PREDICTOR=2' ",Input," ",Output))

#= Import harper1953.tif into grass location
system("r.in.gdal --o input=outputs/harper1953.tif output=harper1953")
system("r.info harper1953")
system("r.stats -c harper1953")

#= Compute for1953
system("r.mapcalc --o 'for1953 = if(harper1953!=1,null(),1)'")
system("r.stats -c for1953")
## 1 225792265
## * 1135151199

#= Export
system("r.out.gdal --o input=for1953 createopt='compress=lzw,predictor=2' \\
       type=Byte output=outputs/for1953.tif")

# =======================================
# Remove salt and pepper
# =======================================

Year <- c(1953,1973,1990,2000,2005,2010,2014)
system("g.region rast=harper -ap")
system("r.mask --o raster=harper")
for (i in 1:length(Year)) {
  # Message
  cat(paste0("Year: ",Year[i],"\n"))
  # Computation  
  system(paste0("r.neighbors --o input=for",Year[i]," output=for",Year[i],"_sum method=sum size=3"))
  system(paste0("r.mapcalc --o 'for",Year[i]," = if(isnull(for",Year[i],") &&& for",Year[i],"_sum==8, 1, for",Year[i],")'"))
  # Export raster as .tif
  if (Year[i]!=1973) {
    system(paste0("r.out.gdal --o input=for",Year[i]," createopt='compress=lzw,predictor=2' \\
           type=Byte output=outputs/for",Year[i],".tif"))
  } else {
    system("r.out.gdal --o input=for1973_5 createopt='compress=lzw,predictor=2' \\
           type=Byte output=outputs/for1973.tif")
  }
}
system("r.mask -r")

#= Counting how many pixels were set as forest
Year <- c(1953,1973,1990,2000,2005,2010,2014)
system("g.region rast=harper -ap")
system("r.mask --o raster=harper")
for (i in 1:length(Year)) {
  # Message
  cat(paste0("Year: ",Year[i],"\n"))
  # Computation
  system(paste0("r.report map=for",Year[i],"_sum unit=h output=outputs/for",Year[i],"_sum.txt"))
}
system("r.mask -r")
# Summary data.frame
df.saltpepper <- data.frame(Year=Year,ha.salt=NA)
df.saltpepper$ha.salt <- c(95209,375241,482122,456907,540093,605812,590946)
write.table(df.saltpepper, file="outputs/saltpepper.txt", sep="\t", row.names=FALSE)

#====================================================================================
# Export images as .png and .gif

#= Colors
system("echo '1 26:152:80' | r.colors for1953 rules=-")
system("echo '1 26:152:80 \n 5 grey' | r.colors for1973_5 rules=-")
system("echo '1 26:152:80' | r.colors for1990 rules=-")
system("echo '1 26:152:80' | r.colors for2000 rules=-")
system("echo '1 26:152:80' | r.colors for2010 rules=-")
system("echo '1 26:152:80' | r.colors for2014 rules=-")

#= PNG
system("g.region res=1000")
system("r.out.png --o input=for1953 output=outputs/for1953.png")
system("r.out.png --o input=for1973_5 output=outputs/for1973.png")
system("r.out.png --o input=for1990 output=outputs/for1990.png")
system("r.out.png --o input=for2000 output=outputs/for2000.png")
system("r.out.png --o input=for2010 output=outputs/for2010.png")
system("r.out.png --o input=for2014 output=outputs/for2014.png")

# #= Animated GIF
# # Image Magick library should be installed: https://www.imagemagick.org
# system("convert -pointsize 72 -gravity North -draw \"text 0,0 '1953'\" outputs/for1953.png outputs/for1953.gif")
# system("convert -pointsize 72 -gravity North -draw \"text 0,0 '1973'\" outputs/for1973.png outputs/for1973.gif")
# system("convert -pointsize 72 -gravity North -draw \"text 0,0 '1990'\" outputs/for1990.png outputs/for1990.gif")
# system("convert -pointsize 72 -gravity North -draw \"text 0,0 '2000'\" outputs/for2000.png outputs/for2000.gif")
# system("convert -pointsize 72 -gravity North -draw \"text 0,0 '2010'\" outputs/for2010.png outputs/for2010.gif")
# system("convert -pointsize 72 -gravity North -draw \"text 0,0 '2014'\" outputs/for2014.png outputs/for2014.gif")
# system("convert -delay 100 -loop 0 outputs/*.gif outputs/defor_Mada.gif")
# ## system("rm *.png")

##==========================
## Forest density
##==========================

Year <- c(1953,1973,1990,2000,2005,2010,2014)
system("g.region rast=harper -ap")

# Density rules
txt <- c("0 thru 20 = 1", "21 thru 40 = 2", "41 thru 60 = 3", "61 thru 80 = 4", "81 thru 100 = 5")
writeLines(txt, "outputs/densrules.txt")

# Loop on years
for (i in 1:length(Year)) {
  # Message
  cat(paste("Year: ",Year[i],"\n",sep=""))
  # Mask on forest
  system(paste0("r.mask --o raster=for",Year[i]))
  # Forest density (takes several hours to run)
  system(paste0("r.neighbors --o input=for",Year[i]," output=forcount",Year[i]," method=count size=51"))
  system(paste0("r.mapcalc --o 'fordens",Year[i]," = round(100*forcount",Year[i],"/2601)'"))
  # Reclassify
  system(paste0("r.reclass --o input=fordens",Year[i]," output=fordens",Year[i],"_class rules=outputs/densrules.txt"))
  # Export
  system(paste0("r.out.gdal --o input=fordens",Year[i]," createopt='compress=lzw,predictor=2' type=Byte output=outputs/fordens",Year[i],".tif"))
  system(paste0("r.out.gdal --o input=fordens",Year[i],"_class createopt='compress=lzw,predictor=2' type=Byte output=outputs/fordens",Year[i],"_class.tif"))
}
# Prepare fordens2014_class for figures
system("r.mask --o raster=harper")
system("r.mapcalc --o 'fordens2014_class_mask = if(isnull(fordens2014_class), 0, fordens2014_class)'")
system("r.out.gdal --o input=fordens2014_class_mask nodata=255 type=Byte createopt='compress=lzw,predictor=2' \\
       output=outputs/fordens2014_class_mask.tif")
system("r.mask -r")

##==========================
## Forest fragmentation
##==========================

## The GRASS Add-on r.forestfrag must be installed
## https://grass.osgeo.org/grass72/manuals/addons/r.forestfrag.html

Year <- c(1953,1973,1990,2000,2005,2010,2014)
system("g.region rast=harper -ap")
system("r.mask --o raster=harper")
for (i in 1:length(Year)) {
  # Message
  cat(paste("Year: ",Year[i],"\n",sep=""))
  # Computation
  system(paste0("r.mapcalc --o 'for",Year[i],"_0 = if(!isnull(for",Year[i],"), 1, 0)'"))
  system(paste0("r.forestfrag input=for",Year[i],"_0 output=frag",Year[i]," size=7 --overwrite"))
  system(paste0("r.out.gdal --o input=frag",Year[i]," createopt='compress=lzw,predictor=2' type=Byte output=outputs/frag",Year[i],".tif"))
}
system("r.mask -r")

##==========================
## Distance to forest edge
##==========================

Year <- c(1953,1973,1990,2000,2005,2010,2014)
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
}
# Prepare dist_edge_2014 for figures
system("r.mask --o raster=harper")
system("r.mapcalc --o 'dist_edge_2014_mask = if(isnull(dist_edge_2014), 0, dist_edge_2014)'")
system("r.out.gdal --o input=dist_edge_2014_mask nodata=9999 createopt='compress=lzw,predictor=2' \\
       output=outputs/dist_edge_2014_mask.tif")
system("r.mask -r")

##==========================
## Histograms forest edge
##==========================

Year <- c(1953,1973,1990,2000,2005,2010,2014) 
year <- length(Year)
# Bins of distance
bins <- seq(0,5000,by=100)
nbins <- length(bins)-1
# Data-frame to store results
r <- data.frame()

# Loop on years
for (i in 1:length(Year)) {
  # Message
  cat(paste("Year: ",Year[i],"\n",sep=""))
  # Histogram
  his <- system(paste0("r.stats -nc input=dist_edge_",Year[i]), intern=TRUE)
  d <- data.frame(matrix(as.numeric(unlist(strsplit(his," "))), ncol=2, byrow=TRUE))
  names(d) <- c("bin","ncell")
  # Number of cells per bin of distance
  hist.df <- data.frame(bins=1:nbins,ncell=NA)
  for (i in 1:nbins) {
    w <- which(d$bin>=bins[i] & d$bin<bins[i+1])
    hist.df$ncell[i] <- sum(d$ncell[w])
  }
  # Proportion
  tot.cell <- sum(hist.df$ncell)
  hist.df$prop <- 100*hist.df$ncell/tot.cell
  # Store results
  r <- rbind(r,hist.df)
}
# Year as factor
r$Year <- as.factor(rep(Year,each=nbins))
# Reformat bins
r$bins <- r$bins*100-50
# Save results
write.table(r,file="outputs/histdist.txt",row.names=FALSE,sep="\t")

# Plot with ggplot
pp <- ggplot(data=r, aes(x=bins, y=prop, colour=Year)) + 
  xlab("Distance to forest edge (m)") +
  ylab("Proportion of forest (%)") +
  xlim(c(0,5000)) +
  geom_line()
ggsave("outputs/histdist.png",pp)

##========================
## Statistics whole forest
##========================

#= Deforestation statistics
Year <- c(1953,1973,1990,2000,2005,2010,2014)
defor.df <- data.frame(Year=Year,area=NA,clouds=0,ann.defor=NA,theta=NA)
# Areas
for (i in 1:length(Year)) {
  # Message
  cat(paste("Year: ",Year[i],"\n",sep=""))
  # Computation
  if (Year[i]=="1973") {
    statcell <- system("r.stats -c for1973_5", intern=TRUE)
  } else {
    statcell <- system(paste0("r.stats -c for",Year[i]), intern=TRUE)
  }
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
# Clouds in 1973
defor.df$clouds[defor.df$Year==1973] <- cloud.1973  
# Export
write.table(defor.df,"outputs/defor.txt",row.names=FALSE,sep="\t")

#= Deforestation statistics for comparison
Year <- c(1953,1973,1990,2000,2005,2010,2013)  # Here we add 2013
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
# Export
write.table(defor.df,"outputs/defor_for_comp.txt",row.names=FALSE,sep="\t")

#= Forest density statistics
Year <- c(1953,1973,1990,2000,2005,2010,2014)
fordens.df <- data.frame(Year=Year,forest=NA,cat1=NA,cat2=NA,
                      cat3=NA,cat4=NA,cat5=NA)
# Areas
for (i in 1:length(Year)) {
  # Message
  cat(paste("Year: ",Year[i],"\n",sep=""))
  # Computation
  statcell <- system(paste0("r.stats -c fordens",Year[i],"_class"), intern=TRUE)
  ncells <- as.numeric(matrix(unlist(strsplit(statcell,split=" ")),ncol=2,byrow=TRUE)[-c(6),2])
  fordens.df$forest[i] <- round(sum(ncells)*(as.numeric(Res)^2)/10000)
  fordens.df[i,c(3:7)] <- round(100*ncells/sum(ncells),2)
}
write.table(fordens.df,"outputs/fordens.txt",row.names=FALSE,sep="\t")

#= Fragmentation statistics
Year <- c(1953,1973,1990,2000,2005,2010,2014)
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

#= Distance to forest edge statistics ## Quantiles with r.quantile
Year <- c(1953,1973,1990,2000,2005,2010,2014)
dist.quant.df <- data.frame(Year=Year,median=NA,q1=NA,q2=NA)
# Loop on year
for (i in 1:length(Year)) {
  # Message
  cat(paste("Year: ",Year[i],"\n",sep=""))
  # Computation
  statcell <- system(paste0("r.quantile percentiles=5,50,95 input=dist_edge_",Year[i]), intern=TRUE)
  mat.statcell <- matrix(as.numeric(unlist(strsplit(statcell,split=":"))), byrow=TRUE, nrow=3)
  dist.quant.df$median[i] <- mat.statcell[2,3]
  dist.quant.df$q1[i] <- mat.statcell[1,3]
  dist.quant.df$q2[i] <- mat.statcell[3,3]
}
write.table(dist.quant.df,"outputs/dist.quant.txt",row.names=FALSE,sep="\t")

#= Distance to forest edge statistics
Year <- c(1953,1973,1990,2000,2005,2010,2014)
dist.df <- data.frame(Year=Year,min=NA,max=NA,mean=NA,sd=NA,q1=NA,q2=NA)
# Areas
for (i in 1:length(Year)) {
  # Message
  cat(paste("Year: ",Year[i],"\n",sep=""))
  # Computation
  statcell <- system(paste0("r.univar -e percentile=5,95 map=dist_edge_",Year[i]), intern=TRUE)
  dist.df$min[i] <- unlist(strsplit(statcell[7],split=" "))[2]
  dist.df$max[i] <- unlist(strsplit(statcell[8],split=" "))[2]
  dist.df$mean[i] <- unlist(strsplit(statcell[10],split=" "))[2]
  dist.df$sd[i] <- unlist(strsplit(statcell[12],split=" "))[3]
  dist.df$q1[i] <- unlist(strsplit(statcell[19],split=" "))[3]
  dist.df$q2[i] <- unlist(strsplit(statcell[20],split=" "))[3]
}
# Replacing approximated quantiles with exact values
dist.df$q1 <- dist.quant.df$q1
dist.df$q2 <- dist.quant.df$q2
write.table(dist.df,"outputs/dist.txt",row.names=FALSE,sep="\t")
  
#= Percentage of forest at less than 500m from the forest edge
Year <- c(1953,1973,1990,2000,2005,2010,2014)
perc.500m.dist.df <- data.frame(Year=Year,perc=NA)
# Intermediate rast
for (i in 1:length(Year)) {
  # Message
  cat(paste("Year: ",Year[i],"\n",sep=""))
  # Computation
  system(paste0("r.mapcalc 'dist_edge_500m_",Year[i]," = if(dist_edge_",Year[i],">=500,0,1)'"))
}
# Stats
for (i in 1:length(Year)) {
  # Message
  cat(paste("Year: ",Year[i],"\n",sep=""))
  # Computation
  stat500m <- system(paste0("r.stats -nacp input=dist_edge_500m_",Year[i]), intern=TRUE)
  mat.stat500m <- matrix(unlist(strsplit(stat500m,split=" ")), byrow=TRUE, nrow=2)
  perc.500m.dist.df$perc[i] <- as.numeric(sub("%","",mat.stat500m[2,4]))
}
write.table(perc.500m.dist.df,"outputs/perc_500m_dist.txt",row.names=FALSE,sep="\t")

#= Percentage of forest at less than 1km from the forest edge
Year <- c(1953,1973,1990,2000,2005,2010,2014)
perc.1km.dist.df <- data.frame(Year=Year,perc=NA)
# Intermediate rast
for (i in 1:length(Year)) {
  # Message
  cat(paste("Year: ",Year[i],"\n",sep=""))
  # Computation
  system(paste0("r.mapcalc --o 'dist_edge_1km_",Year[i]," = if(dist_edge_",Year[i],">=1000,0,1)'"))
}
# Stats
for (i in 1:length(Year)) {
  # Message
  cat(paste("Year: ",Year[i],"\n",sep=""))
  # Computation
  stat1km <- system(paste0("r.stats -nacp input=dist_edge_1km_",Year[i]), intern=TRUE)
  mat.stat1km <- matrix(unlist(strsplit(stat1km,split=" ")), byrow=TRUE, nrow=2)
  perc.1km.dist.df$perc[i] <- as.numeric(sub("%","",mat.stat1km[2,4]))
}
write.table(perc.1km.dist.df,"outputs/perc_1km_dist.txt",row.names=FALSE,sep="\t")

#= Percentage of forest at less than 100m from the forest edge
Year <- c(1953,1973,1990,2000,2005,2010,2014)
perc.100m.dist.df <- data.frame(Year=Year,perc=NA)
# Intermediate rast
for (i in 1:length(Year)) {
  # Message
  cat(paste("Year: ",Year[i],"\n",sep=""))
  # Computation
  system(paste0("r.mapcalc --o 'dist_edge_100m_",Year[i]," = if(dist_edge_",Year[i],">=100,0,1)'"))
}
# Stats
for (i in 1:length(Year)) {
  # Message
  cat(paste("Year: ",Year[i],"\n",sep=""))
  # Computation
  stat100m <- system(paste0("r.stats -nacp input=dist_edge_100m_",Year[i]), intern=TRUE)
  mat.stat100m <- matrix(unlist(strsplit(stat100m,split=" ")), byrow=TRUE, nrow=2)
  perc.100m.dist.df$perc[i] <- as.numeric(sub("%","",mat.stat100m[2,4]))
}
write.table(perc.100m.dist.df,"outputs/perc_100m_dist.txt",row.names=FALSE,sep="\t")


##========================
## Statistics by ecoregion
##========================

# Ecoregions
# 1: spiny, 2: mangroves, 3: moist, 4: dry
ecoregion <- c("spiny","mangroves","moist","dry")

# Loop on ecoregions
#for (j in 1:length(ecoregion)) {
for (j in 1:3) {
  # Message
  cat(paste0("Ecoregion: ",ecoregion[j]))
  # Mask
  system(paste0("r.mask --o raster=ecoregion maskcats=",j,"'"))
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

##========================================================
## Comparison with previous studies on forest-cover change
##========================================================

## Forest-cover
# Historical data
fcc.comp <- read.csv("data/fcc_comp.csv",header=TRUE)
ha.forest.2000.moist <- fcc.comp$y2000[fcc.comp$Source=="Harper2007" & fcc.comp$ForestType=="Moist"]
SavedObjects <- c(SavedObjects,"ha.forest.2000.moist")
# This study
defor_for_comp <- read.table("outputs/defor_for_comp.txt",header=TRUE)
defor_moist_for_comp <- read.table("outputs/defor_moist_for_comp.txt",header=TRUE)
defor_dry_for_comp <- read.table("outputs/defor_dry_for_comp.txt",header=TRUE)
defor_spiny_for_comp <- read.table("outputs/defor_spiny_for_comp.txt",header=TRUE)
defor_mangroves_for_comp <- read.table("outputs/defor_mangroves_for_comp.txt",header=TRUE)
# Complete data
fcc.comp[fcc.comp$ForestType=="Total" & fcc.comp$Source=="this study", 3:9] <- defor_for_comp$area
fcc.comp[fcc.comp$ForestType=="Moist" & fcc.comp$Source=="this study", 3:9] <- defor_moist_for_comp$area
fcc.comp[fcc.comp$ForestType=="Dry" & fcc.comp$Source=="this study", 3:9] <- defor_dry_for_comp$area
fcc.comp[fcc.comp$ForestType=="Spiny" & fcc.comp$Source=="this study", 3:9] <- defor_spiny_for_comp$area
fcc.comp[fcc.comp$ForestType=="Mangroves" & fcc.comp$Source=="this study", 3:9] <- defor_mangroves_for_comp$area
# This study for year 2014
defor <- read.table("outputs/defor.txt",header=TRUE)
defor_moist <- read.table("outputs/defor_moist.txt",header=TRUE)
defor_dry <- read.table("outputs/defor_dry.txt",header=TRUE)
defor_spiny <- read.table("outputs/defor_spiny.txt",header=TRUE)
defor_mangroves <- read.table("outputs/defor_mangroves.txt",header=TRUE)
# Complete data for year 2014
fcc.comp$y2014[fcc.comp$ForestType=="Total" & fcc.comp$Source=="this study"] <- defor$area[defor$Year==2014]
fcc.comp$y2014[fcc.comp$ForestType=="Moist" & fcc.comp$Source=="this study"] <- defor_moist$area[defor_moist$Year==2014]
fcc.comp$y2014[fcc.comp$ForestType=="Dry" & fcc.comp$Source=="this study"] <- defor_dry$area[defor_dry$Year==2014]
fcc.comp$y2014[fcc.comp$ForestType=="Spiny" & fcc.comp$Source=="this study"] <- defor_spiny$area[defor_spiny$Year==2014]
fcc.comp$y2014[fcc.comp$ForestType=="Mangroves" & fcc.comp$Source=="this study"] <- defor_mangroves$area[defor_mangroves$Year==2014]
# Save results
write.table(fcc.comp,file="outputs/fcc_comp.txt",row.names=FALSE)
SavedObjects <- c(SavedObjects,"fcc.comp")

## RMSE between studies forest-cover
this_study <- c(t(matrix(rep(as.numeric(unlist(fcc.comp[c(4,8,12,16,20),c(-1,-2)])),each=3),nrow=15)))
previous_studies <- c(t(fcc.comp[c(-4,-8,-12,-16,-20),c(-1,-2)]))
rmse.studies <- as.data.frame(cbind(this_study,previous_studies))
cor.fc <- cor(rmse.studies$this_study,rmse.studies$previous_studies, use="complete.obs") # 0.99
errors.fc <- rmse.studies$this_study-rmse.studies$previous_studies
Mean.fc <- mean(rmse.studies$this_study[!is.na(rmse.studies$previous_studies)]) # 4.8 Mha
RMSE.fc <- sqrt(mean(errors^2, na.rm=TRUE)) # 299750 ha
PRMSE.fc <- 100*RMSE.fc/Mean.fc # 6%
SavedObjects <- c(SavedObjects,"cor.fc","Mean.fc","RMSE.fc","PRMSE.fc")

## Deforestation
# Historical data
defor.comp <- read.csv("data/defor_comp.csv",header=TRUE,stringsAsFactors=FALSE)
defor.comp.thistudy <- defor.comp # a copy of defor.comp
# Deforestation ha/yr
defor.ha.comp <- fcc.comp[,c(2,1,3:8)]
periods <- c("p1953-1973","p1973-1990","p1990-2000","p2000-2005","p2005-2010","p2010-2013")
lp <- c(20,17,10,5,5,3)
names(defor.ha.comp)[3:8] <- periods
for (i in 1:length(periods)) {
  defor.ha.comp[,2+i] <- round((fcc.comp[,2+i]-fcc.comp[,2+1+i])/lp[i])
}
# Deforestation %/yr
defor.perc.comp <- defor.ha.comp
for (i in 1:length(periods)) {
  defor.perc.comp[,2+i] <- round(100*(1-(1-(fcc.comp[,2+i]-fcc.comp[,2+1+i])/fcc.comp[,2+i])^(1/lp[i])),1)
}
# Combining ha and percentages
ha <- as.numeric(unlist(defor.ha.comp[,3:8]))
ha <- format(round(ha/1000), big.mark=",")
perc <- sprintf("%.1f", as.numeric(unlist(defor.perc.comp[,3:8])))
defor.comp.thistudy[,3:8] <- data.frame(matrix(paste(ha," (",perc,")", sep=""),ncol=6),stringsAsFactors=FALSE)
defor.comp.thistudy[defor.comp.thistudy=="NA (NA)"] <- NA
# We can check how defor.comp (original deforestation rate estimates) and defor.comp.study (deforestation rates estimated here) differ
#defor.comp
#defor.comp.thistudy
# We keep only the results of our study
defor.comp[defor.comp$Source=="this study",3:8] <- defor.comp.thistudy[defor.comp.thistudy$Source=="this study",3:8]
# Save results
write.table(defor.comp,file="outputs/defor_comp.txt",row.names=FALSE)
SavedObjects <- c(SavedObjects,"defor.comp")

##========================
## Forest-cover change map
##========================

## Raster of water-bodies over Madagascar
# Region
Extent <- "298440 7155900 1100820 8682420"
Res <- "30"
proj.s <- "EPSG:4326"
proj.t <- "EPSG:32738"
Input <- "outputs/water.vrt"
Output <- "outputs/water.tif"
# gdalbuildvrt
system("gdalbuildvrt -overwrite outputs/water.vrt gisdata/rasters/waterbodies/*.tif")
# gdalwarp
system(paste0("gdalwarp -overwrite -s_srs ",proj.s," -t_srs ",proj.t," -te ",Extent,
              " -tr ",Res," ",Res," -r near -ot Byte -co 'COMPRESS=LZW' -co 'PREDICTOR=2' ",Input," ",Output))
# Import
system("r.in.gdal --o input=outputs/water.tif output=water")

## FCC map

# Mask on Harper map
system("r.null map=harper setnull=0 --verbose")
system("r.mask --o raster=harper")
# Compute fcc
system(paste0("r.mapcalc --o 'fcc = if(!isnull(for2014),24,if(!isnull(for2000),23,if(!isnull(for1990),22, \\
       if(!isnull(for1973) &&& for1973==1,21,if(!isnull(water) &&& water>0,water, \\
              if(!isnull(for1953),20,if(!isnull(for1973) &&& for1973==5,215,0)))))))'"))
# Color palette
system("r.colors map=fcc rules=- << EOF
0 243:243:220
1 153:217:234
12 0:0:170
20 243:243:220
21 100:100:100
215 243:243:220
22 255:165:0
23 255:0:0
24 34:139:34
nv 255:255:255
EOF")
# Export
system("r.out.gdal --o input=fcc createopt='compress=lzw,predictor=2' type=Byte output=outputs/fcc.tif")

# Compute fcc_for1953
system(paste0("r.mapcalc --o 'fcc_for1953 = if(!isnull(for1953),20,if(!isnull(water) &&& water>0,water,0))'"))
# Color palette
system("r.colors map=fcc_for1953 rules=- << EOF
0 243:243:220
1 153:217:234
12 0:0:170
20 34:139:34
nv 255:255:255
EOF")
# Export
system("r.out.gdal --o input=fcc_for1953 createopt='compress=lzw,predictor=2' type=Byte output=outputs/fcc_for1953.tif")

# Remove mask
system("r.mask -r")

## =======================================
## Plot raster with gplot() from rasterVis
source(file="R/plotfcc.R")

##==================================================
## Plot for evolution of the distance to forest edge
##==================================================

# Data
dist.df <- read.table(file="outputs/dist.txt", header=TRUE)
perc.100m.df <- read.table(file="outputs/perc_100m_dist.txt", header=TRUE)

# Plot
png(file="outputs/dist.png",width=600,height=450)
par(mar=c(4,4,0,0),cex=2,lwd=2)
plot(NA, xlim=c(1953,2014), ylim=c(0,5000),
     xlab="Year",
     ylab="Distance to forest edge (km)",
     axes=FALSE)
# Perc
segments(x0=1953,x1=2014,y0=100,y1=100,lty=3,col=grey(0.5))
label.perc <- round(perc.100m.df$perc)
label.perc[1] <- paste0(label.perc[1], "%")
#text(x=perc.100m.df$Year, y=-200, labels=label.perc, cex=0.9, adj=0.5)
mtext(text=label.perc, at=perc.100m.df$Year, side=1, line=-0.5, cex=1.4, adj=0.5)
# Quantiles
segments(x0=dist.df$Year,x1=dist.df$Year,y0=dist.df$q1,y1=dist.df$q2,lty=2)
segments(x0=dist.df$Year-1,x1=dist.df$Year+1,y0=dist.df$q2,y1=dist.df$q2,lty=1)
segments(x0=dist.df$Year-1,x1=dist.df$Year+1,y0=dist.df$q1,y1=dist.df$q1,lty=1)
axis(1,at=c(1953,1973,1990,2000,2005,2010,2014),labels=c(1953,1973,1990,2000,2005,2010,2014),
     las=3, pos=-500)
axis(2,at=seq(0,5000,by=1000),labels=seq(0,5,by=1))
points(dist.df$Year, dist.df$mean, type="b", pch=19)
dev.off()

##==================================================
## Carbon emissions between 2010 and 2014
##==================================================

system("r.in.gdal --o input=gisdata/rasters/carbon/ACD_RF_2010.tif output=acd")
system("g.region rast=for2010 -ap")
system("r.mask --o raster=for2010")
system("r.univar map=acd")
system("g.region rast=for2014 -ap")
system("r.mask --o raster=for2014")
system("r.univar map=acd")
system("r.mask -r")
acd_2010 <- 9700502114*30*30/10000 # 873045190
acd_2014 <- 9253573526*30*30/10000 # 832821617
carbon_emissions <- acd_2010-acd_2014
SavedObjects <- c(SavedObjects,"carbon_emissions")

##========================
## Save objects
##========================

# load("deforestmap.rda")
save(list=SavedObjects,file="deforestmap.rda")

##========================
## Knit the document
##========================

## Set knitr chunk default options
library(knitr)
opts_chunk$set(echo=FALSE, cache=FALSE,
               results="hide", warning=FALSE,
               message=FALSE, highlight=TRUE,
               fig.show="hide", size="small",
               tidy=FALSE)
options(knitr.kable.NA="-")
opts_knit$set(root.dir="manuscript")

## Knit
knitr::knit2pdf("manuscript/manuscript.Rnw", output="manuscript/manuscript.tex")

## Cover letter
rmarkdown::render("manuscript/coverletter/coverletter3.md", output_format=c("pdf_document"),
                  output_dir="manuscript/coverletter") # pdf output

##===========================================================================
## End of script
##===========================================================================
