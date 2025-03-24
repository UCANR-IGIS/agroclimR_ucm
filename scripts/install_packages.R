## Required packages from CRAN
pkgs_req <- c("sf", "tidyverse", "tmap", "units", "zoo", "remotes", "degday", "chillR", "cimir", "here")

## See which ones are missing
(pkgs_missing <- pkgs_req[!(pkgs_req %in% installed.packages()[,"Package"])])

## Install missing CRAN packages
if (length(pkgs_missing)) install.packages(pkgs_missing, dependencies=TRUE)

## Re-run the check for missing CRAN packages
pkgs_missing <- pkgs_req[!(pkgs_req %in% installed.packages()[,"Package"])]
if (length(pkgs_missing)==0) cat("ALL CRAN PACKAGES WERE INSTALLED SUCCESSFULLY \n")

## Install two packages from GitHub:
if (!"wrkshputils" %in% installed.packages()[,"Package"]) remotes::install_github("ucanr-igis/wrkshputils")
if (!"caladaptr" %in% installed.packages()[,"Package"]) remotes::install_github("ucanr-igis/caladaptr")

#########################################################################################
## TIPS
##
## If you are prompted by the question, 'Do you want to install from sources the 
## package which needs compilation?', select 'No'.
##
## If you get an error message that a package can't be installed because it's already 
## loaded and can't be stopped, restart R (Session >> Restart R), and try again.
#########################################################################################
