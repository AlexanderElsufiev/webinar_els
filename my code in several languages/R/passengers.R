
#setwd("D:/RProjects/test") #- устанавливает корневую рабочую директорию

if (!require("stringr")) {
  install.packages("stringr")
}
library("stringr")

myPackage=list();



myPackage$trs.shema_dannih <- function() {
  shema=data.frame(name='sahalin');sh=shema;
  sh$srok='month';sh$vid='pas';sh$shema='sahalin_%.txt';shema=sh;
  sh$srok='day';sh$shema='dann % k.txt';shema=rbind(shema,sh)
  sh$srok='month';sh$vid='vag';sh$shema='vagoni_%.txt';shema=rbind(shema,sh)
  sh$srok='day';sh$shema='dann % v.txt';shema=rbind(shema,sh)
  
  she=shema[((shema$srok=='month')&(shema$vid=='pas')),]
  she$name='sah';she$shema='sah_%.txt';  shema=rbind(shema,she)
  
  sh=shema[(shema$name=='sahalin'),];sh$name='sapsan'
  sh[((sh$srok=='month')&(sh$vid=='pas')),'shema']='Okt_%.txt'
  sh_=sh[((sh$srok=='month')&(sh$vid=='pas')),];sh_$shema='glavn_hod_%.txt';
  sh=rbind(sh,sh_);shema=rbind(shema,sh)
  
  shema$dir='./data/dannie/month/';
  shema[((shema$srok=='day')),'dir']='./data/dannie/day/';
  
  sh_=unique(subset(shema,select='name'));sh_$srok='rez';sh_$dir='./data/dannie/'
  sh=sh_;sh$vid='pas';sh$shema=paste(sh$name,'_pas.csv',sep='');shema=rbind(shema,sh)
  sh=sh_;sh$vid='vag';sh$shema=paste(sh$name,'_vag.csv',sep='');shema=rbind(shema,sh)
  sh=sh_;sh$vid='mar';sh$shema=paste(sh$name,'_mar.csv',sep='');shema=rbind(shema,sh)
  
  sh=shema[(shema$vid=='mar'),];
  sh$vid='ext';sh$srok='rez';sh$shema=paste(sh$name,'_ext.csv',sep='');
  sh$dir='./data/trainsets/';shema=rbind(shema,sh)
  sh$vid='ext1';sh$shema=paste(sh$name,'_ext1.csv',sep='');shema=rbind(shema,sh)
  
  
  sh=shema[1,];
  sh$name='info';sh$vid='rez';sh$srok='rez';sh$shema='info.csv';sh$dir='./data/dannie/'
  shema=rbind(shema,sh)
  
  sh$name='neiroset';sh$vid='sokr';sh$shema='neir_hist_sokr.csv';sh$dir='./data/neir_hist/'
  sh_=sh;
  sh_$vid='poln';sh_$shema='neir_hist.csv';sh=rbind(sh,sh_);
  
  sh_$name='progn';sh_$vid='poln';sh_$shema='neir_progn.csv';sh=rbind(sh,sh_);
  sh_$vid='stat';sh_$shema='neir_progn_stat.csv';sh=rbind(sh,sh_);
  sh_$vid='itog';sh_$shema='neir_progn_itog.csv';sh=rbind(sh,sh_);
  sh_$vid='dann_tip';sh_$shema='dann_tip.csv';sh=rbind(sh,sh_);
  
  sh_=sh;sh_$name=paste('old_',sh_$name,sep='');sh_$dir='./data/neir_hist_old/';sh=rbind(sh,sh_);
  
  shema=rbind(shema,sh)
  
  sh=shema[(shema$name=='sapsan'),]
  sh$name='strela';
  sh_=sh[(sh$srok=='rez'),];sh_$shema=paste('strela',substr(sh_$shema,7,20),sep='')
  sh=sh[(sh$srok!='rez'),];sh=rbind(sh,sh_)
  shema=rbind(shema,sh)
  
  
  sh=shema[(shema$name=='sapsan'),]
  sh$name='spb_mos';
  sh_=sh[(sh$srok=='rez'),];sh_$shema=paste('spb_mos',substr(sh_$shema,7,20),sep='')
  sh=sh[(sh$srok!='rez'),];sh=rbind(sh,sh_)
  shema=rbind(shema,sh)
  return(shema)
}








# СЛИЯНИЕ ДВУХ ДАТА-ФРЕЙМОВ
myPackage$sliv <- function(a,b) {
  if(!is.null(a)){if(nrow(a)==0){a=NULL}}
  if(!is.null(b)){if(nrow(b)==0){b=NULL}}
  if (is.null(a)){a=b;b=NULL}
  if(!is.null(b)){
    for(nm in colnames(a)){if (!(nm %in% colnames(b))){b[,nm]=NA}}
    for(nm in colnames(b)){if (!(nm %in% colnames(a))){a[,nm]=NA}}
    
    for(nm in colnames(a)){
      #приведение несовпадающих форматов
      if (typeof(a[,nm])!=typeof(b[,nm])) 
      {a[,nm]=as.character(a[,nm]);b[,nm]=as.character(b[,nm])} }
  }
  return (rbind(a,b))
}





#подвыбор файлов, подходящих по схеме
myPackage$trs.vibor_files_shema <- function(files,shemi) {
  file=data.frame(file=files);file$iz=0;kol_f=nrow(file);file$ord=1:kol_f
  
  for (shema in shemi){len=nchar(shema);pr=0
  for (i in 1:len){if (substr(shema,i,i)=='%'){pr=i}}
  for(i in 1:kol_f){z=1;
  fl=as.character(file[(file$ord==i),'file']);l=nchar(fl)
  if(pr>1){if (substr(fl,1,pr-1)!=substr(shema,1,pr-1)){z=0}}
  if(pr<len){if (substr(fl,l-len+pr+1,l)!=substr(shema,pr+1,len)){z=0}}
  if (z==1){file[(file$ord==i),'iz']=z}
  }}
  
  file=file[(file$iz==1),];files=unique(as.character(file$file))
  return(files)
}






myPackage$trs.pData.text.columns <- function(format = "month") {
  # Возвращает названия колонок, содержащихся в 
  # сырых данных о продажах билетов
  # Args:
  #   format: формат данных
  #     "month": данные за месяц
  #     "day": данные за день
  if (format == "month") {
    return (c("Date", "Train", "Sto", "Stn","Vag", "Rasst", 
              #"Type","vcd", "Lgot", "Arenda","Klass", 
              "TVLak","Z_otp", "Z_prib", "Tm_otp", "Tm_prib", "Before", 
              "Kol_pas", "Stoim", "Losses", "Plata", "Service", "Vozvrat")) 
  } else if (format == "day") {
    return (c("InfoDate", "Date", "Train", "Type", "Klass", "Sto", "Stn", 
              "Rasst", "Z_otp", "Z_prib", "vcd", "Lgot", "Arenda", "Kol_pas", "Stoim", 
              "Plata", "Service", "Rsto", "Rstn", "Tm_otp", "Tm_prib"
              #  "H_otp","M_otp","H_prib","M_prib"
    ))
  } else stop("Неправильный формат")
}




myPackage$trs.pData.text.pattern <- function(format = "month") {
  # Возвращает паттерн, распознающий 
  # сырые данные о продажах билетов
  # Args:
  #   format: формат данных
  #     "month": данные за месяц
  #     "day": данные за день
  if (format == "month") {
    return("^([^:]*):([^\\-]*)-([^\\-]*)-([^\\-]*)-([^\\-]*)-([^.]*)\\.([^\\-]*)-([^.]*)\\.([^.]*)\\.([^.]*)\\.([^:/]*)[:/]([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.")
    ## old format
    #return("^([^:]*):([^\\-]*)-([^\\-]*)-([^\\-]*)-([^\\-]*)-([^.]*)\\.(.)(.)(.)(.)(..)*?-([^.]*)\\.([^.]*)\\.([^.]*)\\.([^:/]*)[:/]([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.")
  } else if (format == "day") {
    return ("^([^/]*+)/([^/]*+)/([^/]*+)/(.)(..)/([^/]*+)/([^/]*+)/([^.]*+)\\.([^/]*+)/([^/]*+)/(.)(.)(.)/([^.]*+)\\.([^.]*+)\\.([^.]*+)\\.([^.]*+)\\.([^.]*+)\\.([^.]*+)\\./([^/]*+)/([^/]*+)/")
    #    return ("^([^/]*+)/([^/]*+)/([^/]*+)/(.)(..)/([^/]*+)/([^/]*+)/([^.]*+)\\.([^/]*+)/([^/]*+)/(.)(.)(.)/([^.]*+)\\.([^.]*+)\\.([^.]*+)\\.([^.]*+)\\.([^.]*+)\\.([^.]*+)\\./([^.]*+)\\.([^/]*+)/([^.]*+)\\.([^/]*+)/")
  } else stop("Неправильный формат")
}


myPackage$trs.pData.text.load <- function(path, format = "month") {
  # Загружает текстовые данные о продажах билетов
  # Args:
  #   path: путь до текстового файла с данными
  #   format: формат данных
  # Returns:
  #   матрицу с данными
  text <- iconv(readLines(path, warn = FALSE), from = "WINDOWS-1251", to = "UTF-8")
  tmp <- str_match(text, myPackage$trs.pData.text.pattern(format))
  colnames(tmp) <- c("all", myPackage$trs.pData.text.columns(format))
  return(data.frame(tmp[!is.na(tmp[,1]), -1]))
}



myPackage$trs.file_adres <- function(name,vid) {
  # Возвращает путь до базы агрегированных данных
  # Args:
  #   dbName: имя базы данных
  # Returns:
  #   путь до базы
  srok='rez'
  shema=myPackage$trs.shema_dannih();
  shema=shema[(shema$name==name)&(shema$vid==vid)&(shema$srok==srok),]
  if(nrow(shema)==1){dbPath=paste(shema[1,'dir'],shema[1,'shema'],sep='')}else
  {dbPath=NULL}
  return(dbPath)
}



#ЧТЕНИЕ ИЗ БАЗЫ АГРЕГАТОВ ВО ФРЕЙМ
myPackage$trs.dann_load <- function(name,vid) {
  # Загружает базу агрегированных данных
  # Args:  #   dbName: имя базы
  # Returns:#   базу данных
  dbPath <- myPackage$trs.file_adres(name,vid) 
  aggrdb <- NULL
  if (!is.null(dbPath)){if (file.exists(dbPath)){
    aggrdb <- read.csv(dbPath, header = TRUE,fileEncoding = "WINDOWS-1251")[, -1]}}
  return(aggrdb)
}




myPackage$trs.Data_save <- function(matrix, name,vid,first) {
  # Сохраняет базу агрегированных данных
  # Args:
  #   matrix: база данных
  #   dbName: имя базы
  dbPath <- myPackage$trs.file_adres(name,vid)
  if (first){ write.csv(x = matrix, file = dbPath, fileEncoding = "WINDOWS-1251") }else{
    write.table(matrix, file = dbPath, sep = ",", col.names = FALSE, append=TRUE,
                fileEncoding = "WINDOWS-1251") }
}






myPackage$trs.pData.obrabot<- function(dann,format){
  if (nrow(dann)>0){
    #сперва расшифровка смешанного длинного поля     "Type","vcd", "Lgot", "Arenda","Klass", ===  "TVLak",
    if(format=='month'){
      dann$Type=substr(dann$TVLak,1,1)
      dann$vcd=substr(dann$TVLak,2,2)
      dann$Lgot=substr(dann$TVLak,3,3)
      dann$Arenda=substr(dann$TVLak,4,4)
      dann$Klass=substr(dann$TVLak,5,6)
      dann[(dann$Arenda=='')&(dann$Lgot=='V'),'Arenda']='1'
      dann[(dann$Arenda==''),'Arenda']='0'
      dann[(dann$Klass==''),'Klass']=paste(dann[(dann$Klass==''),'Type'], dann[(dann$Klass==''),'Type'], sep = "")
      dann$TVLak=NULL   }
    
    dann$verx=substr(dann$Train,1,1);#признак верхнее место был в номере поезда 1 символ
    dann$Train=paste('0',substr(dann$Train,2,8),sep='') 
    dann$Arenda <- as.character(dann$Arenda)
    dann[(dann[,'Arenda']!='1'),'Arenda']='0';#аренда =2 и далее - =0. Нужено лишь =1
    #  =2 - это учёт по бумажной копии электронного билета, возможно неправильное изнач. чтение
    dann[(dann$Arenda=='1'),'Lgot']='0'
    
    dann$Z_otp=as.integer(as.character(dann$Z_otp))
    dann$Z_prib=as.integer(as.character(dann$Z_prib)) 
    dann$Kol_pas=as.integer(as.character(dann$Kol_pas))
    dann$Date=as.Date(as.character(dann$Date))
    dann$Rasst=as.integer(as.character(dann$Rasst))
    dann$Stoim=as.integer(as.character(dann$Stoim))
    dann$Plata=as.integer(as.character(dann$Plata))
    dann$Sto=as.character(dann$Sto);dann$Stn=as.character(dann$Stn)
    
    if(format=='day'){
      dann$InfoDate <- as.Date(as.character(dann$InfoDate))
      dann$Tm_otp=60*as.integer(substr(dann$Tm_otp,1,2))+as.integer(substr(dann$Tm_otp,4,5));
      dann$Tm_prib=60*as.integer(substr(dann$Tm_prib,1,2))+as.integer(substr(dann$Tm_prib,4,5));
      
      dann$Date_p=dann$Date-dann$Z_otp
      dann$Before_p <- pmax(dann$Date_p - dann$InfoDate,0)
      dann$cena_niz=dann$Plata;dann$Plata=NULL
    }
    
    if(format=='month'){  
      dann$Service=as.integer(as.character(dann$Service))
      dann$Before=as.integer(as.character(dann$Before))
      dann$Tm_otp=as.integer(as.character(dann$Tm_otp))*2;
      dann$Tm_prib=as.integer(as.character(dann$Tm_prib))*2;#время было изнач вдвое меньше, плюс запаздывания в сутках
      
      #БЛОК ТОЛЬКО для месяцев, дописал - возвраты приписаны с минусами в дату возврата
      dann0=dann[(dann$Vozvrat != "-"),]
      dann0$Before=as.integer(as.character(dann0$Vozvrat));
      dann0$Kol_pas=dann0$Kol_pas*-1;
      dann0$Stoim=dann0$Stoim*-1;
      dann0$Service=dann0$Service*-1;
      dann=rbind(dann,dann0);dann$Vozvrat= '-';rm(dann0);
      dann$Date_p=dann$Date-dann$Z_otp
      dann$Before_p <- pmax(dann$Before - dann$Z_otp,0)
      
      dn=dann[(abs(dann$Stoim)>abs(dann$Plata)),]
      dann$cena_niz=0;
      if (nrow(dn)==0){dann$cena_niz=dann$Plata/dann$Kol_pas};rm(dn)
    }
    dann$Z_prib=dann$Z_prib+dann$Z_otp  
    dann$Tm_otp=dann$Tm_otp + dann$Z_otp*(24*60);  
    dann$Tm_prib=dann$Tm_prib + dann$Z_prib*(24*60);  
    dann[((dann$Kol_pas<=0)|(dann$Lgot!='0')),'cena_niz']=0
  }
  return(dann)
}








#СБОР И АГРЕГАЦИЯ ИСХОДНЫХ ДАННЫХ, ПО ИМЕНИ СХЕМЫ. НИ АГРЕГАТОР НЕ НУЖЕН- ОБЩИЙ, нИ ФИЛЬТР УКАЗЫВАТЬ НЕ НАДО - ИЗ ИМЕНИ
myPackage$trs.pData.aggregate <- function(name) {
  # Агрегирует сырые данные
  # Args:
  #   name: имя базы с агрегированными данными
  srok='month';vid='pas'
  shema=myPackage$trs.shema_dannih();
  shema=shema[((shema$name==name)&(shema$srok==srok)&(shema$vid==vid)),]
  path=unique(as.character(shema[,'dir']));shema=as.character(shema[,'shema'])
  
  files=list.files(path);
  files=myPackage$trs.vibor_files_shema(files,shema) # подвыбор нужных по схеме
  files=data.frame(File=files);files$Database=name;files$vid=vid;files$srok=srok;files$ext='0'
  
  first <- TRUE;format='month'
  
  for (file in files$File) {
    print(paste("Aggregating from \"", file, "\"...", sep = ""))
    filePath <- paste(path, file, sep = "")
    matrix <- myPackage$trs.pData.text.load(filePath);
    matrix <- myPackage$trs.pData.obrabot(matrix,format)
    matrix <- myPackage$trs.pass.filter(name,matrix);#поменял 2 строки местами - сперва обработка. потом уже фильтр
    
    kol_zap=nrow(matrix)
    matrix$Before=matrix$Before_p;matrix$Date=matrix$Date_p;
    mm=myPackage$trs.pass_agregator(matrix);matrix=mm$pass;matrix_mar=mm$mar;
    kol_rez=nrow(matrix);kol_mar=nrow(matrix_mar)
    files[(files$File==file),'kol_zap']=kol_zap
    files[(files$File==file),'kol_rez']=kol_rez
    files[(files$File==file),'kol_mar']=kol_mar
    if (kol_zap>0){
      min_dat=min(matrix_mar$Date);max_dat=max(matrix_mar$Date);
      files[(files$File==file),'min_date']=as.character(min_dat)
      files[(files$File==file),'max_date']=as.character(max_dat)}

    myPackage$trs.Data_save(matrix, name,'pas',first);
    myPackage$trs.Data_save(matrix_mar, name,'mar',first);
    first=FALSE
    print(paste("Itog ",kol_zap," zapisei"))
    #tip=as.character(unique(matrix$Type));print(tip)
  }
  info=myPackage$trs.dann_load('info','rez') 
  info <- info[(info$Database != name)|(info$vid!=vid), ]
  files$Time=as.character(Sys.time());
  info=myPackage$sliv(info,files);
  myPackage$trs.Data_save(info, 'info','rez',TRUE)
}





#СБОР И АГРЕГАЦИЯ ИСХОДНЫХ ДАННЫХ, исходя из первичных - вагонов
myPackage$trs.pData.aggregate_vag <- function(name) {
  # Агрегирует сырые данные
  # Args:
  #   name: имя базы с агрегированными данными
  srok='month';vid='pas'
  shema=myPackage$trs.shema_dannih();
  shema=shema[((shema$name==name)&(shema$srok==srok)&(shema$vid==vid)),]
  path=unique(as.character(shema[,'dir']));shema=as.character(shema[,'shema'])
  
  files=list.files(path);
  files=myPackage$trs.vibor_files_shema(files,shema) # подвыбор нужных по схеме
  files=data.frame(File=files);files$Database=name;files$vid=vid;files$srok=srok;files$ext='0'
  
  first <- TRUE;format='month'
  mar=myPackage$trs.dann_load(name,'mar')  #чтение всех уже накопленных данных по маршрутам
  mar$Date=as.Date(as.character(mar$Date));
  mar$rst=mar$Rasst;
  marb=unique(subset(mar[(mar$bad==0),],select=c('Date','Train','rst')))
  mar$rst=NULL
  marb=as.data.table(marb);
  
  #    file=as.character(files[28,'File'])
  for (file in files$File) {
    print(paste("Aggregating from \"", file, "\"...", sep = ""))
    filePath=paste(path, file, sep = "")
    matrix=myPackage$trs.pData.text.load(filePath);
    matrix=myPackage$trs.pData.obrabot(matrix,format)
    matrix=matrix[(matrix$Lgot!='B'),]
    #далее фильтрация нужных, но сперва правильную дату начала движения
    matrix$Before=matrix$Before_p;matrix$Date=matrix$Date_p;matrix$Before_p=NULL;matrix$Date_p=NULL;
    matrix=as.data.table(matrix)
    matrix=merge(matrix,marb,by=c('Date','Train')) 
    
    #далее - убрать цены (нижние) для немаксимальных маршрутов
    matrix$bad=0;matrix[(matrix$Rasst!=matrix$rst),'bad']=1;matrix$rst=NULL
    matrix[(matrix$bad==1),c('Tm_otp','Tm_prib','cena_niz')]=NA;matrix$bad=NULL
    matrix[(matrix$Z_prib==-1),c('Tm_otp','Tm_prib')]=NA;
    matrix[(matrix$Kol_pas<0),'cena_niz']=NA;#все возвраты - вне цены
    vcd_rus=c('Е','Г','G','И','Й','М','Н','О','Я','С','Т','У','Ж','В','Ы','9','Э','Щ','Ч','I')
    matrix[(!(matrix$vcd %in% vcd_rus)),'cena_niz']=NA #продажи вне России - вне цены
    matrix[(matrix$Lgot!='0'),'cena_niz']=NA;#все льготные - вне цены
    
    kol_zap=nrow(matrix)
    mm=myPackage$trs.pass_agregator(matrix);
    matrix=mm$pass;matrix_mar=mm$mar;
    kol_rez=nrow(matrix);kol_mar=nrow(matrix_mar)
    files[(files$File==file),'kol_zap']=kol_zap
    files[(files$File==file),'kol_rez']=kol_rez
    files[(files$File==file),'kol_mar']=kol_mar
    if (kol_zap>0){
      min_dat=min(matrix_mar$Date);max_dat=max(matrix_mar$Date);
      files[(files$File==file),'min_date']=as.character(min_dat)
      files[(files$File==file),'max_date']=as.character(max_dat)}
    
    myPackage$trs.Data_save(matrix, name,'pas',first);first=FALSE
    # приписка времён отправления-прибытия
    if (kol_mar>0){
      mar=merge(mar,matrix_mar,by=c('Date','Train'),all=TRUE)
      mar[(!is.na(mar$tmo)),'Tm_otp']=mar[(!is.na(mar$tmo)),'tmo']
      mar[(!is.na(mar$tmp)),'Tm_prib']=mar[(!is.na(mar$tmp)),'tmp']
      mar$tmo=NULL;mar$tmp=NULL;}
    print(paste("Itog ",kol_zap," zapisei"))
  }
  myPackage$trs.Data_save(mar, name,'mar',first=TRUE);
  info=myPackage$trs.dann_load('info','rez') 
  info <- info[(info$Database != name)|(info$vid!=vid), ]
  files$Time=as.character(Sys.time());
  info=myPackage$sliv(info,files);
  myPackage$trs.Data_save(info, 'info','rez',TRUE)
}








#агрегация месячных данных - сапсаны (сперва пасс, потом вагоны) и прочие (вагоны, потом пасс)
myPackage$trs.Data.aggregate_month <- function(name) {
  if (name=='sapsan'){
    myPackage$trs.pData.aggregate(name)
    myPackage$trs.wData.aggregate(name)  
  }else{
    myPackage$trs.wData.aggregate_vag(name)
    myPackage$trs.pData.aggregate_vag(name)
  }
}








#сворачивание данных - ещё без станций отправления и назначения и расст, и пасс-км
myPackage$trs.pass_agregator_old <- function(rawdb) {
  # Агрегатор, сворачивающий в одну строку данные о продажах билетов
  # за разное количество суток до отправления поезда
  rawdb=rawdb[(rawdb$Kol_pas!=0),]
  if (nrow(rawdb) == 0) {
    pass <- data.frame(Train = character(0), Date = character(0),
                       Type = character(0), Before = integer(0), 
                       Arenda = character(0), Kol_pas = integer(0),
                       Pkm = integer(0), Stoim = integer(0), Rasst = integer(0), Cena = integer(0));
    rawdb_m <- data.frame(Train = character(0), Date = character(0),
                          Rasst = integer(0),Sto = character(0),Stn = character(0),
                          Tm_otp = character(0),Tm_prib = character(0), Kol_pas = integer(0))
  } else {
    rawdb$Pkm=rawdb$Kol_pas*rawdb$Rasst;rawdb$Cena=round(rawdb$Stoim/rawdb$Kol_pas);
    #несколько сумм, далее сливаемых вместе - наверно можно сделать проще и быстрее
    pass <- aggregate(Kol_pas ~Train+Date+Type+Before+Arenda,data = rawdb, sum)
    pkm <- aggregate(Pkm ~Train+Date+Type+Before+Arenda,data = rawdb, sum)
    stoim <- aggregate(Stoim ~Train+Date+Type+Before+Arenda,data = rawdb, sum);
    rst <- aggregate(Rasst ~Train+Date+Type+Before+Arenda,data = rawdb, max)
    cena <- aggregate(Cena ~Train+Date+Type+Before+Arenda,data = rawdb, max)
    
    pass<- merge(pass, pkm, by = c('Train','Date','Type','Before','Arenda'));
    pass<- merge(pass, stoim, by = c('Train','Date','Type','Before','Arenda'));
    pass<- merge(pass, rst, by = c('Train','Date','Type','Before','Arenda'));
    pass<- merge(pass, cena, by = c('Train','Date','Type','Before','Arenda'));
    rm(pkm,stoim,rst,cena)
    pass <- pass[order(pass$Train, pass$Date, pass$Type, pass$Before, pass$Arenda),]
    
    #самый быстрый вариант!!!
    mar <- subset(rawdb, select = c(Rasst, Train, Date, Sto, Stn, Tm_otp, Tm_prib))
    mar=mar[!is.na(mar$Tm_otp) & !is.na(mar$Tm_prib),]
    mar <- unique(mar)
    mar <- mar[order(mar$Rasst, decreasing = T), ]
    mar <- mar[!duplicated(mar[, c("Train", "Date")]), ]
  }
  mar <- mar[order(mar$Train, mar$Date), c("Train", "Date", "Rasst", "Sto", "Stn", "Tm_otp", "Tm_prib")]
  return(list(pass = pass, mar = mar))
}







#сворачивание данных - новый, со станциями отправления и назначения и расст, и пасс-км
myPackage$trs.pass_agregator <- function(rawdb) {
  # Агрегатор, сворачивающий в одну строку данные о продажах билетов
  # за разное количество суток до отправления поезда
  #rawdb=as.data.table(rawdb)
  rawdb=rawdb[(rawdb$Kol_pas!=0),]
  if (nrow(rawdb) == 0) {
    pass <- data.frame(Train = character(0), Date = character(0),Type = character(0), Before = integer(0), 
                       Arenda = character(0), Sto = integer(0),Stn = integer(0), 
                       Klass = character(0),verx = character(0),Kol_pas = integer(0),
                       Stoim = integer(0), Rasst = integer(0), Cena = integer(0));
    mar <- data.frame(Train = character(0), Date = character(0),
                      Rasst = integer(0),Sto = character(0),Stn = character(0),
                      Tm_otp = character(0),Tm_prib = character(0)#, Kol_pas = integer(0)
    )
  } else {
    rawdb$Cena=round(rawdb$Stoim/rawdb$Kol_pas);
    if (is.null(rawdb$cena_niz)){rawdb$cena_niz=0}
    #обнуление цен неполных маршрутов
    #rawdb[(rawdb$Lgot!='0'),'Cena_niz']=NA;rawdb[(rawdb$Kol_pas<='0'),'Cena_niz']=NA;
    rawdb[(is.na(rawdb$cena_niz)),c('Cena','cena_niz')]=0;  
    #sto stn - нужны потом для вычисления числа занятых мест 
    by = c('Train','Date','Type','Before','Arenda','Rasst','Klass','verx','Sto','Stn','Cena','cena_niz') 
    #по отдельности - суммы и максимумы
    #pass=aggregate(x=subset(rawdb,select=c(Kol_pas,Stoim)),by=subset(rawdb,select=by), FUN="sum" )
    #cena=aggregate(x=subset(rawdb,select=c(Cena,cena_niz)),by=subset(rawdb,select=by), FUN="max" )
    pass=rawdb[, lapply(.SD, sum, na.rm = T), .SDcols = c('Kol_pas','Stoim'),by = by]
    #cena=rawdb[, lapply(.SD, max, na.rm = T), .SDcols = c('Cena','cena_niz'),by = by]
    #suppressWarnings(pass <- merge(pass, cena, by = by));rm(cena) #суммы и максимумы слить вместе
    
    
    #самый быстрый вариант!!!
    mar=subset(rawdb, select = c(Train, Date, Tm_otp, Tm_prib)) # ,Rasst, Sto, Stn
    mar=mar[!is.na(mar$Tm_otp) & !is.na(mar$Tm_prib),]
    mar <- unique(mar)
    mar$tmo=mar$Tm_otp;mar$tmp=mar$Tm_prib;mar$Tm_otp=NULL;mar$Tm_prib=NULL;
    #mar <- mar[order(mar$Rasst, decreasing = T), ]
    #mar <- mar[!duplicated(mar[, c("Train", "Date")]), ]
    #mar <- mar[order(mar$Train, mar$Date), ]
  }
  return(list(pass = pass, mar = mar))
}















#фильтр на всех помесячный
myPackage$trs.pass.filter <- function(name, rawdb) {
  if (name == 'sahalin') {
    # Фильтр, оставляющий только сахалинские данные
    rawdb <- rawdb[(as.integer(as.character(rawdb$Sto)) >= 2068000)
                   & (as.integer(as.character(rawdb$Sto)) <= 2069999)
                   & (as.integer(as.character(rawdb$Z_prib)) >= 0) #защита от неправильных данных - ошибка в дате
                   & (as.character(rawdb$Type) != ' '), ] #защита от неправильных данных - ошибка в типе вагона (багаж)
  }
  if (name == 'sapsan') {
    stan=c('2004001','2004088','2004454','2004456',
           '2004457','2004460','2004576','2004577','2004578','2004579',
           '2004592','2004600','2004615','2004660','2006004','2006200');  # старый полный список станций  
    stan=c('2004001', '2004600', '2004660','2006004') #Только СПб Бологое Тверь и Москва
    
    speed <- 60* as.integer(rawdb$Rasst) / (as.integer(rawdb$Tm_prib) - as.integer(rawdb$Tm_otp))
    rawdb <- rawdb[((as.integer(as.character(rawdb$Z_prib)) >= 0 )#защита от неправильных данных - ошибка в дате
                    & (as.character(rawdb$Type) != ' ')#защита от неправильных данных - ошибка в типе ввагона (багаж)
                    & (speed > 140)
                    & (as.character(rawdb$Sto) %in% stan) & (as.character(rawdb$Stn) %in% stan))
                   , ]
    trains <- sapply(FUN = function(pData) {
      if ((length(unique(pData$Type)) == 1) && (as.character(pData$Type)[1] == 'С')) {
        return (as.character(pData$Train[1]))
      } else {return ("default_string") }
    }, X = split(rawdb, f = rawdb$Train))
    trains <- unique(trains)
    #print(trains)
    rawdb <- rawdb[as.character(rawdb$Train) %in% trains, ]
  } 
  if (name == 'strela') {
    # было только поезда 1А и 2А, но при присоединении файла неправильно берёт русские символы
    stan=c('2004001', '2004600', '2004660','2006004') #Только СПб Бологое Тверь и Москва
    rawdb=rawdb[((substr(rawdb$Train,1,4) %in% c('0001','0002'))
                 & (as.character(rawdb$Sto) %in% stan) & (as.character(rawdb$Stn) %in% stan)),]
  }
  return (rawdb)
}





#фильтр на всех помесячный - по вагонам - не действует на Сапсаны (нет скорости)
myPackage$trs.pass.filter_vag <- function(name, rawdb) {
  if (name == 'sahalin') {
    # Фильтр, оставляющий только сахалинские данные
    rawdb <- rawdb[(as.integer(as.character(rawdb$Sto)) >= 2068000)
                   & (as.integer(as.character(rawdb$Sto)) <= 2069999)
                   #& (as.integer(as.character(rawdb$Z_prib)) >= 0) #защита от неправильных данных - ошибка в дате
                   & (as.character(rawdb$Type) != ' '), ] #защита от неправильных данных - ошибка в типе вагона (багаж)
    rawdb$bad=0
  }
  
  if (name == 'strela') {
    # было только поезда 1А и 2А, но при присоединении файла неправильно берёт русские символы
    stan=c('2004001', '2004600', '2004660','2006004') #Только СПб Бологое Тверь и Москва
    rawdb=rawdb[((substr(rawdb$Train,1,4) %in% c('0001','0002'))
                 & (as.character(rawdb$Sto) %in% stan) & (as.character(rawdb$Stn) %in% stan)),]
    rawdb$bad=0
  }
  
  if (name=='spb_mos'){
    stan=c('2004001', '2006004') #Только СПб Бологое Тверь и Москва
    raw_bad=rawdb[(!((rawdb$Sto %in% stan)&(rawdb$Stn %in% stan))),]
    rawdb=rawdb[((rawdb$Sto %in% stan)&(rawdb$Stn %in% stan)),]
    raw_bad=unique(subset(raw_bad,select=c('Train','Date')));raw_bad$bad=1
    rawdb=merge(rawdb,raw_bad,by=c('Train','Date'),all=TRUE)
    rawdb=rawdb[((rawdb$Sto %in% stan)&(rawdb$Stn %in% stan)),]
    rawdb[(is.na(rawdb$bad)),'bad']=0
  }
  return (rawdb)
}







#теперь вообще не нужный фильтр плосуточный - пользуемся основным помесячным!!!
myPackage$trs.pData.ufilter.sahalin <- function(rawdb,max_date) {
  sahalinTrains <- c("0001Э", "0002Э", "0603Ж", "0604Э")
  rawdb <- rawdb[#rawdb$Train %in% sahalinTrains
                (as.integer(as.character(rawdb$Sto)) >= 2068000)
                & (as.integer(as.character(rawdb$Sto)) <= 2069999)
                #& as.character(rawdb$Date) >= as.character(rawdb$InfoDate)
                & (as.Date(rawdb$InfoDate)>max_date), ]
  return (rawdb)}








#добавка по пассажирам суточных данных
myPackage$trs.pData.update <- function(name) {
  # Обновляет агрегированные данные дневными
  # Args: 
  #   name: имя агрегированной базы
  
  srok='day';vid='pas'
  shema=myPackage$trs.shema_dannih();
  shema=shema[((shema$name==name)&(shema$srok==srok)&(shema$vid==vid)),]
  path=as.character(shema[,'dir']);shema=as.character(shema[,'shema'])
  files=list.files(path);
  files=myPackage$trs.vibor_files_shema(files,shema) # подвыбор нужных по схеме
  
  info <- myPackage$trs.dann_load('info','rez');info=info[(info$Database==name),]
  files <- setdiff(x = files, y = info$File) #только новые файлы!
  files=data.frame(File=files);
  
  info=NULL
  
  if (nrow(files) > 0) { #вместо length поставить nrow
    files$Database=name;files$vid=vid;files$srok=srok;files$ext='0'
    aggrdb <- myPackage$trs.dann_load(name,'pas') #чтение всех уже накопленных данных
    aggrdb_mar <- myPackage$trs.dann_load(name,'mar')  #чтение всех уже накопленных данных
    aggrdb$Date <- as.Date(as.character(aggrdb$Date))
    aggrdb_mar$Date <- as.Date(as.character(aggrdb_mar$Date))
    
    md=subset(aggrdb,select=c('Kol_pas','Date','Before'));md=md[(md$Kol_pas>0),]
    max_dat_pr=max(md$Date-md$Before);rm(md);
    
    for (file in files$File) {
      print(paste("Updating from \"", file, sep = ""))
      filePath <- paste(path, file, sep = "")
      dann <- myPackage$trs.pData.text.load(filePath, srok) #чтение новых данных
      dann <- dann[(as.Date(dann$InfoDate)>max_dat_pr), ] #подвыбор - ещё не читаные (по месяцам)   
      dann <- myPackage$trs.pData.obrabot(dann,srok)
      dann <- myPackage$trs.pass.filter(name,dann)
      kol_zap=nrow(dann)
      
      dann$Before=dann$Before_p;dann$Date=dann$Date_p;
      #сделать разбиение данных на пассажиры и маршруты
      mm=myPackage$trs.pass_agregator(dann);pass=mm$pass;mar=mm$mar;#без цены нижних мест
      kol_rez=nrow(pass);kol_mar=nrow(mar)
      files[(files$File==file),'kol_zap']=kol_zap
      files[(files$File==file),'kol_rez']=kol_rez
      files[(files$File==file),'kol_mar']=kol_mar
      if (kol_rez>0){min_dat=min(pass$Date);max_dat=max(pass$Date);
      files[(files$File==file),'min_date']=as.character(min_dat)
      files[(files$File==file),'max_date']=as.character(max_dat)}
      aggrdb <- rbind(aggrdb, pass);aggrdb_mar <- rbind(aggrdb_mar, mar);#дозапись к основным объёмам
    }
    #тут надо подсократить список маршрутов! снять повторы и неполные маршруты
    aggrdb_mar <- subset(aggrdb_mar, select = c(Rasst, Train, Date, Sto, Stn, Tm_otp, Tm_prib))
    aggrdb_mar <- unique(aggrdb_mar)
    aggrdb_mar <- aggrdb_mar[order(aggrdb_mar$Rasst, decreasing = T), ]
    aggrdb_mar <- aggrdb_mar[!duplicated(aggrdb_mar[, c("Train", "Date")]), ]
    
    first=TRUE
    myPackage$trs.Data_save(aggrdb, name,'pas',first);
    myPackage$trs.Data_save(aggrdb_mar, name,'mar',first);
    
    info <- myPackage$trs.dann_load('info','rez')
    files$Time=as.character(Sys.time());
    info=myPackage$sliv(info,files);
    myPackage$trs.Data_save(info, 'info','rez',TRUE)
  } 
  print('Дозапись суточными данными закончена')
}









#конец файла пассажиры






if (!require("stringr")) {
  install.packages("stringr")
}
library("stringr")



myPackage$trs.wData.text.columns <- function(format = "month") {
  # Возвращает названия колонок, содержащихся в 
  # сырых данных о составности поездов
  # Args:
  #   format: формат данных
  #     "month": данные за месяц
  #     "day": данные за день
  if (format == "month") {
    return (c("Date", "Train", "Vag", "Type", "Sto","Stn", "Seats", "Klass", 
              "NM1", "NMP", "FreeSeats","Rasst", "Arenda"))
  } else if (format == "day") {
    return (c("InfoDate", "Date", "Train", "Type", "Klass", "Arenda", "Kol_vag", "Seats"))
  } else stop("Неправильный формат")
}


myPackage$trs.wData.text.pattern <- function(format = "month") {
  # Возвращает паттерн, распознающий 
  # сырые данные о составности поездов
  # Args:
  #   format: формат данных
  #     "month": данные за месяц
  #     "day": данные за день
  if (format == "month") {
    ## old format
    #return ("(\\S+)\\s+([0-9\\-]+)\\s+([0-9]+)\\s+(\\S)\\s+([0-9]+\\.)\\s+([0-9]+)\\s+([0-9]+)\\s*")
    return ("^([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)")
  } else if (format == "day") {
    return ("^([^/].*)/([^/]*)/([^/]*)/(.)(..)/(.)/([^.]*)\\.([^.]*)\\./")
  } else stop("Неправильный формат")
}



myPackage$trs.wData.text.load <- function(path, format = "month") {
  # Загружает текстовые данные о продажах билетов
  # Args:
  #   path: путь до текстового файла с данными
  #   format: формат данных
  # Returns:
  #   матрицу с данными
  text <- iconv(readLines(path, warn = FALSE), from = "WINDOWS-1251", to = "UTF-8")
  tmp <- str_match(text, myPackage$trs.wData.text.pattern(format))
  colnames(tmp) <- c("all", myPackage$trs.wData.text.columns(format))
  return(data.frame(tmp[!is.na(tmp[,1]), -1]))
}



myPackage$trs.wData.aggr.load <- function(dbName) {
  # Загружает базу агрегированных данных
  # Args:
  #   dbName: имя базы
  # Returns:
  #   базу данных
  dbPath <- myPackage$trs.wData.aggr.path(dbName) 
  if (!file.exists(dbPath)) {
    aggrdb <- NULL
  } else {
    aggrdb <- read.csv(dbPath, header = TRUE)[, -1]
  }
  return(aggrdb)
}




myPackage$trs.wData.aggregate <- function(name) {
  # Агрегирует сырые данные
  # Args:
  #   name: имя базы с агрегированными данными
  #name_mar=paste(name, "_mar", sep = "") # куда выбираются данные по маршрутам. без пассажиров
  mar=myPackage$trs.dann_load(name,'mar')  #чтение всех уже накопленных данных по маршрутам
  mar_pzd=unique(as.character(mar$Train));rm(mar) #список нужных поездов - для фильтра по новому
  
  srok='month';vid='vag'
  shema=myPackage$trs.shema_dannih();
  shema=shema[((shema$name==name)&(shema$srok==srok)&(shema$vid==vid)),]
  path=as.character(shema[,'dir']);shema=as.character(shema[,'shema'])
  
  files=list.files(path);
  files=myPackage$trs.vibor_files_shema(files,shema) # подвыбор нужных по схеме
  files=data.frame(File=files);files$Database=name;files$vid=vid;files$srok=srok;files$ext='0'
  
  first <- TRUE
  
  for (file in files$File) {
    print(paste("Aggregating from \"", file, "\"...", sep = ""))
    filePath <- paste(path, file, sep = "")
    matrix <- myPackage$trs.wData.text.load(filePath)
    matrix = matrix[matrix$Train %in% mar_pzd, ]   
    matrix = matrix[(matrix$Seats!=0), ];
    kol_zap=nrow(matrix)
    if(nrow(matrix)>0){matrix$Kol_vag =1}
    matrix = myPackage$trs.wData.aggr.mergeByType(matrix)
    kol_rez=nrow(matrix)
    if (kol_rez>0){
      min_dat=min(as.Date(matrix$Date));max_dat=max(as.Date(matrix$Date));
      files[(files$File==file),'min_date']=as.character(min_dat)
      files[(files$File==file),'max_date']=as.character(max_dat)}
    files[(files$File==file),'kol_zap']=kol_zap
    files[(files$File==file),'kol_rez']=kol_rez
    myPackage$trs.Data_save(matrix, name,'vag',first);first=FALSE
  }
  
  info <- myPackage$trs.dann_load('info','rez')
  info <- info[(info$Database != name)|(info$vid!=vid), ]
  files$Time=as.character(Sys.time());
  info=myPackage$sliv(info,files);
  
  myPackage$trs.Data_save(info, 'info','rez',TRUE)
  
}



#агрегация вагонов, исходя из - сперва вагоны, потом пассажиры
myPackage$trs.wData.aggregate_vag <- function(name) {
  # Агрегирует сырые данные
  # Args:
  #   name: имя базы с агрегированными данными
  #name_mar=paste(name, "_mar", sep = "") # куда выбираются данные по маршрутам. без пассажиров
  mar=myPackage$trs.dann_load(name,'mar')  #чтение всех уже накопленных данных по маршрутам
  mar_pzd=unique(as.character(mar$Train));rm(mar) #список нужных поездов - для фильтра по новому
  
  srok='month';vid='vag'
  shema=myPackage$trs.shema_dannih();
  shema=shema[((shema$name==name)&(shema$srok==srok)&(shema$vid==vid)),]
  path=as.character(shema[,'dir']);shema=as.character(shema[,'shema'])
  
  files=list.files(path);
  files=myPackage$trs.vibor_files_shema(files,shema) # подвыбор нужных по схеме
  files=data.frame(File=files);files$Database=name;files$vid=vid;files$srok=srok;files$ext='0'
  
  first <- TRUE
  
  for (file in files$File) {
    print(paste("Aggregating from \"", file, "\"...", sep = ""))
    filePath <- paste(path, file, sep = "")
    matrix <- myPackage$trs.wData.text.load(filePath)
    #matrix = matrix[matrix$Train %in% mar_pzd, ]   
    matrix=myPackage$trs.pass.filter_vag(name, matrix) 
    matrix = matrix[(matrix$Seats!=0), ];
    kol_zap=nrow(matrix)
    if(nrow(matrix)>0){matrix$Kol_vag =1}
    matrix = myPackage$trs.wData.aggr.mergeByType(matrix)
    kol_rez=nrow(matrix)
    if (kol_rez>0){
      min_dat=min(as.Date(matrix$Date));max_dat=max(as.Date(matrix$Date));
      files[(files$File==file),'min_date']=as.character(min_dat)
      files[(files$File==file),'max_date']=as.character(max_dat)}
    files[(files$File==file),'kol_zap']=kol_zap
    files[(files$File==file),'kol_rez']=kol_rez
    mar=unique(subset(matrix,select=c('Date','Train','bad','Rasst','Sto','Stn')))
    myPackage$trs.Data_save(mar, name,'mar',first);
    myPackage$trs.Data_save(matrix, name,'vag',first);first=FALSE
  }
  
  info <- myPackage$trs.dann_load('info','rez')
  info <- info[(info$Database != name)|(info$vid!=vid), ]
  files$Time=as.character(Sys.time());
  info=myPackage$sliv(info,files);
  
  myPackage$trs.Data_save(info, 'info','rez',TRUE)
}












myPackage$trs.wData.aggr.mergeByType <- function(rawdb) {
  # Агрегатор, объединяющий данные о вместимости по типу мест
  rawdb$Seats <- as.integer(as.character(rawdb$Seats))
  rawdb$Kol_vag <- as.integer(as.character(rawdb$Kol_vag))
  rawdb$Rasst=as.integer(as.character(rawdb$Rasst))
  
  if (is.null(rawdb$bad)){rawdb$bad=0}
  if (nrow(rawdb) == 0) {
    tmp <- data.frame(Seats = integer(0), Train = character(0),
                      Date = character(0), Type = character(0), Kol_vag = integer(0))
  } else {
    #    tmp <- aggregate(Seats ~ Train + Date + Type, data = rawdb, sum)  
    tmp=aggregate(x = subset(rawdb,select=c('Seats','Kol_vag','bad')), 
                  by = subset(rawdb,select=c('Train','Date','Type','Klass')), FUN = "sum")
    tmp_=aggregate(x = subset(rawdb,select=c('Rasst')), 
                   by = subset(rawdb,select=c('Train','Date','Sto','Stn')), FUN = "max")
    tmp_2=aggregate(x = subset(tmp_,select=c('Rasst')), 
                    by = subset(tmp_,select=c('Train','Date')), FUN = "max")
    tmp_=merge(tmp_,tmp_2,by=c('Train','Date','Rasst'))
    tmp=merge(tmp,tmp_,by=c('Train','Date'))
  }
  tmp$bad=pmin(1,tmp$bad)
  tmp <- tmp[order(tmp$Date,tmp$Train,tmp$Type),]
  return(tmp)
}










myPackage$trs.wData.update <- function(name) {
  # Обновляет агрегированные данные дневными
  # Args:
  #   name: имя агрегированной базы
  mar=myPackage$trs.dann_load(name,'mar')  #чтение всех уже накопленных данных по маршрутам
  mar_pzd=unique(as.character(mar$Train));rm(mar); #список нужных поездов - для фильтра по новому
  
  srok='day';vid='vag'
  shema=myPackage$trs.shema_dannih();
  shema=shema[((shema$name==name)&(shema$srok==srok)&(shema$vid==vid)),]
  path=as.character(shema[,'dir']);shema=as.character(shema[,'shema'])
  files=list.files(path);
  files=myPackage$trs.vibor_files_shema(files,shema) # подвыбор нужных по схеме
  
  info <- myPackage$trs.dann_load('info','rez')
  info=info[(info$Database==name),]
  files <- setdiff(x = files, y = info$File) #кажется - только новые файлы!
  files=data.frame(File=files);
  
  info=NULL
  
  if (nrow(files) > 0) {
    files$Database=name;files$vid=vid;files$srok=srok;files$ext='0'
    aggrdb=myPackage$trs.dann_load(name,'vag')  #чтение всех уже накопленных данных по маршрутам
    
    for (file in files$File) {
      print(paste("Updating from \"", file, "\"...", sep = ""))
      filePath <- paste(path, file, sep = "")
      new = myPackage$trs.wData.text.load(filePath, format = "day")
      new = new[new$Train %in% mar_pzd, ]    
      new = new[(new$Seats!=0)|(new$Klass!='  '), ]    
      kol_zap=nrow(new)
      new = myPackage$trs.wData.aggr.mergeByType(new)
      kol_rez=nrow(new)
      new = new[(new$Seats!=0)|(new$Kol_vag!=0), ]    
      if (kol_rez>0){
        min_dat=min(as.Date(new$Date));max_dat=max(as.Date(new$Date));
        files[(files$File==file),'min_date']=as.character(min_dat)
        files[(files$File==file),'max_date']=as.character(max_dat)}
      files[(files$File==file),'kol_zap']=kol_zap
      files[(files$File==file),'kol_rez']=kol_rez
      aggrdb <- myPackage$trs.wData.upd.sahalin(aggrdb, new) #сливание данных с предварительным приведением типов
    }
    aggrdb = myPackage$trs.wData.aggr.mergeByType(aggrdb) #доагрегация данных
    
    myPackage$trs.Data_save(aggrdb, name,'vag',TRUE);#запись в базу результата
    
    info <- myPackage$trs.dann_load('info','rez')
    files$Time=as.character(Sys.time());
    info=myPackage$sliv(info,files);
    myPackage$trs.Data_save(info, 'info','rez',TRUE)
  }  
}





myPackage$trs.wData.upd.sahalin <- function(aggrdb, new) {
  new$Date <- as.Date(as.character(new$Date))
  new$Seats <- as.integer(as.character(new$Seats))
  new$Train <- as.character(new$Train)
  new$Type <- as.character(new$Type)
  aggrdb$Date <- as.Date(as.character(aggrdb$Date))
  aggrdb <- rbind(aggrdb, new)
  return (aggrdb)}



#конец файла вагоны






#####################
#ТОЛЬКО НУЖНОЕ ИЗ МОДЕЛЕЙ:

# вместо UTF-8  поставил bytes

myPackage$trs.pack <- function(model) {
  # Упаковывает обученную модель в бинарное представление
  # Args:  model: обученная модель
  # Returns:   упакованное бинарное представление
  locale <- Sys.getlocale("LC_COLLATE")
  if (Sys.getlocale("LC_COLLATE") == "en_US.UTF-8") {
    Sys.setlocale(locale = "en_US.ISO-8859-1")
  } else {
    Sys.setlocale(locale = "english")
  }
  l <- list("model" = model)
  f <- file(description = "")
  saveRDS(l, f, ascii = TRUE)
  result <- paste(readLines(f, encoding = "bytes"), collapse = "\n")
  close(f)
  Sys.setlocale(locale = locale)
  return (iconv(result, to = "UTF-8"))
}

myPackage$trs.unpack <- function(s) {
  # Распаковывает упакованную модель
  # Args:  s: бинарное представление упакованной модели
  # Returns:  распакованную модель
  locale <- Sys.getlocale("LC_COLLATE")
  if (Sys.getlocale("LC_COLLATE") == "en_US.UTF-8") {
    Sys.setlocale(locale = "en_US.ISO-8859-1")
  } else {
    Sys.setlocale(locale = "english")
  }
  if (typeof(s) != "character") {s <- as.character(s)}
  s <- iconv(s, from = "UTF-8")
  t <- textConnection(s, encoding = "bytes"); result <- readRDS(t);  close(t)
  rez=result$model
  Sys.setlocale(locale = locale)
  return (rez)
}





znak='К'

#конец файла модели




