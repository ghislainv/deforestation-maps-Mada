#!/usr/bin/Rscript

# ==============================================================================
# author          :Ghislain Vieilledent
# email           :ghislain.vieilledent@cirad.fr, ghislainv@gmail.com
# web             :https://ghislainv.github.io
# license         :GPLv3
# ==============================================================================

library(ggplot2)
library(rasterVis)
library(gridExtra)
library(grid)
library(rgdal)

# Zooms
zoom.w <- list(xmin=346000,xmax=439000,ymin=7387000,ymax=7480000)
zoom.e <- list(xmin=793000,xmax=886000,ymin=7815000,ymax=7908000)
zooms <- list(zoom.w,zoom.e)

# Compute zooms
for (z in 1:length(zooms)) {
  ExtentZ <- paste(zooms[[z]]$xmin,zooms[[z]]$ymin,zooms[[z]]$xmax,zooms[[z]]$ymax)
  Input <- c("fcc.tif","fcc_for1953.tif","frag2014.tif","dist_edge_2014_mask.tif")
  nodata <- c(rep(255,3),9999)
  Output <- paste0(sub(".tif","",Input),"_zoom",z,".tif")
  for (i in 1:length(Input)) {
    system(paste0("gdalwarp -overwrite -srcnodata ",nodata[i]," -dstnodata ",nodata[i]," -te ",ExtentZ," -co 'COMPRESS=LZW' -co 'PREDICTOR=2' ",
                  paste0("outputs/",Input[i])," ",paste0("outputs/",Output[i])))
  }
}

# Resolution
res <- 10e5

# get_legend()
get_legend <- function(myggplot) {
  # Function to extract legend from a plot
  tmp <- ggplot_gtable(ggplot_build(myggplot))
  leg <- which(sapply(tmp$grobs, function(x) {x$name}) == "guide-box")
  legend <- tmp$grobs[[leg]]
  return(legend)
}

# ======
# Colors
for2014.col = rgb(34/255,139/255,34/255) # forest green
defor00_14.col = rgb(255/255,0/255,0/255) # red
defor90_00.col = rgb(255/255,165/255,0/255) # orange
defor73_90.col = rgb(100/255,100/255,100/255) # grey
nofor73.col = rgb(243/255,243/255,220/255) # light yellow
w1.col = rgb(153/255,217/255,234/255) # light blue
w2.col = rgb(0/255,0/255,170/255) # dark blue
water.col <-colorRampPalette(c(w1.col,w2.col))(12)

# =======
# Palette
# fcc (discrete)
fcc.col <- c(nofor73.col,water.col,nofor73.col,defor73_90.col,nofor73.col,
             defor90_00.col,defor00_14.col,for2014.col)
fcc.name <- c(0,1:12,20,21,215,22,23,24)
fcc.palette <- paste0("c(",paste0("\"",fcc.name,"\"","=","\"",fcc.col,"\"",collapse=","),")")
fcc.palette <- eval(parse(text=fcc.palette))
# fcc_for1953 (discrete)
fcc_for1953.col <- c(nofor73.col,water.col,for2014.col)
fcc_for1953.name <- c(0,1:12,20)
fcc_for1953.palette <- paste0("c(",paste0("\"",fcc_for1953.name,"\"","=","\"",
                                          fcc_for1953.col,"\"",collapse=","),")")
fcc_for1953.palette <- eval(parse(text=fcc_for1953.palette))
# fragmentation (discrete)
cf <- colorRampPalette(c("darkred","orange","darkgreen"))(5)
frag.col <- c(nofor73.col,cf)
frag.name <- c(0:6)
frag.palette <- paste0("c(",paste0("\"",frag.name,"\"","=","\"",
                                   frag.col,"\"",collapse=","),")")
frag.palette <- eval(parse(text=frag.palette))
# distance to forest edge (continuous)
dist.v <- c(50,100,500,1000,3000)
dist.vr <- c(0,dist.v)/3000 # rescale
cf <- colorRampPalette(c("darkred","orange","darkgreen"))(5)
dist.palette <- c(nofor73.col,cf)

# ======
# Themes
theme_base <- theme(axis.line=element_blank(),
                    axis.text.x=element_blank(),
                    axis.text.y=element_blank(),
                    axis.ticks=element_blank(),
                    axis.title.x=element_blank(),
                    axis.title.y=element_blank(),
                    plot.margin=unit(c(0,0,0,0),"null"),
                    panel.spacing=unit(c(0,0,0,0),"null"),
                    plot.background=element_rect(fill="transparent"),
                    panel.background=element_rect(fill="transparent"),
                    panel.grid.major=element_blank(),
                    panel.grid.minor=element_blank(),
                    panel.border=element_blank())

theme_zoom <- theme(axis.line=element_blank(),
                    axis.text.x=element_blank(),
                    axis.text.y=element_blank(),
                    axis.ticks=element_blank(),
                    axis.title.x=element_blank(),
                    axis.title.y=element_text(size=18, margin=margin(0,-5,0,0)),
                    plot.title=element_text(size=20,face="bold",hjust=0.5,
                                            margin=margin(-0.5,0,0,0,"lines")),
                    plot.margin=margin(0.5,0,1.0,0.25,"lines"),
                    panel.spacing=unit(c(0,0,0,0),"null"),
                    legend.position="none",
                    plot.background=element_rect(fill="transparent"),
                    panel.background=element_rect(fill="transparent"),
                    panel.grid.major=element_blank(),
                    panel.grid.minor=element_blank(),
                    panel.border=element_blank())

# ================
# ggplot functions

# plot_zoom_fcc()
plot_zoom_fcc <- function(rast_file,palette=fcc.palette) {
  r <- raster(rast_file)
  pzoom <- gplot(r,maxpixels=res) +
    geom_raster(aes(fill=factor(value))) +
    scale_fill_manual(values=palette,
                      na.value="transparent") +
    theme_bw() + theme_zoom + coord_equal() +
    theme(legend.position="none")
  return(pzoom)
}

# plot_zoom_frag()
plot_zoom_frag <- function(rast_file,palette=frag.palette) {
  r <- raster(rast_file)
  pzoom <- gplot(r,maxpixels=res) +
    geom_raster(aes(fill=factor(value))) + ylab("Fragmentation 2014") +
    scale_fill_manual(values=palette,breaks=c(1:5),
                      na.value="transparent",
                      guide=guide_legend(title="Frag. index",title.position="top",
                                         label.position="right")) +
    theme_bw() + theme_zoom + coord_equal() +
    theme(legend.position="bottom", 
          legend.margin=margin(-1.5,-1,-1,-1,"lines"))
  return(pzoom)
}

# plot_zoom_dist()
plot_zoom_dist <- function(rast_file,palette=dist.palette,vr=dist.vr) {
  r <- raster(rast_file)
  pzoom <- gplot(r,maxpixels=res) +
    geom_raster(aes(fill=value)) + ylab("Dist. to forest edge 2014") +
    scale_fill_gradientn(colours=palette,na.value="transparent",
                         values=vr,
                         breaks=c(1,500,1000,1500,2000),
                         labels=c(">0","0.5","1","1.5","2"),
                         guide=guide_colorbar(title="Distance (km)",title.position="top",
                                              label.position="bottom",barwidth=10)) +
    theme_bw() + theme_zoom + coord_equal() +
    theme(legend.position="bottom", 
          legend.margin=margin(-1.5,-1,-1,-1,"lines"))
  return(pzoom)
}

# ================
# Ecoregions

# devtools::install_github("paleolimbot/ggspatial")
library(ggspatial)  # for geom_spatial()

# Import
ecoregion <- readOGR(dsn="gisdata/vectors",layer="madagascar_ecoregion_tenaizy_38s")
# Recode ecoregion
ecoregion.data <- ecoregion@data
ecoregion.data$code <- c("s","m","h","d") # spiny, mangroves, dry, humid
ecoregion@data <- ecoregion.data

# Text
xt <- c(850000,580000,530000,600000)
yt <- c(7920000,8060000,7250000,8460000)
t.df <- data.frame(text=c("Moist","Dry","Spiny","Mangroves"),x=xt,y=yt)

# Forest 2014
for2014 <- raster("outputs/for2014.tif")

# Segments
seg.df <- data.frame(x=c(720000),y=c(8282000),
                     xend=c(600000),yend=c(8405000))

# Colors
red.t <- adjustcolor("red",alpha.f=0.5)
blue.t <- adjustcolor("blue",alpha.f=0.5)
green.t <- adjustcolor("dark green",alpha.f=0.5)
orange.t <- adjustcolor("orange",alpha.f=0.5)
black.t <- adjustcolor("black",alpha.f=0.5)
eco.col <- c("h"=green.t,"d"=orange.t,"s"=red.t,"m"="blue","1"=black.t)

# Plot
plot.ecoregion <- gplot(for2014, maxpixels=10e5) +
  geom_spatial(ecoregion, aes(x=long,y=lat,group=group,fill=factor(code))) +
  geom_raster(aes(fill=factor(value))) +
  scale_fill_manual(values=eco.col, na.value="transparent") +
  geom_text(data=t.df, aes(x=x, y=y, label=text), size=3) +
  geom_segment(data=seg.df, aes(x=x, xend=xend, y=y, yend=yend), size=0.25) +
  theme_bw() + theme_base +
  theme(legend.position="null") +
  scale_y_continuous(limits=c(7165000,8685000),expand=c(0,0)) +
  scale_x_continuous(limits=c(300000,1100000),expand=c(0,0)) +
  coord_equal()
ggsave("outputs/ecoregion.png", plot.ecoregion, width=4, height=7, units="cm")

# ================
# Maps

## for1953
for1953 <- raster("outputs/fcc_for1953.tif")
for1953.plot <- gplot(for1953,maxpixels=res) +
  geom_raster(aes(fill=factor(value))) +
  xlab("Cover 1950s") +
  scale_fill_manual(values=fcc_for1953.palette,na.value="transparent") +
  theme_bw() + theme_base + 
  theme(panel.background=element_rect(fill="transparent"),
        legend.position="null",
        axis.title.x=element_text(hjust=0.5,size=18,face="bold"),
        plot.margin=unit(c(0,0,0,0),"null")) +
  scale_y_continuous(limits=c(7165000,8685000),expand=c(0,0)) +
  scale_x_continuous(limits=c(300000,1100000),expand=c(0,0)) +
  coord_equal()
grob.for1953 <- ggplotGrob(for1953.plot)

## fcc
fcc <- raster("outputs/fcc.tif")
fcc.plot <- gplot(fcc,maxpixels=res) +
  annotation_custom(grob=grob.for1953,xmin=810000,xmax=1110000,ymin=7110000,ymax=7800000) +
  geom_raster(aes(fill=factor(value))) +
  geom_rect(aes(xmin=346000,xmax=439000,ymin=7387000,ymax=7480000),
            fill="transparent",colour="black",size=0.3) +
  geom_rect(aes(xmin=793000,xmax=886000,ymin=7810000,ymax=7903000),
            fill="transparent",colour="black",size=0.3) +
  scale_fill_manual(values=fcc.palette,
                    name="Cover 1973-2014",
                    breaks=c(24,23,22,21,0,12),
                    labels=c("Forest 2014","Defor. 2000-2014","Defor. 1990-2000",
                             "Defor. 1973-1990", "Non-forest 1973","Water"),
                    na.value="transparent") +
  theme_bw() + theme_base +
  theme(legend.background=element_rect(fill="transparent")) + 
  theme(legend.key.width=unit(1,"cm")) +
  theme(legend.key.height=unit(1,"cm")) +
  theme(legend.text=element_text(size=18)) +
  theme(legend.title=element_text(size=20, face="bold")) +
  scale_y_continuous(limits=c(7165000,8685000),expand=c(0,0)) +
  scale_x_continuous(limits=c(300000,1100000),expand=c(0,0)) +
  coord_equal()
## fcc legend
legend <- get_legend(fcc.plot)
## fcc + legend + for1953
fcc.combi <- fcc.plot + theme(legend.position="null") +
  annotation_custom(grob=legend,xmin=400000,xmax=760000,ymin=8200000,ymax=8800000)

## Zooms for1953
zw.for1953 <- plot_zoom_fcc("outputs/fcc_for1953_zoom1.tif",fcc_for1953.palette) + ggtitle("Western zoom") + ylab("Cover 1950s")
ze.for1953 <- plot_zoom_fcc("outputs/fcc_for1953_zoom2.tif",fcc_for1953.palette) + ggtitle("Eastern zoom") + ylab("")

## Zooms fcc
zw.fcc <- plot_zoom_fcc("outputs/fcc_zoom1.tif",fcc.palette) + ylab("Cover 1973-2014")
ze.fcc <- plot_zoom_fcc("outputs/fcc_zoom2.tif",fcc.palette) + ylab("")

## Zooms frag
zw.frag <- plot_zoom_frag("outputs/frag2014_zoom1.tif")
ze.frag <- plot_zoom_frag("outputs/frag2014_zoom2.tif") + ylab("") + theme(legend.position="none")

## Zooms dist
zw.dist <- plot_zoom_dist("outputs/dist_edge_2014_mask_zoom1.tif")
ze.dist <- plot_zoom_dist("outputs/dist_edge_2014_mask_zoom2.tif") + ylab("") + theme(legend.position="none")

## Combine and export
lay <- rbind(c(NA,NA,NA,NA),
             c(1,5,5,6),
             c(2,5,5,7),
             c(3,5,5,8),
             c(4,5,5,9),
             c(NA,NA,NA,NA))
png("outputs/fig_fcc.png",width=1000,height=1000,units="px",pointsize=12)
grid.arrange(zw.for1953,zw.fcc,zw.frag,zw.dist,fcc.combi,
             ze.for1953,ze.fcc,ze.frag,ze.dist,layout_matrix=lay,
             widths=c(1,1,1,1),
             heights=c(0.05,1.04,1.04,1.04,1.04,0.05))
dev.off()
  