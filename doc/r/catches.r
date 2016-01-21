## Functions to load catches table from a csv file, display it as a table,
## and plot the figure. Also calculates years.Can.JV.catch.eq.0.

load.catches <- function(fn ## fn is the filename with relative path
                         ){
  ## Reads in the catches file, splits it up into two data frames,
  ##  one for catches and one for the catches/tac.
  ## In the catches data frame, any NA's will be replaced by zeroes.
  ## In the landings/tac table, they will remain NAs
  catches <- read.csv(fn)
  landings.vs.tac <- as.data.frame(cbind(Year = catches$Year,
                                         Ustotal = catches$Ustotal,
                                         CANtotal = catches$CANtotal,
                                         TOTAL = catches$TOTAL,
                                         TAC = catches$TAC,
                                         TACCAN = catches$TACCAN,
                                         TACUSA = catches$TACUSA))

  landings.vs.tac <- as.data.frame(cbind(landings.vs.tac,
                                         landings.vs.tac$Ustotal / landings.vs.tac$TACUSA * 100,
                                         landings.vs.tac$CANtotal / landings.vs.tac$TACCAN * 100,
                                         landings.vs.tac$TOTAL / landings.vs.tac$TAC * 100))

  colnames(landings.vs.tac) <- c("Year", "Ustotal", "CANtotal",
                                 "TOTAL", "TAC", "TACCAN", "TACUSA",
                                 "USATTAIN", "CANATTAIN", "ATTAIN")
  catches <- catches[,!names(catches) %in% c("TAC", "TACCAN", "TACUSA")]
  catches[is.na(catches)] <- 0
  return(list(catches = catches, landings.vs.tac = landings.vs.tac))
}

## load.landings.tac <- function(fn ## fn is the filename with reletive path
##                               ){
##   ## Reads in the landings vs tac file. This is for the management performance section
##   ## of the executive summary. The table represents coastwide values
##   landings.vs.tac <- read.csv(fn)

##   ## Add column for proportions
##   landings.vs.tac <- cbind(landings.vs.tac, landings.vs.tac$landings / landings.vs.tac$tac * 100)
##   return(landings.vs.tac)
## }

make.catches.table <- function(catches,              ## The output of the load.catches function above.
                               start.yr,             ## start.yr is the first year to show in the table
                               end.yr,               ## end.yr is the last year to show in the table
                               weight.factor = 1000, ## divide catches by this factor
                               xcaption = "default", ## Caption to use
                               xlabel   = "default", ## Latex label to use
                               font.size = 9,        ## Size of the font for the table
                               space.size = 10       ## Size of the spaces for the table
                               ){
  ## Returns an xtable in the proper format for the executive summary catches
  if(start.yr > 1991){
    ## If start.yr > 1991 then US foreign, US JV, and Canadian foreign will be removed since they are all zeroes.
    catches <- catches[,c("Year","atSea_US_MS","atSea_US_CP","US_shore","USresearch","Ustotal",
                          "CAN_JV","CAN_Shoreside","CAN_FreezeTrawl","CANtotal","TOTAL")]
    colnames(catches) <- c("\\specialcell{\\textbf{Year}}",
                           "\\specialcell{\\textbf{US}\\\\\\textbf{Mother-}\\\\\\textbf{ship}}",
                           "\\specialcell{\\textbf{US}\\\\\\textbf{Catcher}-\\\\\\textbf{Processor}}",
                           "\\specialcell{\\textbf{US}\\\\\\textbf{Shore-}\\\\\\textbf{based}}",
                           "\\specialcell{\\textbf{US}\\\\\\textbf{Research}}",
                           "\\specialcell{\\textbf{US}\\\\\\textbf{Total}}",
                           "\\specialcell{\\textbf{CAN}\\\\\\textbf{Joint}\\\\\\textbf{Venture}}",
                           "\\specialcell{\\textbf{CAN}\\\\\\textbf{Shore-}\\\\\\textbf{side}}",
                           "\\specialcell{\\textbf{CAN}\\\\\\textbf{Freezer-}\\\\\\textbf{Trawler}}",
                           "\\specialcell{\\textbf{CAN}\\\\\\textbf{Total}}",
                           "\\specialcell{\\textbf{Total}}")
  }else{
    colnames(catches) <- c("Year","US\nForeign","US\nJV","US\nMother-\nship","US\nCatcher-\nProcessor","US\nShore-\nbased","US\nResearch","US\nTotal",
                           "CAN\nForeign","CAN\nJoint-\nVenture","CAN\nShoreside","CAN\nFreezer-Trawler","CAN\nTotal","Total")
  }
  ## Filter for correct years to show and make thousand-seperated numbers (year assumed to be column 1)
  catches <- catches[catches[,1] >= start.yr & catches[,1] <= end.yr,]
  catches[,-1] <- fmt0(catches[,-1])  ## -1 means leave the years alone and don't comma-seperate them

  ## Make the size string for font and space size
  size.string <- paste0("\\fontsize{",font.size,"}{",space.size,"}\\selectfont")
  return(print(xtable(catches, caption=xcaption, label=xlabel, align=get.align(ncol(catches))),
               caption.placement = "top", include.rownames=FALSE, table.placement="H", sanitize.text.function=function(x){x}, size=size.string))
}

make.catches.plot <- function(catches,
                              leg.y.loc = 430  ## Y-based location to place the legend
                              ){
  ## Plot the catches in a stacked-barplot with legend
  years <- catches$Year
  catches <- catches[,c("CAN_forgn","CAN_JV","CAN_Shoreside","CAN_FreezeTrawl","US_foreign","US_JV","atSea_US_MS","atSea_US_CP","US_shore")]
  cols <- c(rgb(0,0.8,0), rgb(0,0.6,0), rgb(0.8,0,0), rgb(0.4,0,0), rgb(0,0.2,0),
            rgb(0,0.4,0), rgb(0,0,0.7), rgb(0,0,0.4), rgb(0,0,1))
  legOrder <- c(6,5,2,1,4,3,NA,NA,9,8,7)
  oldpar <- par()
  par(las=1,mar=c(4, 4, 6, 2) + 0.1,cex.axis=0.9)
  tmp <- barplot(t(as.matrix(catches))/1000, beside=FALSE, names=catches[,1],
                 col=cols,xlab="Year", ylab="", cex.lab=1, xaxt="n", mgp=c(2.2,1,0))
  axis(1,at=tmp, labels=years, line=-0.12)
  grid(NA,NULL,lty=1,lwd = 1)
  mtext("Catch ('000 mt)",side=2,line=2.8,las=0,cex=1.3)
  barplot(t(as.matrix(catches))/1000,beside=FALSE,names=catches[,1],
          col=cols, xlab="Year",ylab="",cex.lab=1,xaxt="n",add=TRUE,mgp=c(2.2,1,0))

legend(x=0,y=leg.y.loc,
         c("Canadian Foreign","Canadian Joint-Venture","Canadian Shoreside","Canadian Freezer Trawl",
           "U.S. Foreign","U.S. Joint-Venture","U.S. MS","U.S. CP","U.S. Shore-based")[legOrder],
         bg="white",horiz=F,xpd=NA,cex=1,ncol=3,fill=cols[legOrder],border=cols[legOrder],bty="n")
  par <- oldpar
}

# US catches only, for all years:
make.catches.table.US <- function(catches,              ## The output of the load.catches function above.
                                  start.yr,             ## start.yr is the first year to show in the table
                                  end.yr,               ## end.yr is the last year to show in the table
                                  weight.factor = 1000, ## divide catches by this factor
                                  xcaption = "default", ## Caption to use
                                  xlabel   = "default", ## Latex label to use
                                  font.size = 9,        ## Size of the font for the table
                                  space.size = 10       ## Size of the spaces for the table
                                  ){
  ## Returns an xtable in the proper format for the full catches from the U.S.
  catches <- catches[,c("Year", "US_foreign", "US_JV", "atSea_US_MS",
                        "atSea_US_CP", "US_shore",  "USresearch", "Ustotal")]
  ## colnames(catches) <- c("Year","US Foreign","US JV","US Mothership","US Catcher-Processor","US Shore-based","US Research","US Total")  # to include 'US'
  colnames(catches) <- c("Year","Foreign","JV","Mothership","Catcher-Processor","Shore-based","Research","Total")

  ## Filter for correct years to show and make thousand-seperated numbers (year assumed to be column 1)
  catches <- catches[catches[,1] >= start.yr & catches[,1] <= end.yr,]
  catches[,-1] <- fmt0(catches[,-1])  ## -1 means leave the years alone and don't comma-seperate them

  ## Make the size string for font and space size
  size.string <- paste0("\\fontsize{",font.size,"}{",space.size,"}\\selectfont")
  return(print(xtable(catches, caption=xcaption, label=xlabel, align=get.align(ncol(catches))),
               caption.placement = "top", include.rownames=FALSE, table.placement="H", sanitize.text.function=function(x){x}, size=size.string))
}

## Canadian catches only, for all years:
make.catches.table.Can <- function(catches,              ## The output of the load.catches function above.
                                   start.yr,             ## start.yr is the first year to show in the table
                                   end.yr,               ## end.yr is the last year to show in the table
                                   weight.factor = 1000, ## divide catches by this factor
                                   xcaption = "default", ## Caption to use
                                   xlabel   = "default", ## Latex label to use
                                   font.size = 9,        ## Size of the font for the table
                                   space.size = 10       ## Size of the spaces for the table
                                   ){
  ## Returns an xtable in the proper format for the full catches from Canada.
  catches <- catches[,c("Year", "CAN_forgn", "CAN_JV", "CAN_Shoreside",
                        "CAN_FreezeTrawl", "CANtotal")]
  colnames(catches) <- c("Year","Foreign","JV","Shoreside","Freezer-trawl","Total")

  ## Filter for correct years to show and make thousand-seperated numbers (year assumed to be column 1)
  catches <- catches[catches[,1] >= start.yr & catches[,1] <= end.yr,]
  catches[,-1] <- fmt0(catches[,-1])  ## -1 means leave the years alone and don't comma-seperate them

  ## Make the size string for font and space size
  size.string <- paste0("\\fontsize{",font.size,"}{",space.size,"}\\selectfont")
  return(print(xtable(catches, caption=xcaption, label=xlabel, align=get.align(ncol(catches))),
               caption.placement = "top", include.rownames=FALSE, table.placement="H", sanitize.text.function=function(x){x}, size=size.string))
}

## ** Combine these three functions (this and two above) into one with a switch,
##  since it's only the filtering that changes.
## Total catches for both countries, for all years:
make.catches.table.total <- function(catches,              ## The output of the load.catches function above.
                                     start.yr,             ## start.yr is the first year to show in the table
                                     end.yr,               ## end.yr is the last year to show in the table
                                     weight.factor = 1000, ## divide catches by this factor
                                     xcaption = "default", ## Caption to use
                                     xlabel   = "default", ## Latex label to use
                                     font.size = 9,        ## Size of the font for the table
                                     space.size = 10       ## Size of the spaces for the table
                                     ){
  ## Returns an xtable in the proper format for the full catches from Canada.
  catches <- catches[,c("Year", "Ustotal", "CANtotal", "TOTAL")]
  colnames(catches) <- c("Year","Total U.S.","Total Canada","Total coastwide")
  catches[, "Percent U.S."] <- 100 * catches[,"Total U.S."] /
                               catches[,"Total coastwide"]
  ## catches[, "Percent U.S."] = paste0(round(catches[, "Percent U.S."],
  ##    1), "\\%")    # To add % sign, but a bit clutterred and not sure how
  ##                  #  to force 91.0% instead of 91%
  catches[, "Percent Canada"] <- 100 * catches[,"Total Canada"] /
                                 catches[,"Total coastwide"]
  ## catches[, "Percent Canada"] = paste0(round(catches[, "Percent Canada"
  ##    ],  1), "\\%")

  ## Filter for correct years to show and make thousand-seperated numbers (year assumed to be column 1)
  catches <- catches[catches[,1] >= start.yr & catches[,1] <= end.yr,]
  catches[,-c(1, 5, 6)] <- fmt0(catches[,-c(1, 5, 6)])  ## leave three columns
                                   ## alone and don't comma-separate them
  catches[,c(5, 6)] <- fmt0(catches[,c(5, 6)], dec.points=1) ## one dec point

  ## Make the size string for font and space size
  size.string <- paste0("\\fontsize{",font.size,"}{",space.size,"}\\selectfont")
  return(print(xtable(catches, caption=xcaption, label=xlabel, align=get.align(ncol(catches))),
               caption.placement = "top", include.rownames=FALSE, table.placement="H", sanitize.text.function=function(x){x}, size=size.string))
}

make.landings.tac.table <- function(landings.vs.tac,
                                    start.yr,             ## start.yr is the first year to show in the table
                                    end.yr,               ## end.yr is the last year to show in the table
                                    xcaption = "default", ## Caption to use
                                    xlabel   = "default", ## Latex label to use
                                    font.size = 9,        ## Size of the font for the table
                                    space.size = 10       ## Size of the spaces for the table
                                    ){
  ## Returns an xtable in the proper format for the executive summary landings vs. TAC for management performance section
  tab <- landings.vs.tac

  ## Filter for correct years to show and make thousand-seperated numbers (year assumed to be column 1)
  tab <- tab[tab$Year >= start.yr & tab$Year <= end.yr,]
  tab[,-c(1,8,9,10)] <- fmt0(tab[,-c(1,8,9,10)])
  ## Round the proportions to one decimal place
  tab[,8] <- paste0(fmt0(tab[,8],1),"\\%")
  tab[,9] <- paste0(fmt0(tab[,9],1),"\\%")
  tab[,10] <- paste0(fmt0(tab[,10],1),"\\%")
  colnames(tab) <- c("\\textbf{Year}",
                     "\\specialcell{\\textbf{US}\\\\\\textbf{landings (t)}}",
                     "\\specialcell{\\textbf{Canadian}\\\\\\textbf{landings (t)}}",
                     "\\specialcell{\\textbf{Total}\\\\\\textbf{landings (t)}}",
                     "\\specialcell{\\textbf{Coast-wide}\\\\\\textbf{(US+Canada)}\\\\\\textbf{catch}\\\\\\textbf{target (t)}}",
                     "\\specialcell{\\textbf{Canada}\\\\\\textbf{catch}\\\\\\textbf{target (t)}}",
                     "\\specialcell{\\textbf{US}\\\\\\textbf{catch}\\\\\\textbf{target (t)}}",
                     "\\specialcell{\\textbf{US}\\\\\\textbf{Proportion}\\\\\\textbf{of catch}\\\\\\textbf{target}\\\\\\textbf{removed}}",
                     "\\specialcell{\\textbf{Canada}\\\\\\textbf{Proportion}\\\\\\textbf{of catch}\\\\\\textbf{target}\\\\\\textbf{removed}}",
                     "\\specialcell{\\textbf{Total}\\\\\\textbf{Proportion}\\\\\\textbf{of catch}\\\\\\textbf{target}\\\\\\textbf{removed}}")
  ## Make the size string for font and space size
  size.string <- paste0("\\fontsize{",font.size,"}{",space.size,"}\\selectfont")
  return(print(xtable(tab, caption=xcaption, label=xlabel, align=get.align(ncol(tab),first.left=FALSE,just="c"), digits=c(0,0,0,0,0,0,0,0,1,1,1)),
               caption.placement = "top", include.rownames=FALSE, table.placement="H", sanitize.text.function=function(x){x}, size=size.string))
}

years.Can.JV.catch.eq.0 <- function(catches,          ## The output of the load.catches
                                                      ## function above.
                                    start.yr = 1999){ ## the year from which to look for no
                                                      ##  Can JC catch.
  ## Calculate the recent years that had no Canadian JV catch, for Introduction
  years.Can.JV.catch.eq.0 <- catches[ catches$CAN_JV == 0, ]$Year
  years.Can.JV.catch.eq.0.recent <- years.Can.JV.catch.eq.0[ years.Can.JV.catch.eq.0 > 1999]
  return(years.Can.JV.catch.eq.0.recent)
}
