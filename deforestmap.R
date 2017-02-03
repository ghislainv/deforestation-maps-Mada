##=========================================================================
## Sixty years of deforestation and forest fragmentation in Madagascar
## Ghislain Vieilledent <ghislain.vieilledent@cirad.fr>
## January 2017
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
## Create new directories to save outputs
dir.create("outputs")

#= Projection UTM38S (EPSG:32738)

#= Reproject CI map

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

#= Typology of CI map
system("r.info harper")
system("r.describe harper")
# * 111 112 115 122 152 155 222 444 555 755 775 777
# 1=forest, 2=nonforest, 5=cloud, 4=water, 7=mangrove

system("r.report harper units=h")

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
# The objective is to remove clouds (above the moist forest in the year 2000).
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
system("r.out.gdal --o input=for2014 createopt='compress=lzw,predictor=2' type=Byte output=outputs/for2014.tif")
system("r.out.gdal --o input=for2010 createopt='compress=lzw,predictor=2' type=Byte output=outputs/for2010.tif")
system("r.out.gdal --o input=for2005 createopt='compress=lzw,predictor=2' type=Byte output=outputs/for2005.tif")
system("r.out.gdal --o input=for2000 createopt='compress=lzw,predictor=2' type=Byte output=outputs/for2000.tif")

#====================================================================================
# Forest in 1990

#= Integrating classes of forest in 1990 (111, 112, 122, 115, 152, 155, 755, 775 and 777) and uncertainties (555)
system("r.mapcalc --o 'for1990_temp = if(harper==111 || harper==112 || harper==122 || \\
       harper==115 || harper==152 || harper==155 || harper==755 || \\
       harper==775 || harper==777 || harper==555, 1, null())'")

# How many ha of uncertainties ?
# 9603 ha of 555 in harper

#= Removing uncertainties (555) using land-cover in 2000
system("r.mapcalc --o 'for1990 = if(harper==555 && isnull(for2000), null(), for1990_temp)'")
system("r.stats -c for1990_temp") # 1 119671405
system("r.stats -c for1990") # 1 119582639
system("g.remove -f type=raster name=for1990_temp")

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

#= Deforestation rate 1973-1990
system("r.stats -c for1973")
## 1 158236269
## 5 36850880
## * 1165856315

system("r.stats -c for1990")
## 1 119582639
## * 1241360825

theta.prim <- (158236269-119582639)/158236269
Y <- 1990-1973
theta <- 1-(1-theta.prim)^(1/Y) # 1.6 %.yr-1 (ok, in line with Harper et al. 2007)

#= Export
system("r.out.gdal --o input=for1973 createopt='compress=lzw,predictor=2' type=Byte output=outputs/for1973.tif")

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

#= Import for1953_orig_30m.tif into grass location
system("r.in.gdal --o input=outputs/harper1953.tif output=harper1953")
system("r.info harper1953")
system("r.stats -c harper1953")

#= Corrections from for1973
system("r.mapcalc --o 'for1953 = if(!isnull(for1973) &&& (for1973==1 || for1973==7), 1, harper1953)'")
system("r.mapcalc --o 'for1953 = if(for1953!=1,null(),1)'")
system("r.stats -c for1953")
## 1 225792265
## * 1135151199

#= Export
system("r.out.gdal --o input=for1953 createopt='compress=lzw,predictor=2' type=Byte output=outputs/for1953.tif")

#====================================================================================
# Export images

#= Colors
system("echo '1 26:152:80' | r.colors for1953 rules=-")
system("echo '1 26:152:80 \n 5 grey' | r.colors for1973 rules=-")
system("echo '1 26:152:80' | r.colors for1990 rules=-")
system("echo '1 26:152:80' | r.colors for2000 rules=-")
system("echo '1 26:152:80' | r.colors for2010 rules=-")
system("echo '1 26:152:80' | r.colors for2014 rules=-")

# #= PNG
system("g.region res=1000")
system("r.out.png input=for1953 output=outputs/for1953.png")
system("r.out.png input=for1973 output=outputs/for1973.png")
system("r.out.png input=for1990 output=outputs/for1990.png")
system("r.out.png input=for2000 output=outputs/for2000.png")
system("r.out.png input=for2010 output=outputs/for2010.png")
system("r.out.png input=for2014 output=outputs/for2014.png")

#= Label and convert to gif
system("convert -pointsize 72 -gravity North -draw \"text 0,0 '1953'\" outputs/for1953.png outputs/for1953.gif")
system("convert -pointsize 72 -gravity North -draw \"text 0,0 '1973'\" outputs/for1973.png outputs/for1973.gif")
system("convert -pointsize 72 -gravity North -draw \"text 0,0 '1990'\" outputs/for1990.png outputs/for1990.gif")
system("convert -pointsize 72 -gravity North -draw \"text 0,0 '2000'\" outputs/for2000.png outputs/for2000.gif")
system("convert -pointsize 72 -gravity North -draw \"text 0,0 '2010'\" outputs/for2010.png outputs/for2010.gif")
system("convert -pointsize 72 -gravity North -draw \"text 0,0 '2014'\" outputs/for2014.png outputs/for2014.gif")
## system("rm *.png")

#= Animated gif
system("convert -delay 100 -loop 0 outputs/*.gif outputs/defor_Mada.gif")
#= See also OpenShot app for movie and transition effects

##==========================
## Validation
##==========================

# Import perr-fh map
system("r.in.gdal --o input=gisdata/rasters/perr-fh/FCC_051013_MG_VF_38s.tif output=perrfh")

# Classification
system("r.describe perrfh")
# * 7 111 113 119 133 183 222 223 228 233 288 333 444 533 553 555 666 733 773 777 778 788 888 1000
# 1=moist_forest, 2=dry_forest, 3=no_forest, 4=water, 5=spiny_forest, 6=building/soil/rock,
# 7=mangroves, 8=cloud/shadow, 9=cloud, 1000=artefact

# 111	Forêt humide 2013
# 113	Déforestation 2010-2013
# 119	Nuage 2013
# 133	Déforestation 2005-2013
# 183	Ombre 2010
# 222	Forêt sèche 2013
# 223	Déforestation forêt séche 2010-2013
# 228	Ombre 2013
# 233	Déforestation forêt séche 2005-2010
# 288	Ombre 2010
# 333	Mosaic de culture, jachère et savane
# 444	Zone en eau
# 533	Déforestation forêt épineuse 2005-2010
# 553	Déforestation forêt épineuse 2010-2013
# 555	Forêt épineuse
# 666	Etablissement, sol et roche nue
# 733	Déforestation forêt de mangrove 2005-2010
# 773	Déforestation forêt de Mangrove 2010-2013
# 777	Forêt Mangrove 2013
# 778	Nuage 2010
# 788	Nuage 2010
# 888	Nuage

# Report
system("r.report perrfh units=h")

# +-----------------------------------------------------------------------------+
# |                         RASTER MAP CATEGORY REPORT                          |
# |LOCATION: deforestmap                                Fri Feb  3 11:25:54 2017|
# |-----------------------------------------------------------------------------|
# |          north: 8682420    east: 1100820                                    |
# |REGION    south: 7155900    west:  298440                                    |
# |          res:        30    res:       30                                    |
# |-----------------------------------------------------------------------------|
# |MASK: none                                                                   |
# |-----------------------------------------------------------------------------|
# |MAP: (untitled) (perrfh in PERMANENT)                                        |
# |-----------------------------------------------------------------------------|
# |                      Category Information                       |           |
# |   #|description                                                 |   hectares|
# |-----------------------------------------------------------------------------|
# |   7| . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .|         86|
# | 111| . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .|  4,294,071|
# | 113| . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .|     91,692|
# | 119| . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .|         27|
# | 133| . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .|     82,108|
# | 183| . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .|         14|
# | 222| . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .|  2,668,108|
# | 223| . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .|    264,271|
# | 228| . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .|       5644|
# | 233| . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .|    203,389|
# | 288| . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .|        104|
# | 333| . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .| 47,846,303|
# | 444| . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .|    781,158|
# | 533| . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .|    120,621|
# | 553| . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .|     86,507|
# | 555| . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .|  1,506,507|
# | 666| . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .|    968,531|
# | 733| . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .|       2288|
# | 773| . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .|       1313|
# | 777| . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .|    241,526|
# | 778| . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .|        559|
# | 788| . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .|          0|
# | 888| . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .|         79|
# |1000| . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .|       1692|
# |   *|no data. . . . . . . . . . . . . . . . . . . . . . . . . . .| 63,318,314|
# |-----------------------------------------------------------------------------|
# |TOTAL                                                            |122,484,912|
# +-----------------------------------------------------------------------------+

# Reclassification (5 means "unknown")
# 2005
system("r.reclass --o input=perrfh output=perrfh2005 rules=- << EOF
111 113 119 133 183 222 223 228 233 288 533 553 555 733 773 777 778 788 = 1
7 888 1000 = 5
444 666 333 = NULL
* = NULL
EOF")
system("r.mapcalc --o 'perrfh2005 = perrfh2005'")
# 2010
system("r.reclass --o input=perrfh output=perrfh2010 rules=- << EOF
111 113 119 222 223 228 553 555 773 777 778 = 1
7 888 1000 183 288 788 = 5
444 666 333 133 233 533 733 = NULL
* = NULL
EOF")
system("r.mapcalc --o 'perrfh2010 = perrfh2010'")
# 2013
system("r.reclass --o input=perrfh output=perrfh2013 rules=- << EOF
111 222 555 777 = 1
7 888 1000 288 788 119 228 778 = 5
444 666 333 133 233 533 733 113 223 553 773 183 = NULL
* = NULL
EOF")
system("r.mapcalc --o 'perrfh2013 = perrfh2013'")

#===========
# Comparison
Year <- c(2005, 2010, 2013)
comp.df <- data.frame(Year=Year,BSM=NA,PERR_FH=NA,PERR_FH_NA=NA,
                      ad_BSM=NA,ad_PERR_FH=NA,
                      theta_BSM=NA,theta_PERR_FH=NA)
# Areas
for (i in 1:length(Year)) {
  # Message
  cat(paste("Year: ",Year[i],"\n",sep=""))
  # Computation
  # BioSceneMada (BSM)
  statcell.BSM <- system(paste0("r.stats -c for",Year[i]), intern=TRUE)
  ncells.BSM <- as.numeric(strsplit(statcell.BSM[1],split=" ")[[1]][2])
  comp.df$BSM[i] <- round(ncells.BSM*(as.numeric(Res)^2)/10000)
  # PERR-FH
  statcell.perrfh <- system(paste0("r.stats -c perrfh",Year[i]), intern=TRUE)
  ncells.perrfh.for <- as.numeric(strsplit(statcell.perrfh[1],split=" ")[[1]][2])
  ncells.perrfh.na <- as.numeric(strsplit(statcell.perrfh[2],split=" ")[[1]][2])
  comp.df$PERR_FH[i] <- round(ncells.perrfh.for*(as.numeric(Res)^2)/10000)
  comp.df$PERR_FH_NA[i] <- round(ncells.perrfh.na*(as.numeric(Res)^2)/10000)
}
# Defor
for (i in 2:length(Year)) {
  Y <- comp.df$Year[i]-comp.df$Year[i-1]
  # BioSceneMada (BSM)
  theta.prim <- (comp.df$BSM[i-1]-comp.df$BSM[i])/comp.df$BSM[i-1]
  comp.df$ad_BSM[i] <- round((comp.df$BSM[i-1]-comp.df$BSM[i])/Y)
  comp.df$theta_BSM[i] <- round(100*(1-(1-theta.prim)^(1/Y)),2)
  # PERR-FH
  theta.prim <- (comp.df$PERR_FH[i-1]-comp.df$PERR_FH[i])/comp.df$PERR_FH[i-1]
  comp.df$ad_PERR_FH[i] <- round((comp.df$PERR_FH[i-1]-comp.df$PERR_FH[i])/Y)
  comp.df$theta_PERR_FH[i] <- round(100*(1-(1-theta.prim)^(1/Y)),2)
}
# Difference area
comp.df$diff.area <- round(100*(comp.df$BSM-comp.df$PERR_FH)/comp.df$PERR_FH,2)
# Save
write.table(comp.df,"outputs/comp.txt",row.names=FALSE,sep="\t")

#================================
# Comparison on moist forest only

# Ecoregions
system("v.in.ogr --o input=gisdata/vectors layer=madagascar_ecoregion_tenaizy_38s output=ecoregions")

# Mask on humid ecoregion
system("r.mask --o vector=ecoregions where='ecoregion==3'")
system("r.mapcalc --o 'mask_moist = MASK'")

# Data
Year <- c(2005, 2010, 2013)
comp_moist.df <- data.frame(Year=Year,BSM=NA,PERR_FH=NA,PERR_FH_NA=NA,
                            ad_BSM=NA,ad_PERR_FH=NA,
                            theta_BSM=NA,theta_PERR_FH=NA)
# Areas
for (i in 1:length(Year)) {
  # Message
  cat(paste("Year: ",Year[i],"\n",sep=""))
  # Computation
  # BioSceneMada (BSM)
  statcell.BSM <- system(paste0("r.stats -c for",Year[i]), intern=TRUE)
  ncells.BSM <- as.numeric(strsplit(statcell.BSM[1],split=" ")[[1]][2])
  comp_moist.df$BSM[i] <- round(ncells.BSM*(as.numeric(Res)^2)/10000)
  # PERR-FH
  statcell.perrfh <- system(paste0("r.stats -c perrfh",Year[i]), intern=TRUE)
  ncells.perrfh.for <- as.numeric(strsplit(statcell.perrfh[1],split=" ")[[1]][2])
  ncells.perrfh.na <- as.numeric(strsplit(statcell.perrfh[2],split=" ")[[1]][2])
  comp_moist.df$PERR_FH[i] <- round(ncells.perrfh.for*(as.numeric(Res)^2)/10000)
  comp_moist.df$PERR_FH_NA[i] <- round(ncells.perrfh.na*(as.numeric(Res)^2)/10000)
}
# Defor
for (i in 2:length(Year)) {
  Y <- comp_moist.df$Year[i]-comp_moist.df$Year[i-1]
  # BioSceneMada (BSM)
  theta.prim <- (comp_moist.df$BSM[i-1]-comp_moist.df$BSM[i])/comp_moist.df$BSM[i-1]
  comp_moist.df$ad_BSM[i] <- round((comp_moist.df$BSM[i-1]-comp_moist.df$BSM[i])/Y)
  comp_moist.df$theta_BSM[i] <- round(100*(1-(1-theta.prim)^(1/Y)),2)
  # PERR-FH
  theta.prim <- (comp_moist.df$PERR_FH[i-1]-comp_moist.df$PERR_FH[i])/comp_moist.df$PERR_FH[i-1]
  comp_moist.df$ad_PERR_FH[i] <- round((comp_moist.df$PERR_FH[i-1]-comp_moist.df$PERR_FH[i])/Y)
  comp_moist.df$theta_PERR_FH[i] <- round(100*(1-(1-theta.prim)^(1/Y)),2)
}
# Difference area
comp_moist.df$diff.area <- round(100*(comp_moist.df$BSM-comp_moist.df$PERR_FH)/comp_moist.df$PERR_FH,2)
# Save
write.table(comp_moist.df,"outputs/comp_moist.txt",row.names=FALSE,sep="\t")
# Remove mask
system("r.mask -r")

##==========================
## Forest fragmentation
##==========================

Year <- c(1953,1973,1990,2000,2010,2014)
system("g.region rast=harper -ap")
for (i in 1:length(Year)) {
  # Message
  cat(paste("Year: ",Year[i],"\n",sep=""))
  # Computation
  system(paste0("r.mapcalc --o 'for",Year[i],"_0 = if(!isnull(for",Year[i],"), 1, 0)'"))
  system(paste0("r.forestfrag input=for",Year[i],"_0 output=frag",Year[i]," size=7 --overwrite"))
  system(paste0("r.out.gdal --o input=frag",Year[i]," createopt='compress=lzw,predictor=2' type=Byte output=outputs/frag",Year[i],".tif"))
}

##==========================
## Statistics
##==========================

#= Deforestation statistics
Year <- c(1953,1973,1990,2000,2010,2014)
defor.df <- data.frame(Year=Year,ncells=NA,area=NA,ann.defor=NA,theta=NA)
# Areas
for (i in 1:length(Year)) {
  # Message
  cat(paste("Year: ",Year[i],"\n",sep=""))
  # Computation
  statcell <- system(paste0("r.stats -c for",Year[i]), intern=TRUE)
  defor.df$ncells[i] <- as.numeric(strsplit(statcell[1],split=" ")[[1]][2])
  defor.df$area[i] <- round(defor.df$ncells[i]*(as.numeric(Res)^2)/10000)
}
# Annual rates
for (i in 2:length(Year)) {
  theta.prim <- (defor.df$area[i-1]-defor.df$area[i])/defor.df$area[i-1]
  Y <- defor.df$Year[i]-defor.df$Year[i-1]
  defor.df$ann.defor[i] <- round((defor.df$area[i-1]-defor.df$area[i])/Y)
  defor.df$theta[i] <- round(100*(1-(1-theta.prim)^(1/Y)),2)
}
write.table(defor.df,"outputs/defor.txt",row.names=FALSE,sep="\t")

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
  ncells <- as.numeric(matrix(unlist(strsplit(statcell,split=" ")),ncol=2,byrow=TRUE)[-1,2])
  frag.df$forest[i] <- round(sum(ncells)*(as.numeric(Res)^2)/10000)
  frag.df[i,c(3:8)] <- round(100*ncells/sum(ncells),2)
}
write.table(frag.df,"outputs/frag.txt",row.names=FALSE,sep="\t")

##========================
## Save objects
##========================

# load("deforestmap.rda")
save(list=ls(all.names=TRUE),file="deforestmap.rda")

##========================
## Knit the document
##========================

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

