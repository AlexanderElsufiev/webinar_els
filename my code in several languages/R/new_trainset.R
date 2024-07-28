if (!require("data.table")) {
  install.packages("data.table")
}
library("data.table")




myPackage$trs.tData.extractor3=function(pData, mData, wData) {
  # Метод объединения, оставляющий данные о поездах 
  # и типах мест построчно
  #cat(paste("Begin extraction: ", as.character(Sys.time()), "\n"))
  pData=as.data.table(pData)
  pData$Before=pmin(pmax(pData$Before,1),45);
  pData$Pkm=pData$Kol_pas * pData$Rasst;
  #cat(paste("Before aggregate 1: ", as.character(Sys.time()), "\n"))
  marshr=pData[, lapply(.SD, function(x){sum(abs(x))}), 
                  by = c('Sto','Stn','Rasst'), .SDcols = c("Kol_pas")]
  #cat(paste("After aggregate 1: ", as.character(Sys.time()), "\n"))
  marshr=marshr[(marshr$Kol_pas > 100), ];
  marshr$Kol_pas=NULL #удалены редкие ошибки расстояний, менее 100 пассажиров
  
  # А ТУТ ИЗ МАТРИЦЫ РАССТОЯНИЙ СОСТАВЛЯЕМ МАРШРУТ
  rst=myPackage$marshr_to_rasst(marshr);max_rst=max(rst$rst)
  
  rst_o=data.table(Sto = rst$kst, n_o = rst$nom)
  rst_n=data.table(Stn = rst$kst, n_n = rst$nom)

  mesta=merge(pData,rst_o,by=c('Sto'));mesta=merge(mesta,rst_n,by=c('Stn'));
  rm(rst,rst_o,rst_n)
  
  
  mesta=mesta[, lapply(.SD, sum, na.rm = T), .SDcols = "Kol_pas",
                 by = c('Train', 'Date', 'Type', 'Klass', 'n_o', 'n_n','Arenda')]
  
  
  
  
  pData[(pData$Rasst < max_rst), 'Cena'] = 0
  cena=pData[, lapply(.SD, max, na.rm = T), .SDcols = c("Cena"),
                by = c('Date', 'Train', 'Type', 'Klass', 'Arenda', 'Before')]
  pass=pData[, lapply(.SD, sum, na.rm = TRUE), by = c('Date','Train','Type','Klass','Arenda','Before'),
                .SDcols = c("Kol_pas", "Stoim", "Pkm")]
  pass=merge(pass, cena , by = c('Date','Train','Type','Klass','Arenda','Before'))
  pass_=pass[(pass$Klass != '-'), ];#добавка сумм классов вагона
  if (nrow(pass_) > 0) {
    pass_$klass='-'
    cena=pass_[, lapply(.SD, max, na.rm = TRUE), .SDcols = c("Cena"),
                  by = c('Date','Train','Type','Klass','Arenda','Before')]
    pass_=pass_[, lapply(.SD, sum, na.rm = TRUE), by = c('Date','Train','Type','Klass','Arenda','Before'),
                   .SDcols = c("Kol_pas", "Stoim", "Pkm")]
    pass_=merge(pass_, cena, by = c('Date','Train','Type','Klass','Arenda','Before'))
  }
  pass=rbind(pass,pass_)
  pass_=pass[(pass$Klass == '-') & (pass$Type != '-'),];#добавка сумм типов вагона
  if (nrow(pass_) > 0) {
    pass_$Type='-'
    cena=pass_[, lapply(.SD, max, na.rm = TRUE), .SDcols = c("Cena"),
                  by = c('Date','Train','Type','Klass','Arenda','Before')]
    pass_=pass_[, lapply(.SD, sum, na.rm = TRUE), by = c('Date','Train','Type','Klass','Arenda','Before'),
                   .SDcols = c("Kol_pas", "Stoim", "Pkm")]
    pass_=merge(pass_,cena,by = c('Date','Train','Type','Klass','Arenda','Before'))
  }
  pass=rbind(pass,pass_)
  pData=pass;
  rm(pass,pass_,cena)
  
  
  
  
  # здесь кусок множества обозначаю как хочу - удобно part
  f=function(part) {
    kp=numeric(45);
    pkm=numeric(45);stoim=numeric(45);cena=numeric(45)
    len=nrow(part);
    total=0;
    r_total=0;
    before=part$Before
    bkp=part$Kol_pas
    bpkm=part$Pkm
    bstoim=part$Stoim
    bcena=part$Cena
    if (len > 0) {for (i in 1:len) {
      d=before[i]
        {kp[d]=kp[d] + bkp[i]}
      pkm[d]=pkm[d] + bpkm[i]
      stoim[d]=stoim[d] + bstoim[i]
      cena[d]=pmax(cena[d], bcena[i])
    }}
    
    for (i in 44:1) {
      kp[i]=kp[i] + kp[i + 1];
      pkm[i]=pkm[i] + pkm[i + 1];
      stoim[i]=stoim[i] + stoim[i + 1];
      if (cena[i] == 0) {
        cena[i]=cena[i + 1]
      }
    }
    for (i in 1:44) {
      if (cena[i + 1] == 0) {
        cena[i + 1]=cena[i]
      }
    }
    total=kp[1] #+ rent[1];
    l=paste(paste(as.character(total), collapse = ";"), 
            paste(as.character(kp), collapse = ";"), 
            #paste(as.character(rent), collapse = ";"),
            paste(as.character(pkm), collapse = ";"),
            paste(as.character(stoim), collapse = ";"),
            paste(as.character(cena), collapse = ";"),
            sep = ";"
    )        
    return(l)    
  }

  
  # здесь по синтаксису кусок базы обозначается именно .SD
  q=pData[, f(.SD), by = c('Date', 'Train', 'Type', 'Klass','Arenda')]
  columns=c("Total", paste("kp", as.character(1:45), sep = ""),
            paste("rent", as.character(1:45), sep = ""),
            paste("pkm", as.character(1:45), sep = ""),
            paste("stoim", as.character(1:45), sep = ""),
            paste("cena", as.character(1:45), sep = ""))
  parsed=tstrsplit(q$V1, ";")
  names(parsed)=columns
  q$V1=NULL
  q=as.data.table(as.data.frame(as.matrix(q), stringsAsFactors = FALSE))
  result=cbind(q, as.data.table(as.data.frame(parsed, stringsAsFactors = FALSE)))
  result=as.data.table(result)
  rm(parsed, q, columns)
  
  
  
  

  
  
#################################### ПЕРЕДЕЛКА ПРАВИЛЬНОГО ВАРИАНТА ПРОГРАММЫ  
  
pData$Date=as.Date(pData$Date)
pData$Train=as.character(pData$Train)
pData$Type=as.character(pData$Type)
pData$Klass=as.character(pData$Klass)
pData$Arenda=as.character(pData$Arenda)
pData$kk=pmax(0,pmin(as.integer(pData$Date)-max_dat,45))
  
  
ff=function(part) {
  part$Before=pmin(part$Before+1,45);#ограничиваю историю 45 днями
  kp=numeric(45);pkm=numeric(45);stoim=numeric(45);cena=numeric(45)
  kpv=numeric(45);cenv=numeric(45)
  len=nrow(part);
  if (len > 0) {for (i in 1:len) {
    kp[part$Before[i]] =kp[part$Before[i]]+part$Kol_pas[i]
    pkm[part$Before[i]] =pkm[part$Before[i]]+part$Pkm[i]
    stoim[part$Before[i]] =stoim[part$Before[i]]+part$Stoim[i]
    cena[part$Before[i]]=pmax(cena[part$Before[i]],part$Cena[i]) 
    if(part$verx[i]=='V'){
      kpv[part$Before[i]] =kpv[part$Before[i]]+part$Kol_pas[i]
      cenv[part$Before[i]]=pmax(cenv[part$Before[i]],part$cena_niz[i]) }
  }}
  
  for (i in 44:1) {kp[i]=kp[i]+kp[i+1];kpv[i]=kpv[i]+kpv[i+1];
  pkm[i]=pkm[i]+pkm[i+1];stoim[i]=stoim[i]+stoim[i+1];
  if(cena[i]==0){cena[i]=cena[i+1]};if(cenv[i]==0){cenv[i]=cenv[i+1]} }
  for (i in 1:44) {if(cena[i+1]==0){cena[i+1]=cena[i]}
    if(cenv[i+1]==0){cenv[i+1]=cenv[i]} }

  k=part$kk[1]
  if (k>0){for (i in 1:k){kp[i]=NA;kpv[i]=NA;pkm[i]=NA;stoim[i]=NA;cena[i]=NA;cenv[i]=NA} }
  
  l=paste(
    paste(as.character(kp),collapse = ";"), 
    paste(as.character(pkm),collapse = ";"), 
    paste(as.character(stoim),collapse = ";"), 
    paste(as.character(cena),collapse = ";"), 
    paste(as.character(kpv),collapse = ";"), 
    paste(as.character(cenv),collapse = ";"), 
    sep = ";")  
  return (l)
}  
 
  
  # здесь по синтаксису кусок базы обозначается именно .SD
  qq=pData[, ff(.SD), by = c('Date', 'Train', 'Type', 'Klass','Arenda')]
  columns=c(paste("kp", as.character(0:44), sep = ""),
            paste("pkm", as.character(0:44), sep = ""),
            paste("stoim", as.character(0:44), sep = ""),
            paste("cena", as.character(0:44), sep = ""),
            paste("kpv", as.character(0:44), sep = ""),
            paste("cenv", as.character(0:44), sep = "") )
  parsed=tstrsplit(qq$V1, ";")
  names(parsed)=columns
  qq$V1=NULL
  qq=as.data.table(as.data.frame(as.matrix(qq), stringsAsFactors = FALSE))
  result=cbind(qq, as.data.table(as.data.frame(parsed, stringsAsFactors = FALSE)))
  result=as.data.table(result)
  for (c in columns) {suppressWarnings(result[[c]] <- as.integer(result[[c]]))}
  rm(parsed, qq, columns,ff)
  
  
  
  
  
  
  
  
  
  
  
  # из мест по маршртам получить минимальные занятые места
  mesta_=mesta[(mesta$Klass != '-'),]
  if (nrow(mesta_) > 0) {
    mesta$Klass='-'
  }
  mesta=rbind(mesta,mesta_)
  mesta_=mesta[(mesta$Type != '-') & (mesta$Klass != '-'),]
  if (nrow(mesta_) > 0) {
    mesta$Type='-'
  };
  mesta=rbind(mesta,mesta_)
  
  mesta$no=pmin(mesta$n_o,mesta$n_n)
  mesta$nn=pmax(mesta$n_o,mesta$n_n)
  mesta_=mesta;
  mesta_$no=mesta_$nn;
  mesta_$Kol_pas=-mesta_$Kol_pas
  mesta=rbind(mesta,mesta_)
  rm(mesta_)
  mesta=mesta[, lapply(.SD, sum, na.rm = TRUE), .SDcols = c("Kol_pas"),
                 by = c('Date','Train','Type','Klass','no')]
  max_n = max(mesta$no)
  #cat(paste("Before second split: ", as.character(Sys.time()), "\n"))
  f=function(.SD) {
    kp=numeric(max_n);
    kp[.SD$no]=.SD$Kol_pas
    for (i in 1:(max_n - 1)) {
      kp[i + 1]=kp[i + 1] + kp[i]
    }
    kol_mest=max(kp)
    return(kol_mest)   
  }
  kol_mest=mesta[, f(.SD), by = c('Date', 'Train', 'Type', 'Klass')]
  setnames(kol_mest, "V1", "kol_mest")
  
  result=merge(result, kol_mest, by = c("Train", "Date", "Type","Klass"))
  result$Rasst=max_rst
  
  wData$Train=as.character(wData$Train)
  wData$Date=as.character(wData$Date)
  wData$Type=as.character(wData$Type)
  wData$Klass=as.character(wData$Klass) 
  wData=as.data.table(wData)
  vag=wData[(wData$Klass != '-'),]
  if (nrow(vag) > 0) {
    vag$Klass='-'
  }
  wData=rbind(wData,vag)
  vag=wData[(wData$Klass == '-') & (wData$Type != '-'),]
  if (nrow(vag) > 0) {
    vag$Type='-'
  }
  
  wData=rbind(wData,vag)
  wData=wData[, lapply(.SD, sum, na.rm = TRUE), .SDcols = c("Kol_vag", "Seats"),
                 by = c('Date','Train','Type','Klass')]
  
  result=merge(result, wData, by = c("Train", "Date", "Type","Klass"))
  
  #блок - взять только максимальные расстояния
  mData$Train=as.character(mData$Train)
  mData$Date=as.character(mData$Date)
  mData=as.data.table(mData[(mData$Rasst == max_rst),])
  
  #Блок постановки направления - оно не меняется с течением времени, но по неполному маршр вычисляется неправильно
  mr=mData[, lapply(.SD, max, na.rm = TRUE), .SDcols = c("Rasst"),
              by = c('Train','Sto','Stn')]
  mr_=mr[, lapply(.SD, max, na.rm = TRUE), .SDcols = c("Rasst"),
            by = c('Train')]
  mr_$r=mr_$Rasst
  mr_$Rasst=NULL
  mr=merge(mr, mr_, by = c("Train"))
  mr=mr[(mr$Rasst == mr$r),]
  mr$Napr=as.character(as.integer(mr$Sto < mr$Stn))
  mr=subset(mr, select = c(Train, Napr))
  mData=merge(mData, mr, by = c("Train"))
  rm(mr,mr_)
  #
  
  #вычисление кто первый - уже по датам и направлениям
  mData$Time=mData$Tm_prib - mData$Tm_otp
  mt=mData[, lapply(.SD, min, na.rm = TRUE), .SDcols = c("Tm_otp"),
              by = c('Date', 'Napr')]
  mt$tmo=mt$Tm_otp
  mt$Tm_otp=NULL
  mData=merge(mData, mt,  by = c("Date","Napr"))
  mData$First=as.character(as.integer(mData$Tm_otp == mData$tmo))
  #Вычисление кто скорый (наискорейший)
  mt=mData[, lapply(.SD, min, na.rm = TRUE), .SDcols = c("Time"),
              by = c('Date', 'Napr')]
  mt$tm=mt$Time
  mt$Time=NULL
  mData=merge(mData, mt, by = c("Date","Napr"))
  rm(mt)
  mData$Skor=as.character(as.integer(mData$Time == mData$tm))
  mData=subset(mData, select = c(Train, Date, Napr, Tm_otp, Time, First, Skor))
  
  result=merge(mData, result, by = c("Train", "Date"))
  result=as.data.frame(result)
  result=cbind(subset(result, select = c(Date, Train, Type, Seats, Total,kol_mest)),
                  subset(result, select = -c(Date, Train, Type, Seats, Total,kol_mest)))
  columns=paste(c("kp", "rent", "pkm", "cena", "stoim"), as.character(1:45), sep = "")
  for (c in columns) {
    result[[c]]=as.integer(result[[c]])
  }
  result$Total=as.integer(result$Total)
  #cat(paste("End: ", as.character(Sys.time()), "\n"))
  return(result)
}





#по списку расстояний восстановить очерёдность станций и расст в маршрут
myPackage$marshr_to_rasst=function(marshr) {
  mar = data.table(Rasst = marshr$Rasst, Sto = marshr$Stn, Stn = marshr$Sto)
  #взять и туда и обратно симметрично
  marshr = rbind(marshr,mar);
  marshr=unique(marshr)
  
  marshr=marshr[order(-marshr$Rasst),];
  mar=marshr[1,];
  max_rst=mar$Rasst;
  rst=mar;
  rst$kst=rst$Sto;
  rst$Sto=NULL;
  rst$Stn=NULL;
  rst$rst=0;
  rst$Rasst=NULL
  rs=rst;rs$kst=mar$Stn;rs$rst=mar$Rasst;rst=rbind(rst,rs);rm(rs)
  z='1'
  
  while(z=='1')  {
    rst_o=rst;rst_o$Sto=rst_o$kst;rst_o$r_o=rst_o$rst;rst_o$kst=NULL;rst_o$rst=NULL
    rst_n=rst;rst_n$Stn=rst_n$kst;rst_n$r_n=rst_n$rst;rst_n$kst=NULL;rst_n$rst=NULL
    mar=merge(marshr,rst_o,by=c('Sto'), all=TRUE)
    mar=merge(mar,rst_n,by=c('Stn'), all=TRUE)
    
    mar=mar[(!is.na(mar$r_o))|(!is.na(mar$r_n)),]
    mar=mar[(is.na(mar$r_o))|(is.na(mar$r_n)),]
    
    mr=mar[(!is.na(mar$r_o)),];mr=mr[(mr$Rasst>mr$r_o),];
    mr$kst=mr$Stn;mr$rst=mr$Rasst+mr$r_o;
    mr=subset(mr,select=c('kst','rst'));rst=rbind(rst,mr);
    k1=nrow(mr);
    
    mr=mar[(!is.na(mar$r_o)),];mr=mr[(mr$Rasst+mr$r_o>max_rst),];
    mr$kst=mr$Stn;mr$rst=mr$r_o-mr$Rasst;
    mr=subset(mr,select=c('kst','rst'));rst=rbind(rst,mr);
    k2=nrow(mr);
    rst=unique(rst);if((k1+k2)==0){z='0'}
  }
  o=order(rst$rst);rst=rst[o,]
  rst=rst[order(rst$rst),]
  rst$nom=1:nrow(rst)
  return(rst)
}







