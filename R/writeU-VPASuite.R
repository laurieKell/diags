utils::globalVariables(c("name"))
utils::globalVariables(c("dlply"))
utils::globalVariables(c("."))
utils::globalVariables(c("cast"))
utils::globalVariables(c("llply"))
utils::globalVariables(c("m_ply"))

.writeUvpa=function(object,file,smry=attributes(object)$smry) {  
  
  timimgFn=function(x) if (x<0) c(0,1) else (x-1:0)/12
  
  idx=dlply(object, .(name), cast, year~age,value="cpue")
  idx=llply(idx,function(x) {x[is.na(x)]=-999; x})
  
  atNms=names(attributes(object))
  # opens connection to the output file
  #temp <- file(fl, "w")
  #on.exit(close(temp))
  
  #File title  
  if ("desc" %in% atNms) 
    cat(paste("Originally", attributes(object)$desc, sep=" "), "\n", file=file,append=FALSE)
  else
    cat("Generated by R cpue package", "\n", file=file,append=FALSE)
  
  #Code specifying the number of fleets
  cat(length(unique(object$index))+100, "\n", file=file,append=TRUE)
  
  m_ply(names(idx), function(x,idx,smry) {
    cat(x,                                        "\n",file=file,append=TRUE)
    cat(range(idx[[x]][,1]),                      "\n",file=file,append=TRUE)
    cat("1 1",timimgFn(smry[1,"timing"]),         "\n",file=file,append=TRUE)
    cat(paste(range(dimnames(idx[[x]])[[2]][-1])),"\n",file=file,append=TRUE)
    
    cat(paste(apply(cbind(1,as.matrix(idx[[x]])),1,paste,collapse=" "),"\n"),file=file,append=TRUE)
  },idx=idx, smry=smry)
}
