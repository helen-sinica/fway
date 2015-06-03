#!/usr/bin/Rscript

# freeway data processing
# specify the period of time
# [2012-07-01 ~ 2015-03-29]
library(XML)
setwd("/home/helen")

# open file connection
dates <- commandArgs(TRUE)

folder <- "~/LunarNewYear/"
# open by folder (history data are organized by date)
f <- paste0(folder, dates, "_1.csv")
fNa <- paste0(folder, dates, "_1_nals.csv")
fcon <- file(f, "w", encoding = "UTF-8")  
fNacon <- file(fNa, "w", encoding = "UTF-8")

# # input
# rd <- "~/vd-history"      # root directory
# file_ls <- list.files(path = rd, full.names = T)
rd <- paste0("~/vd/vd_20120701-20150329_xml/", dates)
file_ls <- list.files(path=rd, full.names=T)
vd1_ls <- file_ls[grepl("vd_value_", file_ls)]

#create needed lists
parse_na_ls <- data.frame()
err_num <- 0

# f <- paste0(dates, "_5.csv")
# fNa <- paste0(dates, "_5_nals.csv")
# fcon <- file(f, "w", encoding = "UTF-8")  
# fNacon <- file(fNa, "w", encoding = "UTF-8")

# lapply by file list, save main info to csv, and return na_ls
ptm_ls <- lapply(vd1_ls, function(file_name){
    ptm <- proc.time()
    
    # try parsing the file from the file list
    parse <- try(xmlParse(file_name, encoding = "UTF-8"))
    
    # handling error
    if(inherits(parse, "try-error")){ 
        err_num <- err_num + 1
        err <- data.frame(file_name = file_name, err_m = geterrmessage())
        if(err_num == 0){
            write.table(err, file = fNacon, sep = ",", append=FALSE,
                        row.names = FALSE, col.names = TRUE, 
                        fileEncoding = "UTF-8")
        }else{
            write.table(err, file = fNacon, sep = ",", append=TRUE,
                        row.names = FALSE, col.names = FALSE, 
                        fileEncoding = "UTF-8")
        }          
#xxx problematic xxxx
#         NAs <- rep("NA", 8)
#         vd_lane <- c(file_name, NAs)
    }else{
        # extrat the info from xml
        root <- xmlRoot(parse)
#???    time_stamp <- xmlGetAttr(root, 'updatetime')
        time_stamp <- xpathSApply(parse, '//Info', xmlGetAttr, "datacollecttime")[1]
#         time_stamp <- xpathSApply(parse, '//Info', xmlGetAttr, "datacollecttime")
#         if(sum(time_stamp[1]!=time_stamp)!=0){
#             # handle abnormality
#         }
        
        lane_num <- xpathSApply(parse, '//Info', xmlSize)
        vd_list <- t(xpathSApply(parse, '//Info', xmlAttrs)[c("vdid", "status"),])
        
        # vdid/status times lane_num (make the length equal)
        vdid <- unlist(mapply(rep, x = vd_list[,"vdid"], times = lane_num, USE.NAMES=F))
        status <- unlist(mapply(rep, x = vd_list[,"status"], times = lane_num, USE.NAMES=F) )
        
        lane <- t(xpathSApply(parse, '//lane', xmlAttrs))
        
        car_S <- xpathSApply(parse, '//cars[@carid="S"]', xmlAttrs)["volume",]
        car_T <- xpathSApply(parse, '//cars[@carid="T"]', xmlAttrs)["volume",]
        car_L <- xpathSApply(parse, '//cars[@carid="L"]', xmlAttrs)["volume",]
        
        vd_lane <- cbind(time_stamp, vdid, status, lane, car_S, car_T, car_L)
    
        if ( file_name == vd1_ls[1] ){
            write.table(vd_lane, file = fcon, sep = ",", 
                        row.names = FALSE, fileEncoding = "UTF-8")
        }else{
            write.table(vd_lane, file = fcon, sep = ",",
                        row.names = FALSE, fileEncoding = "UTF-8",
                        append=TRUE, col.names = FALSE)
        }
        rm(vd_lane)
    }
    print(file_name)
    flush.console()
    
    proc.time() - ptm
    return(ptm)
})
close(fcon)
close(fNacon)
save(ptm_ls, file = paste0("ptm_ls_", dates, ".RData"))
#     na_name <- paste0(dates, "_nals.csv")
#     write.csv(na_ls, na_name)

#     gc()
#     setwd("~/")
    # 
    # }) (lapply dates)
# }