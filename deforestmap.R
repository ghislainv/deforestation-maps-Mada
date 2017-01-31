##=========================================================================
## Sixty-five years of deforestation and forest fragmentation in Madagascar
## Ghislain Vieilledent <ghislain.vieilledent@cirad.fr>
## January 2017
##=========================================================================

##= Libraries
pkg <- c("broom","sp","rgdal","raster","ggplot2","gridExtra",
         "rasterVis","knitr","rmarkdown","rgeos")
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

##======================================================================
## Download data (263.6 Mo): will have to be done from a Zenodo repository
d <- "http://bioscenemada.cirad.fr/githubdata/deforestmap/deforestmap_data.zip"
#download.file(url=d,destfile="menabe_data.zip",method="wget",quiet=TRUE)
#unzip("menabe_data.zip")

##===========================================================
## Create new directories to save figures and new raster data
dir.create("figs")
dir.create("rast")

##================================================

x <- 1

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

