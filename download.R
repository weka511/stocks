
library(data.table)

if(!file.exists("data"))
  dir.create("data")

if(!file.exists("data/au"))
  dir.create("data/au")



# download.file("http://www.asx.com.au/programs/ISIN.xls","data/codes.csv")
# codes=read.delim("data/codes.csv")
# 
# download.file("http://www.asx.com.au/asx/research/ASXListedCompanies.csv","data/ASXListedCompanies.csv")
# companies=read.table("data/ASXListedCompanies.csv",header=TRUE,sep=",",skip=2)



is.numeric.string<-function(candidate) {
  suppressWarnings(!is.na(as.numeric(candidate)))
}

download.history<-function(year,url="http://www.asxhistoricaldata.com/wp-content/uploads",expand="expand") {
  result<-list()
  short_file_name<-paste(toString(year),".zip",sep="")
  complete_url<-file.path(url,short_file_name)
  store_dir<-tempfile()
  dir.create(store_dir)
  zip_file_name<-file.path(store_dir,short_file_name)
  download.file(complete_url,zip_file_name)
  expand_dir<-file.path(store_dir,expand)
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

rename.history.columns<-function(history.data,new.names=c("Code", "Date", "Open", "High", "Low", "Close", "Volume")) {
  setnames(history.data,names(history.data),new.names)
}



for (year in 2009:2014) {
  history.data<-download.history(year)
  rename.history.columns(history.data)
  short_file<-paste(toString(year),".csv",sep="")
  write.table(history.data,file.path("data/au",short_file),sep=",")
}

