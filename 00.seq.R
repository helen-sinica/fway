# process:
# 1 xml min-by-min => csv daily
# generate sh file to call proc5_time

# input
sta.date <- "2015-02-14"
end.date <- "2015-02-23"
call_processing_file <- "Rscript 01.xmlToCsvDaily.R "
o.name <- "5_20150214_20150223.sh"
    
sta <- strptime(sta.date, format = "%Y-%m-%d")
end <- strptime(end.date, format = "%Y-%m-%d")
s <- seq(sta, end, by = "days")
x <- vector()
for(i in 1:length(s)){
    date <- strftime(s[i], format = "%Y%m%d")
    if(i%%10==0){
        x[i] <- paste0(call_processing_file, date, ";")
    }else if(i==length(s)){
        x[i] <- paste0(call_processing_file, date)
    }else{
        x[i] <- paste0(call_processing_file, date, " &")       
    }
}
write.table(x, file=o.name, sep=" ", quote=F, row.names=F, col.names=F)


#xxx sh 5_20150214_20150223.sh

# # check processing time by loading ptm_ls  in
# #xxx matrix(unlist(ptm_ls), ncol = 5, byrow=T)
# 
# df0124 <- data.frame(matrix(unlist(ptm_ls), ncol = 5, byrow = T))
# # tail(df0124)
# df0124$X6 <- df0124$X3 - c(0, df0124$X3[1:(dim(df0124)[1]-1)])
# plot(df0124$X6)
# 
# df0401 <- data.frame(matrix(unlist(ptm_ls), ncol = 5, byrow = T))
# # tail(df0401)
# df0401$X6 <- df0401$X3 - c(0, df0401$X3[1:(dim(df0401)[1]-1)])
# plot(df0401$X6)
# 
# df1118 <- data.frame(matrix(unlist(ptm_ls), ncol = 5, byrow = T))
# # tail(df1118)
# df1118$X6 <- df1118$X3 - c(0, df1118$X3[1:(dim(df1118)[1]-1)])
# plot(df1118$X6)
# 
# df0131 <- data.frame(matrix(unlist(ptm_ls), ncol = 5, byrow = T))
# # tail(df0131)
# df0131$X6 <- df0131$X3 - c(0, df0131$X3[1:(dim(df0131)[1]-1)])
# plot(df0131$X6)
