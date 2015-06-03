# generate cat list for shell script

library(data.table)
library(plyr)

# file name: 1-min-by-date
f.ls <- list.files("/home/helen/LunarNewYear", full.names=T)

# read the vd/rd reference table
# vd_rd <- fread("neihu-yushan-taipei.csv")
vd_rd <- fread("vd_rd_from_check.csv")
rd_name <- fread("rd_name.csv")

# vd_rd <- fread("N5_192.csv")
f.ls <- f.ls[grep("_1.csv", f.ls)]
count <- 1
lapply(f.ls, function(f){
    vd1spd <- fread(f)#, data.table=F)
    date <- strftime(strptime(vd1spd$time_stamp[1], format="%Y/%m/%d %H:%M:%S"), 
                     format="%Y-%m-%d")
    
    
    # vd1car <- vd1spd[vd1spd$vdid %in% vd_rd$vdid,]
    vd1IO <- vd1spd[grep("-O-|-I-", vd1spd$vdid)]
    vd1IO[status==1, c("speed", "laneoccupy", "car_S", "car_T", "car_L") := NA]
    vd1IO <- vd1IO[, lapply(.SD, as.numeric), by=.(time_stamp, vdid, status,vsrdir,vsrid)]
    
    vd1car <- vd1IO[, lapply(.SD, sum), by=vdid, .SDcol=c("car_S", "car_L", "car_T")]
    
    vd1rd <- join(vd_rd, vd1car, type="right")
    vd1rd[grep("-O-", vd1$vdid), IO:= "O"]
    vd1rd[grep("-I-", vd1$vdid), IO:= "I"]
    
    rd1IO <- vd1[, lapply(.SD, sum), by=.(routeid, IO), .SDcol=c("car_S", "car_L", "car_T")]
    rd1IO[,date:=date]
    setorder(rd1IO, routeid, IO)
    rd1IO <- join(rd_name, rd1IO, type="right")
    
    if(count==1){
        write.csv(rd1IO, "rd1IO.csv", row.names=F)
    }else{
        write.table(rd1IO, "rd1IO.csv", append=T, row.names=F, col.names=F)
    }
    
    count <- count + 1
})

#??? fill in missing time_stamp????

# minutes <- strftime(seq(from=strptime("2015/02/14", "%Y/%m/%d"), by="min", 
#                         length.out=1440), "%Y/%m/%d %H:%M:%S")
# sum(minutes %in% vd1car$time_stamp)



