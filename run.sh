#!/bin/sh
echo "Executing R script in the background"
Rscript --vanilla deforestmap.R > deforestmap.log 2>&1 &
echo "Check the progress with command 'tail -f deforestmap.log'"
echo "Check the processor usage with command 'top'"
## End of script