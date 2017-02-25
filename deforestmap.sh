#!/bin/sh
echo "Executing deforestmap.R script in the background"
Rscript --vanilla deforestmap_test.R > deforestmap.log 2>&1 &
# If you wan't to download the source data do:
# Rscript --vanilla deforestmap.R TRUE > deforestmap.log 2>&1 &
echo "Check the progress with command 'tail -f deforestmap.log'"
echo "Check the processor usage with command 'top'"
## End of script