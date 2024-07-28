
if (!require("hash")) {install.packages("hash")}
  library("hash")

if (!require("stringr")) {install.packages("stringr")}
  library("stringr")

if (!require("plyr")) {install.packages("plyr")}
  library("plyr")

if (!require("zoo")) {install.packages("zoo")}
  library("zoo")

if (!require("data.table")) {install.packages("data.table")}
  library("data.table")



myPackage$trs.tData.extract <- function(name) {
  # Объединяет агрегированные базы данных о продажах
  # билетов и составности поездов в одну базу.
  # Args:
  #   extractor: метод объединения
  # Returns:
  #   объединенную базу, если extdbName = NULL
  
  #if (typeof(pData) == "character") {pData=myPackage$trs.pData.aggr.load(pData)}
  #if (typeof(mData) == "character") {mData=myPackage$trs.pData.aggr.load(paste(mData, "_mar", sep = ""))}
  #if (typeof(wData) == "character") {wData=myPackage$trs.wData.aggr.load(wData)}
  
  pData=myPackage$trs.dann_load(name,'pas')
  mData=myPackage$trs.dann_load(name,'mar')
  wData=myPackage$trs.dann_load(name,'vag')
  
  info=myPackage$trs.dann_load('info','rez') # ЧТО БЫЛО ПРОЧИТАНО РАНЬШЕ?
  info=info[(info$Database==name),]
  info=info[(info$ext!=1)|is.na(info$ext),]
  info=info[(info$kol_rez>0),]
  
  if (nrow(info)>0){
    min_date=min(as.Date(info$min_date))-2
    pData=pData[(as.Date(pData$Date)>=min_date),]
    mData=mData[(as.Date(mData$Date)>=min_date),]
    wData=wData[(as.Date(wData$Date)>=min_date),]
    
    
    pData$Klass=substr(pData$Klass,1,1);pData[(pData$Klass==pData$Type),'Klass']='-' 
    wData$Klass=substr(wData$Klass,1,1);wData[(wData$Klass==wData$Type),'Klass']='-' 
    
    if (name=='sahalin'){pData$Klass='-';wData$Klass='-'}
    
    if (name=='sapsan'){pData$Type=pData$Klass;pData$Klass='-';
    wData$Type=wData$Klass;wData$Klass='-'; }
    
    result <- myPackage$trs.tData.extractor(pData, mData, wData) #СОБСТВЕННО НАРАБОТКА ДАННЫХ
    
    if (name %in% c('sapsan','sahalin')){result$Klass=NULL}
    
    min_date=min_date+2
    result=result[(as.Date(result$Date)>=min_date),]
    
    old_rez=myPackage$trs.dann_load(name,'ext')
    old_rez=old_rez[(as.Date(old_rez$Date)<min_date),]
    result=myPackage$sliv(old_rez,result)
    
    myPackage$trs.Data_save(result, name,'ext',TRUE)
    
    info=myPackage$trs.dann_load('info','rez')
    info[(info$Database==name),'ext']=1
    myPackage$trs.Data_save(info, 'info','rez',TRUE)
  }
  #return (result) 
}








myPackage$trs.tData.extractor <- function(pData, mData, wData) {
  # Метод объединения, оставляющий данные о поездах 
  # и типах мест построчно
  
  pData$Before=pmin(pmax(pData$Before,1),45);pData$Pkm=pData$Kol_pas*pData$Rasst;
  #marshr=subset(pData,select=c(Sto,Stn,Rasst));marshr=unique(marshr)
  marshr=aggregate(x=list(kol=abs(as.integer(pData$Kol_pas))  ),
                   by=subset(pData,select=c('Sto','Stn','Rasst')),FUN="sum")
  marshr=marshr[(marshr$kol>100),];marshr$kol=NULL #удалены редкие ошибки расстояний, менее 100 пассажиров
  
  
  # А ТУТ ИЗ МАТРИЦЫ РАССТОЯНИЙ СОСТАВЛЯЕМ МАРШРУТ
  rst=myPackage$marshr_to_rasst(marshr);max_rst=max(rst$rst)
  
  rst_o=rst;rst_o$Sto=rst_o$kst;rst_o$n_o=rst_o$nom;rst_o=subset(rst_o,select=c(Sto,n_o))
  rst_n=rst;rst_n$Stn=rst_n$kst;rst_n$n_n=rst_n$nom;rst_n=subset(rst_n,select=c(Stn,n_n))
  
  mesta=merge(pData,rst_o,by=c('Sto'));mesta=merge(mesta,rst_n,by=c('Stn'));rm(rst,rst_o,rst_n)
  mesta=aggregate(Kol_pas ~Train+Date+Type+Klass+n_o+n_n,data = mesta, sum)
  
  #pData_=aggregate(c('Kol_pas') ~Train+Date+Type+Before+Arenda,data = pData, sum)
  
  pData[(pData$Rasst<max_rst),'Cena']=0
  cena=aggregate(x=subset(pData,select=c('Cena')),
                 by=subset(pData,select=c('Date','Train','Type','Klass','Arenda','Before')),
                 FUN="max")
  pass=aggregate(x=subset(pData,select=c('Kol_pas','Stoim','Pkm')),
                 by=subset(pData,select=c('Date','Train','Type','Klass','Arenda','Before')),
                 FUN="sum")
  pass=merge(pass,cena,by=c('Date','Train','Type','Klass','Arenda','Before'))
  pass_=pass[(pass$Klass!='-'),];#добавка сумм классов вагона
  if (nrow(pass_)>0){pass_$klass='-'
  cena=aggregate(x=subset(pass_,select=c('Cena')),
                 by=subset(pass_,select=c('Date','Train','Type','Klass','Arenda','Before')),
                 FUN="max")
  pass_=aggregate(x=subset(pass_,select=c('Kol_pas','Stoim','Pkm')),
                  by=subset(pass_,select=c('Date','Train','Type','Klass','Arenda','Before')),
                  FUN="sum")
  pass_=merge(pass_,cena,by=c('Date','Train','Type','Klass','Arenda','Before'))
  };pass=rbind(pass,pass_)
  pass_=pass[(pass$Klass=='-')&(pass$Type!='-'),];#добавка сумм типов вагона
  if (nrow(pass_)>0){pass_$Type='-'
  cena=aggregate(x=subset(pass_,select=c('Cena')),
                 by=subset(pass_,select=c('Date','Train','Type','Klass','Arenda','Before')),
                 FUN="max")
  pass_=aggregate(x=subset(pass_,select=c('Kol_pas','Stoim','Pkm')),
                  by=subset(pass_,select=c('Date','Train','Type','Klass','Arenda','Before')),
                  FUN="sum")
  pass_=merge(pass_,cena,by=c('Date','Train','Type','Klass','Arenda','Before'))
  };pass=rbind(pass,pass_)
  pData=pass;rm(pass,pass_,cena)
  
  
  
  result <- sapply(FUN = function(part) {
    kp <- numeric(45);rent <- numeric(45);pkm <- numeric(45);stoim <- numeric(45);cena <- numeric(45)
    len=nrow(part);total= 0;r_total=0;#rasst=max(part$Rasst)
    if (len > 0) {for (i in 1:len) {
      if (part$Arenda[i] == 1) {rent[part$Before[i]]=rent[part$Before[i]] + part$Kol_pas[i]
      }else{kp[part$Before[i]] =kp[part$Before[i]]+part$Kol_pas[i]}
      pkm[part$Before[i]] =pkm[part$Before[i]]+part$Pkm[i]
      stoim[part$Before[i]] =stoim[part$Before[i]]+part$Stoim[i]
      #if (part$Rasst[i] == rasst)
      {cena[part$Before[i]]=pmax(cena[part$Before[i]],part$Cena[i]) }
    }}
    
    for (i in 44:1) {kp[i]=kp[i]+kp[i+1];rent[i]=rent[i]+rent[i+1];
    pkm[i]=pkm[i]+pkm[i+1];stoim[i]=stoim[i]+stoim[i+1];if(cena[i]==0){cena[i]=cena[i+1]} }
    for (i in 1:44) {if(cena[i+1]==0){cena[i+1]=cena[i]}}
    total=kp[1]+rent[1];
    
    #date <- zoo::as.Date(part$Date[1])
    Date=as.Date(part$Date[1])
    Train=as.character(part$Train[1])
    Type=as.character(part$Type[1])
    Klass=as.character(part$Klass[1])
    
    l <- c(Date=as.character(Date), 
           Train=Train, Type=Type, Klass=Klass, Total=as.character(total), 
           kp=as.character(kp), rent=as.character(rent)
           ,pkm=as.character(pkm),stoim=as.character(stoim),cena=as.character(cena)#,Rasst=rasst
    )        
    return (l)
  }, X = split(pData, paste(pData$Date, pData$Train, pData$Type,pData$Klass)))
  
  result <- t(result)
  
  #ПЕРЕИМЕНОВАНИЕ СТОЛБЦОВ - ПО НУМЕРАЦИИ (ТЕПЕРЬ ВРОДЕ И НЕНУЖНО)
  #colnames(result) <- c("Date", "Weekday", "Month", "Train", "Type", "Total",
  #                      sapply(FUN = function(i) {paste("Total_before", i, "days", sep = "_")}, X = 1:45),
  #                      #"Rent",
  #                      sapply(FUN = function(i) {paste("Rent_before", i, "days", sep = "_")}, X = 1:45))
  
  result <- data.frame(result, stringsAsFactors = FALSE)
  
  
  # из мест по маршртам получить минимальные занятые места
  mesta_=mesta[(mesta$Klass!='-'),]
  if (nrow(mesta_)>0){mesta$Klass='-'};mesta=rbind(mesta,mesta_)
  mesta_=mesta[(mesta$Type!='-')&(mesta$Klass=='-'),]
  if (nrow(mesta_)>0){mesta$Type='-'};mesta=rbind(mesta,mesta_)
  
  mesta$no=pmin(mesta$n_o,mesta$n_n);mesta$nn=pmax(mesta$n_o,mesta$n_n);
  mesta_=mesta;mesta_$no=mesta_$nn;mesta_$Kol_pas=-mesta_$Kol_pas;
  mesta=rbind(mesta,mesta_);rm(mesta_)
  mesta=aggregate(Kol_pas ~Train+Date+Type+Klass+no,data = mesta, sum)
  max_n=max(mesta$no)
  
  kol_mest <- sapply(FUN = function(part) {
    kp <- numeric(max_n);kp[part$no]=part$Kol_pas
    for (i in 1:(max_n-1)) {kp[i+1]=kp[i+1]+kp[i]};kol_mest=max(kp)
    Date=as.character(part$Date[1]);Train=as.character(part$Train[1]);
    Type=as.character(part$Type[1]);Klass=as.character(part$Klass[1])
    l <- c(Date=Date,  Train=Train, Type=Type, Klass=Klass, kol_mest=kol_mest )        
    return (l)
  }, X = split(mesta, paste(mesta$Date, mesta$Train, mesta$Type, mesta$Klass)))
  
  kol_mest=t(kol_mest);kol_mest=data.frame(kol_mest, stringsAsFactors = FALSE)
  
  result=merge(result, kol_mest, by = c("Train", "Date", "Type","Klass"))
  result$Rasst=max_rst
  
  wData$Train <- as.character(wData$Train)
  wData$Date <- as.character(wData$Date)
  wData$Type <- as.character(wData$Type)
  wData$Klass <- as.character(wData$Klass) 
  
  vag=wData[(wData$Klass!='-'),];
  if (nrow(vag)>0){vag$Klass='-'};wData=rbind(wData,vag)
  vag=wData[(wData$Klass=='-')&(wData$Type!='-'),];
  if (nrow(vag)>0){vag$Type='-'};wData=rbind(wData,vag)
  wData=aggregate(x=subset(wData,select=c('Kol_vag','Seats')),
                  by=subset(wData,select=c('Date','Train','Type','Klass')),
                  FUN="sum")
  
  
  
  result <- merge(result, wData, by = c("Train", "Date", "Type","Klass"))
  
  #блок - взять только максимальные расстояния 
  mData=mData[(mData$Rasst==max_rst),];
  
  #Блок постановки направления - оно не меняется с течением времени, но по неполному маршр вычисляется неправильно
  mr=aggregate(Rasst ~Train+Sto+Stn,data = mData, max)
  mr_=aggregate(Rasst ~Train,data = mr, max);
  mr_$r=mr_$Rasst;mr_$Rasst<-NULL;
  mr=merge(mr, mr_, by = c("Train"))
  mr=mr[(mr$Rasst==mr$r),]
  mr$Napr <- as.character(as.integer(mr$Sto < mr$Stn))
  mr=subset(mr, select = c(Train, Napr))
  mData=merge(mData, mr, by = c("Train"));rm(mr,mr_);
  #
  
  #вычисление кто первый - уже по датам и направлениям
  mData$Time=mData$Tm_prib-mData$Tm_otp;
  mt=aggregate(Tm_otp ~Date+Napr,data = mData, min)
  mt$tmo=mt$Tm_otp;mt$Tm_otp=NULL;
  mData=merge(mData, mt,  by = c("Date","Napr"));
  mData$First=as.character(as.integer(mData$Tm_otp==mData$tmo));
  #Вычисление кто скорый (наискорейший)
  mt=aggregate(Time ~Date+Napr,data = mData, min)
  mt$tm=mt$Time;mt$Time=NULL;
  mData=merge(mData, mt,  by = c("Date","Napr"));rm(mt);
  mData$Skor=as.character(as.integer(mData$Time==mData$tm));
  mData <- subset(mData, select = c(Train, Date, Napr, Tm_otp, Time, First, Skor))
  
  result=merge(mData, result, by = c("Train", "Date"))
  
  result <- cbind(subset(result, select = c(Date, Train, Type, Seats, Total,kol_mest)),
                  subset(result, select = -c(Date, Train, Type, Seats, Total,kol_mest)))
  return (result)
}
















#по списку расстояний восстановить очерёдность станций и расст в маршрут
myPackage$marshr_to_rasst <- function(marshr) {
  mar=marshr;mar$c=mar$Sto;mar$Sto=mar$Stn;mar$Stn=mar$c;mar$c=NULL;#взять и туда и обратно симметрично
  marshr=rbind(marshr,mar);
  marshr=marshr[,lapply(.SD, sum, na.rm=T),.SDcols=c('Kol_pas'),by=c('Sto','Stn','Rasst')]
  
  
  marshr=marshr[order(-marshr$Rasst),];mar=marshr[1,];max_rst=mar$Rasst;
  rst=mar;rst$kst=rst$Sto;rst$Sto=NULL;rst$Stn=NULL;rst$rst=0;rst$Rasst=NULL
  rs=rst;rs$kst=mar$Stn;rs$rst=mar$Rasst;rst=rbind(rst,rs);rm(rs)
  rst=subset(rst,select=c('kst','rst'))
  z='1'
  
  while(z=='1')  {
    rst_o=rst;rst_o$Sto=rst_o$kst;rst_o$r_o=rst_o$rst;rst_o$kst=NULL;rst_o$rst=NULL
    rst_n=rst;rst_n$Stn=rst_n$kst;rst_n$r_n=rst_n$rst;rst_n$kst=NULL;rst_n$rst=NULL
    mar=merge(marshr,rst_o,by=c('Sto'), all=TRUE)
    mar=merge(mar,rst_n,by=c('Stn'), all=TRUE)
    
    mar=mar[(!is.na(mar$r_o))|(!is.na(mar$r_n)),]
    mar=mar[(is.na(mar$r_o))|(is.na(mar$r_n)),]
    iz=0
    
    mr=mar[(!is.na(mar$r_o)),];mr=mr[(mr$Rasst>mr$r_o),];
    mr$kst=mr$Stn;mr$rst=mr$Rasst+mr$r_o;
    mr=mr[(order(-mr$Kol_pas)),];
    if (nrow(mr)>0){mr=subset(mr[1],select=c('kst','rst'));rst=rbind(rst,mr);iz=1 }
    
    if (iz==0){
      mr=mar[(!is.na(mar$r_o)),];mr=mr[(mr$Rasst+mr$r_o>max_rst),];
      mr$kst=mr$Stn;mr$rst=mr$r_o-mr$Rasst;
      mr=mr[(order(-mr$Kol_pas)),];
      if (nrow(mr)>0){mr=subset(mr[1],select=c('kst','rst'));rst=rbind(rst,mr);iz=1 }}
    
    rst=unique(rst);if(iz==0){z='0'}}
  o=order(rst$rst);rst=rst[o,]; # в 2 действия - иначе не работает с data.table
  
  rst$nom=1:nrow(rst)
  return(rst)}





myPackage$trs.tData.sel.single <- function(train, type, daysBefore,
                                           withSeats = FALSE,
                                           prevWidth = 7,
                                           extendFactors = TRUE) {
  # Возвращает способ выбора данных, позволяющий 
  # делать прогноз по одному поезду.
  # Args:
  #   train: поезд
  #   type: тип мест
  #   daysBefore: недоступны данные позже этого числа дней до отправления
  #   withSeats: число мест используется как признак
  #   prevWidth: ширина окна предыдущей заполненности
  #   extendFactors: развернуть факторы в разные переменные
  return (function(extdb) {
    extdb <- subset(extdb[extdb$Type == type & extdb$Train == train, ],
                    select = -c(Train, Type))
    dates <- as.Date(extdb$Date)
    lastDate <- dates[length(dates)]
    weights <- sapply(FUN = function(x) {
      diff_in_days <- difftime(lastDate, x, units = "days")
      diff_in_years <- as.double(diff_in_days) / 365
      return (2^(-diff_in_years))
    }, X = dates)
    if (!extendFactors) {
      features <- data.frame(weekday = as.factor(extdb$Weekday), 
                             month = as.factor(extdb$Month))
    } else {
      wd <- as.factor(extdb$Weekday)
      weekdays <- sapply(FUN = function(l) { 
        as.integer(wd == l) 
      }, X = levels(wd))
      colnames(weekdays) <- sapply(FUN = function(x) { 
        paste("weekday", x, sep = "_")
      }, X = colnames(weekdays))
      mn <- as.factor(extdb$Month)
      months <- sapply(FUN = function(l) {
        as.integer(mn == l)
      }, X = levels(mn))
      colnames(months) <- sapply(FUN = function(x) { 
        paste("month", x, sep = "_")
      }, X = colnames(months))
      features <- data.frame(cbind(weekdays, months))
    }    
    obsDays <- daysBefore:min(daysBefore + prevWidth - 1, 45)
    
    beforeAvg <- rowMeans(subset(extdb, select = sapply(FUN = function(i) {
      paste("Total_before", as.character(i), "days", sep = "_")
    }, X = obsDays)))
    
    rentBeforeAvg <- rowMeans(subset(extdb, select = sapply(FUN = function(i) {
      paste("Rent_before", as.character(i), "days", sep = "_")
    }, X = obsDays)))
    
    beforePrecise <- extdb[, paste("Total_before",
                                   daysBefore,
                                   "days", sep = "_")]

    rentPrecise <- extdb[, paste("Rent_before",
                               daysBefore,
                               "days", sep = "_")]
    
    seats <- extdb$Seats
    total <- extdb$Total
    total_before <- sapply(FUN = function(i) {
      return (append(rep(total[1], i), total[1:(length(total) - i)]))
    }, X = obsDays)
    totalAvg <- rowMeans(total_before)
    
    result <- data.frame(cbind(weights, seats, total, totalAvg, 
                               features, beforePrecise, beforeAvg, 
                               rentBeforeAvg, rentPrecise))

    routeFeatures <- subset(extdb, select = c("Napr", "Speed", "First", "Last"))
    routeFeatures$First <- as.numeric(routeFeatures$First)
    routeFeatures$Last <- as.numeric(routeFeatures$Last)
    routeFeatures$Napr <- as.numeric(routeFeatures$Napr)
    routeFeatures$Speed <- as.numeric(routeFeatures$Speed)
    
    result <- cbind(dates, result, routeFeatures)
    if (withSeats) {
      seats.feature <- extdb$Seats
      result <- cbind(result, seats.feature)
    }
    row.names(result) <- NULL
    return (result)
  })
}

myPackage$trs.tData.sel.smart <- function(train, type, daysBefore,
                                          withSeats = FALSE,
                                          prevWidth = 7,
                                          extendFactors = TRUE) {
  # Возвращает способ выбора данных, позволяющий 
  # делать прогноз по одному поезду с учетом остальных.
  # Args:
  #   train: поезд
  #   type: тип мест
  #   daysBefore: недоступны данные позже этого числа дней до отправления
  #   withSeats: число мест используется как признак
  #   prevWidth: ширина окна предыдущей заполненности
  #   extendFactors: развернуть факторы в разные переменные
  return (function(extdb) {
    h <- hash()
    
    dates <- unique(extdb$Date)
    trains <- unique(extdb$Train)
    types <- unique(extdb$Type)
    cnames <- c("dates", "weights", "seats", "total", 
        "Napr", "speed", "first", "last")
    for (tr in trains) {
      for (tp in types) {
        length <- nrow(extdb[extdb$Train == tr
                             & extdb$Type == tp, ])
        h[[paste("exists", tr, tp, sep = "_")]] <- (length > 0)
        if (h[[paste("exists", tr, tp, sep = "_")]]) {
          cnames <- append(cnames, paste("T", tr, tp, "total", sep = "_"))
          cnames <- append(cnames, paste("T", tr, tp, "before", sep = "_"))
          cnames <- append(cnames, paste("T", tr, tp, "rent", sep = "_"))
          cnames <- append(cnames, paste("T", tr, tp, "rent.before", sep = "_"))
        }      
      }
    }
    
    dList <- split(data.frame(extdb), extdb$Date)
    lastDate <- max(as.Date(extdb$Date))
    result <- sapply(FUN = function(dayData) {
      dayString <- as.character(dayData$Date[1])
      day <- as.Date(dayString)
      diff_in_days <- difftime(lastDate, day, units = "days")
      diff_in_years <- as.double(diff_in_days) / 365
      weight <- (2^(-diff_in_years))
      trData <- dayData[as.character(dayData$Train) == as.character(train)
                        & as.character(dayData$Type) == as.character(type), ]
      if (nrow(trData) > 0) {
        total <- trData$Total[1]
        seats <- trData$Seats[1]
        Napr <- trData$Napr[1]
        speed <- trData$Speed[1]
        first <- trData$First[1]
        last <- trData$Last[1]
      } else {
        total <- 0
        seats <- 0
        Napr <- 0
        speed <- 0
        first <- 0
        last <- 0
      }
      resVector <- c(dayString, as.character(weight), 
                     as.character(seats), as.character(total),
                     as.character(Napr), as.character(speed),
                     as.character(first), as.character(last))
      l <- lapply(FUN = function(tr) {
        lapply(FUN = function(tp) {
          if (h[[paste("exists", tr, tp, sep = "_")]]) {
            partData <- dayData[dayData["Train"] == as.character(tr)
                                & dayData["Type"] == as.character(tp),]
            if (nrow(partData) > 0) {
              return (c(partData$Total[1], 
                        partData[[paste("Total_before", daysBefore, "days", sep = "_")]][1],
                        partData$Rent[1],
                        partData[[paste("Rent_before", daysBefore, "days", sep = "_")]][1]))
            } else {
              return (c(0, 0, 0, 0))
            }
          }
        }, X = types)
      }, X = trains)
      l <- as.character(unlist(l))
      resVector <- c(resVector, l)
      return (resVector)
    }, X = dList)
    result <- t(result)
    colnames(result) <- cnames
    result <- data.frame(result, stringsAsFactors = FALSE)
    obsDays <- daysBefore:min(daysBefore + prevWidth - 1, 45)
    for (tr in trains) {
      for (tp in types) {
        if (h[[paste("exists", tr, tp, sep = "_")]]) {
          total <- as.numeric(result[[paste("T", tr, tp, "total", sep = "_")]])
          total_before <- sapply(FUN = function(i) {
            return (append(rep(total[1], i), total[1:(length(total) - i)]))
          }, X = obsDays)
          totalAvg <- rowMeans(total_before)
          result[[paste("T", tr, tp, "avg", sep = "_")]] <- totalAvg
          result[[paste("T", tr, tp, "total", sep = "_")]] <- NULL
          result[[paste("T", tr, tp, "before", sep = "_")]] <- 
            as.numeric(result[[paste("T", tr, tp, "before", sep = "_")]])
          rent <- as.numeric(result[[paste("T", tr, tp, "rent", sep = "_")]])
          rent_before <- sapply(FUN = function(i) {
            return (append(rep(rent[1], i), rent[1:(length(rent) - i)]))
          }, X = obsDays)
          rentAvg <- rowMeans(rent_before)
          result[[paste("T", tr, tp, "rent.avg", sep = "_")]] <- rentAvg
          result[[paste("T", tr, tp, "rent", sep = "_")]] <- NULL
          result[[paste("T", tr, tp, "rent.before", sep = "_")]] <- 
            as.numeric(result[[paste("T", tr, tp, "rent.before", sep = "_")]])
        }
      }
    }
    result$weights <- as.numeric(result$weights)
    result$seats <- as.numeric(result$seats)
    result$total <- as.numeric(result$total)
    result$Napr <- as.numeric(result$Napr)
    result$speed <- as.numeric(result$speed)
    result$first <- as.numeric(result$first)
    result$last <- as.numeric(result$last)
    if (!extendFactors) {
      features <- data.frame(weekday = as.factor(weekdays(as.Date(result$dates))), 
                             month = as.factor(format(as.Date(result$dates), "%m")))
    } else {
      wd <- as.factor(weekdays(as.Date(result$dates)))
      weekdays <- sapply(FUN = function(l) { 
        as.integer(wd == l) 
      }, X = levels(wd))
      colnames(weekdays) <- sapply(FUN = function(x) { 
        paste("weekday", x, sep = "_")
      }, X = colnames(weekdays))
      mn <- as.factor(format(as.Date(result$dates), "%m"))
      months <- sapply(FUN = function(l) {
        as.integer(mn == l)
      }, X = levels(mn))
      colnames(months) <- sapply(FUN = function(x) { 
        paste("month", x, sep = "_")
      }, X = colnames(months))
      features <- data.frame(cbind(weekdays, months))
    }    
    result <- cbind(result, features)
    if (withSeats) {
      result$seats.feature <- result$seats
    }
    
    clear(h)
    return (result)
  })
}

myPackage$trs.tData.sel.simple.all <- function(daysBefore,
                                        withSeats = FALSE,
                                        prevWidth = 10,
                                        extendFactors = TRUE) {
  # Возвращает способ выбора данных, позволяющий 
  # делать прогноз по всем поездам и всем типам мест.
  # Args:
  #   train: поезд
  #   type: тип мест
  #   daysBefore: недоступны данные позже этого числа дней до отправления
  #   withSeats: число мест используется как признак
  #   prevWidth: ширина окна обзора предыдущей заполненности
  #   extendFactors: развернуть факторы в разные переменные
  return (function(extdb) {
    result <- rbind.fill(lapply(FUN = function(db) {
      if (nrow(db) <= daysBefore + prevWidth - 1) {
        return (NULL)
      } else {
        train <- db$Train[1]
        type <- db$Type[1]
        db <- subset(db, select = -c(Train, Type))
        dates <- as.Date(db$Date)
        lastDate <- dates[length(dates)]
        weights <- sapply(FUN = function(x) {
          diff_in_days <- difftime(lastDate, x, units = "days")
          diff_in_years <- as.double(diff_in_days) / 365
          return (2^(-diff_in_years))
        }, X = dates)
        if (!extendFactors) {
          features <- data.frame(weekday = as.factor(db$Weekday), 
                                 month = as.factor(db$Month))
        } else {
          wd <- as.factor(db$Weekday)
          weekdays <- sapply(FUN = function(l) { 
            as.integer(wd == l) 
          }, X = levels(wd))
          colnames(weekdays) <- sapply(FUN = function(x) { 
            paste("weekday", x, sep = "_")
          }, X = colnames(weekdays))
          mn <- as.factor(db$Month)
          months <- sapply(FUN = function(l) {
            as.integer(mn == l)
          }, X = levels(mn))
          colnames(months) <- sapply(FUN = function(x) { 
            paste("month", x, sep = "_")
          }, X = colnames(months))
          features <- data.frame(cbind(weekdays, months))
        }    
        obsDays <- daysBefore:min(daysBefore + prevWidth - 1, 45)
        
        beforeAvg <- rowMeans(subset(db, select = sapply(FUN = function(i) {
          paste("Total_before", as.character(i), "days", sep = "_")
        }, X = obsDays)))
        
        rentBeforeAvg <- rowMeans(subset(db, select = sapply(FUN = function(i) {
          paste("Rent_before", as.character(i), "days", sep = "_")
        }, X = obsDays)))
        
        beforePrecise <- subset(db, select = paste("Total_before",
                                                      daysBefore,
                                                      "days", sep = "_"))
        
        rentPrecise <- subset(db, select = paste("Rent_before",
                                                   daysBefore,
                                                   "days", sep = "_"))
        
        seats <- db$Seats
        total <- db$Total    
        total_before <- sapply(FUN = function(i) {
          return (append(rep(total[1], i), total[1:(length(total) - i)]))
        }, X = obsDays)
        totalAvg <- rowMeans(total_before)
        train <- rep(train, length(total))
        type <- rep(type, length(total))
        
        result <- data.frame(cbind(train, type, weights, seats, 
                                   total, totalAvg, features, 
                                   beforePrecise, beforeAvg, 
                                   rentPrecise, rentBeforeAvg))
        routeFeatures <- subset(db, select = c("Napr", "Speed", "First", "Last"))
        routeFeatures$First <- as.numeric(routeFeatures$First)
        routeFeatures$Last <- as.numeric(routeFeatures$Last)
        routeFeatures$Napr <- as.numeric(routeFeatures$Napr)
        routeFeatures$Speed <- as.numeric(routeFeatures$Speed)
        result <- cbind(dates, result, routeFeatures)
        if (withSeats) {
          seats.feature <- db$Seats
          result <- cbind(result, seats.feature)
        }
        row.names(result) <- NULL
        return (result)  
      }      
    }, X = split(extdb, paste(extdb$Train, extdb$Type))))
    if (extendFactors) {
      tr <- as.factor(result$train)
      trains <- sapply(FUN = function(l) { 
        as.integer(tr == l) 
      }, X = levels(tr))
      colnames(trains) <- sapply(FUN = function(x) { 
        paste("train", x, sep = "_")
      }, X = colnames(trains))
      tp <- as.factor(result$type)
      types <- sapply(FUN = function(l) {
        as.integer(tp == l)
      }, X = levels(tp))
      colnames(types) <- sapply(FUN = function(x) { 
        paste("type", x, sep = "_")
      }, X = colnames(types))
      features <- data.frame(cbind(trains, types))
      result <- cbind(features, subset(result,
                            select = -c(train, type)))
    }
    result <- cbind(subset(result, select = c(dates, weights, seats, total)),
                    subset(result, select = -c(dates, weights, seats, total)))
    return (result)
  })
}






#создание списка полей, идущих на вход = перевод из строки во фрейм
myPackage$stroka_to_spisok <- function(stroka,vozm) {
  stroka=paste(as.character(stroka),',',sep='');l=nchar(stroka);bg=0;
  names=data.frame(name='',bg=0);nm=names;
  for (i in 1:l){
    if (substr(stroka,i,i)==','){nm$name=substr(stroka,bg+1,i-1);nm$bg=bg+1;names=rbind(names,nm);bg=i}  }
  names=names[(names$name %in% vozm ),];
  names=names[order(names$bg),];if (nrow(names)>0){names$bg=1:nrow(names)}
  return(names)
}






##Для работы в параллельном режиме надо знать перевод года в начало года


years=data.frame(year=0,dat=0);yy=years;ye=yy$year;i=0;
while(i<30000){ye=substr(as.character(as.Date(i)),1,4);
  if (ye!=yy$year){yy$year=ye;yy$dat=i;years=rbind(years,yy);
  if(i>370){i=i+363}};i=i+1}
years=years[(years$year>=2000),]
myPackage$years=years;rm(years,ye,i,yy)




#ПРАЗДНИКИ

prazd=c(
  '2014-01-01','2014-01-02','2014-01-03','2014-01-04','2014-01-05',
  '2014-01-06','2014-01-07','2014-01-08','2014-02-23','2014-03-08',
  '2014-03-09','2014-03-10','2014-05-01','2014-05-02','2014-05-03',
  '2014-05-04','2014-05-09','2014-05-10','2014-05-11','2014-06-12',
  '2014-06-13','2014-06-14','2014-06-15','2014-11-03','2014-11-04',
  
  '2015-01-01','2015-01-02','2015-01-03','2015-01-04','2015-01-05',
  '2015-01-06','2015-01-07','2015-01-08','2015-01-09','2015-01-10',
  '2015-01-11','2015-02-23','2015-03-07','2015-03-08','2015-03-09',
  '2015-05-01','2015-05-02','2015-05-03','2015-05-04','2015-05-09',
  '2015-05-10','2015-05-11','2015-06-12','2015-06-13','2015-11-04',
  
  '2016-01-01','2016-01-02','2016-01-03','2016-01-04','2016-01-05',
  '2016-01-06','2016-01-07','2016-01-08','2016-01-09','2016-01-10',
  '2016-02-22','2016-02-23','2016-03-07','2016-03-08','2016-05-01',
  '2016-05-02','2016-05-03','2016-05-07','2016-05-08','2016-05-09',
  '2016-05-10','2016-05-11','2016-06-12','2016-06-13','2016-11-04')

prazd=data.frame(dat=prazd)
prazd$prazd=as.integer(substr(prazd$dat,6,7))
prazd$dt=as.Date(prazd$dat);prazd$dat=NULL;
min_d=min(prazd$dt);max_d=max(prazd$dt)
dats=min_d:max_d;dats=data.frame(dt=dats)
prazd=merge(dats,prazd,by='dt',all=TRUE)
prazd[(is.na(prazd$prazd)),'prazd']=0;prazd$Date=as.Date(prazd$dt);prazd$dt=NULL;

myPackage$prazd<-prazd
rm(dats,prazd,min_d,max_d)







myPackage$trs.runif <- function(n) {
  x1=1288936474345.23456789477;x2=53392947406.26540667893;x=0;c=c()
  for (i in 1:n){x=x*x1+x2;x=(x-round(x))+0.5;c=c(c,x)}
  return(c)}



#НАПИСАНИЕ СВОЕЙ ПРОГРАММЫ СБОРА ДАННЫХ, для прогнозов моих
#sozd=data.frame(name='sahalin',before=10,bef_end=25,plus_napr="2",hist='1',by_day=5,
#                Type="К",Skor="",Napr="",First="",Train="",vhod='kp,pkm',progn='kol_mest'
#                bad_dist=30,bad_k=10,day_f='week,prazd');

#name='sahalin';before=10;plus_napr='2';hist='1';by_day=5;
myPackage$trs.neir_dannie <- function(sozd) {
  # plus_napr='0' - только данные по поезду
  #   =1 - добавляется сумма проданных в том же направлении
  #   =2 - добавляется сумма проданных в обратном направлении
  # hist='0' - только сумма за сейчас
  #     =1 - добавляется итог отправки на этот поезд (+направление?) за  before дней назад,
  #        и ещё за before+by_day дополнительно
  
  # выбор из прогнозируемых параметров: ('kp','pkm','stoim','cena','kol_mest') иное=kp принудительно
  # выбор в подаче на вход: ('kp','pkm','stoim','cena') иное удаляется
  # выбор из функций даты ('month','week','prazdn')/ пока описано лишь month
  
  name=as.character(sozd$name);plus_napr=as.character(sozd$plus_napr);hist=as.character(sozd$hist);
  before=as.integer(sozd$before);by_day=as.integer(sozd$by_day);bef_end=as.integer(sozd$bef_end);  
  
  if(bef_end>44){bef_end=44}
  
  vozm=c('kp','pkm','stoim','cena')
  progn=as.character(sozd$progn);
  if (!((progn %in% vozm)|(progn=='kol_mest'))) {progn='kp'};
  if (progn %in% vozm) {progn=paste(progn,'1',sep='')}
  
  #создание списка полей, идущих на вход
  names=myPackage$stroka_to_spisok(sozd$vhod,vozm=c('kp','pkm','stoim','cena'))
  names2=myPackage$stroka_to_spisok(sozd$vhod,vozm=c('Seats'))
  
  #создание списка функций даты, идущих на вход
  names_dat=myPackage$stroka_to_spisok(sozd$day_f,vozm=c('month','week','prazd'))
  
  
  #создание списка необходимых нам запаздываний
  days=data.frame(i=1:bef_end, iz=0)
  days[(days$i==1),'iz']=1;# итоги всегда сперва брать
  days[(days$i==before),'iz']=1 
  if (by_day>0){days[((days$i-before)==round((days$i-before)/by_day)*by_day)&(days$i>before),'iz']=1 }
  days=days[(days$iz==1),]
  list_days=days$i;rm(days)
  
  #собственно чтение данных
  #dann =myPackage$trs.tData.ext.load(name);
  dann =myPackage$trs.dann_load(name,'ext')
  #диапазон дат полного наличия данных
  max_date=max(as.Date(dann[(dann$kp1>dann$kp2),'Date']))-1;
  min_date=min(as.Date(dann[(dann$kp2>dann$kp3),'Date']));
  dann$kp1=dann$kp1+dann$rent1; #к пассажирам обычным прибавляем аренду
  for (i in 1:45){nm=paste('pkm',i,sep='');dann[,nm]=dann[,nm]/dann[,'Rasst']}# пасс-оборот - в пассажироместах
  
  #выборка только нужных столбцов
  dann_ =subset(dann, select = c(Train, Date, Type, Seats,Total,Napr,First,Skor,Time,Tm_otp,Rasst,kol_mest))
  dann_[ ,progn]=dann[ ,progn];
  dann_.Date=as.Date(as.character(dann_$Date))
  for (vh in as.character(names$name)){
    for(i in 1:45){if (i %in% list_days){
      dann_[,paste(vh,i,sep='')]=as.numeric(dann[,paste(vh,i,sep='')]);}}}
  dann_[,'rent']=0;if (before<45){dann_[,'rent']=dann[,paste('rent',before,sep='')]}
  for (vh in as.character(names2$name)){dann_[,vh]=as.numeric(dann[,vh]);}#список имён не по глубине продажи (=места)
  rm(dann)
  
  
  if(plus_napr>'0'){
    for (vh in as.character(names$name)){svh=paste('s',vh,sep='');fvh=paste('f',vh,sep='');
    
    sm<- subset(dann_, select = c(Total));
    for(i in 1:45){if (i %in% list_days){sm[,paste(svh,i,sep='')]=dann_[,paste(vh,i,sep='')]}}
    by =subset(dann_, select = c(Date,Napr,Type))
    sm=aggregate(x = sm, by = by, FUN = "sum");sm$Total=NULL;
    
    if(plus_napr=='2'){  
      sm$np=1;sm_=sm;sm_$np=0;sm_$Napr=1-sm_$Napr;sm_=rbind(sm,sm_);
      for(i in 1:45){if (i %in% list_days){
        sm_[,paste(fvh,i,sep='')]=0;
        sm_[(sm_[,'np']==0),paste(fvh,i,sep='')]=sm_[(sm_[,'np']==0),paste(svh,i,sep='')];
        sm_[(sm_[,'np']==0),paste(svh,i,sep='')]=0}}
      by_ =subset(sm_, select = c(Date,Napr,Type))   
      sm_ =subset(sm_, select = -c(Date,Napr,Type))   
      sm_=aggregate(x = sm_, by = by_, FUN = "sum");
      sm_=sm_[(sm_$np==1),];sm_$np=NULL;sm=sm_;}
    
    dann_=merge(dann_, sm, by = c('Date','Napr','Type'))
    };#rm(by,by_,sm,sm_)
  }
  
  #если нужна история конечных состояний
  kol_h=0;
  if (hist=='1')  {
    dh <- subset(dann_, select = c('Date','Napr','Type','Train'));
    for (vh in as.character(names$name)){
      svh=paste('s',vh,1,sep='');fvh=paste('f',vh,1,sep='');vh_=paste(vh,1,sep='');
      kol_h=kol_h+1;dh[,paste('h',kol_h,sep='')]=dann_[,vh_];
      if(plus_napr>'0'){kol_h=kol_h+1;dh[,paste('h',kol_h,sep='')]=dann_[,svh]}
      if(plus_napr=='2'){kol_h=kol_h+1;dh[,paste('h',kol_h,sep='')]=dann_[,fvh]}}
    
    dh$Date=as.Date(dh$Date);dh=dh[(dh$Date>=min_date),];dh=dh[(dh$Date<=max_date),];
    if (by_day>0){
      dh2 <- subset(dh, select = c('Date','Napr','Type','Train'))
      for (i in 1:kol_h){dh2[,paste('h_',i,sep='')]=dh[,paste('h',i,sep='')]}
      dh2$Date=as.Date(dh2$Date)+by_day; 
      dh=merge(dh, dh2, by = c('Date','Napr','Type','Train'), all=FALSE);rm(dh2) }
    
    
    dh$Date=as.Date(dh$Date+before);
    dann_$Date=as.Date(dann_$Date);
    dann_=merge(dann_, dh, by = c('Date','Napr','Type','Train'), all=F);rm(dh)
  }
  
  bad_dist=sozd$bad_dist;bad_k=sozd$bad_k
  if (!is.null(bad_dist)){ if (is.null(bad_k)){bad_k=10}
    dann_2=dann_[(dann_$Seats-dann_$Total>bad_dist),]
    if (nrow(dann_2)>0){
      dann_2$Seats=dann_2$Seats+round(bad_dist*bad_k*myPackage$trs.runif(nrow(dann_2)))}
    dann_=rbind(dann_,dann_2);rm(dann_2)}
  
  #далее только выделение нужных данных
  ddd <- subset(dann_, select = c(Train, Date, Type, Seats,Napr,First,Skor,Time)) # ,Total,Napr,First,Skor,Time
  ddd$Date=as.Date(ddd$Date);
  ddd$y=dann_[ ,progn];
  ddd$dann=as.character(1-as.integer(ddd$Date>max_date));
  ddd[(ddd$dann=='0'),'y']=NA;ddd$ves=1;
  ddd$ym.1=0;
  ddd$ym.2=dann_$Seats;
  
  xx=0;
  for (vh_i in 1:nrow(names)){
    vh=as.character(names[(names$bg==vh_i),'name'])
    for (i in 2:45){if (i %in% list_days){xx=xx+1;ddd[,paste('x',xx,sep='.')]=dann_[,paste(vh,i,sep='')];}}
    if ((vh=='kp')&(before %in% list_days))
    {xx=xx+1;ddd[,paste('x',xx,sep='.')]=dann_[,'rent'];}#отдельно аренда пассажиры
    if(plus_napr>'0'){
      for (i in 2:45){if (i %in% list_days){xx=xx+1;ddd[,paste('x',xx,sep='.')]=dann_[,paste('s',vh,i,sep='')];}}}
    if(plus_napr=='2'){
      for (i in 2:45){if (i %in% list_days){xx=xx+1;ddd[,paste('x',xx,sep='.')]=dann_[,paste('f',vh,i,sep='')];}}}
  }
  
  if (kol_h>0)  {
    for (i in 1:kol_h){xx=xx+1;ddd[,paste('x',xx,sep='.')]=dann_[,paste('h',i,sep='')]}
    if (by_day>0){
      for (i in 1:kol_h){xx=xx+1;ddd[,paste('x',xx,sep='.')]=dann_[,paste('h',i,sep='')]}}
  }
  
  if (nrow(names2)>0){for (vh_i in 1:nrow(names2)){
    vh=as.character(names2[(names2$bg==vh_i),'name']);xx=xx+1;ddd[,paste('x',xx,sep='.')]=dann_[,vh] }}
  
  
  #далее постановка массивов
  dt=as.integer(ddd$Date);ddd$m.1=dt-round(dt/7)*7+4;#ровно день недели =1:7 пн-вс
  ddd$m.2=ddd$Type;
  ddd$m.3=dann_$Napr;ddd$m.4=dann_$First;ddd$m.5=dann_$Skor;
  ddd$m.6=round(dann_$Time/60);ddd$m.7=round(dann_$Tm_otp/60);
  ddd$m.8=ddd$Train;
  m=8;
  #добавление функций даты
  for (day_f in names_dat$name){
    if (day_f=='month'){m=m+1;ddd[,paste('m',m,sep='.')] = as.integer(format(ddd$Date, "%m"));}
    #далее надо написать функцию номера недели!!!
    
    if (day_f=='week'){
      dt=unique(subset(ddd,select='Date'));dt$dt=as.integer(as.Date(dt$Date))
      dt$year=substr(as.character(dt$Date),1,4);
      dt=merge(dt,myPackage$years,by='year')
      dt$week=pmin(round(((dt$dt-dt$dat) +4) /7),52);
      dt=subset(dt,select=c(Date,week));ddd=merge(ddd,dt,by='Date')
      m=m+1;ddd[,paste('m',m,sep='.')] = as.integer(ddd$week);ddd$week=NULL
    }
    if (day_f=='prazd'){
      prazd=myPackage$prazd;prazd$Date=as.Date(prazd$Date);ddd=merge(ddd,prazd,by='Date')
      m=m+1;ddd[,paste('m',m,sep='.')] = as.integer(ddd$prazd);ddd$prazd=NULL
    }
  }
  
  ddd=ddd[(ddd$Date>=min_date),];
  ddd=ddd[(ddd$Date<=max_date+before),];
  k=list(m=m,x=xx)
  return(list(k=k,dann=ddd))
}






#а теперь из созданных данных выбрать лишь нужные строки - более быстрый блок, потому и отдельно
myPackage$trs.neir_dannie.vibor <- function(dann,sozd) {
  if(!((sozd$Type=="") |(is.na(sozd$Type))))  { dann=dann[(dann$Type==as.character(sozd$Type)),] }
  if(!((sozd$Skor=="") |(is.na(sozd$Skor))))  { dann=dann[(dann$Skor==sozd$Skor),]}
  if(!((sozd$First=="")|(is.na(sozd$First)))) { dann=dann[(dann$First==as.character(sozd$First)),]}
  if(!((sozd$Napr=="") |(is.na(sozd$Napr))))  { dann=dann[(dann$Napr==as.character(sozd$Napr)),]}
  if(!((sozd$Train=="")|(is.na(sozd$Train)))) { dann=dann[(dann$Train==as.character(sozd$Train)),]}
  return(dann)
}









myPackage$trs.tData.extract2=function(name) {
  # Объединяет агрегированные базы данных о продажах
  # билетов и составности поездов в одну базу.
  # Args:
  #   extractor: метод объединения
  # Returns:
  #   объединенную базу, если extdbName = NULL
  
  #if (typeof(pData) == "character") {pData=myPackage$trs.pData.aggr.load(pData)}
  #if (typeof(mData) == "character") {mData=myPackage$trs.pData.aggr.load(paste(mData, "_mar", sep = ""))}
  #if (typeof(wData) == "character") {wData=myPackage$trs.wData.aggr.load(wData)}
  tm_beg=as.double(Sys.time());
  print(paste("Идёт экстракция данных по макету : ",name,sep=''));
  
  info=myPackage$trs.dann_load('info','rez') # ЧТО БЫЛО ПРОЧИТАНО РАНЬШЕ?
  info=info[(info$Database==name),]
  info=info[(info$ext!=1)|is.na(info$ext),]
  info=info[(info$kol_rez>0),]
  
  if (nrow(info)>0){
    pData=myPackage$trs.dann_load(name,'pas');
    mData=myPackage$trs.dann_load(name,'mar')
    wData=myPackage$trs.dann_load(name,'vag')
    
    min_date=min(as.Date(info$min_date))-2
    
    pData=pData[(as.Date(pData$Date)>=min_date),]
    mData=mData[((as.Date(mData$Date)>=min_date)&(mData$bad==0)),];mData$bad=NULL
    wData=wData[(as.Date(wData$Date)>=min_date),]
    
    
    
    #если в старой сборке не было класса вагона
    #теперь оставляем весь класс. а не только 1 литеру!
    pData$Klass=as.character(pData$Klass);pData$Type=as.character(pData$Type)
    pData$Kl=substr(pData$Klass,1,1);
    pData[(pData$Kl==pData$Type),'Klass']='-';
    pData[(pData$Kl==' '),'Klass']='-'
    wData$Klass=as.character(wData$Klass);wData$Type=as.character(wData$Type)
    wData$Kl=substr(wData$Klass,1,1);
    wData[(wData$Kl==wData$Type),'Klass']='-';
    wData[(wData$Kl==' '),'Klass']='-' 
    wData=wData[(wData$bad==0),];wData$bad=NULL
    pData$Kl=NULL;wData$Kl=NULL;
    
    #аренду оставить принудительно только на Сахалине  
    if (name!='sahalin'){pData$Arenda='-'}      
    
    #добавка - если тип вагона единственен, то брать класс вагона, иначе - тип. И класс - убрать вообще
    pzd=unique(subset(wData,select=c('Train','Type','Klass')))
    pzd=pzd[(pzd$Klass!='-'),];pzd=unique(subset(pzd,select=c('Train','Type')));
    pzd=count(pzd$Train);pzd=pzd[(pzd$freq==1),];pzd$Train=pzd$x;pzd$x=NULL
    
    wData=merge(pzd,wData,by='Train',all=TRUE)
    ddd=wData[(!is.na(wData$freq)),];wData=wData[(is.na(wData$freq)),]
    ddd$Type=paste(ddd$Type,ddd$Klass,sep='')
    wData=rbind(wData,ddd);wData$freq=NULL;wData$Klass=NULL;
    
    pData=merge(pzd,pData,by='Train',all=TRUE);
    pData=pData[(!is.na(pData$Date)),]
    ddd=pData[(!is.na(pData$freq)),];pData=pData[(is.na(pData$freq)),]
    ddd$Type=paste(ddd$Type,ddd$Klass,sep='')
    pData=rbind(pData,ddd);pData$freq=NULL;pData$Klass=NULL;
    rm(ddd,pzd)
    
    
    res=myPackage$trs.tData.extractor3(pData, mData, wData) #СОБСТВЕННО НАРАБОТКА ДАННЫХ
    result1=res$result1;result=res$result;
    
    
    min_date=min_date+2
    result=result[(as.Date(result$Date)>=min_date),]
    result1=result1[(as.Date(result$Date)>=min_date),]
    
    old_rez=myPackage$trs.dann_load(name,'ext')
    old_rez1=myPackage$trs.dann_load(name,'ext1')
    if (!is.null(old_rez)){old_rez=old_rez[(as.Date(old_rez$Date)<min_date),]}
    if (!is.null(old_rez1)){old_rez1=old_rez1[(as.Date(old_rez1$Date)<min_date),]}
    
    result=myPackage$sliv(old_rez,result)
    result1=myPackage$sliv(old_rez1,result1)
    
    myPackage$trs.Data_save(result, name,'ext',TRUE)
    myPackage$trs.Data_save(result1, name,'ext1',TRUE)
    
    info=myPackage$trs.dann_load('info','rez')
    info[(info$Database==name),'ext']=1
    myPackage$trs.Data_save(info, 'info','rez',TRUE)
  }
  
  dt=round(as.double(Sys.time())-tm_beg);
  print(paste("Экстракция закончена, макет : ",name,' /',dt,'сек',sep=''))
}












myPackage$trs.tData.extractor2 <- function(pData, mData, wData) {
  # Метод объединения, оставляющий данные о поездах 
  # и типах мест построчно
  
  arenda=unique(subset(pData,select=c('Train','Type','Arenda')))
  arenda=arenda[(arenda$Arenda==1),];arenda$Arenda=NULL
  arenda=arenda[(arenda$Type!='-'),];
  
  pData$Before=pmin(pmax(pData$Before,0),180);#было 44дня, поставил 180 - реально есть 60 уже
  pData$Pkm=pData$Kol_pas*pData$Rasst;
  #marshr=subset(pData,select=c(Sto,Stn,Rasst));marshr=unique(marshr)
  marshr=aggregate(x=list(kol=abs(as.integer(pData$Kol_pas))  ),
                   by=subset(pData,select=c('Sto','Stn','Rasst')),FUN="sum")
  marshr=marshr[(marshr$kol>100),];marshr$kol=NULL #удалены редкие ошибки расстояний, менее 100 пассажиров
  
  # А ТУТ ИЗ МАТРИЦЫ РАССТОЯНИЙ СОСТАВЛЯЕМ МАРШРУТ
  rst=myPackage$marshr_to_rasst(marshr);max_rst=max(rst$rst)
  
  rst_o=rst;rst_o$Sto=rst_o$kst;rst_o$n_o=rst_o$nom;rst_o=subset(rst_o,select=c(Sto,n_o))
  rst_n=rst;rst_n$Stn=rst_n$kst;rst_n$n_n=rst_n$nom;rst_n=subset(rst_n,select=c(Stn,n_n))
  
  mesta=merge(pData,rst_o,by=c('Sto'));mesta=merge(mesta,rst_n,by=c('Stn'));rm(rst,rst_o,rst_n)
  mesta=aggregate(Kol_pas ~Train+Date+Type+Klass+Arenda+n_o+n_n,data = mesta, sum)
  
  #pData_=aggregate(c('Kol_pas') ~Train+Date+Type+Before+Arenda,data = pData, sum)
  
  pData[(pData$Rasst<max_rst),c('Cena','cena_niz')]=0
  pData[(pData$Cena>200000),c('Cena','cena_niz')]=0 #разные ошибки ввода
  pData[(pData$verx!='V'),'verx']='0'
  
  stroka=c('Date','Train','Type','Klass','Arenda','Before','verx')
  cena=aggregate(x=subset(pData,select=c('Cena','cena_niz')),
                 by=subset(pData,select=stroka),
                 FUN="max")
  pass=aggregate(x=subset(pData,select=c('Kol_pas','Stoim','Pkm')),
                 by=subset(pData,select=stroka),
                 FUN="sum")
  pass=merge(pass,cena,by=stroka)
  pass_=pass[(pass$Klass!='-'),];#добавка сумм классов вагона
  if (nrow(pass_)>0){pass_$klass='-'
  cena=aggregate(x=subset(pass_,select=c('Cena','cena_niz')),
                 by=subset(pass_,select=stroka),
                 FUN="max")
  pass_=aggregate(x=subset(pass_,select=c('Kol_pas','Stoim','Pkm')),
                  by=subset(pass_,select=stroka),
                  FUN="sum")
  pass_=merge(pass_,cena,by=stroka)
  };pass=rbind(pass,pass_)
  pass_=pass[(pass$Klass=='-')&(pass$Type!='-'),];#добавка сумм типов вагона
  if (nrow(pass_)>0){pass_$Type='-';
  pass_2=pass_[(pass_$verx=='V'),];pass_2$Cena=pass_2$cena_niz
  pass_=pass_[(pass_$verx!='V'),];pass_$cena_niz=pass_$Cena;
  pass_=rbind(pass_,pass_2);rm(pass_2)
  pass_$verx='0'
  
  cena=aggregate(x=subset(pass_,select=c('Cena','cena_niz')),
                 by=subset(pass_,select=stroka),
                 FUN="max")
  pass_=aggregate(x=subset(pass_,select=c('Kol_pas','Stoim','Pkm')),
                  by=subset(pass_,select=stroka),
                  FUN="sum")
  pass_=merge(pass_,cena,by=stroka)
  };pass=rbind(pass,pass_)
  pData=pass;rm(pass,pass_,cena)
  
  max_dat=as.integer(max(as.Date(pData$Date)-pData$Before))
  
  pData_=merge(pData,arenda,by=c('Train','Type'))
  pData$Arenda='-';pData=rbind(pData,pData_);rm(pData_)
  
  
  result <- sapply(FUN = function(part) {
    part$Before=pmin(part$Before+1,45);#ограничиваю историю 45 днями
    kp <- numeric(45);pkm <- numeric(45);stoim <- numeric(45);cena <- numeric(45)
    kpv <- numeric(45);cenv <- numeric(45)
    len=nrow(part);#total= 0;
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
    #total=kp[1]
    
    Date=as.Date(part$Date[1])
    Train=as.character(part$Train[1])
    Type=as.character(part$Type[1])
    Klass=as.character(part$Klass[1])
    Arenda=as.character(part$Arenda[1])
    
    if (Date>max_dat){k=min(as.integer(Date)-max_dat,45);
    for (i in 1:k){kp[i]=NA;kpv[i]=NA;pkm[i]=NA;stoim[i]=NA;cena[i]=NA;cenv[i]=NA} }
    
    kp0=kp[1];pkm0=pkm[1];stoim0=stoim[1];cena0=cena[1];kpv0=kpv[1];cenv0=cenv[1]
    for (i in 1:44){kp[i]=kp[i+1];pkm[i]=pkm[i+1];stoim[i]=stoim[i+1];cena[i]=cena[i+1];
    kpv[i]=kpv[i+1];cenv[i]=cenv[i+1];}
    
    l <- c(Date=as.character(Date), Train=Train, Type=Type, Klass=Klass,Arenda=Arenda, 
           kp0=kp0,kp=kp,pkm0=pkm0,pkm=pkm,stoim0=stoim0,stoim=stoim,cena0=cena0,cena=cena,
           kpv0=kpv0,kpv=kpv,cenv0=cenv0,cenv=cenv)        
    return (l)
  }, X = split(pData, paste(pData$Date, pData$Train, pData$Type,pData$Klass,pData$Arenda)))
  
  result <- t(result)
  
  #ПЕРЕИМЕНОВАНИЕ СТОЛБЦОВ - ПО НУМЕРАЦИИ (ТЕПЕРЬ ВРОДЕ И НЕНУЖНО)
  #colnames(result) <- c("Date", "Weekday", "Month", "Train", "Type", "Total",
  #                      sapply(FUN = function(i) {paste("Total_before", i, "days", sep = "_")}, X = 1:45),
  #                      #"Rent",
  #                      sapply(FUN = function(i) {paste("Rent_before", i, "days", sep = "_")}, X = 1:45))
  
  result <- data.frame(result, stringsAsFactors = FALSE)
  result$kp45=NULL;result$pkm45=NULL;result$stoim45=NULL;result$cena45=NULL;
  result$kpv45=NULL;result$cenv45=NULL;
  for (nm in c('kp','pkm','cena','stoim','kpv','cenv')){
    for (i in 0:44){result[,paste(nm,i,sep='')]=as.numeric(result[,paste(nm,i,sep='')]) }}
  
  
  # из мест по маршртам получить минимальные занятые места
  mesta_=merge(mesta,arenda,by=c('Train','Type'))
  mesta$Arenda='-';mesta=rbind(mesta,mesta_);
  
  mesta_=mesta[(mesta$Klass!='-'),]
  if (nrow(mesta_)>0){mesta$Klass='-'};mesta=rbind(mesta,mesta_)
  mesta_=mesta[(mesta$Type!='-')&(mesta$Klass=='-'),]
  if (nrow(mesta_)>0){mesta$Type='-'};mesta=rbind(mesta,mesta_)
  
  mesta$no=pmin(mesta$n_o,mesta$n_n);mesta$nn=pmax(mesta$n_o,mesta$n_n);
  mesta_=mesta;mesta_$no=mesta_$nn;mesta_$Kol_pas=-mesta_$Kol_pas;
  mesta=rbind(mesta,mesta_);rm(mesta_)
  mesta=aggregate(Kol_pas ~Train+Date+Type+Klass+Arenda+no,data = mesta, sum)
  max_n=max(mesta$no)
  
  kol_mest <- sapply(FUN = function(part) {
    kp <- numeric(max_n);kp[part$no]=part$Kol_pas
    for (i in 1:(max_n-1)) {kp[i+1]=kp[i+1]+kp[i]};kol_mest=max(kp)
    Date=as.character(part$Date[1]);Train=as.character(part$Train[1]);
    Type=as.character(part$Type[1]);Klass=as.character(part$Klass[1])
    Arenda=as.character(part$Arenda[1])
    l <- c(Date=Date,  Train=Train, Type=Type, Klass=Klass, Arenda=Arenda, kol_mest=kol_mest )        
    return (l)
  }, X = split(mesta, paste(mesta$Date, mesta$Train, mesta$Type, mesta$Klass, mesta$Arenda)))
  
  kol_mest=t(kol_mest);kol_mest=data.frame(kol_mest, stringsAsFactors = FALSE)
  
  kol_mest[(as.integer(as.Date(kol_mest$Date))>max_dat),'kol_mest']=NA
  result=merge(result, kol_mest, by = c("Train", "Date", "Type","Klass","Arenda"))
  
  wData$Train <- as.character(wData$Train)
  wData$Date <- as.character(wData$Date)
  wData$Type <- as.character(wData$Type)
  wData$Klass <- as.character(wData$Klass) 
  
  vag=wData[(wData$Klass!='-'),];
  if (nrow(vag)>0){vag$Klass='-'};wData=rbind(wData,vag)
  vag=wData[(wData$Klass=='-')&(wData$Type!='-'),];
  if (nrow(vag)>0){vag$Type='-'};wData=rbind(wData,vag)
  wData=aggregate(x=subset(wData,select=c('Kol_vag','Seats')),
                  by=subset(wData,select=c('Date','Train','Type','Klass')),
                  FUN="sum")
  
  result <- merge(result, wData, by = c("Train", "Date", "Type","Klass"))
  result$Rasst=max_rst;
  #result[(result$Arenda!='-'),c('kol_mest','Kol_vag','Seats')]=NA
  
  #блок - взять только максимальные расстояния 
  mData=mData[(mData$Rasst==max_rst),];
  
  #Блок постановки направления - оно не меняется с течением времени, но по неполному маршр вычисляется неправильно
  mr=aggregate(Rasst ~Train+Sto+Stn,data = mData, max)
  mr_=aggregate(Rasst ~Train,data = mr, max);
  mr_$r=mr_$Rasst;mr_$Rasst<-NULL;
  mr=merge(mr, mr_, by = c("Train"))
  mr=mr[(mr$Rasst==mr$r),]
  mr$Napr <- as.character(as.integer(mr$Sto < mr$Stn))
  mr=subset(mr, select = c(Train, Napr))
  mData=merge(mData, mr, by = c("Train"));rm(mr,mr_);
  #
  
  #вычисление кто первый - уже по датам и направлениям
  mData$Time=mData$Tm_prib-mData$Tm_otp;
  mt=aggregate(Tm_otp ~Date+Napr,data = mData, min)
  mt$tmo=mt$Tm_otp;mt$Tm_otp=NULL;
  mData=merge(mData, mt,  by = c("Date","Napr"));
  mData$First=as.character(as.integer(mData$Tm_otp==mData$tmo));
  #Вычисление кто скорый (наискорейший)
  mt=aggregate(Time ~Date+Napr,data = mData, min)
  mt$tm=mt$Time;mt$Time=NULL;
  mData=merge(mData, mt,  by = c("Date","Napr"));rm(mt);
  mData$Skor=as.character(as.integer(mData$Time==mData$tm));
  mData <- subset(mData, select = c(Train, Date, Napr, Tm_otp, Time, First, Skor))
  
  result=merge(mData, result, by = c("Train", "Date"))
  
  result <- cbind(subset(result, select = c(Date, Train, Type, Seats, kol_mest,Kol_vag)),
                  subset(result, select = -c(Date, Train, Type, Seats, kol_mest,Kol_vag)))
  return (result)
}












myPackage$trs.tData.extractor3=function(pData, mData, wData) {
  
  wData$Train=as.character(wData$Train);wData$Date=as.Date(wData$Date)
  wData$Type=as.character(wData$Type);
  wData=as.data.table(wData)
  wData=wData[,lapply(.SD, sum, na.rm=T), .SDcols = c('Kol_vag','Seats'),by = c('Date','Train','Type')]
  
  
  # Метод объединения, оставляющий данные о поездах и типах мест построчно
  pData$Date=as.Date(pData$Date)
  pData$Train=as.character(pData$Train)
  pData$Type=as.character(pData$Type)
  pData$Arenda=as.character(pData$Arenda)
  pData=as.data.table(pData)
  
  #выброс лишних строк
  pData=merge(pData,wData,by=c('Date','Train','Type'))
  pData$Kol_vag=NULL;pData$Seats=NULL
  #оставляем лишь те поезда, где поехал хоть кто-нибудь
  pas=pData[(pData$Kol_pas>0),];pas=unique(subset(pas,select=c('Date','Train')))
  pData=merge(pData,pas,by=c('Date','Train'))
  wData=merge(wData,pas,by=c('Date','Train'))
  
  
  arenda=unique(subset(pData,select=c('Train','Type','Arenda')))
  arenda=arenda[(arenda$Arenda==1),];arenda$Arenda=NULL
  arenda=arenda[(arenda$Type!='-'),];
  
  pData$Before=pmin(pmax(pData$Before,0),180);#было 44дня, поставил 180 - реально есть 60 уже
  pData$Pkm=pData$Kol_pas*pData$Rasst;
  
  
  
  # А ТУТ ИЗ МАТРИЦЫ РАССТОЯНИЙ СОСТАВЛЯЕМ МАРШРУТ  
  marshr=pData[, lapply(.SD, sum, na.rm = T), .SDcols = c('Kol_pas'),by = c('Sto','Stn','Rasst')]
  mar=marshr[, lapply(.SD, max, na.rm = T), .SDcols = c('Kol_pas'),by = c('Sto','Stn')]
  marshr=merge(marshr,mar,by= c('Sto','Stn','Kol_pas'))#удалены редкие ошибки расстояний
  rst=myPackage$marshr_to_rasst(marshr);rm(marshr,mar)
  rst_o=rst;rst_o$Sto=rst_o$kst;rst_o$n_o=rst_o$nom;rst_o=subset(rst_o,select=c(Sto,n_o))
  rst_n=rst;rst_n$Stn=rst_n$kst;rst_n$n_n=rst_n$nom;rst_n=subset(rst_n,select=c(Stn,n_n))
  
  #наверно, с мест можно аренду убрать сразу - не нужна - УБРАЛ
  mesta=pData[, lapply(.SD, sum, na.rm = T), .SDcols = "Kol_pas",
              by = c('Train', 'Date', 'Type', 'Sto', 'Stn')]
  mesta=merge(mesta,rst_o,by=c('Sto'));
  mesta=merge(mesta,rst_n,by=c('Stn'));
  rm(rst,rst_o,rst_n)
  mesta=mesta[, lapply(.SD, sum, na.rm = T), .SDcols = "Kol_pas",
              by = c('Train', 'Date', 'Type', 'n_o', 'n_n')]
  
  
  
  
  pData[(pData$Cena>200000),c('Cena','cena_niz')]=0 #разные ошибки ввода
  pData[(pData$verx!='V'),'verx']='0'
  
  stroka=c('Date','Train','Type','Arenda','Before','verx')
  #cena=aggregate(x=subset(pData,select=c('Cena','cena_niz')),by=subset(pData,select=stroka),FUN="max")
  #pass=aggregate(x=subset(pData,select=c('Kol_pas','Stoim','Pkm')),by=subset(pData,select=stroka),FUN="sum")
  cena=pData[, lapply(.SD, max, na.rm = T), .SDcols = c('Cena','cena_niz'),by = stroka]
  pass=pData[, lapply(.SD, sum, na.rm = T), .SDcols = c('Kol_pas','Stoim','Pkm'),by = stroka]
  
  pass=merge(pass,cena,by=stroka)
  
  
  pass_=pass[(pass$Type!='-'),];#добавка сумм типов вагона
  if (nrow(pass_)>0){
    pass_$Type='-';
    pass_2=pass_[(pass_$verx=='V'),];pass_2$Cena=pass_2$cena_niz
    pass_=pass_[(pass_$verx!='V'),];pass_$cena_niz=pass_$Cena;
    pass_=rbind(pass_,pass_2);rm(pass_2)
    pass_$verx='0'
    #cena=aggregate(x=subset(pass_,select=c('Cena','cena_niz')),by=subset(pass_,select=stroka),FUN="max")
    #pass_=aggregate(x=subset(pass_,select=c('Kol_pas','Stoim','Pkm')),by=subset(pass_,select=stroka),FUN="sum")
    cena=pass_[, lapply(.SD, max, na.rm = T), .SDcols = c('Cena','cena_niz'),by = stroka]
    pass_=pass_[, lapply(.SD, sum, na.rm = T), .SDcols = c('Kol_pas','Stoim','Pkm'),by = stroka]
    pass_=merge(pass_,cena,by=stroka);pass=rbind(pass,pass_)
  }
  
  pData=pass;rm(pass,pass_,cena)
  
  max_dat=as.integer(max(as.Date(pData$Date)-pData$Before)) #МЕДЛЕННО!!!
  
  #оставить аренду лишь в нужных типах вагонов
  pData$Arenda=as.character(pData$Arenda)
  pData_=merge(pData,arenda,by=c('Train','Type'))
  pData$Arenda='-';
  pData=rbind(pData,pData_);rm(pData_)
  
  pData$kk=pmax(0,pmin(as.integer(pData$Date)-max_dat,45))
  
  #расширение таблицы - по суммируемым параметрам
  ff_zn=function(part) {
    bef=pmin(part$Before+1,45);#ограничиваю историю 45 днями
    zz=numeric(45);len=nrow(part);
    if (len > 0) {for (i in 1:len) {zz[bef[i]] =zz[bef[i]]+part$zn[i]}}
    for (i in 44:1) {zz[i]=zz[i]+zz[i+1];}
    k=part$kk[1];if (k>0){for (i in 1:k){zz[i]=NA} }
    l=paste(paste(as.character(zz),collapse = ";"), sep = ";")  
    return (l)}
  
  #расширение таблицы - по ценовым параметрам (максимум)
  ff_cen=function(part) {
    bef=pmin(part$Before+1,45);#ограничиваю историю 45 днями
    zz=numeric(45);len=nrow(part);
    if (len > 0) {for (i in 1:len) {zz[bef[i]] =max(zz[bef[i]],part$zn[i])}}
    for (i in 44:1){if(zz[i]==0){zz[i]=zz[i+1]};}
    for (i in 1:44) {if(zz[i+1]==0){zz[i+1]=zz[i]}}
    k=part$kk[1];if (k>0){for (i in 1:k){zz[i]=NA} }
    l=paste(as.character(zz),collapse = ";")
    return (l)}  
  
  
  #по другому - уже разными полями
  tab=NULL
  pData$kp=pData$Kol_pas;pData$Kol_pas=NULL
  pData$kpv=pData$kp;pData[(pData$verx!='V'),'kpv']=0
  pData$cenv=pData$cena;pData[(pData$verx!='V'),'cenv']=0
  pData$cena=pmax(pData$Cena,pData$cena_niz);pData$Cena=NULL;pData$cena_niz=NULL;pData$verx=NULL
  
  names=c('kp','kpv','cena','cenv','Pkm','Stoim')
  col=colnames(pData)
  col_=c(setdiff(col,names),'name','zn')
  
  for (nm in names){# принципиально распараллеливаемо по (names)
    nm_=nm;if (nm=='Pkm'){nm_='pkm'};if (nm=='Stoim'){nm_='stoim'}
    pd=as.data.frame(pData);pd$name=nm_;pd$zn=pd[,nm]
    pd=subset(pd,select = col_);pd=pd[(pd$zn!=0),];pd=as.data.table(pd)
    if (nrow(pd)>0){
      if (nm %in% c('cena','cenv')){
        qq <- pd[, ff_cen(.SD), by = c('Date', 'Train', 'Type', 'Arenda','name')]
      }else{
        qq <- pd[, ff_zn(.SD), by = c('Date', 'Train', 'Type', 'Arenda','name')]
      }
      if (is.null(tab)){tab=qq}else(tab=rbind(tab,qq))}
  }
  
  rm(pd,qq,pData)
  columns=c(paste("zn", as.character(0:44), sep = ""))
  parsed=tstrsplit(tab$V1, ";")
  names(parsed)=columns
  tab$V1=NULL
  result1=cbind(tab, as.data.table(as.data.frame(parsed, stringsAsFactors = FALSE)))
  for (c in columns) {suppressWarnings(result1[[c]] <- as.integer(result1[[c]]))}
  rm(parsed, columns,ff_zn,ff_cen,tab)
  result1=as.data.frame(result1)
  
  
  # из мест по маршртам получить минимальные занятые места
  mesta_=mesta[(mesta$Type!='-'),]
  if (nrow(mesta_)>0){mesta$Type='-';mesta=rbind(mesta,mesta_)}
  mesta$Arenda='-';
  
  mesta$no=pmin(mesta$n_o,mesta$n_n);mesta$nn=pmax(mesta$n_o,mesta$n_n);
  mesta_=mesta;mesta_$no=mesta_$nn;mesta_$Kol_pas=-mesta_$Kol_pas;
  mesta=rbind(mesta,mesta_);rm(mesta_);mesta$nn=NULL;mesta$n_o=NULL;mesta$n_n=NULL;
  ###mesta=aggregate(Kol_pas ~Train+Date+Type+Arenda+no,data = mesta, sum)
  stroka=c('Date','Train','Type','no')
  mesta=mesta[, lapply(.SD, sum, na.rm = T), .SDcols = 'Kol_pas',by = stroka]
  
  max_n=max(mesta$no)
  fm=function(part) {
    kp=numeric(max_n);kp[part$no]=part$Kol_pas
    for (i in 1:(max_n-1)) {kp[i+1]=kp[i+1]+kp[i]};kol_mest=max(kp)
    return (kol_mest)}
  
  kol_mest=mesta[, fm(.SD), by = c('Date', 'Train', 'Type')]
  rm(mesta)
  kol_mest$kol_mest=kol_mest$V1;kol_mest$V1=NULL;
  
  #result=merge(kol_mest, result, by = c("Train", "Date", "Type","Arenda"),all=TRUE)
  result=as.data.frame(kol_mest);
  result=result[(result$Date<=max_dat),]
  
  #блок добавки числа мест и вагонов
  
  vag=wData[(wData$Type!='-'),];
  if (nrow(vag)>0){vag$Type='-'};wData=rbind(wData,vag)
  
  wData=wData[,lapply(.SD, sum, na.rm=T), .SDcols = c('Kol_vag','Seats'),
              by = c('Date','Train','Type')]
  
  result=merge(wData,result, by = c("Train", "Date", "Type"),all=TRUE)
  #result[(result$Arenda!='-'),c('kol_mest','Kol_vag','Seats')]=NA
  
  
  #Блок постановки направления - оно не меняется с течением времени, но по неполному маршр вычисляется неправильно
  mr=aggregate(Rasst ~Train+Sto+Stn,data = mData, max)
  mr_=aggregate(Rasst ~Train,data = mr, max);
  mr_$r=mr_$Rasst;mr_$Rasst=NULL;
  mr=merge(mr, mr_, by = c("Train"))
  mr=mr[(mr$Rasst==mr$r),]
  mr$Napr=as.character(as.integer(mr$Sto < mr$Stn))
  mr=subset(mr, select = c(Train, Napr))
  mData=merge(mData, mr, by = c("Train"));rm(mr,mr_);
  
  
  #вычисление кто первый - уже по датам и направлениям
  mData$Time=mData$Tm_prib-mData$Tm_otp;
  mt=aggregate(Tm_otp ~Date+Napr,data = mData, min)
  mt$tmo=mt$Tm_otp;mt$Tm_otp=NULL;
  mData=merge(mData, mt,  by = c("Date","Napr"),all=TRUE);
  mData$First=as.character(as.integer(mData$Tm_otp==mData$tmo));
  #Вычисление кто скорый (наискорейший)
  mt=aggregate(Time ~Date+Napr,data = mData, min)
  mt$tm=mt$Time;mt$Time=NULL;
  mData=merge(mData, mt,  by = c("Date","Napr"),all=TRUE);rm(mt);
  mData$Skor=as.character(as.integer(mData$Time==mData$tm));
  mData=subset(mData, select = c(Train, Date, Napr, Tm_otp, Time, First, Skor,Rasst))
  
  mData$Train=as.character(mData$Train)
  mData$Date=as.Date(mData$Date)
  
  
  result=merge(mData, result, by = c("Train", "Date"))
  result$Arenda='-'
  #нет мест - их было 0 штук
  result[(is.na(result$kol_mest))&(result$Date<=max_dat)&(!is.na(result$Tm)),'kol_mest']=0
  
  #опять нет места - нет поездов в эти даты
  del=result[(is.na(result$kol_mest))&(result$Date<max_dat),]
  del=unique(subset(del,select=c('Date')));
  if (nrow(del)>0){ 
    del$del=1;
    result=merge(result,del,by='Date',all=TRUE)
    result=result[(is.na(result$del)),];result$del=NULL
    result1=merge(result1,del,by='Date',all=TRUE)
    result1=result1[(is.na(result1$del)),];result1$del=NULL}
  
  
  #result=cbind(subset(result, select = c(Date, Train, Type, Seats, kol_mest,Kol_vag)),
  #                subset(result, select = -c(Date, Train, Type, Seats, kol_mest,Kol_vag)))
  res=list(result=result,result1=result1)
  return (res)
}







###############################################################################
### ПОДГОТОВКА ДАННЫХ К СЛУЧАЙНОМУ ВЫБОРУ!
#   name='sahalin'

myPackage$trs.dannie_for_neir <- function(name) {
  print("Идёт загрузка исходных данных для прогноза");tm_beg=as.double(Sys.time());
  
  #str=c('Train','Type','Arenda','Napr','First','Skor')# список основных важных полей, кроме даты
  str_osn=c('Train','Type','Arenda');   #,'Klass'
  str_dop=c('First','Skor','Rasst','Napr');str_delet=c()
  str_par=c('kol_mest','Seats','Kol_vag')
  rezult=myPackage$trs.dann_load(name,'ext')
  rezult_=myPackage$trs.dann_load(name,'ext1')
  rezult=rezult[(!is.na(rezult$Tm_otp)),]
  if (name!='sahalin'){str_delet=c('First','Skor')}
  
  
  max_date=max(as.Date(unique(rezult_[(!is.na(rezult_$zn0)),'Date'])))
  #for (nm in setdiff(str,colnames(rezult))){rezult[,nm]='-'}#поля, которых не было
  str_delet=c(str_delet,setdiff(str_osn,colnames(rezult)))
  str_osn=setdiff(str_osn,str_delet)
  
  
  if (nrow(unique(subset(rezult,select='Train')))>20){
    #введение временных параметров
    rezult$hh=round(rezult$Time/30)/2;rezult$hh2=round(rezult$hh/2)*2
    rezult$h_otp=round(rezult$Tm_otp/60);rezult$h_prib=round((rezult$Tm_otp+rezult$Time)/60)
    rezult$h_otp3=round(rezult$h_otp/3)*3;rezult$h_prib3=round(rezult$h_prib/3)*3;
    rezult$h_otp6=round(rezult$h_otp/6)*6;rezult$h_prib6=round(rezult$h_prib/6)*6;
    str_dop2=c('hh','hh2','h_otp','h_prib','h_otp3','h_prib3','h_otp6','h_prib6')
    str_dop=c(str_dop,str_dop2)} # было убрано - сплошные ошибки
  
  #сколько мест в вагоне
  rezult$vag=round(rezult$Seats/rezult$Kol_vag)
  vag=unique(subset(rezult,select=c('vag','Type')))
  vag=aggregate(x=list(vag=vag$vag),by=list(Type=vag$Type), FUN='max')
  
  
  #поиск уникальных вариантов - выкинуть заведомо ненужные поля из списка всез возможных
  str=c(str_osn,str_dop);un=unique(subset(rezult,select=str));
  un_=unique(subset(rezult_,select=str_osn));
  un=myPackage$sliv(un,un_);rm(un_);un$ed=1;
  for(nm in str){
    uu=unique(  subset(un,select=c(nm,'ed')));uu=uu[(!is.na(uu[,nm])),];k=nrow(uu)
    if(k==1){str=setdiff(str,nm);str_delet=c(str_delet,nm)
    str_osn=setdiff(str_osn,nm);str_dop=setdiff(str_dop,nm);
    }};
  str=c(str_osn,str_dop); 
  #поиск, есть ли параметры с равным действием
  for(nm in str){if(!(nm %in% str_delet)){
    for(nm2 in str){if((nm!=nm2)&(nm2!='Train')){
      
      un_=unique(subset(un,select=c(nm,nm2)));
      un_=un_[(!is.na(un_[,nm])),];un_=un_[(!is.na(un_[,nm2])),];
      k=nrow(un_);
      k1=nrow(unique(subset(un_,select=nm)))
      k2=nrow(unique(subset(un_,select=nm2)))
      if ((k==k1)&(k==k2)){str_delet=c(str_delet,nm2)}
      rm(un_,k,k1,k2)
    }}}}
  str_delet=unique(str_delet)
  str_osn=setdiff(str_osn,str_delet);str_dop=setdiff(str_dop,str_delet);
  
  rm(un,str,uu)
  
  #замена старому блоку разделения на части
  str_o=c('Date','Train');str_=c(str_osn,str_dop)
  str_=setdiff(str_,colnames(rezult_));str_=unique(c(str_o,str_,'Rasst'))
  rez=unique(subset(rezult,select=str_))
  rezult_=merge(rez,rezult_,by=str_o);rm(rez)
  rezult_$k=1;
  rezult_[(rezult_$name=='pkm'),'k']=rezult_[(rezult_$name=='pkm'),'Rasst']
  rezult_[(rezult_$name %in% c('stoim','cena','cenv')),'k']=10000
  for (i in 0:44){nnm=paste('zn',i,sep='');rezult_[,nnm]=rezult_[,nnm]/rezult_[,'k']}
  rezult_$k=NULL;
  
  #if ('Rasst' %in% str_delet){rezult_$Rasst=NULL}
  #удаление ненужных полей отовсюду
  for (nm in str_delet){
    if (nm %in% colnames(rezult)){rezult[,nm]=NULL;}
    if (nm %in% colnames(rezult_)){rezult_[,nm]=NULL;} }
  
  
  #Получение числа совсем пустых мест
  rezult$pusto=((rezult$Seats-rezult$kol_mest)*rezult$Kol_vag/rezult$Seats)
  rezult$pusto=pmax(round(rezult$pusto-0.5),0)
  #rezult[(is.na(rezult$pusto)),'pusto']=0 #убрал - в будущем нет пустых
  #rezult[(rezult$Type=='-'),'pusto']=0 # убрал - по всем вагонам пустота возможна
  rezult$pusto=round(rezult$Seats/rezult$Kol_vag)*rezult$pusto
  
  rezult_s=NULL;str=c(str_osn,str_dop)
  for (nm in c('Seats','kol_mest','pusto')){
    rez_=subset(rezult,select=c('Date',str,nm))
    rez_$name=nm;rez_$zn=as.numeric(rez_[,nm]);rez_[,nm]=NULL
    rezult[,nm]=NULL
    #rez_=rez_[(!is.na(rez_$zn)),] # убрал - чтобы было видно неизвестное будущее!
    rezult_s=myPackage$sliv(rezult_s,rez_);rm(rez_)}
  
  
  
  str=c(str_osn,str_dop)
  str_=setdiff(str,c('Train','Type','Arenda')) # по каким параметрам можно подсуммировать
  #ДАЛЬНЕЙШАЯ ОБРАБОТКА
  #КОНКРЕТНО ДЛЯ САХАЛИНА - получение подсуммирований по каждому (ОДНОМУ)параметру;
  summir=sapply(FUN=function(i){paste("zn",i,sep="")},X=0:44)
  by=c('Date',str,'name')
  
  rezz=rezult_;rezz$ed=1;summs=c()
  rezz=rezz[(!(rezz$name %in% c('cena','cenv'))),]
  rezz=rezz[(rezz$Type=='-'),]
  #  nm='Napr'
  for (nm in str_){
    rez=rezz;
    rez$name=paste(rez$name,nm,sep='.');#rez$Train='-';
    for (nm2 in str){if(nm2!=nm){rez[,nm2]='-'}}
    #подсуммировать rez
    rez=aggregate( x=subset(rez,select=c(summir,'ed') ), by=subset(rez,select=by ),FUN="sum")
    rz=aggregate( x=subset(rez,select=c('ed') ), by=subset(rez,select='name' ),FUN="max")
    
    rz_=count(rez,c('Date','name'));rz_=rz_[(as.Date(rz_$Date)<=max_date),]
    rz_=aggregate( x=subset(rz_,select=c('freq') ), by=subset(rz_,select='name' ),FUN="min")
    rz_=rz_[(rz_$freq>1),]
    
    rz=rz[(rz$ed>1),];rz=merge(rz,rz_,by='name');rz=subset(rz,select='name')
    rez$ed=NULL;rez=merge(rez,rz,by='name')
    
    if (nrow(rz)>0){rezult_=rbind(rezult_,rez);summs=c(summs,nm)}
    rm(rez,rz,rz_)}
  rm(rezz)
  
  
  # По кому суммировалась rezult, по тем суммировать и rezult_s
  rezz=rezult_s;  
  for (nm in summs){
    rez=rezz;rez=rez[(rez$name!='cena'),]
    rez$name=paste(rez$name,nm,sep='.');rez$Train='-';
    for (nm2 in str){if(nm2!=nm){rez[,nm2]='-'}}
    #подсуммировать rez
    rez=aggregate( x=subset(rez,select='zn' ), by=subset(rez,select=by ),FUN="sum")
    rezult_s=rbind(rezult_s,rez);rm(rez)}
  #блок - взять тех, у кого хоть раз есть реальные данные
  by_=c(str,'name');rez=rezult_s[(!is.na(rezult_s$zn)),];rez=unique(subset(rez,select=by_))
  rezult_s=merge(rezult_s,rez,by=by_);rm(rezz,rez)
  
  
  str_=c();for (nm in str){str_=c(str_,paste(nm,'_',sep=''))}
  
  #постановка таблицы возможных результатов
  rez1=unique(subset(rezult_,select=c(str,'name')));rez1$tab='1';
  rez2=unique(subset(rezult_s,select=c(str,'name')));rez2$tab='2';
  rez=rbind(rez1,rez2);rm(rez1,rez2)
  
  #Создание  ID на все поля возможных массивов (чтобы не было проблем с кодировками)
  #id_str=c();for (nm in str){if(nm!='Train'){id_str=c(id_str,paste('id_',nm,sep=''))}}
  
  #ТИПЫ ДАННЫХ - СВЕРКА СО СТАРЫМИ, и запись в базу навсегда
  tip=unique(subset(rez,select=str))#все типы входных данных
  tip_ish=tip
  #Блок сокращения числа записей - только тип и поезд, либо - нет поезда и прочее
  tip1=tip[(tip$Train!='-'),];tip2=tip[(tip$Train=='-'),]
  for (nm in setdiff(str,c('Train','Type'))){tip1[,nm]=NA}
  tip1=unique(tip1);tip3=tip[0,];
  for (nm in str){tp=unique(subset(tip,select=nm));tip3=myPackage$sliv(tip3,tp);}
  tip3$dann_tip=0;tip=myPackage$sliv(rbind(tip1,tip2),tip3);rm(tip1,tip2,tip3)
  
  tip$name=name
  dann_tip=myPackage$trs.dann_load('progn','dann_tip')
  ##Объединение старых и новых типов данных
  if (is.null(dann_tip)){
    tip0=tip[(!is.na(tip$dann_tip)),]
    tip=tip[(is.na(tip$dann_tip)),]
    tip$dann_tip=1:nrow(tip);tip=rbind(tip0,tip);rm(tip0)
    dann_tip=tip
  }else {
    tip$dann_tip_=tip$dann_tip;tip$dann_tip=NULL;
    col1=colnames(dann_tip);col2=colnames(tip);col=setdiff(col1,setdiff(col1,col2))
    tip=merge(dann_tip,tip,by=col,all=T);
    tip[(!is.na(tip$dann_tip_)),'dann_tip']=0;tip$dann_tip_=NULL
    
    tip_=tip[(is.na(tip$dann_tip)),];tip=tip[(!is.na(tip$dann_tip)),]
    if (nrow(tip_)>0){tip_$dann_tip=(1:nrow(tip_))+max(tip$dann_tip)
    tip=rbind(tip,tip_);dann_tip=tip}
    rm(col,col1,col2,tip_)}
  
  
  #заполнение id_полей  
  id_str=c();tip=dann_tip #  nm='Train';  nm='Type'
  for (nm in str){#if(nm!='Train'){
    nm_=paste('id_',nm,sep='');id_str=c(id_str,nm_)
    if (!(nm_ %in% colnames(tip))){tip[,nm_]=NA}
    tp=unique(subset(tip,select=c(nm,nm_)));
    tp=tp[(!is.na(tp[,nm])),]
    tp[(tp[,nm]=='-'),nm_]=0;tp[(tp[,nm]=='*'),nm_]=-1;
    tp_=unique(tp[(is.na(tp[,nm_])),]);k=0
    tp=unique(tp[(!is.na(tp[,nm_])),]);
    tps=tp;tps$zzz=tps[,nm_];tps[,nm_]=NULL
    tp_=merge(tp_,tps,by=nm,all=TRUE);tp_=tp_[is.na(tp_$zzz),];tp_$zzz=NULL
    if (nrow(tp)>0){k=max(tp[,nm_])}
    if(nrow(tp_)>0){tp_[,nm_]=(1:nrow(tp_))+k;}
    tp=rbind(tp,tp_);
    tip[,nm_]=NULL;tip=merge(tip,tp,by=nm,all=TRUE)
  }#};
  dann_tip=tip
  #запись итогов в память навсегда
  myPackage$trs.Data_save(dann_tip, 'progn','dann_tip',TRUE)
  tip=dann_tip[(dann_tip$name==name),];tip$name=NULL;rm(dann_tip)
  
  
  for (nm in str){nm_=paste(nm,'_',sep='');tip[,nm_]='-';
  tip[(tip[,nm]!='-')&(!is.na(tip[,nm])),nm_]='*';
  tip[(is.na(tip[,nm])),nm_]=NA;}
  tipp=tip[(tip$dann_tip>0),]
  tipp=unique(subset(tipp,select=str_));
  #сортировка - далее возникающая нумерация обязана быть неизменной
  # str_2=str_[order(str_)]
  tipp$ss='=';for (nm in str_){tipp$ss=paste(tipp$ss,tipp[,nm],sep='')}
  tipp=tipp[order(tipp$ss),];tipp$tip=1:nrow(tipp);tipp$ss=NULL
  
  tip=merge(tip,tipp,by=str_,all=TRUE)
  tip=subset(tip,select=c(str,'tip','dann_tip',id_str))
  
  #постановка полученных типов в исходные данные
  tip1=tip[(tip$Train!='-'),];tip2=tip[(tip$Train=='-'),];
  for (nm in setdiff(str,c('Train','Type'))){tip1[,nm]=NULL}
  tip_ish1=merge(tip_ish,tip1,by=c('Train','Type'))
  tip_ish2=merge(tip_ish,tip2,by=str)
  tip_ish=rbind(tip_ish1,tip_ish2);rm(tip1,tip2,tip_ish1,tip_ish2)
  #а теперь не только типы данных, но и все поля поставить
  for (nm in str){nm_=paste('id_',nm,sep='');
  tp=unique(subset(tip,select=c(nm,nm_)));
  tip_ish[,nm_]=NULL;tip_ish=merge(tip_ish,tp,by=nm)}
  
  
  rez=merge(rez,tip_ish,by=str)
  tip_n=unique(subset(rez,select=c('name','tip')))
  tip_n$tip_n=1:nrow(tip_n);tip_name=tip_n
  rez=merge(rez,tip_n,by=c('name','tip'))
  
  rezult_=merge(rez,rezult_,by=c(str,'name'))
  rezult_s=merge(rez,rezult_s,by=c(str,'name'))
  
  #указатель - что именно вообще надо прогнозированть
  rez$progn='1' #а далее вычёркиваем. кого не прогнозируем
  rez[(rez$name %in% c('cena','cenv','kpv','pkm')),'progn']='0'
  rez[(substr(rez$name,1,5)=='Seats'),'progn']='0'
  rez[(rez$First!='-')&(rez$Train=='-'),'progn']='0'
  rez$progn='0';rez[(rez$name=='kol_mest'),'progn']='1'
  rez[(rez$Type=='-'),'progn']='0'
  rez[(rez$Arenda!='-'),'progn']='0'
  #rez[(substr(rez$name,1,5)!='stoim'),'progn']='0'  # наоборот - прогн только стоимости!!!
  #временная мера - не прогнозируем стоимость
  
  #ДЛЯ ОТЛАДКИ прогнозирования - ПРОГНОЗ ТОЛЬКО ПАССАЖИРОВ, БЕЗ ПОДСУММИРОВАНИЙ (кроме направления)
  #ostavl=c('kp','kp.Napr','kol_mest','kol_mest.Napr')
  #rez[(!(rez$name %in% ostavl)),'progn']='0' 
  
  #глубина событий - за сколько до отправления
  rez$max_bef=44;rez[(rez$tab=='2'),'max_bef']=0
  rez[(substr(rez$name,1,5)=='Seats'),'max_bef']=-1
  rez$vid='x'
  
  #данные массивов о праздниках и прочем
  dats=myPackage$prazd;# праздники
  dats$dat=as.Date(paste(substr(as.character(dats$Date),1,4),'-01-01',sep=''))
  dats$week=pmin(round(((dats$Date-dats$dat) +4) /7),52);dats$dat=NULL;# номер недели
  dats$weekday=as.integer(dats$Date)-round(as.integer(dats$Date)/7)*7+4;#ровно день недели =1:7 пн-вс
  dats$month=as.integer(substr(as.character(dats$Date),6,7))
  
  
  #поставить прочие данные - случайный курс валюты, и возможны прочие поля
  kurs=subset(dats,select='Date');kurs$kurs=sin(as.integer(kurs$Date)/12)+2;
  #kurs[(kurs$Date<'2015-10-01'),]#ограничение по дате уже известного
  
  #информация о столбцах обеих дополнительных таблиц
  rez_=data.frame(name=colnames(dats));rez_$tab=3;rez_$max_bef=-1;rez_$vid='m';
  rez_2=data.frame(name=colnames(kurs));rez_2$tab=4;rez_2$max_bef=0;rez_2$vid='x';
  
  rezz=rbind(rez_,rez_2);rm(rez_,rez_2)
  
  rezz$progn=0;rezz=rezz[(rezz$name!='Date'),];rezz$tip=0
  tip_n=max(tip_name$tip_n)
  rezz$tip_n=(tip_n+1):(tip_n+nrow(rezz))
  
  #приписать итоговую информацию
  rez=myPackage$sliv(rez,rezz)
  rezz=subset(rezz,select=c('name','tip','tip_n'))
  tip_name=rbind(tip_name,rezz)
  
  #удаление из итога ненужных полей
  #for (nm in delet){rezult[,nm]=NULL;rezult_[,nm]=NULL;rezult_s[,nm]=NULL;}
  
  #ПОЛНЫЙ ИТОГ
  dannie= list(rez_dann0=rezult, rez_dann1=rezult_, rez_dann2=rezult_s,
               rez_dann3=dats,rez_dann4=kurs,name=name,
               tip=tipp, tip_name=tip_name, tip_all=rez, dann_tip=tip, 
               params=str,id_params=id_str,max_date=max_date)
  
  #у краткой истории нейросетей удалить факт полной настроенности
  neir_hist_s=myPackage$trs.dann_load('neiroset','sokr') #чтение списка всех нейросетей
  if(!is.null(neir_hist_s)){
    neir_hist_s[((neir_hist_s$activ==1)&(neir_hist_s$name==name)),'poln_nastr']=0
    myPackage$trs.Data_save(neir_hist_s, 'neiroset','sokr',first=TRUE);}#запись обратно
  
  tm=round(as.double(Sys.time())-tm_beg);
  print(paste("Исходные данные загружены /",tm,".сек",sep=""));
  #rm(rezult,rezult_,rezult_s,tipp,tip_n,tip,rez,progn,nm,nm_,nm2,i,str,str_,summir,by,dann,tip_n)  
  return(dannie)
}










#конец файла тестовое множество
