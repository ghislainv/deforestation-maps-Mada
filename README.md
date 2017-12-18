# deforestation-maps-Mada

_Sixty years of deforestation and forest fragmentation in Madagascar_

This repository includes the R script and data used to derive the results of the following article:

**Vieilledent G., C. Grinand, F. A. Rakotomalala, R. Ranaivosoa, J.-R. Rakotoarijaona, T. F. Allnutt, and F. Achard.** Combining global tree cover loss data with historical national forest-cover maps to look at six decades of deforestation and forest fragmentation in Madagascar.

## Reproducibility of the results

The results of the study are fully reproducible running the R/GRASS script `deforestmap.R`.

## File and folder description

- `gisdata`: folder including raster and vector data necessary for the analysis

## Dependencies

### Geospatial libraries

The GDAL library (<http://www.gdal.org/>) and GRASS GIS 7.2.x software (<https://grass.osgeo.org/>) are needed to run this script. Call to GDAL and GRASS GIS 7.2 functions are made through the function `system2()` in R. 

### Fragmentation

For computing fragmentation, the `r.forestfrag` add-on must be installed. GRASS GIS add-ons can be easily installed in the local installation through the graphical user interface (Menu - Settings - Addons Extension - Install) or via the [`g.extension`](https://grass.osgeo.org/grass72/manuals/g.extension.html) command.

## Portability

For our study, computations have been done on a Linux workstation. The script have not been tested on Windows but minimal changes to the code should be necessary to make it work. In case of problems, Windows users can install [OSGeo-Live](https://live.osgeo.org/en/), a geospatial Linux distribution within a [VirtualBox virtual machine](https://live.osgeo.org/en/quickstart/virtualization_quickstart.html).

## References

Previous reports on deforestation in Madagascar might not be accessible on the long term at their original web address. These reports have been archived on a private Google Drive repository [here](https://drive.google.com/drive/folders/1nq8CuMacT0uZuNO6q05al94d6KYp1FaK?usp=sharing). In particular, the following reports have been made available:

## Figure

<img alt="Evolution deforestation" src="outputs/fig_fcc_highres.png" width="1000">


