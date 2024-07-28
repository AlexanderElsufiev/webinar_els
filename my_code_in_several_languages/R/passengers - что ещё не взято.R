




## из этого файла программы ушли в new_program1





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




#конец файла вагоны







znak='К'

#конец файла модели




