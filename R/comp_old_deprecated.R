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
