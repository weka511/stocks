rm(list=ls())
if(!file.exists("data"))
  dir.create("data")

download.file("http://www.asx.com.au/programs/ISIN.xls","data/codes.csv")
codes=read.delim("data/codes.csv")

download.file("http://www.asx.com.au/asx/research/ASXListedCompanies.csv","data/ASXListedCompanies.csv")
companies=read.table("data/ASXListedCompanies.csv",header=TRUE,sep=",",skip=2)

library(data.table)

is.numeric.string<-function(candidate) {
  suppressWarnings(!is.na(as.numeric(candidate)))
}

download.history<-function(url,year) {
  result<-list()
  short_file_name<-paste(toString(year),".zip",sep="")
  complete_url<-file.path(url,short_file_name)
  store_dir<-tempfile()
  dir.create(store_dir)
  zip_file_name<-file.path(store_dir,short_file_name)
  download.file(complete_url,zip_file_name)
  expand_dir<-file.path(store_dir,"expand")
  unzip(zip_file_name, exdir=expand_dir)

  for (subdir in list.files(expand_dir)) {
    if (is.numeric.string(subdir)) {
      subsub=file.path(expand_dir,subdir)
      for (f in list.files(subsub)) {
        ff=file.path(subsub,f)
        result[[length(result)+1]]<-fread(ff,sep=",",header=FALSE)
      }
    }
  }
  rbindlist(result)
}

for (year in 2009:2014) {
  l<-download.history("http://www.asxhistoricaldata.com/wp-content/uploads",year)
  short_file<-paste(toString(year),".csv",sep="")
  write.table(l,file.path("c:\\temp",short_file),sep=",")
}

