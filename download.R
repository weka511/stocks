rm(list=ls())
if(!file.exists("data"))
  dir.create("data")

download.file("http://www.asx.com.au/programs/ISIN.xls","data/codes.csv")
codes=read.delim("data/codes.csv")

download.file("http://www.asx.com.au/asx/research/ASXListedCompanies.csv","data/ASXListedCompanies.csv")
companies=read.table("data/ASXListedCompanies.csv",header=TRUE,sep=",",skip=2)

download.file("http://www.asxhistoricaldata.com/wp-content/uploads/2014.zip","data/2014.zip")
zipdir <- tempfile()
dir.create(zipdir)
unzip("data/2014.zip", exdir=zipdir)

for (d in list.files(zipdir)) {
  sub=file.path(zipdir,d)
  for (f in list.files(sub) ){
    ff=file.path(sub,f)
    codes=read.csv(ff,header=FALSE)
    print (head(codes))
  }
}
