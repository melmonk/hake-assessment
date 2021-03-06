## Pacific Hake Joint Technical Committee
## This is the master file - it loads all packages and sources all
##  other R source code files.
## To debug in an R session, run these commands first:
## source("all.r");load.models.into.parent.env();source("custom-knitr-variables.r")

## Clean your workspace before loading
rm(list = ls(all = TRUE))

## The purpose of the r-functions directory is to separate the
##  r code which is not commonly changed so that the files which are
##  can be clearly seen.
func.dir <- "r-functions"

## Need to source utilities.r before everything because it contains the functions
##  install.packages.if.needed and remove.all.except
source(file.path(func.dir, "utilities.r"))

install.packages.if.needed("devtools", "devtools", github=FALSE)
install.packages.if.needed("caTools", "caTools", github=FALSE)
install.packages.if.needed("stringi", "stringi", github=FALSE)
install.packages.if.needed("nwfscSurvey", "nwfsc-assess/nwfscSurvey", github=TRUE)
install.packages.if.needed("nwfscMapping", "nwfsc-assess/nwfscMapping", github=TRUE)
install.packages.if.needed("date", "date", github=FALSE)
install.packages.if.needed("r4ss", "r4ss/r4ss", github=TRUE)
install.packages.if.needed("xtable", "xtable", github=FALSE)
install.packages.if.needed("PBSmapping", "PBSmapping", github=FALSE)
install.packages.if.needed("PBSmodelling", "PBSmodelling", github=FALSE)
install.packages.if.needed("maps", "maps", github=FALSE)
install.packages.if.needed("coda", "coda", github=FALSE)
install.packages.if.needed("dplyr", "dplyr", github = FALSE)
install.packages.if.needed("maptools", "maptools", github = FALSE)
install.packages.if.needed("gtools", "gtools", github = FALSE)
install.packages.if.needed("knitr", "knitr", github = FALSE)

require(nwfscSurvey)
require(nwfscMapping)
require(date)
require(r4ss)
require(xtable)
require(PBSmapping)
require(PBSmodelling)
require(maps)
require(dplyr)
require(coda)
require(gtools)
require(maptools)
require(lubridate)
require(knitr)

source(file.path(func.dir, "catches.r"))      ## Code to load the catch/TAC data, making catch figures, and making tables for catch/TAC.
source(file.path(func.dir, "load-models.r"))  ## Code to load the models from the model directories.
source(file.path(func.dir, "survey.r"))       ## Code to load the survey data, making survey figures, and making tables for survey.
source(file.path(func.dir, "load-data.r"))    ## Code to load data tables from the data directory.
source(file.path(func.dir, "read-list.r"))    ## Code to read a user file into an R list (for model setup).

source(file.path(func.dir, "figures-timeseries.r"))
source(file.path(func.dir, "figures-compare-forecasts.r"))
source(file.path(func.dir, "figures-mcmc-diagnostics.r"))
source(file.path(func.dir, "figures-age-comps.r"))
source(file.path(func.dir, "figures-selex.r"))
source(file.path(func.dir, "figures-stock-recruitment.r"))
source(file.path(func.dir, "figures-mle-mcmc.r"))
source(file.path(func.dir, "figures-overview-map.r"))
source(file.path(func.dir, "figures-data.r"))
source(file.path(func.dir, "figures-assessment-history.r"))
source(file.path(func.dir, "figures-age-comp-forecast.r"))
source(file.path(func.dir, "figures-SPR-illustration-appendix.r"))

source(file.path(func.dir, "tables-timeseries.r"))
source(file.path(func.dir, "tables-reference-points.r"))
source(file.path(func.dir, "tables-decisions.r"))
source(file.path(func.dir, "tables-age.r"))
source(file.path(func.dir, "tables-parameters.r"))
source(file.path(func.dir, "tables-sampling.r"))
source(file.path(func.dir, "tables-maturity.r"))

source(file.path(func.dir, "verify.r")) ## Code to verify the model setup.
source("model-setup.r")                 ## Code to setup the model names, and start/end years for various things in the models.
source("forecast-catch-levels.r")       ## Code to setup forecast model runs.
source("retrospective-setup.r")         ## Code to setup retrospective model runs.
source("data-tables.r")                 ## Set up variables for data tables (from csv files).

