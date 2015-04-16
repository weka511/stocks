# Download ASX historical data
#
# Copyright (C) 2015 Simon Crase
#
# simon@greenweaves.nz
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

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

index.substring<-function(sub,str) {
  r<-regexpr(sub,str)
  r[1]
}

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
    pos=index.substring("-",subdir)
    prefix<-if (pos>0) substring(subdir,1,pos-1) else subdir
    if (is.numeric.string(prefix)) {
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

for (year in c("2007-2008","2005-2006","2003-2004","2000-2002","1997-1999")) {
  history.data<-download.history(year)
  rename.history.columns(history.data)
  short_file<-paste(toString(year),".csv",sep="")
  write.table(history.data,file.path("data/au",short_file),sep=",")
}

for (month in c("2015-January","2015-February")) {
  history.data<-download.history(month)
  rename.history.columns(history.data)
  short_file<-paste(toString(month),".csv",sep="")
  write.table(history.data,file.path("data/au",short_file),sep=",")
}

