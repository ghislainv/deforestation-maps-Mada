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

# Zooms
zoom.w <- list(xmin=346000,xmax=439000,ymin=7387000,ymax=7480000)
zoom.e <- list(xmin=793000,xmax=886000,ymin=7815000,ymax=7908000)
zooms <- list(zoom.w,zoom.e)

# Compute zooms
for (z in 1:length(zooms)) {
  Extent1 <- paste(zooms[[z]]$xmin,zooms[[z]]$ymin,zooms[[z]]$xmax,zooms[[z]]$ymax)
  Input <- c("fcc.tif","fcc_for1953.tif","frag2014.tif")
  Output <- paste0(sub(".tif","",Input),"_zoom",z,".tif")
  for (i in 1:length(Input)) {
    system(paste0("gdalwarp -overwrite -te ",Extent1," -co 'COMPRESS=LZW' -co 'PREDICTOR=2' ",
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

# Colors
for2014.col = rgb(34/255,139/255,34/255) # forest green
defor00_14.col = rgb(255/255,0/255,0/255) # red
defor90_00.col = rgb(255/255,165/255,0/255) # orange
defor73_90.col = rgb(100/255,100/255,100/255) # grey
nofor73.col = rgb(243/255,243/255,220/255) # light yellow
w1.col = rgb(153/255,217/255,234/255) # light blue
w2.col = rgb(0/255,0/255,170/255) # dark blue
water.col <-colorRampPalette(c(w1.col,w2.col))(12)

# Themes
theme_base <- theme(axis.line=element_blank(),
                    axis.text.x=element_blank(),
                    axis.text.y=element_blank(),
                    axis.ticks=element_blank(),
                    axis.title.x=element_blank(),
                    axis.title.y=element_blank(),
                    legend.position="none",
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
                    axis.title.y=element_text(size=18),
                    plot.title=element_text(size=20,face="bold"),
                    legend.position="none",
                    plot.margin=unit(c(1,1,1,1),"line"),
                    panel.grid.major=element_blank(),
                    panel.grid.minor=element_blank(),
                    panel.border=element_blank())

# plot_zoom()
plot_zoom <- function(rast_file,res,palette) {
  # Function to plot zoom
  r <- raster(rast_file)
  pzoom <- gplot(r,maxpixels=res) +
    geom_raster(aes(fill=factor(value))) +
    scale_fill_manual(values=palette,na.value="transparent") +
    theme_bw() + theme_zoom +
    coord_equal()
  return(pzoom)
}

# Function to plot forest-cover change map
plot_fcc(res=res, zoom.1=zoom.w, zoom.2=zoom.e) {
  
  ## Palette
  # fcc
  fcc.col <- c(nofor73.col,water.col,nofor73.col,defor73_90.col,nofor73.col,
               defor90_00.col,defor00_14.col,for2014.col)
  fcc.name <- c(0,1:12,20,21,215,22,23,24)
  fcc.palette <- paste0("c(",paste0("\"",fcc.name,"\"","=","\"",fcc.col,"\"",collapse=","),")")
  fcc.palette <- eval(parse(text=fcc.palette))
  # fcc_for1953
  fcc_for1953.col <- c(nofor73.col,water.col,for2014.col)
  fcc_for1953.name <- c(0,1:12,20)
  fcc_for1953.palette <- paste0("c(",paste0("\"",fcc_for1953.name,"\"","=","\"",
                                            fcc_for1953.col,"\"",collapse=","),")")
  fcc_for1953.palette <- eval(parse(text=fcc_for1953.palette))
  # fragmentation
  frag.col <- c(nofor73.col,"red","orange","yellow","green","darkgreen")
  frag.name <- c(0:6)
  frag.palette <- paste0("c(",paste0("\"",frag.name,"\"","=","\"",
                                     frag.col,"\"",collapse=","),")")
  frag.palette <- eval(parse(text=frag.palette))
  
  
  ## for1953
  for1953 <- raster("outputs/fcc_for1953.tif")
  for1953.plot <- gplot(for1953,maxpixels=res) +
    geom_raster(aes(fill=factor(value))) +
    xlab("Cover 1950s") +
    scale_fill_manual(values=fcc_for1953.palette,na.value="transparent") +
    theme_bw() + theme_base + 
    theme(panel.background=element_rect(fill="transparent"),
          axis.title.x=element_text(hjust=0.5,size=18,face="bold"),
          plot.margin=unit(c(-0.25,-0.25,-0.5,-0.5),"line")) +
    coord_equal()
  grob.for1953 <- ggplotGrob(for1953.plot)
  
  ## fcc
  fcc <- raster("outputs/fcc.tif")
  fcc.plot <- gplot(fcc,maxpixels=res) +
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
    theme_bw() +
    theme(plot.margin=unit(c(-0.25,-0.25,-0.5,-0.5),"line"),
          legend.background=element_rect(fill="transparent")) + 
    theme(legend.position="right") +
    theme(legend.key.width=unit(1,"cm")) +
    theme(legend.key.height=unit(1,"cm")) +
    theme(legend.text=element_text(size=18)) +
    theme(legend.title=element_text(size=20, face="bold")) +
    coord_equal()
  ## fcc legend
  legend <- get_legend(fcc.plot)
  ## fcc + legend + for1953
  fcc.combi <- fcc.plot + theme_base + 
    annotation_custom(grob=legend,xmin=400000,xmax=760000,ymin=8200000,ymax=8800000) +
    annotation_custom(grob=grob.for1953,xmin=810000,xmax=1110000,ymin=7110000,ymax=7800000)

  ## Zooms for1953
  zw.for1953 <- plot_zoom("outputs/fcc_for1953_zoom1.tif",res,fcc_for1953.palette) +
    ggtitle("Western zoom") + ylab("Cover 1950s") +
    theme(plot.title=element_text(hjust=0.5))
  ze.for1953 <- plot_zoom("outputs/fcc_for1953_zoom2.tif",res,fcc_for1953.palette) +
    ggtitle("Eastern zoom") + ylab("") +
    theme(plot.title=element_text(hjust=0.5))
  
  ## Zooms fcc
  zw.fcc <- plot_zoom("outputs/fcc_zoom1.tif",res,fcc.palette) + ylab("Cover 1973-2014")
  ze.fcc <- plot_zoom("outputs/fcc_zoom2.tif",res,fcc.palette) + ylab("") 
  
  ## Zooms frag
  zw.frag <- plot_zoom("outputs/frag2014_zoom1.tif",res,frag.palette) + ylab("Fragmentation 2014") +
    scale_fill_manual(values=frag.palette,breaks=c(1:5),na.value="transparent") +
    theme(legend.position="bottom", legend.title=element_blank())
  ze.frag <- plot_zoom("outputs/frag2014_zoom2.tif",res,frag.palette) + ylab("") +
    scale_fill_manual(values=frag.palette,breaks=c(1:5),na.value="transparent") +
    theme(legend.position="bottom", legend.title=element_blank())

  ## Zooms dist
  zw.dist <- plot_zoom("outputs/frag2014_zoom1.tif",res,fcc.palette) + ylab("Dist. to forest edge 2014")
  ze.dist <- plot_zoom("outputs/frag2014_zoom2.tif",res,fcc.palette) + ylab("") 
  
  ## Combine and export
  lay <- rbind(c(1,5,5,6),
               c(2,5,5,7),
               c(3,5,5,8),
               c(4,5,5,9))
  png("outputs/fig_fcc.png",width=1000,height=1000,units="px",pointsize=12)
  grid.arrange(zw.for1953,zw.fcc,zw.frag,zw.dist,fcc.combi,
               ze.for1953,ze.fcc,ze.frag,ze.dist,layout_matrix=lay)
  dev.off()
  
}