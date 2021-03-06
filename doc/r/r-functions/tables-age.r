make.input.age.data.table <- function(model,
                                      fleet = 1,            ## 1=Fishery, 2=Survey
                                      start.yr,             ## Start the table on this year
                                      end.yr,
                                      xcaption = "default",
                                      xlabel = "default",
                                      font.size = 9,        ## Size of the font for the table
                                      space.size = 10,      ## Size of the spaces for the table
                                      placement = "H",
                                      decimals = 2
                                      ){
  ## Returns an xtable in the proper format for the main tables section for combined
  ##  fishery or survey age data.
  ##  age data.

  ## Get ages from header names
  age.df <- model$dat$agecomp
  nm <- colnames(age.df)
  yr <- age.df$Yr
  flt <- age.df$FltSvy
  n.samp <- age.df$Nsamp
  ## Get ages from column names
  ages.ind <- grep("^a[[:digit:]]+$", nm)
  ages <- gsub("^a([[:digit:]]+)$", "\\1", nm[ages.ind])
  ## Make all bold
  ages <- paste0("\\textbf{", ages, "}")
  ages <- paste(ages, " & ")
  ## Make the ages vector a string
  ages.tex <- do.call("paste", as.list(ages))
  ## Remove last ampersand
  ages.tex <- sub("& $", "\\\\\\\\", ages.tex)

  ## Construct age data frame
  age.df <- age.df[,ages.ind]
  age.df <- t(apply(age.df, 1, function(x){x / sum(x)}))
  age.headers <- paste0("\\multicolumn{1}{c}{\\textbf{", ages, "}} & ")
  age.df <- cbind(yr, n.samp, flt, age.df)

  ## Fishery or survey?
  age.df <- age.df[age.df[,"flt"] == fleet,]
  ## Remove fleet information from data frame
  age.df <- age.df[,-3]
  ## Extract years
  age.df <- age.df[age.df[,"yr"] >= start.yr & age.df[,"yr"] <= end.yr,]

  ## Make number of samples pretty
  age.df[,2] <- f(age.df[,2])
  ## Make percentages for age proportions
  age.df[,-c(1,2)] <- as.numeric(age.df[,-c(1,2)]) * 100
  age.df[,-c(1,2)] <- f(as.numeric(age.df[,-c(1,2)]), decimals)
  ## Add the extra header spanning multiple columns
  addtorow <- list()
  addtorow$pos <- list()
  addtorow$pos[[1]] <- -1
  addtorow$pos[[2]] <- nrow(age.df)

  addtorow$command <- c(paste0("\\hline \\textbf{Year} & \\specialcell{\\textbf{Number}\\\\\\textbf{of samples}} & \\multicolumn{", length(ages), "}{c}{\\textbf{Age (\\% of total for each year)}} \\\\",
                                 "\\hline & & ", ages.tex),
                          "\\hline ")

  ## Make the size string for font and space size
  size.string <- paste0("\\fontsize{", font.size,"}{", space.size,"}\\selectfont")

  return(print(xtable(age.df,
                      caption = xcaption,
                      label = xlabel,
                      align = get.align(ncol(age.df))),
               caption.placement = "top",
               include.rownames = FALSE,
               include.colnames = FALSE,
               sanitize.text.function = function(x){x},
               size = size.string,
               add.to.row = addtorow,
               table.placement = placement,
               tabular.environment = "tabular",
               hline.after = NULL))
}

make.can.age.data.table <- function(dat,
                                    fleet = 1,            ## 1=Can-Shoreside, 2=Can-FT, 3=Can-JV
                                    start.yr,             ## Start the table on this year
                                    end.yr,
                                    xcaption = "default",
                                    xlabel = "default",
                                    font.size = 9,        ## Size of the font for the table
                                    space.size = 10,      ## Size of the spaces for the table
                                    placement = "H",
                                    decimals = 2
                                    ){
  ## Returns an xtable in the proper format for the main tables section for Canadian
  ##  age data.
  ages.df <- dat[[fleet]]
  n.trip.haul <- as.numeric(dat[[fleet + 3]])
  ages.df <- cbind(n.trip.haul, ages.df)
  dat <- cbind(as.numeric(rownames(ages.df)), ages.df)
  dat <- dat[dat[,1] >= start.yr & dat[,1] <= end.yr,]

  dat[,2] <- as.numeric(f(dat[,2]))
  ## Make percentages
  dat[,-c(1,2)] <- dat[,-c(1,2)] * 100
  dat[,-c(1,2)] <- f(dat[,-c(1,2)], decimals)
  ## Add the extra header spanning multiple columns
  addtorow <- list()
  addtorow$pos <- list()
  addtorow$pos[[1]] <- -1
  addtorow$pos[[2]] <- nrow(dat)
  age.headers <- colnames(dat)[grep("^[[:digit:]].*", colnames(dat))]
  n.age <- length(age.headers)
  ages <- paste0("\\multicolumn{1}{c}{\\textbf{", 1:(n.age), "}} & ")
  ages.tex <- do.call("paste", as.list(ages))
  ## Remove last ampersand
  ages.tex <- sub("& $", "\\\\\\\\", ages.tex)

  if(fleet == 2 | fleet == 3){
    addtorow$command <- c(paste0("\\hline \\textbf{Year} & \\specialcell{\\textbf{Number}\\\\\\textbf{of hauls}} & \\multicolumn{", n.age, "}{c}{\\textbf{Age (\\% of total for each year)}} \\\\",
                                 "\\hline & & ", ages.tex),
                          "\\hline ")
  }else{
    addtorow$command <- c(paste0("\\hline \\textbf{Year} & \\specialcell{\\textbf{Number}\\\\\\textbf{of trips}} & \\multicolumn{", n.age, "}{c}{\\textbf{Age (\\% of total for each year)}} \\\\",
                                 "\\hline & & ", ages.tex),
                          "\\hline ")
  }

  ## Make the size string for font and space size
  size.string <- paste0("\\fontsize{",font.size,"}{",space.size,"}\\selectfont")

  return(print(xtable(dat,
                      caption = xcaption,
                      label = xlabel,
                      align = get.align(ncol(dat))),
               caption.placement = "top",
               include.rownames = FALSE,
               include.colnames = FALSE,
               sanitize.text.function = function(x){x},
               size = size.string,
               add.to.row = addtorow,
               table.placement = placement,
               tabular.environment = "tabular",
               hline.after = NULL))
}

make.us.age.data.table <- function(dat,
                                   fleet = 1,            ## 1=US-CP, 2=US-MS, 3=US-Shoreside
                                   start.yr,             ## Start the table on this year
                                   end.yr,
                                   xcaption = "default",
                                   xlabel = "default",
                                   font.size = 9,        ## Size of the font for the table
                                   space.size = 10,      ## Size of the spaces for the table
                                   placement = "H",
                                   decimals = 2
                                   ){

  ## Returns an xtable in the proper format for the main tables section for US
  ##  age data.

  if(fleet == 1 | fleet == 2){
    dat[,c(2,3)] <- f(dat[,c(2,3)])
    ## Make percentages
    dat[,-c(1,2,3)] <- dat[,-c(1,2,3)] * 100
    ## Make pretty
    dat[,-c(1,2,3)] <- f(dat[,-c(1,2,3)], decimals)
  }else{
    dat[,2] <- f(dat[,2])
    ## Make percentages
    dat[,-c(1,2)] <- dat[,-c(1,2)] * 100
    ## Make pretty
    dat[,-c(1,2)] <- f(dat[,-c(1,2)], decimals)
  }
  dat <- dat[dat[,1] >= start.yr & dat[,1] <= end.yr,]

  ## Add the extra header spanning multiple columns
  addtorow <- list()
  addtorow$pos <- list()
  addtorow$pos[[1]] <- -1
  addtorow$pos[[2]] <- nrow(dat)
  age.headers <- colnames(dat)[grep("^a.*", colnames(dat))]
  n.age <- length(age.headers)
  ages <- paste0("\\multicolumn{1}{c}{\\textbf{", 1:(n.age), "}} & ")
  ages.tex <- do.call("paste", as.list(ages))
  ## Remove last ampersand
  ages.tex <- sub("& $", "\\\\\\\\", ages.tex)
  if(fleet == 1 | fleet == 2){
    addtorow$command <- c(paste0("\\hline \\textbf{Year} & \\specialcell{\\textbf{Number}\\\\\\textbf{of fish}} & \\specialcell{\\textbf{Number}\\\\\\textbf{of hauls}} & \\multicolumn{", n.age, "}{c}{\\textbf{Age (\\% of total for each year)}} \\\\",
                                 "\\hline & & & ", ages.tex),
                          "\\hline ")
  }else{
    addtorow$command <- c(paste0("\\hline \\textbf{Year} & \\specialcell{\\textbf{Number}\\\\\\textbf{of trips}} & \\multicolumn{", n.age, "}{c}{\\textbf{Age (\\% of total for each year)}} \\\\",
                                 "\\hline & & ", ages.tex),
                          "\\hline ")
  }

  ## Make the size string for font and space size
  size.string <- paste0("\\fontsize{",font.size,"}{",space.size,"}\\selectfont")

  return(print(xtable(dat,
                      caption = xcaption,
                      label = xlabel,
                      align = get.align(ncol(dat))),
               caption.placement = "top",
               include.rownames = FALSE,
               include.colnames = FALSE,
               sanitize.text.function = function(x){x},
               size = size.string,
               add.to.row = addtorow,
               table.placement = placement,
               tabular.environment = "tabular",
               hline.after = NULL))
}

make.est.numbers.at.age.table <- function(model,                ## model is an mcmc run and is the output of the r4ss package's function SSgetMCMC
                                          start.yr,             ## start.yr is the first year to show in the table
                                          end.yr,               ## end.yr is the last year to show in the table
                                          weight.factor = 1000, ## divide catches by this factor
                                          plus.group = 15,      ## ages this and older will be grouped in table
                                          table.type = 1,       ## 1=NAA, 2=Exploitation Rate by age
                                                                ## 3=CAA in number, 4=CAA in biomass, 5=Biomass at age
                                          csv.dir = "out-csv",  ## The outputs will be written to a csv file in this directory
                                          xcaption = "default", ## Caption to use
                                          xlabel   = "default", ## Latex label to use
                                          font.size = 9,        ## Size of the font for the table
                                          space.size = 10       ## Size of the spaces for the table
                                          ){
  ## Returns an xtable in the proper format for the main tables section for credibility intervals for biomass,
  ##  relative biomass, recruitment, fishing intensity, and exploitation fraction

  ## Make sure the csv directory exists
  if(!dir.exists(csv.dir)){
    dir.create(csv.dir)
  }

  yrs <- start.yr:end.yr

  ## Filter the values by years
  if(table.type == 1){
    ## Numbers-at-age
    dat <- model$natage[model$natage$"Beg/Mid" == "B", -c(1:6,8:11)]
    dat <- dat[dat$Yr %in% yrs,]
    ## Group ages greater than or equal to plus.group together by summing
    max.age <- max(as.numeric(names(dat[,-1])))
    plus.ages <- plus.group:max.age
    dat.plus <- dat[,names(dat) %in% plus.ages]
    dat.minus <- dat[,!names(dat) %in% plus.ages]
    dat <- cbind(dat.minus, apply(dat.plus, 1, sum))
    names(dat)[ncol(dat)] <- paste0(plus.group, "+")
    names(dat)[1] <- "Year"
    write.csv(dat, file.path(csv.dir, "estimated-numbers-at-age.csv"), row.names = FALSE)

    ## Apply division by weight factor and formatting
    dat[,-1] <- apply(dat[-1], c(1,2), function(x) x / weight.factor)
    dat[,-1] <- apply(dat[-1], c(1,2), f)
    dat[,1] <- as.character(dat[,1])
  }else if(table.type == 2){
    ## Exploitation rate at age
    ## Extract catch-at-age by year and remove extraneous columns
    c.age <- model$catage[model$catage[,"Yr"] >= start.yr & model$catage[,"Yr"] <= end.yr, ]
    c.age <- c.age[,-(1:10)]
    ## Extract catch-at-age by year and remove extraneous columns
    n.age <- model$natage[model$natage$"Beg/Mid" == "M", -c(1:6,8:11)]
    n.age <- n.age[n.age[,"Yr"] >= start.yr & n.age[,"Yr"] <= end.yr,]
    yrs <- n.age[,"Yr"]
    ## Remove year column, do calculation and add year column back
    n.age <- n.age[,-1]
    dat <- f((c.age / n.age) * 100, 2)
    dat <- cbind(as.character(yrs), dat)
    colnames(dat)[1] <- "Year"
    write.csv(dat, file.path(csv.dir, "estimated-exploitation-at-age.csv"), row.names = FALSE)
  }else if(table.type == 3){
    ## Catch-at-age in numbers
    ## Extract catch-at-age by year and remove extraneous columns
    c.age <- model$catage[model$catage[,"Yr"] >= start.yr & model$catage[,"Yr"] <= end.yr, ]
    yrs <- as.character(c.age[,"Yr"])
    c.age <- c.age[,-(1:10)]
    csv.dat <- c.age
    csv.dat <- cbind(yrs, csv.dat)
    colnames(csv.dat)[1] <- "Year"
    write.csv(csv.dat, file.path(csv.dir, "estimated-catch-at-age.csv"), row.names = FALSE)

    c.age <- f(c.age)
    dat <- cbind(yrs, c.age)
    colnames(dat)[1] <- "Year"
  }else if(table.type == 4){
    ## Catch-at-age in biomass
    c.age <- model$catage[model$catage[,"Yr"] >= start.yr & model$catage[,"Yr"] <= end.yr, ]
    yrs <- as.character(c.age[,"Yr"])
    c.age <- c.age[,-(1:10)]
    wt.at.age <- model$wtatage[model$wtatage$fleet == 1,]
    wt.at.age <- wt.at.age[,-(1:6)]
    dat <- c.age * wt.at.age
    csv.dat <- cbind(yrs, dat)
    colnames(csv.dat)[1] <- "Year"
    write.csv(csv.dat, file.path(csv.dir, "estimated-catch-at-age-biomass.csv"), row.names = FALSE)

    dat <- f(dat)
    dat <- cbind(yrs, dat)
    colnames(dat)[1] <- "Year"
  }else if(table.type == 5){
    ## Biomass-at-age
    dat <- model$natage[model$natage$"Beg/Mid" == "B", -c(1:6,8:11)]
    dat <- dat[dat$Yr %in% yrs,]
    yrs <- as.character(dat[,"Yr"])
    dat <- dat[,-1]
    wt.at.age <- model$wtatage[model$wtatage$fleet == 1,]
    wt.at.age <- wt.at.age[,-(1:6)]
    dat <- dat * wt.at.age
    dat <- cbind(yrs, dat)
    names(dat)[1] <- "Year"
    write.csv(dat, file.path(csv.dir, "estimated-biomass-at-age.csv"), row.names = FALSE)

    ## Apply division by weight factor and formatting
    dat[,-1] <- apply(dat[-1], c(1,2), function(x) x / weight.factor)
    dat[,-1] <- apply(dat[-1], c(1,2), f)
    dat[,1] <- as.character(dat[,1])
  }else{
    return(invisible())
  }
  ## Add latex headers
  colnames(dat) <- sapply(colnames(dat), function(x) paste0("\\textbf{", x, "}"))

  ## Make the size string for font and space size
  size.string <- paste0("\\fontsize{", font.size, "}{", space.size, "}\\selectfont")
  return(print(xtable(dat,
                      caption = xcaption,
                      label = xlabel,
                      align = get.align(ncol(dat))),
               caption.placement = "top",
               table.placement = "H",
               include.rownames = FALSE,
               sanitize.text.function = function(x){x},
               size = size.string))

}

make.cohort.table <- function(model,
                              cohorts,              ## a vector of cohort years which are to appear in the table
                              start.yr,             ## year to start the at-age matrix calcs
                              end.yr,               ## year to end the  at-age matrix calcs
                              weight.factor = 1000, ## divide catches by this factor
                              xcaption = "default",
                              xlabel   = "default",
                              font.size = 9,
                              space.size = 10       ## Size of the spacing for the table
                              ){
  ## Returns an xtable in the proper format for cohort's start biomass,
  ## catch weight, natural mortality weight, and surviving biomass all by age

  if(!length(cohorts)){
    return(invisible())
  }

  get.cohorts <- function(d, cohorts){
    ## Returns a list of the cohort values for data frame d
    ## cohorts is a vector of the years you want the cohort
    ## info for. Diagonals of the data frame d make up these cohorts.
    ## Assumes the year is in column 1.
    coh.inds <- as.character(which(d[,1] %in% cohorts) - 1)
    delta <- row(d[-1]) - col(d[-1])
    coh.list <- split(as.matrix(d[,-1]), delta)
    lapply(coh.inds, function(x){get(x, coh.list)})
  }

  ## Extract the numbers-at-age
  naa <- model$natage[model$natage$"Beg/Mid" == "B", -c(1:6,8:11)]
  # numbers at age in next year
  naa.next <- naa[naa$Yr >= start.yr+1 & naa$Yr <= end.yr+1,]
  # numbers at age in same year
  naa <- naa[naa$Yr >= start.yr & naa$Yr <= end.yr,]
  naa.next$Yr <- naa.next$Yr-1 # change year to match other 
  
  coh.naa <- get.cohorts(naa, cohorts)

  # cohort numbers at age in next year (
  coh.naa.next <- get.cohorts(naa.next, cohorts-1)
  ## Throw away the first one so that this represents shifted by 1 year values
  coh.naa.next <- lapply(coh.naa.next, function(x){x[-1]})

  ## Extract weight-at-age for the fishery (fleet 1)
  waa <- model$wtatage[model$wtatage$fleet == 1,]
  waa <- waa[,-(2:6)]
  waa$yr <- -waa$yr
  coh.waa <- get.cohorts(waa, cohorts)

  ## Catch-at-age
  caa <- model$catage
  caa <- caa[,-c(1:6,8:10)]
  coh.caa <- get.cohorts(caa, cohorts)
  ages <- 0:(ncol(caa) - 2)

  ## Start biomass-at-age
  baa <- cbind(naa$Yr, naa[-1] * waa[-1] / weight.factor)
  coh.baa <- get.cohorts(baa, cohorts)

  ## Catch weight
  coh.catch <- lapply(1:length(coh.waa),
                      function(i, waa, caa){waa[[i]] * caa[[i]] / weight.factor},
                      waa = coh.waa, caa = coh.caa)

  ## ## Natural mortality weight (old way of calculating)
  ## coh.m <- lapply(1:length(coh.baa),
  ##                     function(i, baa, catch){baa[[i]] - catch[[i]]},
  ##                     baa = coh.baa, catch = coh.catch)

  ## Surviving biomass
  ## Get the weights-at-age for the year before the cohorts of interest.
  coh.waa.prev <- get.cohorts(waa, cohorts - 1)
  ## Throw away the first one so the weight-at-age applied
  ## to the numbers-at-age in the current year is one less.
  coh.waa.prev <- lapply(coh.waa.prev, function(x){x[-1]})

  coh.surv <- lapply(1:length(coh.naa),
                      function(i, waa, naa){waa[[i]] * naa[[i]] / weight.factor},
                     waa = coh.waa, naa = coh.naa.next)

  ## Natural mortality weight (new way of calculating based on coh.surv above)
  coh.m <- lapply(1:length(coh.surv),
                      function(i, baa, catch, surv){baa[[i]] - surv[[i]] - catch[[i]]},
                      baa = coh.baa, catch = coh.catch, surv = coh.surv)

  ## trying again as the above came out funny
  ##coh.m = coh.baa - coh.surv - coh.catch
  
  ## Bind the individual cohort value vectors into matrices
  coh.sum <- lapply(1:length(coh.naa),
                    function(i, baa, catch, m, surv){
                      do.call(cbind, list(f(baa[[i]], 1),
                                          f(catch[[i]], 1),
                                          f(m[[i]], 1),
                                          f(surv[[i]], 1)))},
                    baa = coh.baa,
                    catch = coh.catch,
                    m = coh.m,
                    surv = coh.surv)
  ## Add a column in the first column for the ages
  coh.sum <- append(coh.sum, list(as.data.frame(ages)), after = 0)
  ## Bind the list of cohort value matrices into a single ragged matrix
  n <- max(sapply(coh.sum, nrow))
  coh.sum.mat <- do.call(cbind,
                         lapply(coh.sum, function(x){
                           rbind(x, matrix(, n - nrow(x), ncol(x)))}))
  coh.sum.mat <- as.data.frame(coh.sum.mat)

  ## Add latex headers
  colnames(coh.sum.mat) <- c("\\textbf{Age}",
                             rep(c("\\specialcell{\\textbf{Start}\\\\\\textbf{Biomass}\\\\\\textbf{(000s t)}}",
                                   "\\specialcell{\\textbf{Catch}\\\\\\textbf{Weight}\\\\\\textbf{(000s t)}}",
                                   "\\specialcell{\\textbf{M}\\\\\\textbf{(000s t)}}",
                                   "\\specialcell{\\textbf{Surviving}\\\\\\textbf{Biomass}\\\\\\textbf{(000s t)}}"),
                                 length(cohorts)))
  ## Add the extra header spanning multiple columns
  addtorow <- list()
  addtorow$pos <- list()
  addtorow$pos[[1]] <- -1
  addtorow$command <- "\\hline "
  for(i in 1:length(cohorts)){
    addtorow$command <- paste0(addtorow$command,
                               " & \\multicolumn{4}{c}{\\textbf{",
                               cohorts[i],
                               " cohort}}")
  }
  addtorow$command <- paste0(addtorow$command, " \\\\")
  size.string <- paste0("\\fontsize{", font.size, "}{", space.size, "}\\selectfont")
  return(print(xtable(coh.sum.mat,
                      caption = xcaption,
                      label = xlabel,
                      align = get.align(ncol(coh.sum.mat))),
               caption.placement = "top",
               add.to.row = addtorow,
               table.placement = "H",
               include.rownames = FALSE,
               sanitize.text.function = function(x){x},
               size = size.string))

}
