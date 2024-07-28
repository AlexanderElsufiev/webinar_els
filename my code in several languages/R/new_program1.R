
# ИЗ СТАРОЙ ПРОГРАММЫ passengers, ЧТО ЕЩЁ НЕ ВЗЯТО - В ФАЙЛЕ "passengers - что ещё не взято"

#устанавливает корневую рабочую директорию - если на локальной машине
if (getwd()=="C:/Users/user/Documents"){  #если на локальной машине - не отрабатывает пока
  setwd("D:/RProjects/test/")}

setwd("D:/RProjects/test") #устанавливает корневую рабочую директорию - в любой машине


# подключения разных программ моих, по адресу - умолчание + далее
#eval(parse('./scripts/passengers.R', encoding="UTF-8"))
#eval(parse('./scripts/trainset.R', encoding="UTF-8"))
#eval(parse('./scripts/neural.R', encoding="UTF-8"))
#eval(parse('./scripts/neural2.R', encoding="UTF-8"))


# подсоединение нужных библиотек процедур
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




# мой проект - пустой, далее будет наполняться
myPackage=list();





# генерация схемы всех данных - при пополнении надо менять программу - на выходе дата фрейм  +++
myPackage$trs.shema_dannih <- function() {
  shema=data.frame(name='sahalin');sh=shema;
  sh$srok='month';sh$vid='pas';sh$shema='sahalin_%.txt';sh$format='month';shema=sh;
  sh$srok='day';sh$shema='dann % k.txt';sh$format='day';shema=rbind(shema,sh)
  sh$srok='month';sh$vid='vag';sh$shema='vagoni_%.txt';sh$format='vag_month';shema=rbind(shema,sh)
  sh$srok='day';sh$shema='dann % v.txt';sh$format='vag_day';shema=rbind(shema,sh)
  
  she=shema[((shema$srok=='month')&(shema$vid=='pas')),]
  she$name='sah';she$shema='sah_%.txt';she$format='';  shema=rbind(shema,she)
  
  sh=shema[(shema$name=='sahalin'),];sh$name='sapsan'
  sh[((sh$srok=='month')&(sh$vid=='pas')),'shema']='Okt_%.txt'
  sh_=sh[((sh$srok=='month')&(sh$vid=='pas')),];sh_$shema='glavn_hod_%.txt';
  sh=rbind(sh,sh_);shema=rbind(shema,sh)
  
  shema$dir='./data/dannie/month/';
  shema[((shema$srok=='day')),'dir']='./data/dannie/day/';
  
  sh_=unique(subset(shema,select='name'));sh_$srok='rez';sh_$dir='./data/dannie/';sh_$format=''
  vid=c('pas','vag','pzd');# убрал 'mar'
  vid=as.data.frame(vid);sh=merge(sh_,vid)
  sh$shema=paste(sh$name,'_',sh$vid,'.csv',sep='');shema=rbind(shema,sh)
  
  
  #Выводы настроек нейросети, наверно (???)
  vid=c('ext','ext1');vid=as.data.frame(vid);sh=merge(sh_,vid)
  sh$dir='./data/trainsets/';sh$shema=paste(sh$name,'_',sh$vid,'.csv',sep='');
  shema=rbind(shema,sh)
  
  
  sh=shema[1,];
  sh$name='info';sh$vid='rez';sh$srok='rez';sh$shema='info.csv';sh$dir='./data/dannie/'
  shema=rbind(shema,sh)
  
  #всё по нейросети - настройки сокр, полн данные, данные по лучшим значениям по точкам
  sh$name='neiroset';sh$vid='sokr';sh$shema='neir_hist_sokr.csv';sh$dir='./data/neir_hist/'
  sh_=sh;
  sh_$vid='poln';sh_$shema='neir_hist.csv';sh=rbind(sh,sh_);
  sh_$vid='results';sh_$shema='neir_hist_results.csv';sh=rbind(sh,sh_);
  sh_$vid='new';sh_$shema='neir_new.csv';sh=rbind(sh,sh_);# на случай ошибки - сложить перед обработкой что угодно
  
  #
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
  
  
  sh=shema[(shema$name=='sahalin')&(shema$srok!='day'),]
  sh$name='doss';
  sh[((sh$srok=="month")&(sh$vid=='vag')),'shema']='vag_doss%.txt'
  sh[((sh$srok=="month")&(sh$vid=='pas')),'shema']='doss_%.txt'
  
  sh_=sh[(sh$srok=='rez'),];sh_$shema=paste('doss',substr(sh_$shema,8,20),sep='')
  sh=sh[(sh$srok!='rez'),];sh=rbind(sh,sh_)
  shema=rbind(shema,sh)
  
  # специально для сахалина - короткая база вагонов
  shema[((shema$name=='sahalin')&(shema$srok=="month")&(shema$vid=='vag')),'shema']='vag_sahalin%.txt'
  
  ### теперь добавить полные данные
  sh=data.frame(name='dann');sh$srok='month';sh$dir='./data/dannie/month/'
  sh$vid='pas';sh$shema='min_dann_%.txt';sh$format='min_dann'; sh_=sh;
  sh$vid='vag';sh$shema='vagoni_%.txt';sh$format='vag_month';sh_=rbind(sh_,sh)
  sh$vid='spas';sh$shema='mins_dann_st_%.txt';sh$format='min_danns';sh_=rbind(sh_,sh)
  sh$vid='rasp';sh$shema='raspis%.txt';sh$format='rasp';sh_=rbind(sh_,sh)
  #sh$srok='day';sh$shema='dann % k.txt';sh$format='day';shema=rbind(shema,sh)
  #sh$srok='day';sh$shema='dann % v.txt';sh$format='vag_day';shema=rbind(shema,sh)
  sh$vid='stan';sh$shema='stan_dann_%.txt';sh$format=sh$vid;sh_=rbind(sh_,sh)
  sh$vid='stanon';sh$shema='stanon_dann_%.txt';sh$format=sh$vid;sh_=rbind(sh_,sh)
  
  
  # и теперь куда писать результаты
  sh=sh_;sh$srok='rez';sh$dir='./data/dannie/';sh$format=''
  she=sh[(sh$vid=='rasp'),];#she=rbind(she,she,she,she)
  vid=c('rasp1','rasp2','rasp3','mar');vid=as.data.frame(vid)
  she$vid=NULL;she=merge(she,vid)
  #name=as.character(unique(shema$name))
  name=c("sahalin","sapsan","dann","strela","spb_mos","doss" )
  name=as.data.frame(name)
  she$name=NULL;she=merge(she,name)
  #she$vid=c('rasp1','rasp2','rasp3','mar')
  sh=sh[(sh$vid!='rasp'),];sh=rbind(sh,she)
  sh$shema=paste(sh$name,'_',sh$vid,'.csv',sep='')
  sh=rbind(sh_,sh);shema=rbind(shema,sh)
  
  
  {#добавка статистика ДОСС
    sh=shema[(shema$name=='doss')&(shema$vid=='pas'),]
    sh$name='stat_doss'
    sh$vid='st_pas'
    sh[(sh$srok=='month'),'shema']='stat_doss_%'
    sh[(sh$srok=='month'),'format']='st_month'
    sh[(sh$srok=='rez'),'shema']='stat_doss.csv'
    shema=rbind(shema,sh)}
  
  {# ДОБАВКА ПРИГОРОДА
    sh$name='prig'
    sh$vid='prig'
    sh[(sh$srok=='month'),'shema']='PRIG2_%'
    sh[(sh$srok=='rez'),'shema']='prig.csv'
    sh[(sh$srok=='month'),'format']='prig'
    shema=rbind(shema,sh)}
  
  shema=unique(shema)
  return(shema)
  rm(sh,sh_,she,shema,vid,name)
}
# пример запуска shema=myPackage$trs.shema_dannih()






# СЛИЯНИЕ ДВУХ ДАТА-ФРЕЙМОВ - поля обязаны быть одинаковых форматов, иначе ошибка
myPackage$sliv <- function(a,b) {
  if(!is.null(a)){if(nrow(a)==0){a=NULL}}
  if(!is.null(b)){if(nrow(b)==0){b=NULL}}
  if (is.null(a)){a=b;b=NULL}
  if(!is.null(b)){
    for(nm in colnames(a)){if (!(nm %in% colnames(b))){b[,nm]=NA}}
    for(nm in colnames(b)){if (!(nm %in% colnames(a))){a[,nm]=NA}}
    for(nm in colnames(a)){
      #приведение несовпадающих форматов - если оба формата определены
      if ((typeof(a[,nm])!=typeof(b[,nm])) 
          &(typeof(a[,nm])!="logical")&(typeof(b[,nm])!="logical"))
      {
        if ((is.numeric(a[,nm]))&(is.numeric(b[,nm]))) { #если оба числовые - сделать числовыми
          a[,nm]=as.numeric(a[,nm]);b[,nm]=as.numeric(b[,nm]);
        } else { # а иначе - строковыми
          a[,nm]=as.character(a[,nm]);b[,nm]=as.character(b[,nm])} } }
  }
  return (rbind(a,b))
  rm(a,b,nm)
}
#  пример  с=myPackage$sliv(a,b)








#  shemi=shema  ;  files=list.files(path);  s=1   ;i=1    rm(files)
#подвыбор файлов, подходящих по схеме, с возможностью разных форматов одновременно +++
myPackage$trs.vibor_files_shema <- function(shemi) {
  files=NULL
  if (nrow(shemi)>0){
    for (s in 1:nrow(shemi)){   #  s=1
      sh=shemi[s,];shema=as.character(sh$shema)
      path=as.character(sh$dir)
      #перечень всех файлов, существующих в каталоге
      #files=list.files(path);file=data.frame(File=files);
      
      #перечень файлов с параметрами - дата и размер
      #File=list.files(path, full.names = TRUE);
      File=list.files(path);
      file=as.data.frame(File);
      file$file=paste(path,file$File,sep='')
      for(nm in file$file){
        info=file.info(nm);o=(file$file==nm);file[o,'size']=info$size;
        file[o,'c_time']=as.character(info$mtime)}
      file=file[(!is.na(file$size)),]
      file$file=NULL
      
      
      file$iz=0;kol_f=nrow(file);file$ord=1:kol_f
      
      #for (shema in shemi){  # если shemi=unique(as.character(shemi$shema))
      len=nchar(shema);pr=0
      for (i in 1:len){if (substr(shema,i,i)=='%'){pr=i}}
      for(i in 1:kol_f){
        z=1;
        fl=as.character(file[(file$ord==i),'File']);l=nchar(fl)
        if(pr>1){if (substr(fl,1,pr-1)!=substr(shema,1,pr-1)){z=0}}
        if(pr<len){if (substr(fl,l-len+pr+1,l)!=substr(shema,pr+1,len)){z=0}}
        if (z==1){file[(file$ord==i),'iz']=z}
      }
      file$format=as.character(sh$format)
      file$shema=as.character(sh$shema)
      file$dir=as.character(sh$dir)
      if (s==1){files_=file}else{files_=rbind(files_,file)}
    }
    files=files_[(files_$iz==1),];
    files$iz=NULL;files$ord=NULL
  }
  #files=unique(as.character(file$file))
  return(files)
  rm(file,files,files_,info,sh,shemi,File,fl,i,kol_f,l,len,nm,o,path,pr,s,shema,z)
  
}
# пример запуска  files=myPackage$trs.vibor_files_shema(shema) 







myPackage$trs.file_adres <- function(name,vid,nname='') {
  # Возвращает путь до базы агрегированных (прочитанных и переработаных) данных,
  # Args:Name= имя базы данных,  vid = вид данных (пассажиры, маршруты)
  # Returns:  путь до базы = строка
  # nname = дополнительная поддиректория - для настройки разных нейросетей
  srok='rez'
  shema=myPackage$trs.shema_dannih();
  shema=shema[(shema$vid==vid)&(shema$srok==srok),]
  dir=shema[1,'dir']
  sh=shema[(shema$name==name),]
  if (nname!=''){dir=paste(dir,nname,'/',sep='')}
  if(nrow(sh)==1){dbPath=paste(dir,as.character(sh$shema),sep='')}else
  {dbPath=NULL
  if (vid %in% c('ext','pzd')){dbPath=paste(dir,name,'_',vid,'.csv',sep='')}
  if (name=='prognoz'){dbPath='./data/prognoz/pronnoz.csv'}
  }
  return(dbPath)
  rm(name,vid,nname,dbPath,srok,shema,sh,dir)
}
#  пример запуска dbPath <- myPackage$trs.file_adres('sahalin','pas')





#ЧТЕНИЕ ИЗ БАЗЫ АГРЕГАТОВ ВО ФРЕЙМ +++
myPackage$trs.dann_load <- function(name,vid,nname='') {
  # Загружает базу агрегированных данных
  # Args:  #   dbName: имя базы
  # Returns:#   базу данных
  dbPath <- myPackage$trs.file_adres(name,vid,nname) 
  aggrdb <- NULL
  if (!is.null(dbPath)){if (file.exists(dbPath)){
    aggrdb <- read.csv2(dbPath, header = TRUE,fileEncoding = "WINDOWS-1251")[, -1]
    if(ncol(aggrdb)==0){
      aggrdb <- read.csv(dbPath, header = TRUE,fileEncoding = "WINDOWS-1251")[, -1]}
    }}
  return(aggrdb)
  rm(name,vid,nname,dbPath,aggrdb)
}
# пример запуска dann=myPackage$trs.dann_load('sahalin','mar')







#  выдача и патерна чтения таблицы, и перечня названий столбцов
myPackage$trs.Data.patern_col <- function(format = "month") {
  # Возвращает паттерн, распознающий сырые данные о продажах билетов, а теперь и вагоны
  # Args:
  #   format: формат данных
  #     "month": данные за месяц
  #     "day": данные за день
  pat=NA;col=NA
  if (format == "month") {
    pat="^([^:]*):([^\\/]*)/([^\\-]*)-([^\\-]*)-([^\\-]*)-([^\\-]*)-([^.]*)\\.([^\\-]*)-([^.]*)\\.([^.]*)\\.([^.]*)\\.([^:/]*)[:/]([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\."
    col=c("Date","Train","Skp","Sto","Stn","Vag","Rasst","TVLak","Z_otp","Z_prib",
          "Tm_otp","Tm_prib","Before","Kol_pas","Plata","Cena","Ndu","Pol_Gos_Vozv")
    
    
    #return("^([^:]*):([^\\/]*)/([^\\-]*)-([^\\-]*)-([^\\-]*)-([^\\-]*)-([^.]*)\\.([^\\-]*)-([^.]*)\\.([^.]*)\\.([^.]*)\\.([^:/]*)[:/]([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.")
    #return("^([^:]*):([^\\-]*)-([^\\-]*)-([^\\-]*)-([^\\-]*)-([^.]*)\\.([^\\-]*)-([^.]*)\\.([^.]*)\\.([^.]*)\\.([^:/]*)[:/]([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.")
    
    ## old2 format
    #return("^([^:]*):([^\\-]*)-([^\\-]*)-([^\\-]*)-([^\\-]*)-([^.]*)\\.([^\\-]*)-([^.]*)\\.([^.]*)\\.([^.]*)\\.([^:/]*)[:/]([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.")
    ## old format
    #return("^([^:]*):([^\\-]*)-([^\\-]*)-([^\\-]*)-([^\\-]*)-([^.]*)\\.(.)(.)(.)(.)(..)*?-([^.]*)\\.([^.]*)\\.([^.]*)\\.([^:/]*)[:/]([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.")
  }
  if (format == "day") {
    pat="^([^/]*+)/([^/]*+)/([^/]*+)/(.)(..)/([^/]*+)/([^/]*+)/([^.]*+)\\.([^/]*+)/([^/]*+)/(.)(.)(.)/([^.]*+)\\.([^.]*+)\\.([^.]*+)\\.([^.]*+)\\.([^.]*+)\\.([^.]*+)\\./([^/]*+)/([^/]*+)/"
    col=c("InfoDate", "Date", "Train", "Type", "Klass", "Sto", "Stn", 
          "Rasst", "Z_otp", "Z_prib", "vcd", "Lgot", "Arenda", "Kol_pas", "Stoim", 
          "Plata", "Service", "Rsto", "Rstn", "Tm_otp", "Tm_prib")
    #return ("^([^/]*+)/([^/]*+)/([^/]*+)/(.)(..)/([^/]*+)/([^/]*+)/([^.]*+)\\.([^/]*+)/([^/]*+)/(.)(.)(.)/([^.]*+)\\.([^.]*+)\\.([^.]*+)\\.([^.]*+)\\.([^.]*+)\\.([^.]*+)\\./([^/]*+)/([^/]*+)/")
    #    return ("^([^/]*+)/([^/]*+)/([^/]*+)/(.)(..)/([^/]*+)/([^/]*+)/([^.]*+)\\.([^/]*+)/([^/]*+)/(.)(.)(.)/([^.]*+)\\.([^.]*+)\\.([^.]*+)\\.([^.]*+)\\.([^.]*+)\\.([^.]*+)\\./([^.]*+)\\.([^/]*+)/([^.]*+)\\.([^/]*+)/")
  }
  
  if (format == "vag_month") {
    pat="^([^.]*)\\.([^\\/]*)/([^\\.]*).([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)"
    col=c("Date", "Train","Skp", "Vag", "Type", "Sto","Stn", "Seats", "Klass", 
          "NM1", "NMP", "FreeSeats","Rasst", "Arenda")
    #2018-01-01.0001ЭА/36.1.К.2068400.2068498.36.2К.001.036.0.613.1.
    #2018-01-01.0001ЭА/36.2.Л.2068400.2068498.16.1Б.001.016.6.613.0.
      } 
  
  if (format == "vag_day") {
    pat="^([^/].*)/([^/]*)/([^/]*)/(.)(..)/(.)/([^.]*)\\.([^.]*)\\./"
    #return ("^([^/].*)/([^/]*)/([^/]*)/(.)(..)/(.)/([^.]*)\\.([^.]*)\\./")
    col=c("InfoDate", "Date", "Train", "Type", "Klass", "Arenda", "Kol_vag", "Seats")
  } 
  
  if (format == "min_dann") {    
    pat="^([^:]*):([^\\/]*)/([^\\/]*)/([^\\/]*)/([^\\/]*)/([^\\/]*)/([^:]*):([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\."
    col=c("Date","Train","Train2","pzdm","Tip_vid","Klass","Skp","z_week","Kol_pas","Pkm","Plata","Cena")
    #  2018-09-24:0099Э/0651Ж/0/К/2К/1:0.5.1880.83865.83865.
    #  2018-09-24:0099Э///К/2Л/1:0.1.376.16140.22422.
  }
  
  if (format == "stan") {    
    pat="^([^:]*):([^\\/]*)/([^\\/]*)/([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\."
    col=c("Date","Sto","Stn","z_prib","Kol_pas","Pkm","Plata","Cena")
    #  2018-08-01:1000001/2004682/0.12.3444.125804.125804.
  }
  if (format == "stanon") {    
    pat="^([^:]*):([^\\/]*)/([^\\/]*)/([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\."
    col=c("Date","Sto","Stn","z_prib","Kol_pas","Pkm","Plata","Cena")
    #  2018-01-01:0/1000001/0.109.43589.4648527.4860056.
  }
  
  if (format == "min_danns") {    
    pat="^([^:]*):([^\\/]*)/([^\\/]*)/([^\\/]*)/([^\\/]*)/([^:]*):([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\."
    col=c("Date","Train","Tp_vid","Sto","Stn","Skp","Kol_pas","Pkm","Plata","Cena")
    
    #  2017-10-02:0070ЧА/К2Л/2030002/2030400/1:1.190.0.9376.
    #  2017-10-02:0070ЧА/К2Л/2030010/2030020/1:2.442.10159.18838.
    
  }
  if (format=="rasp"){
    pat="^([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\."
    col=c("has","Date","Train","dp","do","vrmp","vrmo")
    #  74.0.2004001.0.0.2355.2355.
    #  291.2019-01-15.0809СА.....
  }
  
  if (format=="st_month"){
    pat="^([^:]*):([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\."
    col=c("Date","Train","tp","Sto","Stn",'gos','zap','Rasst','nde','Cena','Kol_pas','Plata','s_pot','sumv')
    # 2018-10-01:0718ИА.С1С.2010050.2000001.---.6.335.CHFX.35.1.35386.0.35386.
    # 2018-10-01:0718ИА.С1С.2010050.2000001.RUS.0.335.CHFX.21.1.21413.0.21413.
  }
  
  if (format=="prig"){
    pat="^([^:]*):([^:]*)\\:([^:]*)\\:([^/]*)\\/([^-]*)\\-([^-]*)\\-([^=]*)\\=([^-]*)\\-([^/]*)\\/([^.]*)\\.([^/]*)\\/([^/]*)\\/([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\."
    col=c("Date","d_pr","d_otp","d_naz","skp",'agt','Stp','Sto','Stn','dor_prz','srok','lgot','Kol_bil','Pkm','sum','sump','sumt')
    # 2019-01-01:31:0:29/10-10-2044001=0-0/НM.1//5.93.76020.0.76020.
    # 2019-01-01:31:0:29/10-10-2044035=0-0/НM.1//1.16.17500.0.17500.
  }
  
  if (is.na(pat)){
    print(paste("BAD FORMAT (",format,')',sep=''))
    # stop("BAD FORMAT")
  }
  rez=list();rez$pat=pat;rez$col=col
  
  return(rez)
  rm(format,pat,col,rez)
}
# пример запуска pat=myPackage$trs.Data.patern_col(format) 






# Возвращает названия колонок, содержащихся в сырых данных о продажах билетов, а теперь и вагоны +++
myPackage$trs.Data.text.columns_old <- function(format = "month") {
  # Args:
  #   format: формат данных
  #     "month": данные за месяц
  #     "day": данные за день
  if (format == "month") {
    return (c("Date","Train","Skp","Sto","Stn","Vag","Rasst","TVLak","Z_otp","Z_prib",
              "Tm_otp","Tm_prib","Before","Kol_pas","Plata","Cena","Ndu","Pol_Gos_Vozv")) 
    #return (c("Date","Train_skp","Sto","Stn","Vag","Rasst","TVLak","Z_otp","Z_prib",
    #          "Tm_otp","Tm_prib","Before","Kol_pas","Plata","Cena","Ndu","Pol_Gos_Vozv")) 
    
    ## old2 format
    #return (c("Date", "Train", "Sto", "Stn","Vag", "Rasst", 
    #          #"Type","vcd", "Lgot", "Arenda","Klass", 
    #          "TVLak","Z_otp", "Z_prib", "Tm_otp", "Tm_prib", "Before", 
    #          "Kol_pas", "Stoim", "Losses", "Plata", "Service", "Vozvrat")) 
    
  } else if (format == "day") {
    return (c("InfoDate", "Date", "Train", "Type", "Klass", "Sto", "Stn", 
              "Rasst", "Z_otp", "Z_prib", "vcd", "Lgot", "Arenda", "Kol_pas", "Stoim", 
              "Plata", "Service", "Rsto", "Rstn", "Tm_otp", "Tm_prib"
              #  "H_otp","M_otp","H_prib","M_prib"
    ))
  } else if (format == "vag_month") {
    return (c("Date", "Train","Skp", "Vag", "Type", "Sto","Stn", "Seats", "Klass", 
              "NM1", "NMP", "FreeSeats","Rasst", "Arenda"))
  } else if (format == "vag_day") {
    return (c("InfoDate", "Date", "Train", "Type", "Klass", "Arenda", "Kol_vag", "Seats"))
  } else stop("Неправильный формат")
}
# пример запуска cols=myPackage$trs.pData.text.columns() на выходе список строковый
# пример запуска cols=myPackage$trs.pData.text.columns('day') на выходе список строковый





#  наверно надо расширить - и для вагонов и расписаний - расширил  +++
myPackage$trs.Data.text.pattern_old <- function(format = "month") {
  # Возвращает паттерн, распознающий сырые данные о продажах билетов, а теперь и вагоны
  # Args:
  #   format: формат данных
  #     "month": данные за месяц
  #     "day": данные за день
  if (format == "month") {
    return("^([^:]*):([^\\/]*)/([^\\-]*)-([^\\-]*)-([^\\-]*)-([^\\-]*)-([^.]*)\\.([^\\-]*)-([^.]*)\\.([^.]*)\\.([^.]*)\\.([^:/]*)[:/]([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.")
    #return("^([^:]*):([^\\-]*)-([^\\-]*)-([^\\-]*)-([^\\-]*)-([^.]*)\\.([^\\-]*)-([^.]*)\\.([^.]*)\\.([^.]*)\\.([^:/]*)[:/]([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.")
    
    ## old2 format
    #return("^([^:]*):([^\\-]*)-([^\\-]*)-([^\\-]*)-([^\\-]*)-([^.]*)\\.([^\\-]*)-([^.]*)\\.([^.]*)\\.([^.]*)\\.([^:/]*)[:/]([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.")
    ## old format
    #return("^([^:]*):([^\\-]*)-([^\\-]*)-([^\\-]*)-([^\\-]*)-([^.]*)\\.(.)(.)(.)(.)(..)*?-([^.]*)\\.([^.]*)\\.([^.]*)\\.([^:/]*)[:/]([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.")
  } else if (format == "day") {
    return ("^([^/]*+)/([^/]*+)/([^/]*+)/(.)(..)/([^/]*+)/([^/]*+)/([^.]*+)\\.([^/]*+)/([^/]*+)/(.)(.)(.)/([^.]*+)\\.([^.]*+)\\.([^.]*+)\\.([^.]*+)\\.([^.]*+)\\.([^.]*+)\\./([^/]*+)/([^/]*+)/")
    #    return ("^([^/]*+)/([^/]*+)/([^/]*+)/(.)(..)/([^/]*+)/([^/]*+)/([^.]*+)\\.([^/]*+)/([^/]*+)/(.)(.)(.)/([^.]*+)\\.([^.]*+)\\.([^.]*+)\\.([^.]*+)\\.([^.]*+)\\.([^.]*+)\\./([^.]*+)\\.([^/]*+)/([^.]*+)\\.([^/]*+)/")
  } else if (format == "vag_month") {
    ## old format
    #return ("(\\S+)\\s+([0-9\\-]+)\\s+([0-9]+)\\s+(\\S)\\s+([0-9]+\\.)\\s+([0-9]+)\\s+([0-9]+)\\s*")
    return ("^([^.]*)\\.([^\\/]*)/([^\\.]*).([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)")
  #  return ("^([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)\\.([^.]*)")
  } else if (format == "vag_day") {
    return ("^([^/].*)/([^/]*)/([^/]*)/(.)(..)/(.)/([^.]*)\\.([^.]*)\\./")
  } else stop("Неправильный формат")
}
# пример запуска form=myPackage$trs.pData.text.pattern() - одна длинная строка









# первичное чтение из текста, с разбивкой по полям. Далее надо обработать - некоторые поля есть функции от нескольких +++
myPackage$trs.Data.text.load <- function(filePath, format = "month") {
  # Загружает текстовые данные о продажах билетов
  # Args:
  #   path: путь до текстового файла с данными
  #   format: формат данных
  # Returns:
  #   матрицу с данными
  pat=myPackage$trs.Data.patern_col(format)
  tmp=NA
  if (!is.na(pat$pat)){
    text <- iconv(readLines(filePath, warn = FALSE), from = "WINDOWS-1251", to = "UTF-8")
    #tmp <- str_match(text, myPackage$trs.Data.text.pattern(format))
    tmp <- str_match(text, pat$pat)
    #первое поле обзываем 'all' - неразобранная структура
    #colnames(tmp) <- c("all", myPackage$trs.Data.text.columns(format)) 
    colnames(tmp) <- c("all", pat$col) # обозвать каждый столбец матрицы
    tmp=data.frame(tmp[!is.na(tmp[,1]), -1])
  }
  
  
  {# заплатка - убрать явно лишние строки, грязь
    nms=names(tmp)
    for (nm in nms){
      tmp=tmp[(!(tmp[,nm] %like% 'SELECT')),]
    }}
  
  kol_zap=nrow(tmp);print(paste('kol_zap(tmp)',kol_zap,sep='='));
  
  return(tmp)
  text=1
  rm(filePath,format,text,tmp,pat,kol_zap,nm,nms)
}
# пример запуска 
#path='./data/dannie/month/sahalin_2016_12.txt' ; format = "month"
#dann <- myPackage$trs.Data.text.load(path, format) 







# непосредственно запись данных в память 
myPackage$trs.Data_save <- function(matrix, name,vid='',first=TRUE,nname='') {
  
  #отсортировать поля в алфавитном порядке
  matrix=as.data.frame(as.data.table(matrix))
  nm=names(matrix);nm=as.data.frame(nm);nm$id=1
  o=order(nm$nm);nm=nm[o,]
  for (nm_ in nm$nm){v=matrix[,nm_];matrix[,nm_]=NULL;matrix[,nm_]=v}
  
  # Сохраняет базу агрегированных данных в файле
  dbPath=myPackage$trs.file_adres(name,vid,nname)
  if (is.null(dbPath)) {dbPath=paste("./data/",name,'.csv',sep='')}
  
  
  if (first){ write.csv2(x = matrix, file = dbPath, fileEncoding = "WINDOWS-1251") }else{
    #write.table(matrix, file = dbPath, sep = ",", col.names = FALSE, append=TRUE,
    #           fileEncoding = "WINDOWS-1251") 
    write.table(matrix, file = dbPath, sep = ";", col.names = FALSE, append=TRUE,
                fileEncoding = "WINDOWS-1251") 
    
  }
  print(paste("Save to : ",dbPath , sep = ""))
  rm(nm,o,v,nm_,dbPath,matrix,name,vid,first,nname)
}
# пример запуска   myPackage$trs.Data_save(results,'neiroset','results',TRUE) 








#  обработка прочитанных из текста данных - приведение полей к нормальному виду +++
myPackage$trs.Data.obrabot<- function(dann,format){
  dann=as.data.frame(as.data.table(dann))
  
  if (format=='stan'){#если надо - ввести тип
    dann$Stn=as.character(dann$Stn)
    dann$nnn=nchar(dann$Stn)
    dann$Type='-'
    o=(dann$nnn>7)
    dann[o,'Type']=substr(dann[o,'Stn'],9,dann[o,'nnn'])
    dann[o,'Stn']=substr(dann[o,'Stn'],1,7)   
    dann$nnn=NULL
  }
  
  if (format=='rasp') {
    o=(dann$do!='')
    dann[o,'Rasst']=dann[o,'Date'];dann[o,'Stan']=dann[o,'Train']
    dann[o,'Date']=NA;dann[o,'Train']=NA
    #dann$Train=as.character(dann$Train)
    #dann$nit=substr(dann$Train,6,6);
    #dann$Train=substr(dann$Train,1,5)
    #dann$nit=NULL
  }
  
  
  names=names(dann)  
  if ('Date' %in% names) {dann$Date=as.Date(as.character(dann$Date))}
  if ('InfoDate' %in% names) {dann$InfoDate=as.Date(as.character(dann$InfoDate))}
  
  nums=c('Rasst','Kol_pas','Plata','Cena','Pkm','Sto','Stn','z_week','Seats',
         'FreeSeats','Z_otp','Z_prib','z_otp','z_prib','Ndu','NM1','NMP','Before','Skp','Stan',
         'has','do','dp','vrmo','vrmp','s_pot','zap','sumv',
         'Kol_bil','sum','sump','sumt','srok','skp','agt','d_pr','d_otp','d_naz')
  for (pol in nums){
    if (pol %in% names){
      dann[,pol]=as.numeric(as.character(dann[,pol]))
    }}
  
  if ('Tip_vid' %in% names(dann)){
    dann$Type=substr(dann$Tip_vid,1,1)
    dann$vid=substr(dann$Tip_vid,2,2)
    dann$Tip_vid=NULL}
  
  
  if (nrow(dann)>0){
    if (format %in% c('month','day')){
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
        dann$TVLak=NULL  
        
        dann$Pol=substr(dann$Pol_Gos_Vozv,1,1)
        dann$Gos=substr(dann$Pol_Gos_Vozv,2,2)
        dann$Vozvrat=substr(dann$Pol_Gos_Vozv,3,8)
        dann$Pol_Gos_Vozv=NULL
      }
      
      #dann$verx=substr(dann$Train,1,1);#признак верхнее место был в номере поезда 1 символ
      #dann$Train=paste('0',substr(dann$Train,2,8),sep='')
      dann$Train=paste('0',dann$Train,sep='') 
      dann$Arenda <- as.character(dann$Arenda)
      dann[(dann[,'Arenda']!='1'),'Arenda']='0';#аренда =2 и далее - =0. Нужено лишь =1
      #  =2 - это учёт по бумажной копии электронного билета, возможно неправильное изнач. чтение
      dann[(dann$Arenda=='1'),'Lgot']='0'
      
      dann$Cena=round(dann$Cena/dann$Kol_pas)
      
      if(format=='day'){
        dann$Tm_otp=60*as.integer(substr(dann$Tm_otp,1,2))+as.integer(substr(dann$Tm_otp,4,5));
        dann$Tm_prib=60*as.integer(substr(dann$Tm_prib,1,2))+as.integer(substr(dann$Tm_prib,4,5));
        
        dann$Date_p=dann$Date-dann$Z_otp
        dann$Before_p=pmax(dann$Date_p - dann$InfoDate,0)
        dann$cena_niz=dann$Plata;dann$Plata=NULL
      }
      
      if(format=='month'){  
        dann$Tm_otp=as.integer(as.character(dann$Tm_otp))*2;
        dann$Tm_prib=as.integer(as.character(dann$Tm_prib))*2;#время было изнач вдвое меньше, плюс запаздывания в сутках
        
        #БЛОК ТОЛЬКО для месяцев, дописал - возвраты приписаны с минусами в дату возврата
        dann0=dann[(dann$Vozvrat != "-"),]
        dann0$Before=as.integer(as.character(dann0$Vozvrat));
        dann0$Kol_pas=dann0$Kol_pas*-1;
        dann0$Cena=dann0$Cena*-1;dann0$Plata=dann0$Plata*-1;
        dann=rbind(dann,dann0);dann$Vozvrat= '-';rm(dann0);
        dann$Vozvrat=NULL #убираю поле - не нужно теперь
        dann$Date_p=dann$Date-dann$Z_otp
        dann$Before_p <- pmax(dann$Before - dann$Z_otp,0)
        
        #dn=dann[(abs(dann$Stoim)>abs(dann$Plata)),]
        #dann$cena_niz=0;
        #if (nrow(dn)==0){dann$cena_niz=dann$Plata/dann$Kol_pas};rm(dn)
      }
      dann$Z_prib=dann$Z_prib+dann$Z_otp  
      dann$Tm_otp=dann$Tm_otp + dann$Z_otp*(24*60);  
      dann$Tm_prib=dann$Tm_prib + dann$Z_prib*(24*60);  
      dann[(dann$Ndu==1),'Ndu']=1000
    }
    
    
    if (format %in% c('vag_month','vag_day')) {
      dann$Arenda <- as.character(dann$Arenda)
      dann[(dann[,'Arenda']!='1'),'Arenda']='0';#аренда =2 и далее - =0. Нужено лишь =1
    }
  }
  
  if(format=='min_dann'){  
    #dann$Date=as.Date(as.character(dann$Date))
    dann$pzdm=as.integer(as.character(dann$pzdm))
    dann[(is.na(dann$pzdm)),'pzdm']=0
    dann[(dann$pzdm>100),'pzdm']=0
    #dann$Type=substr(dann$Tip_vid,1,1)
    #dann$vid=substr(dann$Tip_vid,2,2)
    #dann$Tip_vid=NULL
    #пока не использую - убить поля
    dann$Train2=NULL;dann$pzdm=NULL;dann$vid=NULL
  }
  
  if(format=='min_danns'){dann$vid=NULL}
  
  if (format %in% c('stan','stanon')) {
    dann[(dann$z_prib==-1),'z_prib']=0
    dann=dann[(!((dann$Kol_pas==0)&(dann$Pkm==0)&(dann$Plata==0)&(dann$Cena==0))),]
  }
  
  if (format=='stan') {
    #какие станции оставить
    dn=aggregate(x=subset(dann,select=c('Kol_pas')),
                 by=subset(dann,select=c('Sto','Stn')), FUN="sum" )
    dn_=dn;dn_$Sto=dn_$Stn;dn=rbind(dn,dn_)
    dn=aggregate(x=subset(dn,select=c('Kol_pas')),
                 by=subset(dn,select=c('Sto')), FUN="sum" )
    o=order(-dn$Kol_pas);dn=dn[o,]
    dn$n=(1:nrow(dn));dn_=dn[(dn$n<=500),];dn=dn[(dn$n<=100),]
    dann$goso=as.numeric(substr(as.character(dann$Sto),1,2))
    dann$gosn=as.numeric(substr(as.character(dann$Stn),1,2))
    
    {# по отправлению
      dn1=aggregate(x=subset(dann,select=c('Kol_pas','Pkm','Plata','Cena')),
                    by=subset(dann,select=c('Date','Sto','gosn','Type')), FUN="sum" )
      dn1=dn1[(dn1$Sto %in% dn_$Sto),];dn1$Stn=dn1$gosn;dn1$gosn=NULL}
    {# суммарно
      dns=aggregate(x=subset(dann,select=c('Kol_pas','Pkm','Plata','Cena')),
                    by=subset(dann,select=c('Date','goso','gosn','Type')), FUN="sum" )
      dns$Stn=dns$gosn;dns$Sto=dns$goso;dns$gosn=NULL;dns$goso=NULL}
    {#по прибытию
      dn2=aggregate(x=subset(dann,select=c('Kol_pas','Pkm','Plata','Cena')),
                    by=subset(dann,select=c('Date','Stn','z_prib','goso','Type')), FUN="sum" )
      dn2$Date=as.Date(dn2$Date)+dn2$z_prib
      dn2=aggregate(x=subset(dn2,select=c('Kol_pas','Pkm','Plata','Cena')),
                    by=subset(dn2,select=c('Date','Stn','goso','Type')), FUN="sum" )
      dn2=dn2[(dn2$Stn %in% dn_$Sto),];
      dn2$Sto=dn2$goso;dn2$goso=NULL}
    
    dann=dann[(dann$Sto %in% dn$Sto),]
    dann=dann[(dann$Stn %in% dn$Sto),]
    dann=aggregate(x=subset(dann,select=c('Kol_pas','Pkm','Plata','Cena')),
                   by=subset(dann,select=c('Date','Sto','Stn','Type')), FUN="sum" )
    #отправки, прибытия и маршруты
    dann=rbind(dann,dn1,dn2,dns);rm(dn1,dn2,dns,dn,dn_)
  }
  
  
  if (format=='stanon') {
    dann$z_week=0;o=(dann$Sto<100)
    dann[o,'z_week']=dann[o,'Sto'];
    dann[!o,'z_week']=dann[!o,'Stn'];
    dann[o,'napr']=-1;dann[!o,'napr']=1;
    dann[o,'Stan']=dann[o,'Stn'];dann[!o,'Stan']=dann[!o,'Sto']
    
    dann=aggregate(x=subset(dann,select=c('Kol_pas','Plata','Cena','Pkm')),
                   by=subset(dann,select=c('Date','z_week','Stan','napr')), FUN="sum" )
    
    #иногос - оставим только государство
    dann$st=as.numeric(substr(as.character(dann$Stan),1,2))
    dn=dann;dn$Stan=dn$st
    dann=dann[(dann$st==20),];dann$st=NULL
    
    dn=aggregate(x=subset(dn,select=c('Kol_pas','Plata','Cena','Pkm')),
                 by=subset(dn,select=c('Date','z_week','Stan','napr')), FUN="sum" )
    dann=rbind(dann,dn)
    #оставить 200 лучших
    dn=aggregate(x=subset(dann,select=c('Kol_pas')),
                 by=subset(dann,select=c('Stan')), FUN="sum" )
    
    o=order(-dn$Kol_pas);dn=dn[o,]
    dn$n=(1:nrow(dn));dn=dn[(dn$n<=200),]
    dn$n=NULL;dn$Kol_pas=NULL
    dann=merge(dann,dn,by='Stan')
  }
  
  
  if (format=='prig'){
    dann$Date_pr=dann$Date- as.numeric(dann$d_pr)
    dann$Date_otp=dann$Date_pr+ as.numeric(dann$d_otp)
    dann$Date_naz=dann$Date_pr+ as.numeric(dann$d_naz)
    dann$d_n=as.numeric(dann$d_naz)-as.numeric(dann$d_otp)
    
    dann$dor=as.character(substr(dann$dor_prz,1,1))
    dann$vid=as.character(substr(dann$dor_prz,2,2))
    dann$lgot=as.numeric(as.character(dann$lgot))
    dann[(is.na(dann$lgot)),'lgot']=0
    
    o=((dann$sum==0)&(dann$sump==0)&(dann$sumt==0)&(dann$lgot<100))
    dann[o,'lgot']=dann[o,'lgot']+100 #вроде бы заведомо ошибочные!
    
    for (nm in c('d_pr','d_otp','d_naz','dor_prz')){dann[,nm]=NULL}
    
    
    { # собственно рассчёт
      # здесь *2 - для туда-обратно
      dann$kp=dann$srok
      dann[(dann$vid %in% c('Z','D')),'kp']=dann[(dann$vid %in% c('Z','D')),'srok']*2
      dann[(dann$vid=='M'),'kp']=dann[(dann$vid=='M'),'srok']*25*2
      dann$Kol_pas=dann$Kol_bil*dann$kp;dann$Pass_km=dann$Pkm*dann$kp
      print(paste('nrow=',nrow(dann),nrow(dann[(dann$vid=='R'),]),sep='='))
      dann[(dann$vid=='R'),'d_n']=0
      
      ##### данные по билетам и деньгам
      dann_bil=aggregate(x=subset(dann,select=c('Kol_bil','Pass_km','Kol_pas','sum','sump','sumt')),
                         by=subset(dann,select=c('Date','dor','skp','agt','lgot','vid','srok','Date_pr')), FUN="sum" )
      dann_pas=aggregate(x=subset(dann,select=c('Pass_km','Kol_pas')),
                         by=subset(dann,select=c('Date','dor','skp','agt','lgot','vid','srok','Date_otp','d_n')), FUN="sum" )
      
      {dann_pas1=dann_pas[(dann_pas$vid=='R'),] # разовые
        dann_pas1$pas=dann_pas1$Kol_pas
        dann_pas1$pkm=dann_pas1$Pass_km
        dann_pas1$Kol_pas=NULL;dann_pas1$Pass_km=NULL;dann_pas1$d_n=NULL 
      }
      
      {# абонементы
        dann_pas2=dann_pas[(dann_pas$vid!='R'),] 
        dann_pas21=dann_pas2[(dann_pas2$d_n<=30),]
        dann_pas22=dann_pas2[(dann_pas2$d_n>30),]
        d_n=max(dann_pas2$d_n)
        dd=(0:d_n);dd=as.data.frame(dd);dd$f=1
        dd1=dd[(dd$dd<=30),];dd1$f=NULL;dd$f=NULL
        
        dp21=merge(dann_pas21,dd1)
        dp21=dp21[(dp21$dd<=dp21$d_n),]
        
        dp22=merge(dann_pas22,dd)
        dp22=dp22[(dp22$dd<=dp22$d_n),]
        dp2=rbind(dp21,dp22)
        rm(dp21,dp22,dann_pas21,dann_pas22,d_n)
        
        
        dp2$pas2=round(dp2$Kol_pas*(dp2$dd+1)/(dp2$d_n+1))
        dp2$pas1=round(dp2$Kol_pas*(dp2$dd)/(dp2$d_n+1))
        
        dp2$pkm2=round(dp2$Pass_km*dp2$pas2/dp2$Kol_pas)
        dp2$pkm1=round(dp2$Pass_km*dp2$pas1/dp2$Kol_pas)
        dp2$pkm=dp2$pkm2-dp2$pkm1
        dp2$pas=dp2$pas2-dp2$pas1
        dp2=dp2[(dp2$pas!=0),]
        dp2$Date_otp=dp2$Date_otp+dp2$dd
        
        
        dann_pas2=aggregate(x=subset(dp2,select=c('pas','pkm')),
                            by=subset(dp2,select=c('Date','dor','skp','agt','lgot','vid','srok','Date_otp')), FUN="sum" )
      }
      dann_pas=rbind(dann_pas1,dann_pas2)
      rm(dann_pas1,dann_pas2,dp2,dd,dd1)
      
      dann_bil$Date_otp=dann_bil$Date_pr;dann_bil$Date_pr=NULL
      dann_bil$pas=0;dann_bil$pkm=0
      dann_pas$Kol_bil=0;dann_pas$Kol_pas=0;dann_pas$Pass_km=0;
      dann_pas$sum=0;dann_pas$sump=0;dann_pas$sumt=0
      dann=rbind(dann_bil,dann_pas);rm(dann_bil,dann_pas)
      dann=aggregate(x=subset(dann,select=c('pas','pkm',"Kol_bil","Pass_km","Kol_pas","sum","sump","sumt")),
                     by=subset(dann,select=c('Date','dor','skp','agt','lgot','vid','srok','Date_otp')), FUN="sum" )
    }
  }
  
  return(dann)
  dn=1;dann=1;format=1;names=1;nums=1;pol=1;o=1;nm=1;
  rm(dann,format,names,nums,pol,dn,o,nm)
}
# пример запуска 
#path='./data/dannie/month/sahalin_2016_12.txt'; format = "month"
#dann <- myPackage$trs.Data.text.load(path, format) 
#dann <- myPackage$trs.Data.obrabot(dann,format)
















#  Некие фильтры - на вагоны +++
#фильтр на всех помесячный - по вагонам - не действует на Сапсаны (нет скорости)
myPackage$trs.pass.filter_vag <- function(name, rawdb) {
  if (name == 'sahalin') {
    # Фильтр, оставляющий только сахалинские данные
    rawdb <- rawdb[(as.integer(as.character(abs(rawdb$Sto))) >= 2068000)
                   & (as.integer(as.character(abs(rawdb$Sto))) <= 2069999)
                   #& (as.integer(as.character(rawdb$Z_prib)) >= 0) #защита от неправильных данных - ошибка в дате
                   & (as.character(rawdb$Type) != ' '), ] #защита от неправильных данных - ошибка в типе вагона (багаж)
    rawdb$bad=0
  }
  
  if (name == 'strela') {
    # было только поезда 1А и 2А, но при присоединении файла неправильно берёт русские символы
    stan=c('2004001', '2004600', '2004660','2006004') #Только СПб Бологое Тверь и Москва
    rawdb=rawdb[((substr(rawdb$Train,1,4) %in% c('0001','0002'))
                 & (as.character(abs(rawdb$Sto)) %in% stan) & (as.character(abs(rawdb$Stn)) %in% stan)),]
    rawdb$bad=0
  }
  
  if (name=='spb_mos'){
    stan=c('2004001', '2006004') #Только СПб Бологое Тверь и Москва
    raw_bad=rawdb[(!((abs(rawdb$Sto) %in% stan)&(abs(rawdb$Stn) %in% stan))),]
    rawdb=rawdb[((abs(rawdb$Sto) %in% stan)&(abs(rawdb$Stn) %in% stan)),]
    raw_bad=unique(subset(raw_bad,select=c('Train','Date')));raw_bad$bad=1
    rawdb=merge(rawdb,raw_bad,by=c('Train','Date'),all=TRUE)
    rawdb=rawdb[((abs(rawdb$Sto) %in% stan)&(abs(rawdb$Stn) %in% stan)),]
    rawdb[(is.na(rawdb$bad)),'bad']=0
  }
  return (rawdb)
  stan=1;raw_bad=1;
  rm(name,rawdb,stan,raw_bad)
}









#   rawdb=matrix


#фильтр на всех помесячный - на пассажиров - по наименованию условие фильтрации +++
myPackage$trs.pass.filter <- function(name, rawdb) {
  # первый фильтр кроме неправ данных, и не багаж
  rawdb <- rawdb[(as.integer(as.character(rawdb$Z_prib)) >= 0) #защита от неправильных данных - ошибка в дате
                 & (as.character(rawdb$Type) != ' '), ] #защита от неправильных данных - ошибка в типе вагона (багаж)
  
  
  if (name == 'sahalin') {
    # Фильтр, оставляющий только сахалинские данные
    rawdb <- rawdb[(as.integer(as.character(rawdb$Sto)) >= 2068000)
                   & (as.integer(as.character(rawdb$Sto)) <= 2069999), ] 
  }
  if (name == 'sapsan') {
    stan=c('2004001','2004088','2004454','2004456',
           '2004457','2004460','2004576','2004577','2004578','2004579',
           '2004592','2004600','2004615','2004660','2006004','2006200');  # старый полный список станций  
    stan=c('2004001', '2004600', '2004660','2006004') #Только СПб Бологое Тверь и Москва
    
    speed <- 60* as.integer(rawdb$Rasst) / (as.integer(rawdb$Tm_prib) - as.integer(rawdb$Tm_otp))
    rawdb <- rawdb[((speed > 140)
                    & (as.character(rawdb$Sto) %in% stan) & (as.character(rawdb$Stn) %in% stan))
                   , ]
    # процедура - только те поезда, по которым лишь 1 тип вагона, и он ='C'
    trains <- sapply(FUN = function(pData) {
      if ((length(unique(pData$Type)) == 1) && (as.character(pData$Type)[1] == 'С')) {
        return (as.character(pData$Train[1]))
      } else {return ("default_string") }
    }, X = split(rawdb, f = rawdb$Train))
    trains <- unique(trains)
    # print(trains)
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







#   rawdb=matrix

#сворачивание данных - новый, со станциями отправления и назначения и расст, и пасс-км +++
myPackage$trs.pass_agregator <- function(rawdb) {
  # Агрегатор, сворачивающий в одну строку данные о продажах билетов
  # за разное количество суток до отправления поезда
  #rawdb=as.data.table(rawdb)
  rawdb=rawdb[(rawdb$Kol_pas!=0),]
  if (nrow(rawdb) == 0) {
    pass <- data.frame(Train = character(0), Date = character(0),Type = character(0), Before = integer(0), 
                       Arenda = character(0), Sto = integer(0),Stn = integer(0), 
                       Rasst = integer(0),Klass = character(0),Kol_pas = integer(0),
                       Plata = integer(0),  s_cena = integer(0),  Cena = integer(0));
    mar <- data.frame(Train = character(0), Date = character(0),
                      Rasst = integer(0),Sto = character(0),Stn = character(0),
                      Tm_otp = character(0),Tm_prib = character(0) )
  } else {
    # rawdb$Cena=round(rawdb$Cena/rawdb$Kol_pas); # отменил - цена делится на этапе чтения
    #if (is.null(rawdb$cena_niz)){rawdb$cena_niz=0}
    #обнуление цен неполных маршрутов
    #rawdb[(rawdb$Lgot!='0'),'Cena_niz']=NA;rawdb[(rawdb$Kol_pas<='0'),'Cena_niz']=NA;
    #rawdb[(is.na(rawdb$cena_niz)),c('Cena','cena_niz')]=0;  
    #sto stn - нужны потом для вычисления числа занятых мест 
    by = c('Train','Date','Type','Before','Arenda','Rasst','Klass','Sto','Stn') # ,'Ndu','Cena'
    by_t=c("Train", "Date")
    # непонятно почему - строка отказывается работать, не помню её смысла  
    #pass=rawdb[, lapply(.SD, sum, na.rm = T), .SDcols = c('Kol_pas','Plata'),by = by]
    #cena=rawdb[, lapply(.SD, max, na.rm = T), .SDcols = c('Cena','cena_niz'),by = by]
    #поэтому, по отдельности - суммы и максимумы, и слить вместе
    pass=aggregate(x=subset(rawdb,select=c('Kol_pas','Plata','s_cena')),by=subset(rawdb,select=by), FUN="sum" )
    cena=aggregate(x=subset(rawdb,select=c('Cena')),by=subset(rawdb,select=by), FUN="max" )
    suppressWarnings(pass <- merge(pass, cena, by = by));#слияние 2 агрегатов - суммирования и максимума
    rm(cena) #удалить ненужное
    
    
    #самый быстрый вариант!!!
    mar=subset(rawdb, select = c(Train, Date, Tm_otp, Tm_prib,Rasst, Sto, Stn,Ssto,Sstn)) # ,Rasst, Sto, Stn
    mar=mar[!is.na(mar$Tm_otp) & !is.na(mar$Tm_prib),]
    mar <- unique(mar)
    mar$tmo=mar$Tm_otp;mar$tmp=mar$Tm_prib;mar$Tm_otp=NULL;mar$Tm_prib=NULL; # нужное переименование
    mar[(mar$Sto!=mar$Ssto),'tmo']=NA
    mar[(mar$Stn!=mar$Sstn),'tmp']=NA
    #старый вариант - сорт по расст, первое вхождение пары (поезд,дата), и отсортировать
    #mar <- mar[order(mar$Rasst, decreasing = T), ]
    #mar <- mar[!duplicated(mar[, c("Train", "Date")]), ]
    #mar <- mar[order(mar$Train, mar$Date), ]
    
    #Новый вариант - наличие ст начала и конца хоть где то, крайние значения - их и взять. Для случая отсутствия билетов по всему маршруту
    maro=mar[(mar$Sto==mar$Ssto),c("Train", "Date","tmo")]
    maro=aggregate(x=subset(maro,select=c(tmo)),by=subset(maro,select=by_t), FUN="min" )
    marp=mar[(mar$Stn==mar$Sstn),c("Train", "Date","tmp")]
    marp=aggregate(x=subset(marp,select=c(tmp)),by=subset(marp,select=by_t), FUN="max" )
    mar <- merge( maro, marp, by = by_t, all=TRUE)
    
    # ещё разобраться с уникальными ценами
    #cena=subset(rawdb, select = c(Train, Date, Rasst, Sto, Stn,Cena,Type,Klass)) 
    #cena <- unique(cena)
    #by = c('Train','Date') #  ,'Rasst','Sto','Stn'       ,'Type','Klass'
    #suppressWarnings(cen <- merge( cena, mar, by = by));
    
    # а ещё хорошо бы подсчитать количества вагонов в поезде, хотя бы занятых и частично занятых
  }
  return(list(pass = pass, mar = mar))
  
  by=1;by_t=1;cena=1;maro=1;marp=1;
  rm(rawdb,pass,mar,by,by_t,cena,maro,marp)
}








#СБОР И АГРЕГАЦИЯ ИСХОДНЫХ ДАННЫХ из текстов, ПО ИМЕНИ СХЕМЫ. НИ АГРЕГАТОР НЕ НУЖЕН- ОБЩИЙ, нИ ФИЛЬТР УКАЗЫВАТЬ НЕ НАДО - ИЗ ИМЕНИ
# и далее всё записывается в .csv файл, на выход не идёт ничего +++
myPackage$trs.Data.read_sapsan_pas <- function(name) { 
  # Агрегирует сырые данные
  # Args:
  #   name: имя базы с агрегированными данными
  srok='month';vid='pas'
  shema=myPackage$trs.shema_dannih();
  shema=shema[((shema$name==name)&(shema$srok==srok)&(shema$vid==vid)),]
  #format=as.character(shema[,'format'])
  path=unique(as.character(shema[,'dir']));
    # shema=as.character(shema[,'shema'])
  
  files=myPackage$trs.vibor_files_shema(shema) # подвыбор нужных по схеме
  #files=data.frame(File=files);
  files$Database=name;files$vid=vid;files$srok=srok;files$ext='0'
  
  first <- TRUE;
  kol=nrow(files)
      if (kol>0){for (i in 1:kol){   #   i=1
      ff=files[i,];file=as.character(ff$File);format=as.character(ff$format)
  #for (file in files$File) {
    print(paste("Aggregating from \"", file, "\"...", sep = ""))
    filePath <- paste(path, file, sep = "")
    matrix <- myPackage$trs.Data.text.load(filePath,format);
    matrix <- myPackage$trs.Data.obrabot(matrix,srok)
    matrix <- myPackage$trs.pass.filter(name,matrix);#поменял 2 строки местами - сперва обработка. потом уже фильтр
    
    kol_zap=nrow(matrix);kol_rez=0;kol_mar=0
    if (kol_zap>0){
      matrix$Before=matrix$Before_p;matrix$Date=matrix$Date_p;
      mm=myPackage$trs.pass_agregator(matrix); # нечто, разбивает данные на 2 группы - ОШИБКА!
      matrix=mm$pass;matrix_mar=mm$mar;
      kol_rez=nrow(matrix);kol_mar=nrow(matrix_mar) 
      }
    files[(files$File==file),'kol_zap']=kol_zap
    files[(files$File==file),'kol_rez']=kol_rez
    files[(files$File==file),'kol_mar']=kol_mar
    if (kol_zap>0){
      min_dat=min(matrix_mar$Date);max_dat=max(matrix_mar$Date);
      files[(files$File==file),'min_date']=as.character(min_dat)
      files[(files$File==file),'max_date']=as.character(max_dat)   
    
    myPackage$trs.Data_save(matrix, name,'pas',first);
    myPackage$trs.Data_save(matrix_mar, name,'mar',first);
    first=FALSE    } # Сделал здесь конец цикла - для нового(первого) куска данных нулевой длины
    print(paste("Itog ",kol_zap," zapisei"))
    #tip=as.character(unique(matrix$Type));print(tip)
    }}
  info=myPackage$trs.dann_load('info','rez') 
  info <- info[(info$Database != name)|(info$vid!=vid), ]
  files$Time=as.character(Sys.time());
  info=myPackage$sliv(info,files);
  myPackage$trs.Data_save(info, 'info','rez',TRUE)
}

# пример запуска 
# name='sapsan'; myPackage$trs.pData.aggregate(name)





# +++
myPackage$trs.Data.read_sapsan_vag <- function(name) {
  # Агрегирует сырые данные
  # Args:
  #   name: имя базы с агрегированными данными
  mar=myPackage$trs.dann_load(name,'mar')  #чтение всех уже накопленных данных по маршрутам
  mar_pzd=unique(as.character(mar$Train));rm(mar) #список нужных поездов - для фильтра по новому
  
  srok='month';vid='vag'
  shema=myPackage$trs.shema_dannih();
  shema=shema[((shema$name==name)&(shema$srok==srok)&(shema$vid==vid)),]

  files=myPackage$trs.vibor_files_shema(shema) # подвыбор нужных по схеме
  files$Database=name;files$vid=vid;files$srok=srok;files$ext='0'
  
  first <- TRUE
  
  files$filePath <- paste(files$dir, files$File, sep = "")
  
  if(nrow(files)>0){  
  for (i in 1:nrow(files)){
    file=as.character(files[i,]$filePath);format=as.character(files[i,]$format);
    #for (file in files$filePath) {
    print(paste("Aggregating from \"", file, "\"...", sep = ""))
    matrix <- myPackage$trs.Data.text.load(file,format)  # ошибка
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
  }}
  
  info <- myPackage$trs.dann_load('info','rez')
  info <- info[(info$Database != name)|(info$vid!=vid), ]
  files$Time=as.character(Sys.time());
  info=myPackage$sliv(info,files);
  
  myPackage$trs.Data_save(info, 'info','rez',TRUE)
  
}









# Чтение вагонов, агрегация и запись в итог , исходя из - сперва вагоны, потом пассажиры. Непонятно значение поля Bad. +++
# изменяю - теперь это дочтение, по свойствам файла
myPackage$trs.Data.read_prig <- function(name) {
  
  first=TRUE
  srok='month';vid='prig'
  shema=myPackage$trs.shema_dannih();
  shema=shema[((shema$name==name)&(shema$srok==srok)&(shema$vid==vid)),]
  format=as.character(shema[,'format'])
  path=as.character(shema[,'dir']);
  #shema=as.character(shema[,'shema'])
  
  files=myPackage$trs.vibor_files_shema(shema) # подвыбор нужных по схеме
  if (nrow(files)>0) {
    files$Database=name;files$vid=vid;files$srok=srok;files$ext='0'}
  
  #исходно что уже было прочитано
  files=myPackage$trs.Data.readed(files)
  
  if (sum(files$read)>0){first=FALSE} #  были результаты - уже не записывать с нуля
  files=files[(files$read==0),]
  files$read=NULL
  
  if (nrow(files)>0) { 
    for (i in 1:nrow(files)){ # i=1
      
      ff=files[i,]; file=as.character(ff$File);format=as.character(ff$format);
      path=as.character(ff$dir);
      
      print(paste("Aggregating from \"", file, "\"...", sep = ""))
      filePath=paste(path, file, sep = "")
      
      matrix=myPackage$trs.Data.text.load(filePath,format) # чтение - исправлено
      kol_zap=nrow(matrix);print(paste('kol_zap',kol_zap,sep='='));
      matrix=myPackage$trs.Data.obrabot(matrix,format)   # приведение типов, сделано далее
      kol_rez=nrow(matrix)
      
      if (kol_rez>0){
        min_dat=min(as.Date(matrix$Date));max_dat=max(as.Date(matrix$Date));
        ff$min_date=as.character(min_dat)
        ff$max_date=as.character(max_dat)
      }
      
      #последние подчистки в базе
      tab_nom=ff$tab_nom
      ff$kol_zap=kol_zap
      ff$kol_rez=kol_rez
      ff$Time=as.character(Sys.time())
      
      matrix$tab_nom=tab_nom
      
      { #занесение информации в базу первично 
        info=myPackage$trs.dann_load('info','rez')
        ff$act=0;info=myPackage$sliv(info,ff);
        myPackage$trs.Data_save(info, 'info','rez',TRUE)
        
        #myPackage$trs.Data_save(mar, name,'mar',first);
        myPackage$trs.Data_save(matrix, name,'prig',first);
        first=FALSE
        print(paste("PRIG end: kol_zap=", kol_zap, " /kol_rez=", kol_rez, sep = ""))
        rm(matrix)
        
        #занесение информации в базу вторично - подтверждение
        info[(info$tab_nom==tab_nom)&(!is.na(info$tab_nom)),'act']=1
        myPackage$trs.Data_save(info, 'info','rez',TRUE)
      }
    }
  }
  
  ff=1;files=1;inf=1;info=1;info_=1;matrix=1;shema=1;file=1;filePath=1;format=1;
  i=1;kol_0=1;kol_1=1;kol_rez=1;kol_zap=1;max_dat=1;tab_nom=1;min_dat=1;o=1;path=1;
  srok=1;vid=1;
  
  rm(ff,files,inf,info,info_,matrix,shema,file,filePath,first,format,i,kol_0,kol_1)
  rm(kol_rez,kol_zap,max_dat,tab_nom,min_dat,name,o,path,srok,vid)
}

# пример запуска 
# name='prig'; # myPackage$trs.Data.read_prig(name)
















# сокращение данных о вагонах, до минимума +++
myPackage$trs.wData.aggr.mergeByType <- function(rawdb) {
  # Агрегатор, объединяющий данные о вместимости по типу мест
  rawdb$Seats=as.integer(as.character(rawdb$Seats))
  rawdb$Kol_vag=as.integer(as.character(rawdb$Kol_vag))
  rawdb$Rasst=as.integer(as.character(rawdb$Rasst))
  rawdb$Skp=as.integer(as.character(rawdb$Skp))
  rawdb$Seats_km=rawdb$Seats*rawdb$Rasst
  rawdb$Vag_km=rawdb$Kol_vag*rawdb$Rasst
  
  rawdb=rawdb[(rawdb$Rasst>0),] #избавление от ошибок
  # степень занятости вагона
  rawdb$zan=3
  rawdb[(rawdb$FreeSeats>rawdb$Seats/2),'zan']=2
  rawdb[(rawdb$FreeSeats>rawdb$Seats*3/4),'zan']=1
  rawdb[(rawdb$FreeSeats==rawdb$Seats),'zan']=0
  for (i in (0:3)){
    zn=paste('zan',i,sep='');rawdb[,zn]=0
    o=(rawdb$zan==i);rawdb[o,zn]=rawdb[o,'Kol_vag']
  }
  
  if (nrow(rawdb) == 0) {
    tmp <- data.frame(Seats = integer(0), Train = character(0),
                      Date = character(0), Type = character(0), Kol_vag = integer(0))
  } else {
    #    tmp <- aggregate(Seats ~ Train + Date + Type, data = rawdb, sum)  
    tmp=aggregate(x = subset(rawdb,select=c('Seats','Kol_vag','FreeSeats','Seats_km','Vag_km','zan0','zan1','zan2','zan3')), 
                  by = subset(rawdb,select=c('Train','Date','Type','Klass','Skp','Sto','Stn')), FUN = "sum")
    
    tmp_=aggregate(x = subset(rawdb,select=c('Seats')), 
                   by = subset(rawdb,select=c('Train','Date','Type','Klass','Skp','Sto','Stn')), FUN = "max")
    
    tmp_$max_seats=tmp_$Seats;tmp_$Seats=NULL
    tmp=merge(tmp,tmp_,by=c('Train','Date','Type','Klass','Skp','Sto','Stn'))
    
    
    tmp_=aggregate(x = subset(rawdb,select=c('Rasst')), 
                   by = subset(rawdb,select=c('Train','Date','Sto','Stn')), FUN = "max")
    #tmp_2=aggregate(x = subset(tmp_,select=c('Rasst')), 
    #                by = subset(tmp_,select=c('Train','Date')), FUN = "max")
    #tmp_=merge(tmp_,tmp_2,by=c('Train','Date','Rasst'))
    
    
    tmp=merge(tmp,tmp_,by=c('Train','Date','Sto','Stn'))
    
  }
  
  o=order(tmp$Date,tmp$Train,tmp$Type);tmp=tmp[o,]
  tmp=as.data.table(tmp)  # перенумерация строк до сквозной
  return(tmp)
  rm(tmp,o,rawdb,tmp_,i,zn)
}
#примр matrix=myPackage$trs.wData.aggr.mergeByType(matrix) # проверено - в процессе жрёт память!!!










# Чтение вагонов, агрегация и запись в итог , исходя из - сперва вагоны, потом пассажиры. Непонятно значение поля Bad. +++
# изменяю - теперь это дочтение, по свойствам файла
myPackage$trs.Data.read_vag <- function(name) {
  
  first=TRUE
  srok='month';vid='vag'
  shema=myPackage$trs.shema_dannih();
  shema=shema[((shema$name==name)&(shema$srok==srok)&(shema$vid==vid)),]
  format=as.character(shema[,'format'])
  path=as.character(shema[,'dir']);
  #shema=as.character(shema[,'shema'])
  
  files=myPackage$trs.vibor_files_shema(shema) # подвыбор нужных по схеме
  if (nrow(files)>0) {
    files$Database=name;files$vid=vid;files$srok=srok;files$ext='0'}
  
  #исходно что уже было прочитано
  files=myPackage$trs.Data.readed(files)
  
  if (sum(files$read)>0){first=FALSE} #  были результаты - уже не записывать с нуля
  files=files[(files$read==0),]
  files$read=NULL
  
  if (nrow(files)>0) { 
    for (i in 1:nrow(files)){ # i=1
      ff=files[i,]; file=as.character(ff$File);format=as.character(ff$format);
      path=as.character(ff$dir);
      #for (file in files$File) {
      print(paste("Aggregating from \"", file, "\"...", sep = ""))
      filePath=paste(path, file, sep = "")
      matrix=myPackage$trs.Data.text.load(filePath,format) # чтение - исправлено
      kol_zap=nrow(matrix)
      matrix=myPackage$trs.Data.obrabot(matrix,format)   # приведение типов, сделано далее
      #matrix = matrix[matrix$Train %in% mar_pzd, ]   
      #matrix=myPackage$trs.pass.filter(name, matrix) 
      matrix=myPackage$trs.pass.filter_vag(name, matrix) 
      
      matrix=matrix[(matrix$Seats!=0),];
      if(nrow(matrix)>0){
        #matrix$Vag=as.integer(matrix$Vag)
        matrix$Kol_vag=1
        matrix[(matrix$Vag==-1),'Kol_vag']=0
      }
      
      matrix=myPackage$trs.wData.aggr.mergeByType(matrix) # проверено - в процессе жрёт память!!!
      kol_rez=nrow(matrix)
      
      if (kol_rez>0){
        min_dat=min(as.Date(matrix$Date));max_dat=max(as.Date(matrix$Date));
        ff$min_date=as.character(min_dat)
        ff$max_date=as.character(max_dat)
      }
      
      #последние подчистки в базе
      tab_nom=ff$tab_nom
      ff$kol_zap=kol_zap
      ff$kol_rez=kol_rez
      ff$Time=as.character(Sys.time())
      
      matrix$tab_nom=tab_nom
      
      #запись в базу - СБОЙНУЛО
      { #занесение информации в базу первично 
        info=myPackage$trs.dann_load('info','rez')
        ff$act=0;info=myPackage$sliv(info,ff);
        myPackage$trs.Data_save(info, 'info','rez',TRUE)
        
        #myPackage$trs.Data_save(mar, name,'mar',first);
        myPackage$trs.Data_save(matrix, name,'vag',first);
        first=FALSE
        print(paste("Vag end: kol_zap=", kol_zap, " /kol_rez=", kol_rez, sep = ""))
        rm(matrix)
        
        #занесение информации в базу вторично - подтверждение
        info[(info$tab_nom==tab_nom)&(!is.na(info$tab_nom)),'act']=1
        myPackage$trs.Data_save(info, 'info','rez',TRUE)
      }
    }
  }
  
  ff=1;files=1;inf=1;info=1;info_=1;matrix=1;shema=1;file=1;filePath=1;format=1;
  i=1;kol_0=1;kol_1=1;kol_rez=1;kol_zap=1;max_dat=1;tab_nom=1;min_dat=1;o=1;path=1;
  srok=1;vid=1;
  
  rm(ff,files,inf,info,info_,matrix,shema,file,filePath,first,format,i,kol_0,kol_1)
  rm(kol_rez,kol_zap,max_dat,tab_nom,min_dat,name,o,path,srok,vid)
}

# пример запуска 
# name='sahalin'; # myPackage$trs.Data.read_vag(name)











# Чтение вагонов, агрегация и запись в итог , исходя из - сперва вагоны, потом пассажиры. Непонятно значение поля Bad. +++
# изменяю - теперь это дочтение, по свойствам файла
myPackage$trs.Data.read_vag_old <- function(name) {
  
  raspis=NULL;
  
  first=TRUE
  srok='month';vid='vag'
  shema=myPackage$trs.shema_dannih();
  shema=shema[((shema$name==name)&(shema$srok==srok)&(shema$vid==vid)),]
  format=as.character(shema[,'format'])
  path=as.character(shema[,'dir']);
  #shema=as.character(shema[,'shema'])
  
  files=myPackage$trs.vibor_files_shema(shema) # подвыбор нужных по схеме
  if (nrow(files)>0) {
    files$Database=name;files$vid=vid;files$srok=srok;files$ext='0'
    
    
    #исходно что уже было прочитано
    max_tab_nom=0
    info=myPackage$trs.dann_load('info','rez')
    if (!is.null(info)){
      if (is.null(info$size)){info$size=0;info$c_time=""}
      if (is.null(info$tab_nom)){info$tab_nom=0}
      max_tab_nom=max(max(info$tab_nom),nrow(info))
      o=((info$Database != name)|(info$vid!=vid))
      info_=info[o, ] #что нас не касается
      inf=info[(!o),] #что нам надо проверить
      
      #выявить, какие прочитаны и нормально
      ff=files[,c('File','c_time','size')]; #ff$iz=1
      kol_0=nrow(inf)
      inf=merge(inf,ff,by=c('File','c_time','size'))
      kol_1=nrow(inf); #  inf$iz=NULL;
      info=rbind(info_,inf)
      
      if (sum(inf$kol_rez)>0) {first=FALSE} # есть уже данные - новое дописывать, а не поверх
      
      if (kol_0>kol_1){ #если часть данных надо удалить и затем перечитать
        # прочитать
        mar=myPackage$trs.dann_load(name,'mar') 
        if (is.null(mar$tab_nom)){mar$tab_nom=0}
        matrix=myPackage$trs.dann_load(name,'vag') 
        if (is.null(matrix$tab_nom)){matrix$tab_nom=0}
        #взять расписания, на будущее
        raspis=mar[((!is.na(mar$Tm_otp))|(!is.na(mar$Tm_prib))),c('Date','Train','Tm_otp','Tm_prib')]
        #уменьшить
        mar=mar[(mar$tab_nom %in% inf$tab_nom),]
        matrix=matrix[(matrix$tab_nom %in% inf$tab_nom),]
        #обратно записать после уменьшения
        myPackage$trs.Data_save(mar,name,'mar',TRUE);
        myPackage$trs.Data_save(matrix, name,'vag',TRUE);
        rm(mar,matrix)
        myPackage$trs.Data_save(info, 'info','rez',TRUE)
      }
      
      #убрать из прочтения уже прочитанное
      files=files[(!(files$File %in% inf$File)),]
    }
  }   
  
  
  if (nrow(files)>0) { 
    for (i in 1:nrow(files)){ # i=1
      ff=files[i,]; file=as.character(ff$File);format=as.character(ff$format);
      path=as.character(ff$dir);
      #for (file in files$File) {
      print(paste("Aggregating from \"", file, "\"...", sep = ""))
      filePath=paste(path, file, sep = "")
      matrix=myPackage$trs.Data.text.load(filePath,format) # чтение - исправлено
      matrix=myPackage$trs.Data.obrabot(matrix,format)   #необязательно - только приведение типов, сделано далее
      #matrix = matrix[matrix$Train %in% mar_pzd, ]   
      #matrix=myPackage$trs.pass.filter(name, matrix) 
      matrix=myPackage$trs.pass.filter_vag(name, matrix) 
      matrix=matrix[(matrix$Seats!=0),];
      kol_zap=nrow(matrix)
      if(nrow(matrix)>0){matrix$Kol_vag =1}
      matrix=myPackage$trs.wData.aggr.mergeByType(matrix) # проверено - в процессе жрёт память!!!
      kol_rez=nrow(matrix)
      
      if (kol_rez>0){
        min_dat=min(as.Date(matrix$Date));max_dat=max(as.Date(matrix$Date));
        files[(files$File==file),'min_date']=as.character(min_dat)
        files[(files$File==file),'max_date']=as.character(max_dat)
      }
      
      #последние подчистки в базе
      max_tab_nom=max_tab_nom+1
      files[(files$File==file),'kol_zap']=kol_zap
      files[(files$File==file),'kol_rez']=kol_rez
      files[(files$File==file),'tab_nom']=max_tab_nom
      files[(files$File==file),'Time']=as.character(Sys.time())
      mar=unique(subset(matrix,select=c('Date','Train','bad','Rasst','Sto','Stn')))
      mar$Date=as.character(mar$Date)
      
      #ввести расписания обратно
      if (!is.null(raspis)){
        mar=merge(mar,raspis,by=c('Date','Train'),all=TRUE)
        mar=mar[(!is.na(mar$Rasst)),]}
      if (is.null(mar$Tm_otp)){mar$Tm_otp=NA;mar$Tm_prib=NA} ## наверно убрать добавление полей
      
      mar$tab_nom=max_tab_nom
      matrix$tab_nom=max_tab_nom
      
      #запись в базу - СБОЙНУЛО
      myPackage$trs.Data_save(mar, name,'mar',first);
      myPackage$trs.Data_save(matrix, name,'vag',first);
      first=FALSE
      print(paste("Vag end: kol_zap=", kol_zap, " /kol_rez=", kol_rez, sep = ""))
      rm(mar,matrix)
    }
    
    #занесение информации в базу
    info=myPackage$sliv(info,files);
    
    myPackage$trs.Data_save(info, 'info','rez',TRUE)
  }
  
  
  ff=1;files=1;inf=1;info=1;info_=1;mar=1;matrix=1;shema=1;file=1;filePath=1;format=1;
  i=1;kol_0=1;kol_1=1;kol_rez=1;kol_zap=1;max_dat=1;max_tab_nom=1;min_dat=1;o=1;path=1;
  srok=1;vid=1;
  
  
  rm(ff,files,inf,info,info_,mar,matrix,shema,file,filePath,first,format,i,kol_0,kol_1)
  rm(kol_rez,kol_zap,max_dat,max_tab_nom,min_dat,name,o,path,srok,vid,raspis)
}

# пример запуска 
# name='sahalin'; # myPackage$trs.Data.read_vag(name)






#исходно что уже было прочитано - вычеркнуть. изменённое - удалить старую версию
myPackage$trs.Data.readed <- function(files) {
  #исходно что уже было прочитано
  max_tab_nom=0
  info=myPackage$trs.dann_load('info','rez')
  
  info=info[(!is.na(info$act)),] #подчистка случайных выбросов
  if (!is.null(info)){
    if (is.null(info$size)){info$size=0;info$c_time=""}
    if (is.null(info$tab_nom)){info$tab_nom=0}
    
    max_tab_nom=max(info[(!is.na(info$tab_nom)),'tab_nom'])
    
    o=((info$Database %in% files$Database)&(info$format %in% files$format))
    info_=info[(!o), ] #что нас не касается
    inf=info[(o),] #что нам надо проверить
    
    #выявить, какие прочитаны и нормально
    ff=unique(files[,c('File','c_time','size')]);ff$k=1;
    
    if (nrow(inf)>0){
      inf$inf=1
      inf=merge(inf,ff,by=c('File','c_time','size'),all=TRUE)
      inf=inf[(!is.na(inf$inf)),];inf$inf=NULL
      o=((is.na(inf$k))|(inf$act==0))
      inf_bad=inf[o,];inf=inf[(!o),];inf$k=NULL
      info=rbind(info_,inf)
    }else{inf_bad=inf}
    
    
    if (nrow(inf_bad)>0){ #если часть данных надо удалить и затем перечитать
      matrix=NULL;#print('подчистка неправильного');
      print('Podchistka nepravilnogo');
      vidi=as.character(unique(inf_bad$vid))
      name=unique(as.character(inf_bad$Database))
      for (vid in vidi){
        matrix=myPackage$trs.dann_load(name,vid)  # прочитать
        if (!is.null(matrix)){
          if (is.null(matrix$tab_nom)){matrix$tab_nom=0}     # если нет поля
          matrix=matrix[(matrix$tab_nom %in% inf$tab_nom),]  # уменьшить
          myPackage$trs.Data_save(matrix, name,vid,TRUE);  # обратно записать после уменьшения
        }
        if (vid=='vag'){ #по вагонам - удалить и маршруты
          vid='mar';matrix=NULL
          matrix=myPackage$trs.dann_load(name,vid)  # прочитать
          if (!is.null(matrix)){
            if (is.null(matrix$tab_nom)){matrix$tab_nom=0}     # если нет поля
            matrix=matrix[(matrix$tab_nom %in% inf$tab_nom),]  # уменьшить
            myPackage$trs.Data_save(matrix, name,vid,TRUE);  # обратно записать после уменьшения
          }
        }
        rm(matrix)
      }
      myPackage$trs.Data_save(info, 'info','rez',TRUE)
      #print('подчистка неправильного закончена')
      print('Podchistka nepravilnogo zakonchena');
    }
    
    #if (sum(inf$kol_rez)>0){first=FALSE} #  были результаты - уже не записывать с нуля
    
    #уже прочитанное - оставить но с признаком - надо знать что имеются хоть какие-то данные
    files$read=0;
    files[((files$File %in% inf$File)),'read']=1
    #files=files[(!(files$File %in% inf$File)),]
    files$tab_nom=0;
    o=order(files$File);files=files[o,]
    
    if (nrow(files)>0){
      files$i=(1:nrow(files))
      for (i in (files$i)){  # i=2
        if (files[(files$i==i),'read']==0){
          max_tab_nom=max_tab_nom+1
          files[(files$i==i),'tab_nom']=max_tab_nom}
      }
    }
    files$i=NULL
    
  } else{
    files$read=0
    files$tab_nom=(1:nrow(files))
  }
  return (files)
  vid=1;vidi=1;inf_bad=1;name=1
  rm(files,max_tab_nom,info,info_,i,o,ff,vid,vidi,inf_bad,inf,name)
}
#пример   files=myPackage$trs.Data.readed(files)








#СБОР И АГРЕГАЦИЯ ИСХОДНЫХ ДАННЫХ по билетам, исходя из первичных - вагонов, в вагоны приписка времени отпр/приб +++
myPackage$trs.Data.read_pas <- function(name) {
  # Агрегирует сырые данные
  # Args:
  #   name: имя базы с агрегированными данными
  
  first=TRUE; 
  srok='month';vid='pas'
  shema=myPackage$trs.shema_dannih();
  shema=shema[((shema$name==name)&(shema$srok==srok)&(shema$vid==vid)),]
  
  files=myPackage$trs.vibor_files_shema(shema) # подвыбор нужных по схеме
  files$Database=name;files$vid=vid;files$srok=srok;files$ext='0'
  
  #исходно что уже было прочитано
  files=myPackage$trs.Data.readed(files)
  
  if (sum(files$read)>0){first=FALSE} #  были результаты - уже не записывать с нуля
  files=files[(files$read==0),]
  files$read=NULL
  
  sum_mar=0 
  if (('day' %in% files$format)|('month' %in% files$format)) {
    #первичные данные по маршрутам - если вообще нужны
    #mar=myPackage$trs.dann_load(name,'mar')  #чтение всех уже накопленных данных по маршрутам, с базы
    mar=myPackage$trs.dann_load(name,'vag')
    marb=NULL
    if (!is.null(mar)){
      if (is.null(mar$bad)){mar$bad=0}
      
      mar$Date=as.Date(as.character(mar$Date));mar$rst=mar$Rasst;
      marb=unique(mar[,c('Date','Train','rst','Sto','Stn')])
      
      mm=aggregate(x=subset(marb,select=c('rst')),
                   by=subset(marb,select=c('Date','Train')),FUN="max" ) 
      marb=merge(marb,mm,by=c('Date','Train','rst'));rm(mm)
      mar$rst=NULL
      marb$Ssto=abs(marb$Sto);marb$Sstn=abs(marb$Stn);marb$Sto=NULL;marb$Stn=NULL;
      marb=as.data.table(marb)
      marb=unique(marb)
    }
  }
  
  
  # перебор всех новых файлов данных  ##############################  i=1
  if (nrow(files)>0){ for (i in 1:nrow(files)){ 
    ff=files[i,]
    file=as.character(ff$File)
    format=as.character(ff$format)
    path=as.character(ff$dir)
    tab_nom=as.numeric(ff$tab_nom)
    
    print(paste("Aggregating from \"", file, "\"...", sep = ""))
    filePath=paste(path, file, sep = "")
    matrix=myPackage$trs.Data.text.load(filePath,format); # готово
    
    mmm=matrix[(matrix$Train==''),] # для диапазонов дат
    matrix=matrix[(matrix$Train!=''),] # без добавочной записи
    
    kol_zap=nrow(matrix);
    matrix=myPackage$trs.Data.obrabot(matrix,format)  # готово
    if (!is.null(matrix$Lgot)){matrix=matrix[(matrix$Lgot!='B'),]}
    kol_rez=0;kol_mar=0
    
    if (format %in% c('day','month')){
      if (kol_zap>0){
        matrix$zn=1;
        if (nrow(matrix[(matrix$Kol_pas<0),])>0){
          matrix[(matrix$Kol_pas<0),'zn']=-1  }
        matrix$s_cena=matrix$Cena*matrix$Kol_pas*matrix$zn # добавил исходную цену билета, по проданному участку маршрута
        
        #далее фильтрация нужных, но сперва правильную дату начала движения
        matrix$Before=matrix$Before_p;matrix$Date=matrix$Date_p;
        matrix$Before_p=NULL;matrix$Date_p=NULL;
        matrix=as.data.table(matrix)  # перенумерация строк до сквозной
        
        if (!is.null(marb)) {
          
          if (max(nchar(matrix$Train))==5)  { #если старые данные, без нитки поезда
            marb_=marb
            marb_$tr=as.character(marb_$Train)
            marb_$Train=substr(marb_$Train,1,5)
            mb=aggregate(x=subset(marb_,select=c('tr')),
                         by=subset(marb_,select=c('Date','Train')),FUN="max" )  
            marb_=merge(marb_,mb,by=c('Date','Train','tr'))
            
            matrix=merge(matrix,marb_,by=c('Date','Train'))
            
            matrix$Train=matrix$tr;matrix$tr=NULL
            rm(marb_,mb)
          }else {matrix=merge(matrix,marb,by=c('Date','Train'))}
        }
        
        #далее - убрать цены (нижние) для немаксимальных маршрутов  
        # bad=1 - билет не на полный маршрут 
        matrix$bad=0;matrix[(matrix$Rasst!=matrix$rst),'bad']=1;
        matrix$rst=NULL
        matrix[(matrix$bad==1),c('Cena')]=NA; #было c('Tm_otp','Tm_prib','Cena')
        matrix$bad=NULL
        matrix[(matrix$Z_prib==-1),c('Tm_otp','Tm_prib')]=NA;
        matrix[(matrix$Kol_pas<0),'Cena']=NA;#все возвраты - вне цены
        vcd_rus=c('Е','Г','G','И','Й','М','Н','О','Я','С','Т','У','Ж','В','Ы','9','Э','Щ','Ч','I')
        matrix[(!(matrix$vcd %in% vcd_rus)),'Cena']=NA #продажи вне России - вне цены
        # matrix[(matrix$Lgot!='0'),'Cena']=NA;#все льготные - вне цены - отменил
      }  
      mm=myPackage$trs.pass_agregator(matrix); 
      matrix=mm$pass;matrix_mar=mm$mar;
      kol_mar=nrow(matrix_mar)
    }
    
    
    if (format=='min_dann') {
      matrix=aggregate(x=subset(matrix,select=c('Kol_pas','Plata','Cena','Pkm')),
                       by=subset(matrix,select=c('Date','Train','Klass','Type','Skp')),
                       FUN="sum" )  # убрал ,'z_week'
      matrix=matrix[(!((matrix$Kol_pas==0)&(matrix$Plata==0)&(matrix$Cena==0)&(matrix$Pkm==0))),]
    }
    
    kol_rez=nrow(matrix);
    ff$kol_zap=kol_zap
    ff$kol_rez=kol_rez
    ff$kol_mar=kol_mar
    ff$Time=as.character(Sys.time()); # системное время
    
    if (kol_rez>0){ #было (kol_zap>0)
      matrix$tab_nom=tab_nom
      if (kol_mar>0){
        min_dat=min(matrix_mar$Date);max_dat=max(matrix_mar$Date);
      }else{
        min_dat=min(matrix$Date);max_dat=max(matrix$Date);
      }
      if (nrow(mmm)>0){ 
        mmm$Date=as.Date(as.character(mmm$Date))
        max_dat=min(max_dat,mmm$Date)
        if ('z_week' %in% names(mmm)){
          mmm$z_week=as.numeric(as.character(mmm$z_week))
          min_dat=max(min_dat,mmm$Date-mmm$z_week)
        } 
      }
      ff$min_date=as.character(min_dat)
      ff$max_date=as.character(max_dat)
    }
    
    # запись итогов первично
    info=myPackage$trs.dann_load('info','rez')
    ff$act=0;info=myPackage$sliv(info,ff);
    myPackage$trs.Data_save(info, 'info','rez',TRUE)
    if (kol_rez>0){
      myPackage$trs.Data_save(matrix, name,'pas',first);first=FALSE #запись на диск
    }
    
    # приписка времён отправления-прибытия
    if (kol_mar>0){
      sum_mar=sum_mar+kol_mar
      mar=merge(mar,matrix_mar,by=c('Date','Train'),all=TRUE) #удалил ,'Rasst','Sto','Stn'
      mar[(!is.na(mar$tmo)),'Tm_otp']=mar[(!is.na(mar$tmo)),'tmo']
      mar[(!is.na(mar$tmp)),'Tm_prib']=mar[(!is.na(mar$tmp)),'tmp']
      mar$tmo=NULL;mar$tmp=NULL;}
    print(paste("Vhod=",kol_zap," / Itog=",kol_rez," zapisei"))
    
    # запись итогов окончательно
    info[(info$tab_nom==tab_nom)&(!is.na(info$tab_nom)),'act']=1
    myPackage$trs.Data_save(info, 'info','rez',TRUE)
  }
    gc()
  }#конец цикла
  
  #if (sum_mar>0){ #окончательно записать, если был хоть 1 новый файл
  #  myPackage$trs.Data_save(mar, name,'mar',first=TRUE)}
  
  
  ff=1;inf=1;info_=1;mar=1;marb=1;matrix=1;matrix_mar=1;file=1;filePath=1;
  format=1;i=1;kol_0=1;kol_1=1;kol_mar=1;kol_rez=1;kol_zap=1;max_dat=1;
  min_dat=1;mm=1;o=1;path=1;vcd_rus=1;info=1;tab_nom=1;mmm=1;
  
  rm(ff,files,inf,info,info_,mar,marb,matrix,matrix_mar,shema,file,filePath,first,format)
  rm(i,kol_0,kol_1,kol_mar,kol_rez,kol_zap,max_dat,tab_nom,min_dat,mm,name,o,path)
  rm(srok,vcd_rus,vid,sum_mar,mmm)
}
#пример запуска  name='sahalin'; # myPackage$trs.Data.read_pas(name)













#СБОР И АГРЕГАЦИЯ ИСХОДНЫХ ДАННЫХ по билетам, исходя из первичных - вагонов, в вагоны приписка времени отпр/приб +++
myPackage$trs.Data.read_st_pas <- function(name) {
  # Агрегирует сырые данные
  # Args:
  #   name: имя базы с агрегированными данными
  
  first=TRUE; 
  srok='month';
  shema=myPackage$trs.shema_dannih();
  shema=shema[((shema$name==name)&(shema$srok==srok)),]
  vid=as.character(shema$vid)
  
  files=myPackage$trs.vibor_files_shema(shema) # подвыбор нужных по схеме
  files$Database=name;files$vid=vid;files$srok=srok;files$ext='0'
  
  
  #исходно что уже было прочитано
  files=myPackage$trs.Data.readed(files)
  
  if (sum(files$read)>0){first=FALSE} #  были результаты - уже не записывать с нуля
  files=files[(files$read==0),]
  files$read=NULL
  
  
  # перебор всех новых файлов данных  ##############################  i=1
  if (nrow(files)>0){ for (i in 1:nrow(files)){
    ff=files[i,]
    file=as.character(ff$File)
    format=as.character(ff$format)
    path=as.character(ff$dir)
    tab_nom=as.numeric(ff$tab_nom)
    
    print(paste("Aggregating from \"", file, "\"...", sep = ""))
    filePath=paste(path, file, sep = "")
    matrix=myPackage$trs.Data.text.load(filePath,format); # готово
    kol_zap=nrow(matrix);
    matrix=myPackage$trs.Data.obrabot(matrix,format)  # готово
    if (!is.null(matrix$Lgot)){matrix=matrix[(matrix$Lgot!='B'),]}
    kol_rez=0
    
    
    
    
    kol_rez=nrow(matrix);
    ff$kol_zap=kol_zap
    ff$kol_rez=kol_rez
    ff$Time=as.character(Sys.time()); # системное время
    
    if (kol_rez>0){ #было (kol_zap>0)
      matrix$tab_nom=tab_nom
      min_dat=min(as.character(matrix$Date));max_dat=max(as.character(matrix$Date));
      
      ff$min_date=as.character(min_dat)
      ff$max_date=as.character(max_dat)
      myPackage$trs.Data_save(matrix, name,'st_pas',first);first=FALSE #запись на диск
    }
    
    
    print(paste("Vhod=",kol_zap," / Itog=",kol_rez," zapisei"))
    
    # запись итогов
    info=myPackage$trs.dann_load('info','rez')
    info=myPackage$sliv(info,ff);
    myPackage$trs.Data_save(info, 'info','rez',TRUE)
  }}#конец цикла
  
  
  ff=1;files=1;matrix=1;shema=1;file=1;filePath=1;first=1;format=1;i=1;kol_rez=1;
  kol_zap=1;max_dat=1;min_dat=1;name=1;path=1;srok=1;tab_nom=1;vid=1;mm=1
  
  rm(ff,files,matrix,shema,file,filePath,first,format,i,kol_rez,kol_zap,max_dat,min_dat)
  rm(name,path,srok,tab_nom,vid,mm)
}
#пример запуска  name='stat_doss'; # myPackage$trs.Data.read_st_pas(name)










#СБОР И АГРЕГАЦИЯ ИСХОДНЫХ ДАННЫХ по билетам, исходя из первичных - вагонов, в вагоны приписка времени отпр/приб +++
myPackage$trs.Data.read_rasp <- function(name) {
  # Агрегирует сырые данные
  # Args:
  #   name: имя базы с агрегированными данными
  
  print('Chtenie raspisanii')
  
  first=TRUE; 
  srok='month';vid='rasp'
  shema=myPackage$trs.shema_dannih();
  shema=shema[((shema$name==name)&(shema$srok==srok)&(shema$vid==vid)),]
  
  files=myPackage$trs.vibor_files_shema(shema) # подвыбор нужных по схеме
  files$Database=name;files$vid=vid;files$srok=srok;files$ext='0'
  
  #исходно что уже было прочитано
  files=myPackage$trs.Data.readed(files)
  
  if (sum(files$read)>0){first=FALSE} #  были результаты - уже не записывать с нуля
  files=files[(files$read==0),]
  files$read=NULL
  
  # перебор всех новых файлов данных  ##############################  i=1
  if (nrow(files)>0){
    
    rasp3=myPackage$trs.dann_load(name,'rasp3')
    if (!is.null(rasp3)){ # по маршрутам rasp3 создать их хэши rasp4
      
      o=order(rasp3$has2,rasp3$Rasst);rasp3=rasp3[o,];rm(o)
      
      rr_ <-sapply(FUN = function(part) {
        has2=part$has2[1];
        s=paste(part$Stan,part$Rasst,part$dp,part$do,sep='')
        hass=digest(s)
        l <- c(has2=has2,hass=hass )        
        return (l)
      }, X = split(rasp3, paste(rasp3$has2)))
      
      rr_ <- t(rr_)  #??? просто транспонирование
      rr_ <- data.frame(rr_, stringsAsFactors = FALSE)
      rr_$has2=as.numeric(rr_$has2)
      rasp4=rr_;rm(rr_)
    }
    
    for (i in 1:nrow(files)){  ##############  i=1
      ff=files[i,]
      file=as.character(ff$File)
      format=as.character(ff$format)
      path=as.character(ff$dir)
      tab_nom=as.numeric(ff$tab_nom)
      
      print(paste("Aggregating from \"", file, "\"...", sep = ""))
      filePath=paste(path, file, sep = "")
      matrix=myPackage$trs.Data.text.load(filePath,format); # готово
      kol_zap=nrow(matrix);
      matrix=myPackage$trs.Data.obrabot(matrix,format)  # готово
      
      kol_rez=0;
      # matrix$Kol_pas=as.numeric(matrix$Kol_pas);
      matr1=matrix[(!is.na(matrix$Rasst)),]
      matr1$Date=NULL;matr1$Train=NULL;matr1$nit=NULL;
      matr1$tab_nom=tab_nom
      matr2=matrix[(is.na(matrix$Rasst)),c('has','Date','Train')]
      matr2$tab_nom=tab_nom
      matr1=as.data.frame(as.data.table(matr1))
      matr2=as.data.frame(as.data.table(matr2))
      
      kol_rez=nrow(matr1);kol_rez2=nrow(matr2);
      
      {##  вставка создания rasp3
        rr=matr1;rr$vrmp=NULL;rr$vrmo=NULL
        o=order(rr$tab_nom,rr$has,rr$Rasst);rr=rr[o,];rm(o)
        
        rr_ <-sapply(FUN = function(part) {
          tab_nom=part$tab_nom[1];has=part$has[1]
          s=paste(part$Stan,part$Rasst,part$dp,part$do,sep='')
          hass=digest(s)
          l <- c(tab_nom=tab_nom,has=has,hass=hass )        
          return (l)
        }, X = split(rr, paste(rr$tab_nom,rr$has)))
        
        rr_ <- t(rr_)  #??? просто транспонирование
        rr_ <- data.frame(rr_, stringsAsFactors = FALSE)
        rr_$has=as.numeric(rr_$has)
        hass=unique(rr_$hass);hass=as.data.frame(hass)
        
        if (is.null(rasp3)){
          hass$has2=(1:nrow(hass))
          rr_=merge(rr_,hass,by='hass')
          rasp4=hass
          
          rr_$hass=NULL
          rr=merge(rr,rr_,by=c('tab_nom','has'))
          matr1=merge(matr1,rr_,by=c('tab_nom','has'))
          matr2=merge(matr2,rr_,by=c('tab_nom','has'))
          
          rasp3=matr1
          rasp3$tab_nom=NULL;rasp3$has=NULL;rasp3$vrmo=NULL;rasp3$vrmp=NULL
          rasp3=unique(rasp3)
        }else{
          hass=merge(hass,rasp4,by='hass',all=TRUE)
          has2=max(rasp4$has2)
          hass=hass[(is.na(hass$has2)),]
          if (nrow(hass)>0){
            hass$has2=has2+(1:nrow(hass))
            rasp4=rbind(rasp4,hass)}
          
          rr_=merge(rr_,rasp4,by='hass');rr_$hass=NULL
          matr1=merge(matr1,rr_,by=c('tab_nom','has'))
          matr2=merge(matr2,rr_,by=c('tab_nom','has'))
          
          rr=matr1;rr$tab_nom=NULL;rr$has=NULL;rr$vrmo=NULL;rr$vrmp=NULL
          rr=rr[(rr$has2>has2),];rr=unique(rr)
          rasp3=rbind(rasp3,rr)
        }
      }
      
      ff$kol_zap=kol_zap;ff$kol_rez=kol_rez;ff$act=0
      ff$Time=as.character(Sys.time()); # системное время
      
      ff_=ff;ff$vid='rasp1'
      ff_$vid='rasp2';ff_$kol_rez=kol_rez2
      ff=rbind(ff,ff_)
      
      if (kol_rez>0){
        min_dat=min(matr2$Date);max_dat=max(matr2$Date);
        ff$min_date=as.character(min_dat)
        ff$max_date=as.character(max_dat)
        
        info=myPackage$trs.dann_load('info','rez')
        info=myPackage$sliv(info,ff);
        myPackage$trs.Data_save(info, 'info','rez',TRUE) #запись на диск предварительная
        
        myPackage$trs.Data_save(matr1, name,'rasp1',first);#запись на диск
        myPackage$trs.Data_save(matr2, name,'rasp2',first);#запись на диск
        
        myPackage$trs.Data_save(rasp3, name,'rasp3',TRUE);#запись на диск
        
        first=FALSE 
        rm(matr1,matr2)
      }
      
      # приписка времён отправления-прибытия
      print(paste("Vhod=",kol_zap," / Itog=",kol_rez,'-',kol_rez2," zapisei",sep=' '))
      
      # запись итогов
      info=myPackage$trs.dann_load('info','rez')
      info=info[(!((info$act==0)&(info$File %in% ff$File))),]
      ff$act=1;info=myPackage$sliv(info,ff);
      myPackage$trs.Data_save(info, 'info','rez',TRUE)
    }}#конец цикла
  
  
  ff=1;inf=1;info_=1;mar=1;marb=1;matrix=1;matrix_mar=1;file=1;filePath=1;
  format=1;i=1;kol_0=1;kol_1=1;kol_mar=1;kol_rez=1;kol_zap=1;max_dat=1;
  min_dat=1;mm=1;o=1;path=1;vcd_rus=1;info=1;tab_nom=1;kol_rez2=1
  ff_=1;hass=1;rasp3=1;rasp4=1;rr=1;rr_=1;has2=1
  
  rm(ff,files,inf,info,info_,mar,marb,matrix,matrix_mar,shema,file,filePath,first,format)
  rm(i,kol_0,kol_1,kol_mar,kol_rez,kol_zap,max_dat,tab_nom,min_dat,mm,name,o,path,kol_rez2)
  rm(srok,vcd_rus,vid,ff_,has2,hass,rasp3,rasp4,rr,rr_)
}
#пример запуска  name='dann'; # myPackage$trs.Data.read_rasp(name)










#выбор нужных расписаний из полного списка, исходя из данных о вагонах
myPackage$trs.Data.dobavl_rasp <- function(name) {
  
  if (name!='dann') { # кто угодно кроме dann
    {# выяснить надо ли пересчитывать
      info=myPackage$trs.dann_load('info','rez') 
      info$c_time=as.character(info$c_time)
      
      inf=info[((info$Database=='dann')&(info$format=='rasp'))|
                 ((info$Database==name)&(info$vid=='vag')),]
      
      
      inf1=aggregate(x=subset(inf,select=c('kol_rez')),
                     by=subset(inf,select=c('vid')), FUN="sum" )
      inf2=aggregate(x=subset(inf,select=c('c_time')),
                     by=subset(inf,select=c('vid')), FUN="max" )
      
      inf=merge(inf1,inf2,by='vid');rm(inf1,inf2)
      inf$File=inf$vid
      inf$Database=name;inf$vid='rasp'
      
      inf_p=info[((info$Database==name)&(info$vid=='rasp')),] #с чем сверять
      
      inf_p=merge(inf_p,inf,by=c("vid","kol_rez","c_time","File","Database"))
    }
    if ((nrow(inf_p)<3)&(nrow(inf)==3)) {
      # Менялось - значит перечитывать всё.
      
      vag=myPackage$trs.dann_load(name,'vag')
      
      rasp1=myPackage$trs.dann_load('dann','rasp1')
      rasp2=myPackage$trs.dann_load('dann','rasp2')
      rasp2$has2=NULL;rasp1$has2=NULL;
      
      train=unique(as.character(vag$Train))
      
      rr2=rasp2[(rasp2$Train %in% train),]
      
      pzd=unique(vag[,c('Date','Train')])
      pzd=merge(pzd,rr2,by=c('Date','Train'));rm(rr2)
      
      has=unique(pzd[,c('tab_nom','has')])
      
      {#выбрать конечные станции - в sts могут быть промежуточные случайно
        o=order(rasp1$tab_nom,rasp1$has);rasp1=rasp1[o,]
        o=order(has$tab_nom,has$has);has=has[o,]
        rs1=merge(has,rasp1,by=c('tab_nom','has'))
        rs1=rs1[,c('tab_nom','has','Rasst','Stan')]
        rs=aggregate(x=subset(rs1,select=c('Rasst')),
                     by=subset(rs1,select=c('tab_nom','has')), FUN="max" )
        rs1_=merge(rs1,rs,by=c('tab_nom','has','Rasst'))
        rs1$Sto=rs1$Stan;rs1_$Stn=rs1_$Stan;
        sts=rs1[(rs1$Rasst==0),];sts$Rasst=NULL
        sts=merge(sts,rs1_,by=c('tab_nom','has'))
        sts=unique(sts[,c('Sto','Stn','Rasst')])
        sts=aggregate(x=subset(sts,select=c('Rasst')),
                      by=subset(sts,select=c('Sto','Stn')), FUN="max" )
        rm(rs1,rs1_)
      }
      
      
      
      {# их же - занумеровать, и в ином виде
        sts$st1=pmin(sts$Sto,sts$Stn)
        sts$st2=pmax(sts$Sto,sts$Stn)
        sts=aggregate(x=subset(sts,select=c('Rasst')),
                      by=subset(sts,select=c('st1','st2')), FUN="max" )
        #sts=unique(sts[,c('st1','st2','Rasst')])
        sts$n=(1:nrow(sts))
        sts_=sts;sts_$st1=sts_$st2
        sts$kol=1;sts_$kol=-1
        sts=rbind(sts,sts_)
        sts$Stan=sts$st1
        sts$rst=sts$Rasst
        sts$st1=NULL;sts$st2=NULL;sts$Rasst=NULL;rm(sts_)}
      
      
      {# все поезда, проходящие через нужные станции
        rs1=rasp1[(rasp1$Stan %in% sts$Stan),]
        rs1=merge(rs1,sts,by='Stan');rs1$kk=1
        rs1$kr=rs1$kol*rs1$Rasst
        
        rs1=aggregate(x=subset(rs1,select=c('kol','kk','kr','rst')),
                      by=subset(rs1,select=c('tab_nom','has','n')), FUN="sum" )
        rs1=rs1[(rs1$kol==0)&(rs1$kk==2),]
        
        rs1$napr=-1;rs1[(rs1$kr<0),'napr']=1
        rs1=unique(rs1[,c('tab_nom','has','n','napr','rst')])
        rs1$rst=rs1$rst/2
        
        #каждый маршрут - приписать только максимальному варианту
        rs=aggregate(x=subset(rs1,select=c('rst')),
                     by=subset(rs1,select=c('tab_nom','has')), FUN="max" )
        rs1=merge(rs1,rs,by=c('tab_nom','has','rst'))
        rm(rs)
      }
      
      {#вычислить isp на каждый has
        has$isp=1
        has=merge(has,rs1,by=c('tab_nom','has'),all='TRUE')
        has[(is.na(has$isp)),'isp']=0
        rm(rs1)}
      
      {# дописать станцию отпр и назн
        sts$rst=NULL
        sts$napr=1;sts1=sts;sts1$napr=-1;sts=rbind(sts,sts1)
        sts$kol=sts$kol*sts$napr
        sts1=sts[(sts$kol==1),];sts1$Sto=sts1$Stan;sts1$Stan=NULL;sts1$kol=NULL
        sts2=sts[(sts$kol==-1),];sts2$Stn=sts2$Stan;sts2$Stan=NULL;sts2$kol=NULL
        sts=merge(sts1,sts2,by=c('n','napr'))
        has=merge(has,sts,,by=c('n','napr'))
        rm(sts1,sts2)
      }
      
      {#взять старые номера поездов-направлений - если есть
        pz=myPackage$trs.dann_load(name,'pzd')
        if (!is.null(pz)){
          pz=unique(pz[(pz$isp==1),c('tab_nom','has','pzd')])
          has=merge(has,pz,by=c('tab_nom','has'),all=TRUE)
        }else{has$pzd=NA}
        has=has[(!is.na(has$rst)),] #убрал NA записи, возможно это ещё не всё
      }
      
      
      {#распространить номера поездов
        pz=unique(has[,c('n','pzd')]);pz$k=1
        pz_=unique(pz[,c('n','k')])
        pz=pz[(!is.na(pz$pzd)),];
        if (nrow(pz)==0){mpz=0}else{mpz=max(pz$pzd)}
        pz=merge(pz,pz_,by=c('n','k'),all=TRUE)
        pz_=pz[(is.na(pz$pzd)),];
        if (nrow(pz_)>0){
          pz_$pzd=mpz+(1:nrow(pz_))
        }
        pz=rbind(pz,pz_)
        pz=pz[(!is.na(pz$pzd)),];pz$k=NULL
        rm(pz_,mpz)
        has$pzd=NULL
        has=merge(has,pz,by='n')
        has=has[,c('tab_nom','has','pzd','napr','isp','Sto','Stn')]
      }
      
      {#записать номера
        myPackage$trs.Data_save(has, name,'pzd',TRUE)
        has=has[,c('tab_nom','has')]
        rr1=merge(rasp1,has,by=c('tab_nom','has'))
        rr2=merge(rasp2,has,by=c('tab_nom','has'))  
        
        # записи в память расписаний
        myPackage$trs.Data_save(rr1, name,'rasp1',TRUE)
        myPackage$trs.Data_save(rr2, name,'rasp2',TRUE)
      }
      
      # запись итогов
      info=info[(!((info$Database==name)&(info$vid=='rasp'))),] #с чем сверять
      info=myPackage$sliv(info,inf)
      myPackage$trs.Data_save(info, 'info','rez',TRUE)
    }
  }
  
  has=1;pzd=1;rasp1=1;rasp2=1;rr1=1;rr2=1;sts=1;vag=1;name=1;train=1;
  inf=1;inf_p=1;info=1;pz=1;o=1;
  
  rm(has,pzd,rasp1,rasp2,rr1,rr2,sts,vag,name,train,inf,inf_p,info,pz,o)
}
#пример запуска  name='sahalin'; # myPackage$trs.Data.dobavl_rasp(name)









#СБОР И АГРЕГАЦИЯ ИСХОДНЫХ ДАННЫХ по билетам, ст отправления и назначения
myPackage$trs.Data.read_spas <- function(name) {
  # Агрегирует сырые данные
  # Args:
  #   name: имя базы с агрегированными данными
  
  first=TRUE; 
  srok='month';vid='spas'
  shema=myPackage$trs.shema_dannih();
  shema=shema[((shema$name==name)&(shema$srok==srok)&(shema$vid==vid)),]
  
  files=myPackage$trs.vibor_files_shema(shema) # подвыбор нужных по схеме
  files$Database=name;files$vid=vid;files$srok=srok;files$ext='0'
  
  #исходно что уже было прочитано
  files=myPackage$trs.Data.readed(files)
  
  if (sum(files$read)>0){first=FALSE} #  были результаты - уже не записывать с нуля
  files=files[(files$read==0),]
  files$read=NULL
  
  sum_mar=0 
  
  # перебор всех новых файлов данных  ##############################  i=1
  if (nrow(files)>0){ 
    {#  все расписания, кроме иногос
      rasp2=myPackage$trs.dann_load('dann','rasp2') #  поезда по датам 
      rasp3=myPackage$trs.dann_load('dann','rasp3') #  сами маршруты
      rasp3$bad=1*(substr(as.character(rasp3$Stan),1,2)!='20')
      
      rb=aggregate(x=subset(rasp3,select=c('bad')),by=subset(rasp3,select=c('has2')),FUN="max" )
      rb=rb[(rb$bad==0),];rb[,'bad']=NULL
      rasp3$bad=NULL
      rasp3=merge(rasp3,rb,by='has2')
      rasp2=merge(rasp2,rb,by='has2')
      rasp2$has=NULL;rasp2$tab_nom=NULL
      rasp3$do=NULL;rasp3$dp=NULL
      rm(rb)
      
      o=order(rasp2$Date,rasp2$Train);
      rasp2=rasp2[o,];rm(o)
    }
    
    files_=NULL;pred_tabnom=0
    
    for (i in 1:nrow(files)){ #################  i=1   i=i+1
      ff=files[i,];ff$act=0
      file=as.character(ff$File)
      format=as.character(ff$format)
      path=as.character(ff$dir)
      tab_nom=as.numeric(ff$tab_nom)
      
      print(paste("Aggregating from \"", file, "\"...", sep = ""))
      filePath=paste(path, file, sep = "")
      matrix=myPackage$trs.Data.text.load(filePath,format); # готово
      kol_zap=nrow(matrix);
      matrix=myPackage$trs.Data.obrabot(matrix,format)  # готово
      if (!is.null(matrix$Lgot)){matrix=matrix[(matrix$Lgot!='B'),]}
      o=(matrix$Cena<=0);matrix[o,'Cena']=matrix[o,'Plata'] # заплатка
      
      if (format=='min_danns'){
        matrix=matrix[(substr(as.character(matrix$Sto),1,2)=='20'),] # не нужны иногос все
        matrix=matrix[(substr(as.character(matrix$Stn),1,2)=='20'),] # не нужны иногос все
        
        matrix$tp=substr(matrix$Tp_vid,1,3)
        matrix$Tp_vid=NULL
        
        matrix=aggregate(x=subset(matrix,select=c('Kol_pas','Pkm','Plata','Cena')),
                         by=subset(matrix,select=c('Date','Train','tp','Skp','Sto','Stn')),
                         FUN="sum" )  
        matrix=matrix[(matrix$Kol_pas!=0),]
        
        # теперь добавить расписания
        o=order(matrix$Date,matrix$Train);matrix=matrix[o,];rm(o)
        matrix=merge(matrix,rasp2,by=c('Date','Train'))
        
        { # уникальные сочетания станций
          o=order(matrix$has2,matrix$Sto,matrix$Stn);matrix=matrix[o,]
          sts=unique(matrix[,c('has2','Sto','Stn')])
          
          st=sts;st$Stan=st$Sto
          st_=st;st_$Stan=st_$Stn
          st=rbind(st,st_)
          st$Sto=NULL;st$Stn=NULL
          st=unique(st);rm(st_)
          st=merge(st,rasp3,by=c('has2','Stan'))
          
          sts$Stan=sts$Sto
          sts=merge(sts,st,by=c('has2','Stan'))
          sts$rsto=sts$Rasst;sts$Rasst=NULL
          
          sts$Stan=sts$Stn
          sts=merge(sts,st,by=c('has2','Stan'))
          sts$rstn=sts$Rasst;sts$Rasst=NULL
          sts=sts[(sts$rsto<sts$rstn),]
          sts$rst=abs(sts$rstn-sts$rsto)
          sts$Stan=NULL
          
          st=aggregate(x=subset(sts,select=c('rst')),
                       by=subset(sts,select=c('has2','Sto','Stn')), FUN="min" )
          sts=merge(sts,st,by=c('has2','Sto','Stn','rst'))
          
          sts=unique(sts)
          rm(st)
        }
        
        
        matrix=merge(matrix,sts,by=c('has2','Sto','Stn'))
        matrix$has2=NULL;matrix$Sto=NULL;matrix$Stn=NULL
        
        kol_rez=nrow(matrix);
        min_dat=min(matrix$Date);max_dat=max(matrix$Date);
        
        matr=matrix
        matr$Rasst=matr$rsto;matr$pkm=matr$Kol_pas*matr$rst;matr$kp=matr$Kol_pas
        
        matr_sm=aggregate(x=subset(matr,select=c('pkm','kp','Pkm','Plata','Cena')),
                          by=subset(matr,select=c('Date','Train','tp','Skp')), FUN="sum" )
        o=order(matr_sm$Date,matr_sm$Train,matr_sm$tp,matr_sm$Skp);matr_sm=matr_sm[o,]
        
        matr=aggregate(x=subset(matr,select=c('Kol_pas')),
                       by=subset(matr,select=c('Date','Train','tp','Skp','Rasst')), FUN="sum" )
        matr_=matrix;rm(matrix)
        matr_$Rasst=matr_$rstn;matr_$Kol_pas=-matr_$Kol_pas;
        matr_=aggregate(x=subset(matr_,select=c('Kol_pas')),
                        by=subset(matr_,select=c('Date','Train','tp','Skp','Rasst')), FUN="sum" )
        
        
        matr=rbind(matr,matr_);rm(matr_)
        matr=aggregate(x=subset(matr,select=c('Kol_pas')),
                       by=subset(matr,select=c('Date','Train','tp','Skp','Rasst')), FUN="sum" )
        
        
        # теперь обработка - поиск мин числа пассажиров
        o=order(matr$Date,matr$Train,matr$tp,matr$Skp,matr$Rasst)
        matr=matr[o,];rm(o)
        
        mest <-sapply(FUN = function(part) {
          Date=as.character(part$Date[1]);Train=as.character(part$Train[1]);
          tp=as.character(part$tp[1]);Skp=as.character(part$Skp[1])
          kol=nrow(part);kp=0;mkp=0
          for (i in (1:kol)){kp=kp+part$Kol_pas[i];mkp=max(mkp,kp)}
          kp=sum(part$kp)
          l <- c(Date=Date,  Train=Train, tp=tp, Skp=Skp, mest=mkp ) 
          return (l)
        }, X = split(matr, paste(matr$Date,matr$Train,matr$tp,matr$Skp)))
        
        mest=t(mest);mest=data.frame(mest, stringsAsFactors = FALSE)
        mest=as.data.frame(as.data.table(mest))
        
        mest$mest=as.numeric(mest$mest)
        matr_sm$Date=as.character(matr_sm$Date)
        
        mest=merge(mest,matr_sm,by=c('Date','Train','tp','Skp'))
        mest$pkm=NULL #убрал вычисленное pkm, оставил из АБД Pkm
        rm(matr_sm,matr,sts) 
        
      }
      
      kol_rez=nrow(mest);
      ff$kol_zap=kol_zap
      ff$kol_rez=kol_rez
      
      ff$Time=as.character(Sys.time()); # системное время
      ff$min_date=as.character(min_dat)
      ff$max_date=as.character(max_dat)
      
      
      {# предзапись итогов
        info=myPackage$trs.dann_load('info','rez')
        info=myPackage$sliv(info,ff);
        info[((info$tab_nom==pred_tabnom)&(!is.na(info$tab_nom))),'act']=1
        pred_tabnom=ff$tab_nom
        myPackage$trs.Data_save(info, 'info','rez',TRUE) }
      
      
      if (kol_rez>0){ #было (kol_zap>0)
        mest$tab_nom=pred_tabnom
        myPackage$trs.Data_save(mest, name,'spas',first);first=FALSE #запись на диск
      }
      
      # приписка времён отправления-прибытия
      
      print(paste("Vhod=",kol_zap," / Itog=",kol_rez," zapisei"))
      
    }
    
    # запись итогов - последний добавленый сделать активным
    info=myPackage$trs.dann_load('info','rez')
    info[((info$tab_nom==pred_tabnom)&(!is.na(info$tab_nom))),'act']=1
    myPackage$trs.Data_save(info, 'info','rez',TRUE)
  }#конец цикла
  
  
  ff=1;inf=1;info_=1;mar=1;marb=1;matrix=1;matrix_mar=1;file=1;filePath=1;
  format=1;i=1;kol_0=1;kol_1=1;kol_mar=1;kol_rez=1;kol_zap=1;max_dat=1;
  min_dat=1;mm=1;o=1;path=1;vcd_rus=1;info=1;tab_nom=1;files_=1;pred_tabnom=1;
  matr_old=0;rasp2=1;rasp3=1;max_dt=1;max_tab_nom=1;inf_bad=1;mest=1
  rm(ff,files,inf,info,info_,mar,marb,matrix,matrix_mar,shema,file,filePath,first,format)
  rm(i,kol_0,kol_1,kol_mar,kol_rez,kol_zap,max_dat,tab_nom,min_dat,mm,name,o,path)
  rm(srok,vcd_rus,vid,sum_mar,pred_tabnom)
  rm(inf_bad,mest,max_dt,max_tab_nom,rasp2,rasp3,files_)
}
#пример запуска  name='dann'; # myPackage$trs.Data.read_spas(name)










#агрегация месячных данных - сапсаны (сперва пасс, потом вагоны) и прочие (вагоны, потом пасс) +++
myPackage$trs.Data.aggregate_month <- function(name) {
  if (name=='sapsan'){ name='doss' }
  shema=myPackage$trs.shema_dannih();
  shema=shema[((shema$name==name)&(shema$srok=='month')),]  
  myPackage$trs.Data.read_rasp('dann')
  if (('rasp' %in% shema$vid)&(name!='dann')){myPackage$trs.Data.read_rasp(name)}
  if ('vag' %in% shema$vid){myPackage$trs.Data.read_vag(name)} # хор
  if ('pas' %in% shema$vid){myPackage$trs.Data.read_pas(name)} # хор но изменить
  #if ('spas' %in% shema$vid){myPackage$trs.Data.read_spas(name)} # по поездам - станция отпр-назн
  
  if (('stan' %in% shema$vid)|('stanon' %in% shema$vid)){ #станции отпр-назн всего
    myPackage$trs.Data.read_stan(name)}
  #if ('st_pas' %in% shema$vid){myPackage$trs.Data.read_st_pas(name)}
  
  if (name!='dann') {myPackage$trs.Data.dobavl_rasp(name)} #добавка расписаний
  if ('prig' %in% shema$vid){myPackage$trs.Data.read_prig(name)} # по пригороду
  
  rm(name,shema)
}
#   name='sahalin';#   name='doss'; #   myPackage$trs.Data.aggregate_month(name)










#СБОР И АГРЕГАЦИЯ ИСХОДНЫХ ДАННЫХ по билетам, исходя из первичных - вагонов, в вагоны приписка времени отпр/приб +++
myPackage$trs.Data.read_stan <- function(name) {
  
  srok='month';vid='stan';
  for (vid in c('stan')){  # c('stan','stanon'    vid='stan'   #   vid='stanon'   
    first <- TRUE;
    
    shema=myPackage$trs.shema_dannih();
    shema=shema[((shema$name==name)&(shema$srok==srok)&(shema$vid==vid)),]
    
    files=myPackage$trs.vibor_files_shema(shema) # подвыбор нужных по схеме
    #files=data.frame(File=files);
    files$Database=name;files$vid=vid;files$srok=srok;files$ext='0'
    
    #исходно что уже было прочитано
    files=myPackage$trs.Data.readed(files)
    
    if (sum(files$read)>0){first=FALSE} #  были результаты - уже не записывать с нуля
    files=files[(files$read==0),]
    files$read=NULL
    
    # перебор всех новых файлов данных  ##############################  tab_nom=46
    if (nrow(files)>0){ for (tab_nom in files$tab_nom){   
      
      fil=files[(files$tab_nom==tab_nom),]
      file=as.character(fil$File)
      format=as.character(fil$format)
      path=as.character(fil$dir)
      tab_nom=as.numeric(fil$tab_nom)
      
      print(paste("Aggregating from \"", file, "\"...", sep = ""))
      filePath=paste(path, file, sep = "")
      matrix=myPackage$trs.Data.text.load(filePath,format); # собственно чтение
      kol_zap=nrow(matrix);kol_rez=0;kol_mar=0
      {#максимальная дата
        matrix$Date=as.character(matrix$Date)
        mm=matrix[((matrix$Sto==0)&(matrix$Stn==0)),]
        if (nrow(mm)>0) { max_dat=as.character(mm$Date)
        matrix=matrix[(!((matrix$Sto==0)&(matrix$Stn==0))),]
        }else{max_dat=as.character(max(matrix$Date))}
      }
      matrix=myPackage$trs.Data.obrabot(matrix,format)  # обработка результатов с ужатием
      kol_rez=nrow(matrix);
      
      #max_tab_nom=max_tab_nom+1
      fil$kol_zap=kol_zap
      fil$kol_rez=kol_rez
      fil$kol_mar=kol_mar
      fil$Time=as.character(Sys.time()); # системное время
      fil$act=0
      min_dat=min(matrix$Date);
      fil$min_date=as.character(min_dat)
      fil$max_date=as.character(max_dat)
      
      {#предварительная запись
        info=myPackage$trs.dann_load('info','rez')
        info=myPackage$sliv(info,fil);
        myPackage$trs.Data_save(info, 'info','rez',TRUE)}
      
      if (kol_rez>0){ #было (kol_zap>0)
        matrix$tab_nom=tab_nom
        myPackage$trs.Data_save(matrix, name,vid,first);first=FALSE #запись на диск
      }
      
      print(paste("Vhod=",kol_zap," / Itog=",kol_rez," zapisei"))
      info=myPackage$trs.dann_load('info','rez')
      info[((info$tab_nom==tab_nom)&(!is.na(info$tab_nom))),'act']=1
      myPackage$trs.Data_save(info, 'info','rez',TRUE)
      
    }}#конец цикла
  } # конец перебора vid
  
  
  ff=1;inf=1;info_=1;mar=1;marb=1;matrix=1;matrix_mar=1;file=1;filePath=1;
  format=1;i=1;kol_0=1;kol_1=1;kol_mar=1;kol_rez=1;kol_zap=1;max_dat=1;
  min_dat=1;mm=1;o=1;path=1;vcd_rus=1;fil=1;sum_mar=1;tab_nom=1;info=1;
  
  rm(ff,files,inf,info,info_,mar,marb,matrix,matrix_mar,shema,file,filePath,first,format)
  rm(i,kol_0,kol_1,kol_mar,kol_rez,kol_zap,max_dat,tab_nom,min_dat,mm,name,o,path)
  rm(srok,vcd_rus,vid,sum_mar,fil)
}
#пример запуска  name='sahalin'; # myPackage$trs.Data.read_stan(name)










#Есть - рассчитать для каждого поезда - в ДОСС их тьма разных!. Или вообще расписание ввести!
#по списку расстояний восстановить очерёдность станций и расст в маршрут
myPackage$marshr_to_rasst <- function(marshr) {
  
  mar=aggregate(x=list(Kol_pas=abs(as.integer(marshr$Kol_pas))  ),
                by=subset(marshr,select=c('Train')),FUN="max")
  mar=merge(marshr,mar,by=c('Train','Kol_pas')) #каждый поезд - самые массовые
  
  rst=mar;rst$kst=rst$Sto;rst$rst=0;
  rs=mar;rs$kst=mar$Stn;rs$rst=mar$Rasst;
  rst=rbind(rst,rs);rm(rs)
  rst=subset(rst,select=c('Train','kst','rst'));z='1'
  
  while(z=='1')  {
    rst_o=rst;rst_o$Sto=rst_o$kst;rst_o$r_o=rst_o$rst;rst_o$kst=NULL;rst_o$rst=NULL
    rst_n=rst;rst_n$Stn=rst_n$kst;rst_n$r_n=rst_n$rst;rst_n$kst=NULL;rst_n$rst=NULL
    mar=merge(marshr,rst_o,by=c('Train','Sto'), all=TRUE)
    mar=merge(mar,rst_n,by=c('Train','Stn'), all=TRUE)
    mar=mar[(!is.na(mar$Rasst)),]
    
    mar=mar[(!is.na(mar$r_o))|(!is.na(mar$r_n)),]
    mar=mar[(is.na(mar$r_o))|(is.na(mar$r_n)),]
    z='0'
    
    if (nrow(mar)>0){
      mr=aggregate(x=list(Kol_pas=abs(as.integer(mar$Kol_pas))  ),
                   by=subset(mar,select=c('Train')),FUN="max")
      mr=merge(mar,mr,by=c('Train','Kol_pas'))
      mr$kst=mr$Sto;mr[is.na(mr$r_n),]$kst=mr[is.na(mr$r_n),]$Stn
      mr$rst=mr$r_o+mr$Rasst;
      mr[is.na(mr$rst),]$rst=mr[is.na(mr$rst),]$r_n-mr[is.na(mr$rst),]$Rasst
      mr=subset(mr,select=c('Train','kst','rst'));rst=rbind(rst,mr);z='1' }
  }
  
  rst=unique(rst);
  o=order(rst$Train,rst$rst);rst=rst[o,]; # в 2 действия - иначе не работает с data.table
  rst$nom=1:nrow(rst)
  mr=aggregate(x=list(mnom=abs(as.integer(rst$nom))  ),
               by=subset(rst,select=c('Train')),FUN="min")
  rst=merge(rst,mr,by=c('Train'), all=TRUE)
  rst$nom=rst$nom+1-rst$mnom;rst$mnom=NULL
  return(rst)}










#ПРОГ ПЕРЕРАББОТКИ - ЗА 45 ДНЕЙ ОСТАВЛЯЕТ ПАСС (И АРЕНДУ ПАСС), ПКМ, ПЛАТУ, ЦЕНУ БИЛЕТА
#плюс - число мест и свободных мест, необходимый минимум занятых мест (по посадке-высадке =min_mest)
# плюс - направление поезда, первый, скорый(наискорейший)в сутки по напр
myPackage$trs.tData.extractor_old <- function(pData, mData, wData, pzd_, kol_day) {
  # Метод объединения, оставляющий данные о поездах и типах мест построчно
  
  # kol_day=в каком диапазоне дат оставлять наличие данных
  zap=round((max(mData[(!is.na(mData$Tm_prib)),]$Tm_prib)-720)/1440)
  min_date=min(as.Date(pData$Date))+zap
  max_date=max(as.Date(pData$Date)-pData$Before)
  
  pData=pData[(as.Date(pData$Date)>=as.Date(min_date)),]
  rm(min_date)
  
  #добавляем нулевых пассажиров, если был тип вагона пустой
  r1=unique(subset(pData, select = c(Date,Train,Type,Klass)))
  r2=unique(subset(wData, select = c(Date,Train,Type,Klass)))
  rr=unique(subset(r1, select = c(Date,Train)))
  r2=merge(r2,rr,by=c('Date','Train'));r2$seat=1
  r1$kp=1;rr=merge(r1,r2,by=c('Date','Train','Type','Klass'),all=TRUE)
  rs=rr[(is.na(rr$seat)),];rs$kp=NULL;rs$seat=NULL
  rr=rr[(is.na(rr$kp)),];rr$kp=NULL;rr$seat=NULL
  dn=subset(pData, select = -c(Type,Klass))
  dn=merge(dn,rr,by=c('Date','Train'))
  if (nrow(dn)>0){
    dn$Before=0;dn$Kol_pas=0;dn$Plata=0;dn$Cena=NA;dn$s_cena=0;
    pData=rbind(pData,dn);}
  rm(r1,r2,rr,dn)
  
  #Добавляем нулевые места, если пассажиры были, а вагон изъяли из поезда (бывает!!!)
  if (nrow(rs)>0){
    rs$Seats=0;rs$Rasst=0;rs$FreeSeats=0;rs$Kol_vag=0
    wData=myPackage$sliv(wData,rs);}
  rm(rs)
  
  
  kol_day=max(kol_day,1)
  pData$Before=pmin(pmax(pData$Before,1),kol_day);pData$Pkm=pData$Kol_pas*pData$Rasst;
  marshr=aggregate(x=list(Kol_pas=abs(as.integer(pData$Kol_pas))  ),
                   by=subset(pData,select=c('Train','Sto','Stn','Rasst')),FUN="sum")
  
  # А ТУТ ИЗ МАТРИЦЫ РАССТОЯНИЙ СОСТАВЛЯЕМ МАРШРУТ
  rst=myPackage$marshr_to_rasst(marshr);#max_rst=max(rst$rst) #пока не исправлена программа
  mrst=aggregate(x=list(Rasst=abs(as.integer(rst$rst))),by=subset(rst,select=c('Train')),FUN="max")
  
  rst_o=rst;rst_o$Sto=rst_o$kst;rst_o$n_o=rst_o$nom;rst_o=subset(rst_o,select=c(Train,Sto,n_o))
  rst_n=rst;rst_n$Stn=rst_n$kst;rst_n$n_n=rst_n$nom;rst_n=subset(rst_n,select=c(Train,Stn,n_n))
  
  mesta=merge(pData,rst_o,by=c('Train','Sto'));mesta=merge(mesta,rst_n,by=c('Train','Stn'));
  rm(rst,rst_o,rst_n)
  mesta=aggregate(Kol_pas ~Train+Date+Type+Klass+n_o+n_n,data = mesta, sum)
  
  #pData_=aggregate(c('Kol_pas') ~Train+Date+Type+Before+Arenda,data = pData, sum)
  
  pData[is.na(pData$Cena),]$Cena=0 #обнуляем все NA, иначе максимум врёт
  cena=aggregate(x=subset(pData,select=c('Cena')),
                 by=subset(pData,select=c('Date','Train','Type','Klass','Arenda','Before')),
                 FUN="max")
  pass=aggregate(x=subset(pData,select=c('Kol_pas','Plata','s_cena','Pkm')),
                 by=subset(pData,select=c('Date','Train','Type','Klass','Arenda','Before')),
                 FUN="sum")
  pass=merge(pass,cena,by=c('Date','Train','Type','Klass','Arenda','Before'))
  
  pass_=pass[(pass$Klass!='-'),];#добавка сумм классов вагона
  if (nrow(pass_)>0){
    pass_$Klass='-'
    cena=aggregate(x=subset(pass_,select=c('Cena')),
                   by=subset(pass_,select=c('Date','Train','Type','Klass','Arenda','Before')),
                   FUN="max")
    pass_=aggregate(x=subset(pass_,select=c('Kol_pas','Plata','s_cena','Pkm')),
                    by=subset(pass_,select=c('Date','Train','Type','Klass','Arenda','Before')),
                    FUN="sum")
    pass_=merge(pass_,cena,by=c('Date','Train','Type','Klass','Arenda','Before'))
  };pass=rbind(pass,pass_)
  
  pass_=pass[(pass$Klass=='-')&(pass$Type!='-'),];#добавка сумм типов вагона
  if (nrow(pass_)>0){
    pass_$Type='-'
    #cena=aggregate(x=subset(pass_,select=c('Cena')),
    #              by=subset(pass_,select=c('Date','Train','Type','Klass','Arenda','Before')),
    #              FUN="max")
    pass_=aggregate(x=subset(pass_,select=c('Kol_pas','Plata','s_cena','Pkm')),
                    by=subset(pass_,select=c('Date','Train','Type','Klass','Arenda','Before')),
                    FUN="sum")
    pass_$Cena=0 #  в разных типах вагонов цены принципиально разные
    #pass_=merge(pass_,cena,by=c('Date','Train','Type','Klass','Arenda','Before'))
  };pass=rbind(pass,pass_)
  pData=pass;rm(pass,pass_,cena)
  
  
  {# постановка номера маршрута (поезд), с дополнением прежнего из pzd_
    pzd=unique(mData[,c('Sto','Stn')])
    if (is.null(pzd_)){pzd$pzd=NA;pzd$Napr=NA}else{
      pzd=merge(pzd,pzd_,by=c('Sto','Stn'),all=TRUE)}
    pzd_=pzd;pzd_$Napr=NULL
    o=(pzd_$Stn<pzd_$Sto)
    pzd_[o,'c']=pzd_[o,'Sto'];pzd_[o,'Sto']=pzd_[o,'Stn'];pzd_[o,'Stn']=pzd_[o,'c'];
    pzd_$c=NULL;pzd_$pzd=abs(pzd_$pzd)
    pzd_2=pzd_[(!is.na(pzd_$pzd)),]
    pzd_2=unique(pzd_2)
    pzd_$pzd=NULL;pzd_=unique(pzd_)
    pzd_=merge(pzd_,pzd_2,by=c('Sto','Stn'),all=TRUE)
    o=order( (is.na(pzd_$pzd)*1),pzd_$pzd,pzd_$Sto,pzd_$Stn)
    pzd_=pzd_[o,];pzd_$pzd=(1:nrow(pzd_));pzd_$Napr=1
    pzd=pzd_;
    pzd_$c=pzd_$Sto;pzd_$Sto=pzd_$Stn;pzd_$Stn=pzd_$c;pzd_$c=NULL
    pzd_$Napr=-1;pzd_$pzd=-pzd_$pzd
    pzd=rbind(pzd,pzd_)
    rm(pzd_,pzd_2)
  }
  
  mData=merge(mData, pzd, by = c('Sto','Stn'));
  mDt=subset(mData, select = c(Date, Train, pzd, Napr))
  
  #добавить ещё сумму по направлению, по всем поездам направления
  pData=merge(pData, mDt, by = c('Date','Train'));
  pData_=pData;pData_$Train='-';
  pData=rbind(pData,pData_);rm(pData_)
  
  
  # рассчёт пасс, пасс-км, цены,
  kdd=max(kol_day,2);kd=kol_day-1
  result <- sapply(FUN = function(part) {
    kp <- numeric(kdd);rent <- numeric(kdd);
    pkm <- numeric(kdd);plata <- numeric(kdd);cena <- numeric(kdd);scena <- numeric(kdd)
    len=nrow(part);total= 0;r_total=0;#rasst=max(part$Rasst)
    if (len > 0) {for (i in 1:len) {
      kp[part$Before[i]] =kp[part$Before[i]]+part$Kol_pas[i] #пасс все, и арендованные
      if (part$Arenda[i] == 1) {rent[part$Before[i]]=rent[part$Before[i]] + part$Kol_pas[i]} #отдельно аренда
      pkm[part$Before[i]] =pkm[part$Before[i]]+part$Pkm[i]
      plata[part$Before[i]] =plata[part$Before[i]]+part$Plata[i]
      scena[part$Before[i]] =scena[part$Before[i]]+part$s_cena[i]
      cena[part$Before[i]]=pmax(cena[part$Before[i]],part$Cena[i]) 
    }}
    
    if (kd>0){
      for (i in kd:1) {kp[i]=kp[i]+kp[i+1];rent[i]=rent[i]+rent[i+1];
      pkm[i]=pkm[i]+pkm[i+1];plata[i]=plata[i]+plata[i+1];scena[i]=scena[i]+scena[i+1];
      if(cena[i]==0){cena[i]=cena[i+1]} }
      for (i in 1:kd) {if(cena[i+1]==0){cena[i+1]=cena[i]}}
    };
    #date <- zoo::as.Date(part$Date[1])
    Date=as.Date(part$Date[1])
    Train=as.character(part$Train[1])
    Type=as.character(part$Type[1])
    Klass=as.character(part$Klass[1])
    pzd=as.character(part$pzd[1])
    
    #вычерк недопроданных данных  Date=as.Date('2017-06-28')
    if(Date>max_date) {ii=min(max((as.integer(Date)-as.integer(max_date))-1,1),kdd)
    for (i in 1:ii) {kp[i]=NA;rent[i]=NA;pkm[i]=NA;plata[i]=NA;cena[i]=NA;scena[i]=NA
    }}
    
    l <- c(Date=as.character(Date), Train=Train, Type=Type, Klass=Klass, pzd=pzd, 
           kp=as.character(kp), rent=as.character(rent),
           pkm=as.character(pkm),plata=as.character(plata),cena=as.character(cena),
           scena=as.character(scena)
    )        
    return (l)
  }, X = split(pData, paste(pData$Date, pData$Train, pData$Type,pData$Klass, pData$pzd)))
  
  result <- t(result)  #??? просто транспонирование
  
  #ПЕРЕИМЕНОВАНИЕ СТОЛБЦОВ - ПО НУМЕРАЦИИ (ТЕПЕРЬ ВРОДЕ И НЕНУЖНО)
  #colnames(result) <- c("Date", "Weekday", "Month", "Train", "Type", "Total",
  #                      sapply(FUN = function(i) {paste("Total_before", i, "days", sep = "_")}, X = 1:45),
  #                      #"Rent",
  #                      sapply(FUN = function(i) {paste("Rent_before", i, "days", sep = "_")}, X = 1:45))
  
  result <- data.frame(result, stringsAsFactors = FALSE)
  
  if (kol_day==1){result=subset(result, select = -c(kp2, rent2,pkm2,plata2,cena2,scena2))}
  
  for (i in 1:kol_day) { #в числовой формат переписать
    st=paste("kp", i, sep = "");result[,st]=as.integer(result[,st])
    st=paste("rent", i, sep = "");result[,st]=as.integer(result[,st])
    st=paste("plata", i, sep = "");result[,st]=as.integer(result[,st])
    st=paste("scena", i, sep = "");result[,st]=as.integer(result[,st])
    st=paste("cena", i, sep = "");result[,st]=as.integer(result[,st])
    st=paste("pkm", i, sep = "");result[,st]=as.integer(result[,st]) }
  
  # из мест по маршртам получить минимальные занятые места
  mesta_=mesta[(mesta$Klass!='-'),]
  if (nrow(mesta_)>0){mesta_$Klass='-'};mesta=rbind(mesta,mesta_)
  mesta_=mesta[(mesta$Type!='-')&(mesta$Klass=='-'),]
  if (nrow(mesta_)>0){mesta_$Type='-'};mesta=rbind(mesta,mesta_)
  
  mesta$no=pmin(mesta$n_o,mesta$n_n);mesta$nn=pmax(mesta$n_o,mesta$n_n);
  mesta_=mesta;mesta_$no=mesta_$nn;mesta_$Kol_pas=-mesta_$Kol_pas;
  mesta=rbind(mesta,mesta_);rm(mesta_)
  mesta=aggregate(Kol_pas ~Train+Date+Type+Klass+no,data = mesta, sum)
  max_n=max(mesta$no)
  
  #тоже для сумм по направлению. 
  #??? может сильно врать - у разных поездов разное число остановок и их нумерация
  mesta=merge(mesta, mDt, by = c('Date','Train'));
  
  mesta_=aggregate(Kol_pas ~pzd+Napr+Date+Type+Klass+no,data = mesta, sum)
  mesta_$Train='-'
  mesta=rbind(mesta,mesta_);rm(mesta_)
  
  
  min_mest <- sapply(FUN = function(part) {
    kp <- numeric(max_n);kp[part$no]=part$Kol_pas
    for (i in 1:(max_n-1)) {kp[i+1]=kp[i+1]+kp[i]};min_mest=max(kp)
    Date=as.character(part$Date[1]);Train=as.character(part$Train[1]);
    Type=as.character(part$Type[1]);Klass=as.character(part$Klass[1]);
    pzd=as.character(part$pzd[1]);
    l <- c(Date=Date,  pzd=pzd, Train=Train, Type=Type, Klass=Klass, min_mest=min_mest )        
    return (l)
  }, X = split(mesta, paste(mesta$Date, mesta$pzd, mesta$Train, mesta$Type, mesta$Klass)))
  
  min_mest=t(min_mest);min_mest=data.frame(min_mest, stringsAsFactors = FALSE)
  
  result=merge(result, min_mest, by = c("Train", "Date", "Type","Klass","pzd"))
  result$min_mest=as.integer(result$min_mest)
  rm(min_mest)
  # надо - поставить своё расст для каждого поезда отдельно - непонятно теперь, а зачем?
  result=merge(result, mrst, by = c("Train"), all=TRUE) 
  
  wData$Train <- as.character(wData$Train)
  wData$Date <- as.character(wData$Date)
  wData$Type <- as.character(wData$Type)
  wData$Klass <- as.character(wData$Klass) 
  
  vag=wData[(wData$Klass!='-'),];
  if (nrow(vag)>0){vag$Klass='-'};wData=rbind(wData,vag)
  vag=wData[(wData$Klass=='-')&(wData$Type!='-'),];
  if (nrow(vag)>0){vag$Type='-'};wData=rbind(wData,vag)
  wData$Seats_km=wData$Seats*wData$Rasst
  wData=aggregate(x=subset(wData,select=c('Kol_vag','Seats','FreeSeats','Seats_km')),
                  by=subset(wData,select=c('Date','Train','Type','Klass')),
                  FUN="sum")
  
  #и сумма по направлению движения
  min_date=as.Date(min(result$Date))
  wData=wData[(as.Date(wData$Date)>=min_date-365),]
  wData <- merge(wData, mDt, by = c("Train", "Date"))
  wData_=aggregate(x=subset(wData,select=c('Kol_vag','Seats','FreeSeats','Seats_km')),
                   by=subset(wData,select=c('Date','pzd','Napr','Type','Klass')),
                   FUN="sum")
  wData_$Train='-';wData=rbind(wData,wData_);rm(wData_)
  
  result <- merge(result, wData, by = c("Train", "Date", "Type","Klass","pzd"),all=TRUE)
  result[(as.Date(result$Date)>max_date),c('FreeSeats','min_mest')]=NA
  
  
  #вычисление кто первый - уже по датам и поездам - теперь это порядк номер в сутках
  o=order(mData$pzd,mData$Date,mData$Tm_otp,mData$Train);mData=mData[o,]; # в 2 действия - иначе не работает с data.table
  mData$n=(1:nrow(mData))
  tm=aggregate(x=subset(mData,select=c('n')),
               by=subset(mData,select=c('Date','pzd')), FUN="min")
  tm$nn=tm$n;tm$n=NULL
  mData=merge(mData, tm, by = c('Date','pzd'));
  mData$First=1+mData$n-mData$nn;mData$n=NULL;mData$nn=NULL
  
  #Вычисление кто скорый (наискорейший) - порядк номер в скоростях
  mData$Time=mData$Tm_prib-mData$Tm_otp
  o=order(mData$pzd,mData$Date,mData$Time,mData$Train);mData=mData[o,]; # в 2 действия - иначе не работает с data.table
  mData$n=(1:nrow(mData))
  tm=aggregate(x=subset(mData,select=c('n')),
               by=subset(mData,select=c('Date','pzd')), FUN="min")
  tm$nn=tm$n;tm$n=NULL
  mData=merge(mData, tm, by = c('Date','pzd'));
  mData$Skor=1+mData$n-mData$nn;mData$n=NULL;mData$nn=NULL;rm(o,tm)
  
  mData <- subset(mData, select = c(Train, Date, Tm_otp, Time, First, Skor)) # ,pzd,Napr
  
  result=merge(mData, result, by = c("Train", "Date"),all=TRUE)
  result=result[(!is.na(result$pzd)),]
  
  result[(result$Train=='-'),c('First','Skor')]=0
  
  result <- cbind(subset(result, select = c(Date, Train, Type, Seats, min_mest)),
                  subset(result, select = -c(Date, Train, Type, Seats, min_mest)))
  
  res=list(result=result,pzd=pzd)
  return (res)
  rm(marshr,mData,mDt,mesta,mrst,pData,pzd,result,vag,wData,i,kd,kdd,kol_day)
  rm(max_date,max_n,min_date,res,st,zap)
}
# пример запуска   res=myPackage$trs.tData.extractor_old(pData, mData, wData, pzd, kol_day) 








#ПРОГ ПЕРЕРАББОТКИ - ЗА 45 ДНЕЙ ОСТАВЛЯЕТ ПАСС (И АРЕНДУ ПАСС), ПКМ, ПЛАТУ, ЦЕНУ БИЛЕТА
#плюс - число мест и свободных мест, необходимый минимум занятых мест (по посадке-высадке =min_mest)
# плюс - направление поезда, первый, скорый(наискорейший)в сутки по напр

#myPackage$trs.tData.extractor <- function(pData, mData, wData, pzd_, kol_day) {
myPackage$trs.tData.extractor <- function(pData, wData, pzd,rasp1,rasp2, kol_day) {
  # Метод объединения, оставляющий данные о поездах и типах мест построчно
  
  # kol_day=перечень дат, когда оставлять наличие данных
  
  zap=max(rasp1$do)
  dt=as.Date(pData$Date)
  min_date=min(dt)+zap
  max_date=max(dt-pData$Before)
  
  pData=pData[(dt>=as.Date(min_date)),]
  rm(min_date,zap,dt)
  
  {#добавляем нулевых пассажиров, если был тип вагона пустой - если был хоть 1 пасс в ином вагоне
    r1=unique(subset(pData, select = c(Date,Train,Type,Klass)))
    r2=unique(subset(wData, select = c(Date,Train,Type,Klass)))
    rr=unique(subset(r1, select = c(Date,Train)))
    r2=merge(r2,rr,by=c('Date','Train'));r2$seat=1
    r1$kp=1;rr=merge(r1,r2,by=c('Date','Train','Type','Klass'),all=TRUE)
    rs=rr[(is.na(rr$seat)),];rs$kp=NULL;rs$seat=NULL
    rr=rr[(is.na(rr$kp)),];rr$kp=NULL;rr$seat=NULL
    dn=subset(pData, select = -c(Type,Klass))
    dn=merge(dn,rr,by=c('Date','Train'))
    if (nrow(dn)>0){
      dn$Before=1000;dn$Kol_pas=0;dn$Plata=0;dn$Cena=NA;dn$s_cena=0;
      dn=unique(dn)
      pData=rbind(pData,dn);}
    rm(r1,r2,rr,dn)}
  
  {#Добавляем нулевые места, если пассажиры были, а вагон изъяли из поезда (бывает!!!)
    if (nrow(rs)>0){
      rs$Seats=0;rs$Rasst=0;rs$FreeSeats=0;rs$Kol_vag=0
      wData=myPackage$sliv(wData,rs);}
    rm(rs)}
  
  {# постановки запаздываний по новому списком
    kol_day=unique(c(kol_day,0))
    kday=as.data.frame(kol_day);kday$kd=1
    o=order(kday$kol_day);kday=kday[o,]
    kday$kd=(1:nrow(kday))
    kday_=kday[(kday$kd==nrow(kday)),]
    kday_$kd=kday_$kd+1;kday_$kol_day=10000 #бесконечность
    kday_=rbind(kday,kday_)
    pData$Pkm=pData$Kol_pas*pData$Rasst;
    
    pdat=pData
    
    for (bef in kday$kd){
      bef1=kday[(kday$kd==bef),'kol_day']
      bef2=kday_[(kday_$kd==(bef+1)),'kol_day']
      o=((pdat$Before>=bef1)&(pdat$Before<bef2))
      pdat[o,'bef']=bef;pdat[o,'Before']=bef1
    }
    rm(bef,bef1,bef2,o,kday_)
  }
  
  
  
  {# суммирование (NA превратить в -1)
    pdat[(is.na(pdat$Cena)),'Cena']=-1
    pdat=aggregate(x=subset(pdat,select=c('Kol_pas','Plata','Pkm','s_cena')),
                   by=subset(pdat,select=c('Date','Train','Type','Klass','Arenda','bef','Before','Cena')), FUN="sum" )
    pdat[(pdat$Cena==-1),'Cena']=NA
  }
  
  
  
  
  { # рассчёт пасс, пасс-км, цены,
    kdd=max(kday$kd);kd=kdd-1
    result <- sapply(FUN = function(part) {
      kp <- numeric(kdd);rent <- numeric(kdd);pkm <- numeric(kdd);
      plata <- numeric(kdd);cena <- numeric(kdd);scena <- numeric(kdd)
      cena=cena*NA
      len=nrow(part);total= 0;r_total=0;#rasst=max(part$Rasst)
      if (len > 0) {for (i in 1:len) {
        bef=part$bef[i]
        kp[bef] =kp[bef]+part$Kol_pas[i] #пасс все, и арендованные
        if (part$Arenda[i] == 1) {rent[bef]=rent[bef] + part$Kol_pas[i]} #отдельно аренда
        pkm[bef] =pkm[bef]+part$Pkm[i]
        plata[bef] =plata[bef]+part$Plata[i]
        scena[bef] =scena[bef]+part$s_cena[i]
        if (!is.na(part$Cena[i])) { cena[bef]=pmax(cena[bef],part$Cena[i])
        if (is.na(cena[bef])) {cena[bef]=part$Cena[i]}}
      }}
      
      if (kd>0){
        for (i in (kd:1)) {kp[i]=kp[i]+kp[i+1];rent[i]=rent[i]+rent[i+1];
        pkm[i]=pkm[i]+pkm[i+1];plata[i]=plata[i]+plata[i+1];scena[i]=scena[i]+scena[i+1];
        if(is.na(cena[i])){cena[i]=cena[i+1]} }
        for (i in 1:kd) {if(is.na(cena[i+1])){cena[i+1]=cena[i]}}
      };
      Date=as.Date(part$Date[1])
      Train=as.character(part$Train[1])
      Type=as.character(part$Type[1])
      Klass=as.character(part$Klass[1])
      pzd=as.character(part$pzd[1])
      
      l <- c(Date=as.character(Date), Train=Train, Type=Type, Klass=Klass, pzd=pzd, 
             kp_=as.character(kp), rent_=as.character(rent),
             pkm_=as.character(pkm),plata_=as.character(plata),
             cena_=as.character(cena),scena_=as.character(scena)
      )        
      return (l)
    }, X = split(pdat, paste(pdat$Date, pdat$Train, pdat$Type,pdat$Klass, pdat$pzd)))
    
    result <- t(result)  #??? просто транспонирование
    
    result <- data.frame(result, stringsAsFactors = FALSE)
    
    sum_pol=NULL;max_pol=NULL
    {#переименование столбцов по запаздываниям
      for (nm in c('kp', 'rent','pkm','plata','cena','scena')){
        for (kd in kday$kd){
          nm1=paste(nm,'_',sep='')
          if (kdd>1){nm1=paste(nm1,kd,sep='')}
          bef=kday[(kday$kd==kd),'kol_day']
          mdt=max_date+bef
          nm_=paste(nm,bef,sep='');
          if (nm1 %in% names(result)){
            result[,nm_]=as.integer(result[,nm1]);result[,nm1]=NULL}
          result[(result$Date>mdt),nm_]=NA
          if (nm!='cena'){sum_pol=c(sum_pol,nm_)}else{max_pol=c(max_pol,nm_)}
        }}}
    
    result=as.data.frame(as.data.table(result))
    rm(nm,nm_,nm1,kd,bef,pdat,kdd)
  }
  
  
  
  
  {#места минимальное количество -  через расписание - только на момент отправки
    pd=aggregate(x=subset(pData,select=c('Kol_pas')),
                 by=subset(pData,select=c('Date','Train','Type','Klass','Sto','Stn')), FUN="sum" )
    pd$Stan=pd$Sto
    pd_=pd;pd_$Stan=pd_$Stn;pd_$Kol_pas=-pd_$Kol_pas
    pd=rbind(pd,pd_);rm(pd_)
    pd=aggregate(x=subset(pd,select=c('Kol_pas')),
                 by=subset(pd,select=c('Date','Train','Type','Klass','Stan')), FUN="sum" )
    
    o=order(rasp2$Date,rasp2$Train);rasp2=rasp2[o,];rasp2$isp=NULL
    o=order(pd$Date,pd$Train);pd=pd[o,]
    pd=merge(pd,rasp2,by=c('Date','Train'))
    
    rs=rasp1[,c('tab_nom','has','Stan','Rasst')]
    o=order(rs$tab_nom,rs$has,rs$Stan);rs=rs[o,]
    o=order(pd$tab_nom,pd$has,pd$Stan);pd=pd[o,]
    pd=merge(pd,rs,by=c('tab_nom','has','Stan'))
    pd$tab_nom=NULL;pd$has=NULL;pd$Stan=NULL
    
    o=order(pd$Date,pd$Train,pd$Type,pd$Klass,pd$Rasst);pd=pd[o,];rm(o)
    
    {#собственно подсчёт минимума мест - по каждому конкретному поезду, а не вообще
      mest <- sapply(FUN = function(part) {
        kp=0;mkp=0;n=nrow(part)
        for (i in (1:n)){kp=kp+part[i,'Kol_pas'];mkp=max(mkp,kp)}
        Date=as.character(part$Date[1]);Train=as.character(part$Train[1]);
        Type=as.character(part$Type[1]);Klass=as.character(part$Klass[1]);
        l <- c(Date=Date,   Train=Train, Type=Type, Klass=Klass, min_mest=mkp )        
        return (l)
      }, X = split(pd, paste(pd$Date, pd$Train, pd$Type, pd$Klass)))
      
      mest=t(mest);mest=data.frame(mest,stringsAsFactors = FALSE)
      mest$min_mest=as.integer(mest$min_mest)
      mest=as.data.frame(as.data.table(mest))}
    
    o=order(mest$Date,mest$Train,mest$Type,mest$Klass)
    mest=mest[o,]
    o=order(result$Date,result$Train,result$Type,result$Klass)
    result=result[o,]
    
    result=merge(result,mest, by = c("Date","Train","Type","Klass"))
    result[(result$Date>max_date),'min_mest']=NA
    sum_pol=c(sum_pol,'min_mest')
    rm(mest,pd,pData)
  }
  
  
  {# количества вагонов,мест всего и свободных
    for (nm in c('Date','Train','Type','Klass')){
      wData[,nm]=as.character(wData[,nm])   }
    
    wData$Seats_km=wData$Seats*wData$Rasst
    wData=aggregate(x=subset(wData,select=c('Kol_vag','Seats','FreeSeats','Seats_km')),
                    by=subset(wData,select=c('Date','Train','Type','Klass')),
                    FUN="sum")
    
    min_date=as.Date(min(result$Date))
    wData=wData[(as.Date(wData$Date)>=min_date-365),]
    
    o=order(wData$Date,wData$Train,wData$Type,wData$Klass);wData=wData[o,]
    o=order(result$Date,result$Train,result$Type,result$Klass);result=result[o,]
    
    result <- merge(result, wData, by = c("Date","Train","Type","Klass"),all=TRUE)
    result[(as.Date(result$Date)>max_date),c('FreeSeats','min_mest')]=NA
    sum_pol=c(sum_pol,'Kol_vag','Seats','FreeSeats','Seats_km')
    rm(wData,nm)
  }
  
  # поезда номера по направлениям. только нужные (пока что)
  pzd=pzd[(pzd$isp>0),];pzd$isp=NULL
  if (min(pzd$pzd)>0){pzd$pzd=pzd$pzd*pzd$napr;pzd$napr=NULL}
  
  {#приклеить поезда(направления)
    r2=merge(rasp2,pzd,by=c('tab_nom','has'))
    #r2$tab_nom=NULL;r2$has=NULL
    r2=r2[,c('Date','Train','pzd')]
    o=order(r2$Date,r2$Train);r2=r2[o,]
    o=order(result$Date,result$Train);result=result[o,]
    result=merge(result,r2,by=c('Date','Train'))
    rm(r2)}
  
  
  
  
  
  {#теперь подсуммировать по поездам и направлениям
    sum_pol=c(sum_pol,'k');result$k=1
    
    dn=result[(result$Klass!='-'),]
    if (nrow(dn)>0){
      dn$Klass='-'
      dn=aggregate(x=subset(dn,select=sum_pol),
                   by=subset(dn,select=c('Date','pzd','Train','Type','Klass')), FUN="sum" )
      dnk=aggregate(x=subset(dn,select='k'),by=subset(dn,select=c('pzd')), FUN="max" )
      dnk=dnk[(dnk$k>1),];dnk$k=NULL
      dn=merge(dn,dnk,by='pzd');dn$k=1
      dn[,max_pol]=NA;result=rbind(result,dn)}
    
    
    
    dn=result[(result$Type!='-'),]
    if (nrow(dn)>0){
      dn$Type='-'
      dn=aggregate(x=subset(dn,select=sum_pol),
                   by=subset(dn,select=c('Date','pzd','Train','Type','Klass')), FUN="sum" )
      dnk=aggregate(x=subset(dn,select='k'),by=subset(dn,select=c('pzd')), FUN="max" )
      dnk=dnk[(dnk$k>1),];dnk$k=NULL
      dn=merge(dn,dnk,by='pzd');dn$k=1
      dn[,max_pol]=NA;result=rbind(result,dn)
    }
    
    
    for (nm in names(result)){
      if (!(nm %in% names(dn))) {print(nm)}
    }
    
    
    
    dn=result[((result$Type!='-')|(result$Klass!='-')),]
    if (nrow(dn)>0){
      dn$Train='-'
      dn=aggregate(x=subset(dn,select=sum_pol),
                   by=subset(dn,select=c('Date','pzd','Train','Type','Klass')), FUN="sum" )
      dnk=aggregate(x=subset(dn,select='k'),by=subset(dn,select=c('pzd')), FUN="max" )
      dnk=dnk[(dnk$k>1),];dnk$k=NULL
      dn=merge(dn,dnk,by='pzd');dn$k=1
      dn[,max_pol]=NA;result=rbind(result,dn)
      #и сразу тип и класс тоже в ноль
      dn$Type='-';dn$Klass='-'
      dn=aggregate(x=subset(dn,select=sum_pol),
                   by=subset(dn,select=c('Date','pzd','Train','Type','Klass')), FUN="sum" )
      dnk=aggregate(x=subset(dn,select='k'),by=subset(dn,select=c('pzd')), FUN="max" )
      dnk=dnk[(dnk$k>1),];dnk$k=NULL
      dn=merge(dn,dnk,by='pzd');dn$k=1
      dn[,max_pol]=NA;result=rbind(result,dn)
    }
    rm(dn,dnk)
  }
  
  {#вычисление кто первый - уже по датам и поездам - теперь по расписанию
    rasp1$Tm=round((rasp1$vrmo-10)/100);
    rasp1$Tm=rasp1$vrmo-40*rasp1$Tm+1440*rasp1$do #время отправления в минутах
    
    rs=rasp1[,c('tab_nom','has','Tm','Rasst')]
    rs1=rs[(rs$Rasst==0),];rs1$Tm_otp=rs1$Tm;rs1$Rasst=NULL;rs1$tm1=rs1$Tm;rs1$Tm=NULL
    rs2=aggregate(x=subset(rs,select=c('Rasst')),by=subset(rs,select=c('tab_nom','has')), FUN="max" )
    rs2=merge(rs2,rs,by=c('tab_nom','has','Rasst'))
    rs2$tm2=rs2$Tm;rs2$Tm=NULL
    rs1=merge(rs1,rs2,by=c('tab_nom','has'))
    rs1$time=rs1$tm2-rs1$tm1
    rs1$Rasst=NULL;rs1$tm2=NULL
    rs1=merge(rs1,pzd,by=c('tab_nom','has'))
    
    mar=merge(rasp2,rs1,by=c('tab_nom','has'))
    mar$tab_nom=NULL;mar$has=NULL
    
    o=order(mar$Date,mar$pzd,mar$tm1);mar=mar[o,]
    mar$n=(1:nrow(mar))
    mar_=aggregate(x=subset(mar,select=c('n')),
                   by=subset(mar,select=c('Date','pzd')), FUN="min" )
    mar_$nn=mar_$n;mar_$n=NULL
    mar=merge(mar,mar_,by=c('Date','pzd'))
    mar$First=mar$n+1-mar$nn;mar$nn=NULL
    
    o=order(mar$Date,mar$pzd,mar$time);mar=mar[o,]
    mar$n=(1:nrow(mar))
    mar_=aggregate(x=subset(mar,select=c('n')),
                   by=subset(mar,select=c('Date','pzd')), FUN="min" )
    mar_$nn=mar_$n;mar_$n=NULL
    mar=merge(mar,mar_,by=c('Date','pzd'))
    mar$Skor=mar$n+1-mar$nn;mar$nn=NULL;mar$n=NULL
    mar$tm1=NULL;mar$time=NULL;
    o=order(mar$Date,mar$pzd,mar$Train);mar=mar[o,]
    o=order(result$Date,result$pzd,result$Train);result=result[o,]
    
    result=merge(mar, result, by = c("Date","pzd","Train"),all=TRUE)
    result=result[(!is.na(result$k)),]
    result[(is.na(result$First)),c('First','Skor')]=0
    result$k=NULL
    rm(rs,rs1,rs2,mar,mar_,o)
  }
  
  #result <- cbind(subset(result, select = c(Date, Train, Type, Seats, min_mest)),
  #                subset(result, select = -c(Date, Train, Type, Seats, min_mest)))
  return (result)
  
  kday=1;pzd=1;rasp1=1;rasp2=1;result=1;
  kol_day=1;max_date=1;max_pol=1;mdt=1;min_date=1;sum_pol=1;
  rm(kday,pzd,rasp1,rasp2,result,kol_day,max_date,max_pol,mdt,min_date,sum_pol)
}
# пример запуска   result=myPackage$trs.tData.extractor(pData, wData, pzd,rasp1,rasp2, kol_day)











#Экстракция данных в базу, всё что есть по указанному направлению (станции начала и конца)
myPackage$trs.tData.extract_mars <- function(napr) {
  
  {#0.проверка наличия записи в память
    info=myPackage$trs.dann_load('info','rez')
    
    inf=info[(info$Database=='dann')&(info$vid %in% c('pas','vag','rasp1','rasp2','stan')),]
    inf=inf[,c('tab_nom','vid','min_date','max_date')]
    inf$Database=napr$name;inf$ext=1
    inf_=merge(info,inf, by=names(inf))
    good=(nrow(inf)==nrow(inf_))
    for (vid in c('ext','pzd')){#если нет файла данных или поездов
      dbPath=myPackage$trs.file_adres(napr$name,vid) 
      if (is.null(dbPath)){good=FALSE}else{if (!file.exists(dbPath)){good=FALSE}}}
    rm(inf_,dbPath,vid)
  }
  
  if (!good){
    
    {#1.просто маршруты нужные
      mars=myPackage$trs.dann_load('dann','rasp3') # только станции и сутки. has2 создан уже внутри R
      mr1=mars[(mars$Stan %in% napr$sto),];mr1$r1=mr1$Rasst;mr1$Sto=mr1$Stan;mr1=mr1[,c('has2','r1','Sto')]
      mr2=mars[(mars$Stan %in% napr$stn),];mr2$r2=mr2$Rasst;mr2$Stn=mr2$Stan;mr2=mr2[,c('has2','r2','Stn')]
      mr=merge(mr1,mr2,by='has2')
      rm(mr1,mr2)
      mr$rst=abs(mr$r1-mr$r2)
      mr_=aggregate(x=subset(mr,select=c('rst')),by=subset(mr,select=c('has2')), FUN="max" )
      mr=merge(mr,mr_,by=c('has2','rst')) # по каждому маршруту - максимальное из входящих
      
      mars=mars[(mars$has2 %in% mr$has2),]
      
      mr_=aggregate(x=subset(mars,select=c('Rasst')),by=subset(mars,select=c('has2')), FUN="max" )
      mr=merge(mr,mr_,by=c('has2')) #полная длина маршрута
      mr$napr=(mr$r1<mr$r2)*2-1;rm(mr_)
      
      # число типов = 1:N по числу поездов, N+1 = больше любого из них
      mr$tip=2;mr[(mr$rst==mr$Rasst),'tip']=1 # маршрут строго от и до
      sts=unique(mr[,c('Sto','Stn')])
      sts$pzd=(1:nrow(sts));mr=merge(mr,sts,by=c('Sto','Stn'))
      sts=max(sts$pzd)+1;mr[(mr$tip==2),'pzd']=sts;mr[(mr$tip==2),c('Sto','Stn')]=NA
      #mr$tip=mr$pzd;mr$pzd=NULL;
      mr$Rasst=NULL}
    
    
    {#2. теперь и расписания
      rasp1=myPackage$trs.dann_load('dann','rasp1') # полные маршруты с временами, в часах-минутах
      rasp1=rasp1[(rasp1$has2 %in% mr$has2),]
      rasp1=rasp1[(rasp1$Stan %in% c(napr$sto,napr$stn)),]
      
      mar=mr;mar$Rasst=mar$r1
      mar=merge(mar,rasp1,by=c('has2','Rasst'))
      o=(mar$napr==1)
      mar[o,'dotp']=mar[o,'do'];mar[o,'otp']=mar[o,'vrmo']
      mar[!o,'dprib']=mar[!o,'dp'];mar[!o,'prib']=mar[!o,'vrmp']
      for (nm in c('Rasst','do','dp','vrmo','vrmp','Stan')){mar[,nm]=NULL}
      
      mar$Rasst=mar$r2
      mar=merge(mar,rasp1,by=c('has2','has','Rasst','tab_nom'))
      o=(mar$napr==-1)
      mar[o,'dotp']=mar[o,'do'];mar[o,'otp']=mar[o,'vrmo']
      mar[!o,'dprib']=mar[!o,'dp'];mar[!o,'prib']=mar[!o,'vrmp']
      for (nm in c('Rasst','do','dp','vrmo','vrmp','Stan')){mar[,nm]=NULL}
      
      mar$h=round((mar$otp-10)/100);mar$totp=mar$otp-40*mar$h
      mar$h=round((mar$prib-10)/100);mar$tprib=mar$prib-40*mar$h
      mar$h=NULL
      mar$tm=(mar$tprib-mar$totp)+24*60*(mar$dprib-mar$dotp)
      
      for (nm in c('otp','prib','tprib','dprib','r1','r2')){mar[,nm]=NULL} # подчистка полей
      #готовы все нужные данные по расписаниям. теперь их в реальные отправки поставить.
    }
    
    
    {#3.все расписания по датам отправки
      rasp2=myPackage$trs.dann_load('dann','rasp2') # какие поезда когда идут
      rasp2=rasp2[(rasp2$has2 %in% mr$has2),]
      
      rasp=merge(rasp2,mar,by=c('has','tab_nom','has2'))
      rasp$dt=as.Date(as.numeric(as.Date(rasp$Date))+rasp$dotp)
      
      #вычислить First Skor
      #First
      o=order(rasp$napr,rasp$tip,rasp$dt,rasp$totp);rasp=rasp[o,];rasp$n=(1:nrow(rasp))
      rs=aggregate(x=subset(rasp,select=c('n')),by=subset(rasp,select=c('napr','tip','dt')), FUN="min" )
      rs$nn=rs$n;rs$n=NULL;rasp=merge(rasp,rs,by=c('napr','tip','dt'))
      rasp$First=rasp$n-rasp$nn+1;rasp$nn=NULL
      #First2 - то же самое, но по всем типам
      o=order(rasp$napr,rasp$dt,rasp$totp);rasp=rasp[o,];rasp$n=(1:nrow(rasp))
      rs=aggregate(x=subset(rasp,select=c('n')),by=subset(rasp,select=c('napr','dt')), FUN="min" )
      rs$nn=rs$n;rs$n=NULL;rasp=merge(rasp,rs,by=c('napr','dt'))
      rasp$First2=rasp$n-rasp$nn+1;rasp$nn=NULL
      
      #Skor
      o=order(rasp$napr,rasp$tip,rasp$dt,rasp$tm);rasp=rasp[o,];rasp$n=(1:nrow(rasp))
      rs=aggregate(x=subset(rasp,select=c('n')),by=subset(rasp,select=c('napr','tip','dt')), FUN="min" )
      rs$nn=rs$n;rs$n=NULL;rasp=merge(rasp,rs,by=c('napr','tip','dt'))
      rasp$Skor=rasp$n-rasp$nn+1;rasp$nn=NULL
      #Skor2 - то же самое, но по всем типам
      o=order(rasp$napr,rasp$dt,rasp$tm);rasp=rasp[o,];rasp$n=(1:nrow(rasp))
      rs=aggregate(x=subset(rasp,select=c('n')),by=subset(rasp,select=c('napr','dt')), FUN="min" )
      rs$nn=rs$n;rs$n=NULL;rasp=merge(rasp,rs,by=c('napr','dt'))
      rasp$Skor2=rasp$n-rasp$nn+1;rasp$nn=NULL
      rm(rs)
      
      rasp[(rasp$tip>1),c('First','First2','Skor','Skor2')]=0
      for (nm in c('tab_nom','rst','dotp','totp','tm','n','has','has2')){rasp[,nm]=NULL} # подчистка полей
    }
    
    
    {# 4.теперь данные по вагонам
      # выдаёт ошибку In scan(file = file, what = what, sep = sep, quote = quote, dec = dec,  : 
      #   embedded nul(s) found in input
      rasp$Sto=NULL;rasp$Stn=NULL;
      
      vag=myPackage$trs.dann_load('dann','vag')
      train=unique(as.character(rasp$Train))
      polls=c('Seats','FreeSeats','Kol_vag','max_seats','Vag_km','Seats_km') # список суммируемых полей
      for (nm in polls){vag[,nm]=as.numeric(as.character(vag[,nm]))} #в числовые типы 
      
      {# отдельно что точно не распознано
        vag0=vag[(!(vag$Train %in% train)),]
        vag0$Klass=substr(vag0$Klass,1,1)
        vag0$Type=paste(vag0$Type,vag0$Klass,sep='')
        vag0=vag0[(vag0$Type!='-'),];#pp=vag;pp$Type='-';vag=rbind(vag,pp)
        vag0=aggregate(x=subset(vag0,select=polls),
                       by=subset(vag0,select=c('Type','Date')),
                       FUN="sum" )
        for (nm in c('First','First2','Skor','Skor2','tip','pzd','napr')){vag0[,nm]=0}
        vag0$Train='-';vag0$dt=vag0$Date;vag0$Date=NULL}
      
      {# распознаваемое
        vag=vag[(vag$Train %in% train),]
        vag=merge(vag,rasp,by=c('Date','Train'),all=TRUE)
        vag=vag[(!is.na(vag$Seats)),]
        vag[(is.na(vag$napr)),c('First','First2','Skor','Skor2','tip','pzd','napr')]=0
        
        vag$Train=as.character(vag$Train)
        vag[(vag$tip!=1),'Train']='-'
        vag$Klass=substr(vag$Klass,1,1)
        vag$Type=paste(vag$Type,vag$Klass,sep='')
        vag=vag[(vag$Type!='-'),];#pp=vag;pp$Type='-';vag=rbind(vag,pp)
        o=(is.na(vag$dt));vag[o,'dt']=vag[o,'Date']
        vag=aggregate(x=subset(vag,select=polls),
                      by=subset(vag,select=c('Train','Type','napr','dt','tip','pzd','First','First2','Skor','Skor2')),
                      FUN="sum" )
        #не помню - что есть max_seats - УБРАЛ!
      }
      
      {# слить оба, и добавить сумму по всем типам
        vag$dt=as.Date(vag$dt)
        vag0=vag0[(!is.na(vag0$Vag_km)),] #грязь входных данных
        vag0$dt=as.Date(vag0$dt)
        vag=rbind(vag,vag0)
        pp=vag;pp$Type='-';vag=rbind(vag,pp)
        vag=aggregate(x=subset(vag,select=polls),
                      by=subset(vag,select=c('Train','Type','napr','dt','tip','pzd','First','First2','Skor','Skor2')),
                      FUN="sum" )
        rm(pp,vag0,polls)
      }
    }
    
    {#5.теперь надо пассажиров
      {# как определить последнюю дату загрузки?
        info=myPackage$trs.dann_load('info','rez') # ЧТО БЫЛО ПРОЧИТАНО РАНЬШЕ?
        info=info[(info$Database=='dann')&(info$vid=='pas'),]
        max_dt=max(as.Date(as.character(info$max_date)))
        
        dp=aggregate(x=subset(rasp1,select=c('dp')),by=subset(rasp1,select=c('has','tab_nom')),FUN="max" )
        dp=merge(dp,mar,by=c('has','tab_nom'))
        dp=max(dp$dp-dp$dotp)
        max_dt=max_dt-dp-3;rm(info,dp)}
      
      pas=myPackage$trs.dann_load('dann','pas') #исходник пассажиров
      
      polls=c('Kol_pas','Pkm','Plata','Cena')
      for (nm in polls){pas[,nm]=as.numeric(as.character(pas[,nm]))} #в числовые типы
      
      {# нераспознаваемые
        pas0=pas[(!(pas$Train %in% train)),]
        pas0$Klass=substr(pas0$Klass,1,1)
        pas0$dt=as.Date(pas0$Date)
        pas0=pas0[(pas0$dt<=max_dt),]
        pas0$Type=paste(pas0$Type,pas0$Klass,sep='')
        pas0=pas0[(pas0$Type!='-'),];#pp=pas;pp$Type='-';pas=rbind(pas,pp)
        
        pas0=aggregate(x=subset(pas0,select=polls),
                       by=subset(pas0,select=c('Type','dt')),
                       FUN="sum" )  # by=...,'Skp'
        for (nm in c('First','First2','Skor','Skor2','tip','pzd','napr')){pas0[,nm]=0}
        pas0$Train='-';
      }
      {#распознанные
        pas=pas[(pas$Train %in% train),]
        pas$Klass=substr(pas$Klass,1,1)
        pas$tab_nom=NULL
        
        pas$Date=as.Date(pas$Date)
        pas$Train=as.character(pas$Train)
        pas=merge(pas,rasp,by=c('Train','Date'),all=TRUE)
        pas=pas[(!is.na(pas$Kol_pas)),]
        pas[(is.na(pas$napr)),c('First','First2','Skor','Skor2','tip','pzd','napr')]=0
        o=(is.na(pas$dt));pas[o,'dt']=pas[o,'Date']
        
        pas=pas[(pas$dt<=max_dt),]
        pas[(pas$tip!=1),'Train']='-'
        pas$Type=paste(pas$Type,pas$Klass,sep='')
        pas=pas[(pas$Type!='-'),];#pp=pas;pp$Type='-';pas=rbind(pas,pp)
        
        pas=aggregate(x=subset(pas,select=polls),
                      by=subset(pas,select=c('Train','Type','napr','dt','tip','pzd','First','First2','Skor','Skor2')),
                      FUN="sum" )  # by=...,'Skp'
      }
      {#слияние нулевых и распознаных
        pas=rbind(pas,pas0)
        pp=pas;pp$Type='-';pas=rbind(pas,pp)
        pas=aggregate(x=subset(pas,select=polls),
                      by=subset(pas,select=c('Train','Type','napr','dt','tip','pzd','First','First2','Skor','Skor2')),
                      FUN="sum")
        
        # переименования до нужных
        pas$kp0=pas$Kol_pas;pas$pkm0=pas$Pkm;pas$scena0=pas$Cena;pas$plata0=pas$Plata
        for (nm in c('Kol_pas','Plata','Cena','Pkm')){pas[,nm]=NULL} # подчистка полей
      }
    }
    
    
    
    {# 6.чтение по станциям
      stan=myPackage$trs.dann_load('dann','stan')
      
      sts=c(napr$sto,napr$stn);sts=as.character(sts)
      st=substr(sts,1,2);st=c(st,0);sts=unique(c(sts,st));rm(st)
      stan=stan[((stan$Sto %in% sts)&(stan$Stn %in% sts)),]
      
      max_dt=max(as.character(inf[(inf$vid=='stan'),'max_date']))
      stan$Date=as.character(stan$Date)
      stan=stan[(stan$Date<=max_dt),]
      
      stan_=stan[(stan$Type!='-'),]
      stan_$Type='-';stan=rbind(stan,stan_);rm(stan_)
      stan=aggregate(x=subset(stan,select=c('Kol_pas','Pkm','Plata','Cena')),
                     by=subset(stan,select=c('Date','Sto','Stn','Type')),FUN="sum")
      
      {#кого оставить - по sto-stn по наличию дат
        st=aggregate(x=subset(stan,select=c('Kol_pas')),
                     by=subset(stan,select=c('Date','Sto','Stn')),FUN="sum")
        st$k=1
        st=aggregate(x=subset(st,select=c('k')),by=subset(st,select=c('Sto','Stn')),FUN="sum")
        mk=max(st$k);st=st[(st$k>=mk*0.95),];st$k=NULL
        stan=merge(stan,st,by=c('Sto','Stn'))
        st$nm=paste('stan_pas',st$Sto,st$Stn,sep='_')
      }
      
      {#теперь привоить номера поездов, и направления, для невозможных - создать
        stan$napr=0;
        stan[((stan$Sto %in% napr$sto)&(stan$Stn %in% napr$stn)),'napr']=1
        stan[((stan$Sto %in% napr$stn)&(stan$Stn %in% napr$sto)),'napr']=-1
        stan[((stan$napr==0)&(stan$Sto>stan$Stn)),'napr']=-1
        stan[((stan$napr==0)&(stan$Sto<stan$Stn)),'napr']=1
        
        o=(stan$napr==-1)
        stan[o,'c']=stan[o,'Sto'];stan[o,'Sto']=stan[o,'Stn'];stan[o,'Stn']=stan[o,'c']
        stan$c=NULL
        
        pzd=unique(mr[,c('pzd','Sto','Stn')])
        stan=merge(stan,pzd,by=c('Sto','Stn'),all=TRUE)
        stan=stan[(!is.na(stan$Date)),]
        o=(is.na(stan$pzd))
        stan[o,'pzd']=paste(stan[o,'Sto'],stan[o,'Stn'],sep='-')
        stan$Sto=NULL;stan$Stn=NULL;}
      
      
      stan_=stan[(stan$napr!=0),]
      stan_=aggregate(x=subset(stan_,select=c('Kol_pas','Pkm','Plata','Cena')),
                      by=subset(stan_,select=c('Date','Type','pzd')),FUN="sum")
      stan_$napr=0
      stan=rbind(stan,stan_)
      stan$stan_pas=stan$Kol_pas;stan$stan_plata=stan$Plata;stan$stan_pkm=stan$Pkm;
      stan$stan_cena=stan$Cena;stan$Napr=stan$napr;
      stan$Kol_pas=NULL;stan$Plata=NULL;stan$Pkm=NULL;stan$Cena=NULL;stan$napr=NULL;
      rm(stan_)
    }
    
    
    
    {#7.итоговые данные - кроме станций - их отдельно
      dann=merge(pas,vag,by=c('Train','Type','napr','dt','tip','pzd','First','First2','Skor','Skor2'),all=TRUE)
      
      dann=dann[(!is.na(dann$Kol_vag)),] #убрать видимо ошибки 
      dann$Date=dann$dt;dann$dt=NULL
      dann[(dann$Date>max_dt),'FreeSeats']=NA # в будущем свободные места ещё неизвестны
      dann$max_seats=NULL # не помню смысла поля
      dann$pzd=dann$napr*dann$pzd
      dann$zan_mest=dann$Seats-dann$FreeSeats
      dann$FreeSeats=NULL
      #ещё признак - строки которые надо прогнозировать, а не просто данные
      dann$dann=1 # данные в настройку прогноза
      dann[(dann$Date>max_dt),'dann']=2 # данные в прогноз
      dann[(dann$tip!=1),'dann']=0 # данные вспомогательные
      dann$napr=NULL;dann$tip=NULL
    }
    
    {#8.запись в память
      myPackage$trs.Data_save(dann, napr$name,'ext',TRUE) #данные по поездам
      #myPackage$trs.Data_save(dt, paste(napr$name,'sts',sep='_'),'ext',TRUE) #данные по станциям
      myPackage$trs.Data_save(stan, paste(napr$name,'sts',sep='_'),'ext',TRUE) #данные по станциям
      pzd=unique(mr[,c('pzd','napr','Sto','Stn')])
      o=(pzd$napr==-1)
      pzd[o,'st']=pzd[o,'Sto'];pzd[o,'Sto']=pzd[o,'Stn'];pzd[o,'Stn']=pzd[o,'st']
      pzd$st=NULL
      myPackage$trs.Data_save(pzd, napr$name,'pzd',TRUE)
      
      info=myPackage$trs.dann_load('info','rez')
      inf$Time=as.character(Sys.time());
      info=info[(info$Database!=napr$name),]
      info=myPackage$sliv(info,inf)
      myPackage$trs.Data_save(info, 'info','rez',TRUE)
    }
  }
  dann=1;inf=1;info=1;mar=1;mars=1;mr=1;pas=1;pp=1;rasp=1;rasp1=1;rasp2=1;vag=1;
  good=1;max_dt=1;napr=1;nm=1;o=1;train=1;sts=1;pas0=1;vag0=1;pzd=1;polls=1;dt=1;ss=1;st=1;stan=1;mk=1;
  rm(dann,inf,info,mar,mars,mr,pas,pp,rasp,rasp1,rasp2,vag,good,max_dt,napr)
  rm(nm,o,train,sts,pas0,vag0,pzd,polls,dt,ss,st,stan,mk)
}
# napr=list();napr$name='SPb-Murmansk';napr$sto=c(2004001:2004006);napr$stn=2004200
# пример запуска   myPackage$trs.tData.extract_mars(napr) 
















#Экстракция данных в базу, всё что есть. Хранит историю продажи в kol_day дней
myPackage$trs.tData.extract <- function(name,kol_day) {
  # Объединяет агрегированные базы данных о продажах
  # билетов и составности поездов в одну базу.
  # Args:
  #   extractor: метод объединения
  # Returns:
  #   объединенную базу, если extdbName = NULL
  
  if (name=='sapsan'){ name='doss' }
  
  #if (typeof(pData) == "character") {pData=myPackage$trs.pData.aggr.load(pData)}
  #if (typeof(mData) == "character") {mData=myPackage$trs.pData.aggr.load(paste(mData, "_mar", sep = ""))}
  #if (typeof(wData) == "character") {wData=myPackage$trs.wData.aggr.load(wData)}
  
  info=myPackage$trs.dann_load('info','rez') # ЧТО БЫЛО ПРОЧИТАНО РАНЬШЕ?
  info=info[(info$Database==name),]
  info=info[(info$kol_rez>0),]
  info=info[(info$ext!=1)|is.na(info$ext),]
  old=nrow(info[(info$ext==1),])
  
  if (nrow(info)>0){
    # исходники
    pData=myPackage$trs.dann_load(name,'pas')
    wData=myPackage$trs.dann_load(name,'vag')
    
    #mData=myPackage$trs.dann_load(name,'mar')
    pzd=myPackage$trs.dann_load(name,'pzd')  #прежний список поездов
    rasp1=myPackage$trs.dann_load(name,'rasp1')
    rasp2=myPackage$trs.dann_load(name,'rasp2')
    
    min_date=NA
    info=info[(!is.na(info$min_date)),]
    if (nrow(info)>0) {
      min_date=min(as.Date(info$min_date))-2 #пересчёт только того, что ещё не экстрагировалось!
    }
    if (!is.na(min_date)) {# только свежие данные
      pData=pData[(as.Date(pData$Date)>=min_date),]
      wData=wData[(as.Date(wData$Date)>=min_date),]
      rasp2=rasp2[(as.Date(rasp2$Date)>=min_date),] }
    
    pData$Klass=substr(pData$Klass,1,1);pData[(pData$Klass==pData$Type),'Klass']='-' 
    wData$Klass=substr(wData$Klass,1,1);wData[(wData$Klass==wData$Type),'Klass']='-' 
    
    if (name=='sahalin'){pData$Klass='-';wData$Klass='-'}
    
    if (name %in% c('sapsan','doss')){
      pData$Type=pData$Klass;pData$Klass='-';
      wData$Type=wData$Klass;wData$Klass='-'; }
    
    
    # собственно рассчёт истории заполнения каждого конкретного поезда
    result=myPackage$trs.tData.extractor(pData, wData, pzd,rasp1,rasp2, kol_day)  #СОБСТВЕННО НАРАБОТКА ДАННЫХ
    #result=res$result;pzd=res$pzd;rm(res)
    
    if (name %in% c('sapsan','sahalin','doss')){result$Klass=NULL}
    
    if (!is.na(min_date)) {   
      min_date=min_date+2
      result=result[(as.Date(result$Date)>=min_date),] 
      
      # чтение старых агрегатов
      if (old>1){# если раньше что-то было
        old_rez=myPackage$trs.dann_load(name,'ext')
        if (!is.null(old_rez)>0){
          old_rez=old_rez[(as.Date(old_rez$Date)<min_date),]
          result=myPackage$sliv(old_rez,result)}
        rm(old_rez)}
    }
    
    #запись в память
    myPackage$trs.Data_save(result, name,'ext',TRUE)
    #myPackage$trs.Data_save(pzd, name,'pzd',TRUE)
    
    info=myPackage$trs.dann_load('info','rez')
    info[(info$Database==name),'ext']=1
    myPackage$trs.Data_save(info, 'info','rez',TRUE)
  }
  #return (result) 
  
  result=1;min_date=1;pData=1;wData=1;rasp1=1;rasp2=1;old=1;pzd=1;
  
  rm(info,pData,result,wData,kol_day,min_date,name,rasp1,rasp2,old,pzd)
}
#Экстракция данных в базу, всё что есть. Хранит историю продажи в kol_day дней
#   kol_day=c(0,7);   name='sahalin';
#   myPackage$trs.tData.extract(name,kol_day) 







# удаление всех лишних переменных
#rm(dann,aggrdb,shema,cols,dbPath, form,tmp,text,matrix,file,filePath,files,path,vid,srok,name,info,matrix_mar,first)
#rm(format,kol_mar,kol_rez,kol_zap,mm,cen,mar,pass,rawdb,by,ll,SDcols,mar_,pass_,marb,sh,sh_,she,mar_pzd,dn)
#rm(min_dat,max_dat,vcd_rus,matrix_,files_,shemi,fl,i,kol_f,ksh,l,len,pr,s,z,f,ff,kol,p,pp,sp,maro,maro_,marp,by_t)
#rm(mData,pData,wData)

