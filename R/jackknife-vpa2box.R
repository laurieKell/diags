skip.hash<-function(i,file){
  i <- i+1
  while (substr(scan(file,skip=i,nlines=1,what=("character"),quiet=TRUE)[1],1,1)=="#")
    i <- i+1
  
  return(i)}

skip.until.hash<-function(i,file){
  i <- i+1
  while (substr(scan(file,skip=i,nlines=1,what=("character"),quiet=TRUE)[1],1,1)!="#")
    i <- i+1
  
  return(i)
}

vpa2boxFiles<-function(file,print=FALSE){
  i <- skip.hash(0,file)
  j <- skip.until.hash(i,file)
  
  res <- gsub(" ","",gsub("'","",substr(scan(file,skip=i+1,nlines=j-i-1,
                                             quiet=TRUE,what=character(),sep="\n"),1,20)))
  
  if (print)  print(res)
  
  return(res)}

getPath <- function(file) {
  if (!grepl(.Platform$file.sep,file))
    res <- getwd()
  else
    res <- substr(file,1,max(gregexpr(.Platform$file.sep,file)[[1]])-1)
  return(res)}

getFile <- function(file) {
  res <- substr(file,max(gregexpr(.Platform$file.sep,file)[[1]])+1,
                nchar(file))
  return(res)}

saveNF<-function(i,spd,dir){
  tmp=str_trim(scan(spd,sep="\n",what=as.character("t"),quiet=TRUE))
  spc=seq(length(tmp))[nchar(tmp)==0]
  F  =seq(length(tmp))[substr(tmp,1,1)=="F"]
  N  =seq(length(tmp))[substr(tmp,1,1)=="N"]
  
  N=read.table(spd,skip=N,nrows=spc[spc>N][1]-N-1)
  names(N)=c("year",0:5)
  F=read.table(spd,skip=F,nrows=spc[spc>F][1]-F-1)
  names(F)=c("year",0:5)
  
  write.table(cbind(iter=i,N),file=file.path(dir,"n.txt"),append=TRUE,row.names=FALSE,col.names=FALSE)
  write.table(cbind(iter=i,F),file=file.path(dir,"f.txt"),append=TRUE,row.names=FALSE,col.names=FALSE)   }

saveQ<-function(i,dgs,dir){
  res=diags.vpa2box(dgs)
  res=res[!duplicated(res$name),c("name","q")]
  
  write.table(cbind(iter=i,res),file=file.path(dir,"q.txt"),append=TRUE,row.names=FALSE,col.names=FALSE)
  }

saveDiags<-function(i,dgs,dir){
  res=diags.vpa2box(dgs)
  
  write.table(cbind(iter=i,res),file=file.path(dir,"diags.txt"),append=TRUE,row.names=FALSE,col.names=FALSE)
  }

run.vpa2box<-function(file,m=0.2){
  
  sink("/dev/null")
  
  path =getPath(file)
  ctl  =getFile(file)
  where=getwd()
  setwd(getPath(file))
  
  dirTmp= tempdir() 
  system(paste("wine vpa-2box.exe", ctl, ">tmp.txt"))
  res=readVPA2Box(file,m=m)
  
  setwd(where)
  
  sink(NULL)
  
  return(res)}

jackknife.vpa2box<-function(file,m=0.2){
  
  #tmp <- tempfile()
  #sink(file=tmp)
  #on.exit(sink(file=NULL))
  #on.exit(file.remove(tmp),add=TRUE)
  
  dirTmp= tempdir() 
  
  path=getPath(file)
  ctl =getFile(file)
  where=getwd()
  setwd(getPath(file))
  fls =vpa2boxFiles(file)
  
  #so can replace latter
  dFl=paste(fls[1],"_",sep="")
  file.copy(fls[1],dFl)
  
  d  =scan(dFl,sep="\n",what=as.character("a"),quiet=TRUE)
  ln =seq(length(d))[substr(d,1,2)=="-1"]
  d1 =d[1:(ln[2])]
  idx=d[(ln[2]+1):(ln[3])]
  idx=idx[substr(idx,1,1)!="#"]
  d2 =d[(ln[3]+1):length(d)][substr(idx,1,1)!="#"]
  
  system(paste("wine vpa-2box.exe", ctl, ">tmp.txt"))
  saveNF(   0,fls[5],dirTmp)
  saveQ(    0,fls[3],dirTmp)
  
  m_ply(data.frame(i=seq(length(idx)-1)), 
    function(i){
    cat(d1,     file=fls[1],sep="\n")
    cat(idx[-i],file=fls[1],sep="\n",append=TRUE)
    cat(d2,     file=fls[1],sep="\n",append=TRUE)
    system(paste("wine vpa-2box.exe", ctl, ">tmp.txt"))
    saveNF(   i,file.path(path,fls[5]),dirTmp)
    saveQ(    i,file.path(path,fls[3]),dirTmp)
    })
  
  file.remove(fls[1])
  file.copy(dFl,fls[1])
  file.remove(dFl)
  
  yf=as.data.frame(maply(idx[-length(idx)],function(x) as.numeric(unlist(strsplit(x,"\t"))[1:2])))
  names(yf)=c("name","year")
  yf=rbind(data.frame(name=0,year=0),yf)
  dimnames(yf)[[1]]=c(0,seq(dim(yf)[1]-1))
  
  n  =read.table(file.path(dirTmp,"n.txt"))
  n  =as.FLQuant(transmute(melt(n,id=c("V1","V2")),age=as.numeric(variable),data=value,year=V2,iter=V1))
  f  =read.table(file.path(dirTmp,"f.txt"))
  f  =as.FLQuant(transmute(melt(f,id=c("V1","V2")),age=as.numeric(variable),data=value,year=V2,iter=V1))

  ## catchability by fleet for leave-one-out point
  nms=getFLindexNames(fls[1])
  q  =read.table(file.path(dirTmp,"q.txt"))
  names(q)=c("iter","name","q")
  q  =subset(q,iter!=0)
  
  ## observations by fleet and year
  obs=ldply(idx[-length(idx)],function(x) t(unlist(strsplit(x,"\t"))[1:2]))
  names(obs)=c("index","year")
  obs=transform(obs,name=nms[as.integer(ac(index))])
  obs=cbind(obs,iter=seq(dim(obs)[1]))[,-1]
  
  obs$name=ac(obs$name)
  q$name=ac(q$name)
  
  q=merge(obs,q,by=c("name","iter"))
  q=q[order(as.integer(q$iter)),]
  dimnames(q)[[1]]=q$iter
  q$name=ac(q$name)

  stk=readVPA2Box(file,m=m)
  
  stock.n(stk)=n
  harvest(stk)=f
  units(harvest(stk))="f"
  
  attributes(stk)[["iter.key"]]=yf[-1]
  
  rf1=stk
  stock.n(rf1)=stock.n(iter(stk,1))
  harvest(rf1)=harvest(iter(stk,1))
  dimnames(stock.n(rf1))$iter=1
  dimnames(harvest(rf1))$iter=1
  
  rfs=stk
  rfs@stock.n=stock.n(iter(rfs,-1))
  rfs@harvest=harvest(iter(rfs,-1))
  
  setwd(where)
  
  file.remove(file.path(dirTmp,"n.txt"))
  file.remove(file.path(dirTmp,"f.txt"))
  file.remove(file.path(dirTmp,"q.txt"))
  file.remove(dirTmp)
  
  press=list(stock=FLStocks("fit"=rf1,"jackknife"=rfs),"q"=q[,c("iter","name","year","q")])
  
  return(press)}

perrFn<-function(idx,stk,q){
  
  res=NULL
  for (i in seq(dim(q)[1])){
    nm =ac(q[i,"name"])
    yr =ac(q[i,"year"])
    
    obs=(index(idx[[nm]])/q[i,"q"])[,yr]
    hat=uHat(idx[[nm]],iter(stk,i))[,yr]
    
    res=rbind(res,data.frame("obs"=c(obs),"hat"=c(hat),"p.error"=c(log(obs/(hat)))))
    }  
  
  cbind(q,res)}

perr.vpa2box<-function(file,m=0.2){
  
  # tmp <- tempfile()
  # sink(tmp)
  # on.exit(sink(file=NULL))
  # on.exit(file.remove(tmp),add=TRUE)
  # 
  res=jackknife.vpa2box(file,m=m)
  
  path=getPath(file)
  ctl =getFile(file)
  where=getwd()
  setwd(getPath(file))
  fls =vpa2boxFiles(file)
  
  idx=readVPA2BoxIndices(fls[1])
  res[["p.error"]]=perrFn(idx,res[[1]][[2]],res[[2]])
  res=res[-2]
  
  setwd(where)
  
  res}
