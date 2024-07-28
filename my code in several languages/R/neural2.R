

#программа для генетического алгоитма выбора лучших нейросетей










#создание случайной нейросети. с ограничением по числу входов и миним запаздыванию
#             max_vhod=2;min_before=10;  ogran=list(o2='Seats',o1='') #ogran$o1=min , o2=max
neural$trs.sozd_neir <- function(dannie,max_vhod,min_before,ogran) {
  
  #наличие ограничений на вход
  ogr1='-';ogr2='-';
  if(typeof(ogran)!='list'){ogran=0}else{ogr1=ogran$o1;ogr2=ogran$o2;ogran=1}
  
  #далее создать данные -3 случайных входа и 1 выход
  tip_all=dannie$tip_all
  progn=tip_all[(tip_all$progn=='1'),]
  
  tip_n=unique(subset(progn,select=c('tip_n','tip')))
  tip_n=tip_n[order(runif(nrow(tip_n))),]
  tip=tip_n[1,2];tip_n=tip_n[1,1];
  progn=progn[ (progn$tip_n==tip_n) ,]
  
  #params=dannie$params;
  params=dannie$id_params;
  #  pars=unique(subset(progn,select=params))
  
  #ВЫХОД УЖЕ ЕСТЬ, ТЕПЕРЬ ВОПРОС - ЧТО ВОЗМОЖНО НА ВХОД?
  #tip_isp=merge(tip_all,pars,by=params);
  tip_isp=tip_all[((tip_all$tip==tip)|(tip_all$name %in% c('weekday','month'))),]
  tip_isp=unique(subset(tip_isp,select=c('tip_n','name','max_bef','tip','tab','vid')))
  
  ograns=tip_isp[((tip_isp$name==ogr1)|(tip_isp$name==ogr2)),]
  tip_isp=tip_isp[((tip_isp$name!=ogr1)&(tip_isp$name!=ogr2)),]
  if (nrow(ograns)==0){ogran=0}
  
  vhod=tip_isp;vhod$ord=runif(nrow(vhod))+10;
  #vhod[(vhod$max_bef==-1),'ord']=0;
  #установка порядка нескольких первых входов
  vhod[(substr(vhod$name,1,5)=='Seats'),'ord']=1
  vhod[(vhod$name=='weekday'),'ord']=2
  vhod[(substr(vhod$name,1,3) %in% c('kp.','kp')),'ord']=3
  
  vhod=vhod[order(vhod$ord),];vhod$vhod=1:nrow(vhod);
  vhod=vhod[(vhod$vhod<=max_vhod),]
  #за сколько дней до отправки поезда берутся данные
  vhod$bef_otp=pmax(round(runif(nrow(vhod))*(pmin(vhod$max_bef,30)+1)-0.5),0)
  if (nrow(vhod[(vhod$ord==3),])>0){vhod[(vhod$ord=3),'bef_otp']=min_before}
  vhod$ord=NULL
  # на какой именно поезд берутся данные - текущий (=0) или предыдущий/последующий
  vhod$before=pmax(min_before-vhod$bef_otp,0) #тут вместо 0 можно -1 или -2 - был бы смысл только
  vhod[(vhod$max_bef==-1),'before']=0
  #поиск, за сколько получилась нейросеть?
  before=vhod[(vhod$max_bef!=-1),]
  if (nrow(before)>0){before=min(before$before+before$bef_otp)}else{before=NA}
  vhod$max_bef=NULL;#vhod$vid='x'
  #vhod$vibor=1#индекс подвыбора - пока только 1:1, потом и иные
  
  #добавляем и выход - вход=0
  vh=unique(subset(progn,select=c('name','tip','tip_n','tab')))
  vh[,c('vhod','bef_otp','before')]=0;vh$vid='y'
  vhod=rbind(vh,vhod)
  #добавляем ограничения
  if (ogran==1){
    vh=unique(subset(ograns,select=c('name','tip','tip_n','tab')))
    vh[,c('vhod','bef_otp','before')]=0;
    vh[(vh$name==ogr1),'vid']='ym.1';vh[(vh$name==ogr2),'vid']='ym.2';
    vhod=rbind(vh,vhod)}
  
  #сперва что выбираем - парамерт выбора
  vibor=progn[1,];
  vibor=subset(vibor,select=params)
  for (nm in params){zn=unique(subset(progn,select=nm))
  if (nrow(zn)==1){vibor[,nm]=zn[1,nm]}else{vibor[,nm]='*'} }
  
  vibor$vhod=-1;vibori=vibor[0,]
  for (vh in unique(vhod$vhod)){vib=vibor;
  tip_n=vhod[(vhod$vhod==vh)&(vhod$vid %in% c('y','x','m')),'tip_n'];
  zn=tip_all[(tip_all$tip_n==tip_n),]
  if (nrow(zn)==1){for (nm in params){vib[,nm]=zn[,nm]}}
  vib$vhod=vh;
  #if ((runif(1)<=0.5)&(vibor$Napr=='*')&(vh>0)){
  #  if (runif(1)<=0.5){vib$Napr='0'}else{vib$Napr='1'}}
  vibori=rbind(vibori,vib); }
  vibor=vibori;rm(vib,vibori) 
  
  #постановка массивов - все изменяемые параметры, кроме номера поезда
  x=count(vhod$vid)
  k=list();k$versia=0;k$kol_neir=0;k$ogran=ogran;if(ogran==1){k$ogr_k=0.1}
  k$x=max(0,x[(x$x=='x'),'freq']);k$m=max(0,x[(x$x=='m'),'freq']);
  vib=vibor[(vibor$vhod==0),]
  for (nm in params){if (!(nm %in% c('Train','id_Train'))){
    if (vib[1,nm]=='*'){k$m=k$m+1;vh=vhod[0,];vh=vh[1,]
    vh$name=nm;vh$vid='m';vh$vhod=k$x+k$m;vh$tab=0;vhod=rbind(vhod,vh) }
  }}
  vhod$tip_n=NULL
  sozd=list(name=dannie$name,vibor=vibor,vhod=vhod,before=before)
  k$best_sigma=0;# ограничитель средней точности прогноза
  neir=list(sozd=sozd);neir$k=k
  return(neir)
}










#собственно подготовка данных, пока без оптимизации
neural$trs.sozd_neir_dann <- function(dannie,neir) {
  
  sozd=neir$sozd;k=neir$k;vhod=sozd$vhod;vibor=sozd$vibor;
  id_params=dannie$id_params;params=dannie$params;
  ogran=vhod[(!(vhod$vid %in% c('x','y','m'))),]
  vhod=vhod[(vhod$vid %in% c('x','y','m')),]
  k$ogr_min=nrow(ogran[(ogran$vid=='ym.1'),]);k$ogr_max=nrow(ogran[(ogran$vid=='ym.2'),]);
  
  #список сохраняемых полей, с координатами поля Y
  hran=c('Seats');
  if (vhod[(vhod$vhod==0),'name'] %in% c('kp.Napr','kol_mest.Napr')){hran=c('Seats.Napr')}
  
  vhod[is.na(vhod$tip),'tip']=0
  x=0;m=0;y=0
  for (vh in 0:(nrow(vhod)-1)){
    if (vhod[(vhod$vhod==vh),'vid']=='x'){x=x+1;vhod[(vhod$vhod==vh),'nom']=x}
    if (vhod[(vhod$vhod==vh),'vid']=='m'){m=m+1;vhod[(vhod$vhod==vh),'nom']=m}
    if (vhod[(vhod$vhod==vh),'vid']=='y'){y=y+1;vhod[(vhod$vhod==vh),'nom']=y}
  };rm(x,m,y)
  if (nrow(ogran)>0){ogran$nom=0;vhod=rbind(vhod,ogran)}  ####
  
  vhod$tip_n=NULL;vhod$tab=NULL
  tip_all=unique(subset(dannie$tip_all,select=c('name','tip','tip_n','tab')))
  vhod=merge(vhod,tip_all,by=c('name','tip'),all=T);
  vhod=vhod[(!is.na(vhod$vhod)),]
  vhod=vhod[order(is.na(vhod$tip_n),vhod$vhod,vhod$vid),];vhod$vh=1:nrow(vhod)
  vhod[(is.na(vhod$tip_n)),'vh']=0;max_vh=max(vhod$vh)
  
  #блок - сохраняем ПЕРВЫЙ вход с подходящим именем
  vhod$hr=as.integer(vhod$name %in% hran)
  nm=aggregate(x=list(min_vh=vhod$vhod),by=list(name=vhod$name), FUN='min')
  vhod=merge(vhod,nm,by='name');vhod[(vhod$vhod>vhod$min_vh),'hr']=0
  vhod$min_vh=NULL
  
  for (vh in 1:max_vh){
    #  vh=1
    vhod_=vhod[(vhod$vh==vh),];vhod_zn=vhod_[1,'vhod']
    tab=vhod_[1,'tab'];bef=vhod_[1,'bef_otp'];before=vhod_[1,'before']
    tip_n=vhod_[1,'tip_n']
    nm=as.character(vhod_[1,'name']);nom=vhod_[1,'nom'];vid=vhod_[1,'vid'];nam=nm;hr=vhod_$hr
    
    if (tab=='1'){dann=dannie$rez_dann1;dann$zn=dann[,paste('zn',bef,sep='')]}
    if (tab=='2'){dann=dannie$rez_dann2;}
    if (tab=='3'){dann=dannie$rez_dann3;dann$zn=dann[,nm]}
    if (tab=='4'){dann=dannie$rez_dann4;dann$zn=dann[,nm]}
    
    if (tab %in% c('1','2')){dann=dann[(dann$tip_n==tip_n),];
    dann=subset(dann,select=c(params,id_params,'Date','zn','dann_tip'))}else
    {dann=subset(dann,select=c('Date','zn'))}
    
    vib=vibor[(vibor$vhod==vhod_zn),]
    sklei=c('Date')
    for (nm in id_params){if ((vib[1,nm]=='*')&(!is.na(vib[1,nm]))){sklei=c(sklei,nm)}else
    {zn=as.character(vib[1,nm]);if (!is.na(zn)){dann=dann[(dann[,nm]==zn),]} }  }
    
    dann$Date=as.Date(dann$Date)+before;xx='y'
    if(vid %in% c('y','ym.1','ym.2')){dann[,vid]=dann$zn;xx=vid}
    if(vid=='x'){xx=paste(vid,nom,sep='.');dann[,xx]=dann$zn}
    if(vid=='m'){xx=paste(vid,nom,sep='.');dann[,xx]=dann$zn}
    if (hr==1){dann[,nam]=dann$zn}
    dann$zn=NULL;xx_=xx;
    if(vid=='y'){rez=dann}else{dann=dann[(!is.na(dann[,xx])),]
    if (hr==1){xx=c(xx,nam)}
    rez=merge(rez,subset(dann,select=c(sklei,xx)),by=sklei)
    }
    rm(dann)
  }
  
  #теперь проверить, нет ли доп ограничений на данные из за склейки со входами
  if(nrow(rez)>0){
    vibor_=vibor[(vibor$vhod==0),];
    vib=unique(subset(rez,select=id_params))
    for (nm in id_params){zn=unique(subset(vib,select=nm))
    if (nrow(zn)==1){vibor_[,nm]=zn[1,nm]}else{vibor_[,nm]='*'} }
    vibor=vibor[(vibor$vhod!=0),];vibor=rbind(vibor,vibor_);rm(vib,vibor_,zn,nm)
    sozd$vibor=vibor  }
  
  #постановка массивов 
  for (vh in vhod[((vhod$vid=='m')&(is.na(vhod$tip_n))),'vhod']){
    nm=as.character(vhod[(vhod$vhod==vh),'name']);
    nom=vhod[(vhod$vhod==vh),'nom'];rez[,paste('m',nom,sep='.')]=rez[,nm]}
  
  nn=((is.na(rez$y))&(rez$Date<=dannie$max_date))
  if (nrow(rez[nn,])>0){rez[nn,'y']=0} #старых данных нет = нулевые

  neir$sozd=sozd;neir$hran=hran;neir$k=k;
  itog=list(neir=neir,dann=rez)
  return(itog)
}










#прибавить к нейросети входов! Случайным образом
#   min_before=10
neural$trs.sozd_neir_plus <- function(dannie,neir,min_before) {
  popitka=0;bad=1;
  
  while (bad==1){popitka=popitka+1;
  
  #ПРОВЕРКА НА ВОЗМОЖНОСТЬ СУЖЕНИЯ ОБЛАСТИ РАССМОТРЕНИЯ, 20% случаев
  if (runif(1)<0.2){
    tip_all=dannie$tip_all;tip_name=dannie$tip_name;params=dannie$id_params;
    sozd=neir$sozd;k=neir$k;
    vibor=sozd$vibor;vibor=vibor[(vibor$vhod==0),];pars=c()
    for (nm in params){if (vibor[1,nm]=='*'){pars=c(pars,nm)}}
    vv=data.frame(nm=pars);
    if (nrow(vv)>0){vhod=sozd$vhod;
    vv$r=runif(nrow(vv));vv=vv[order(vv$r),];nm=as.character(vv[1,'nm'])
    tip_n=vhod[(vhod$vhod==0),c('tip','name')]
    progn=tip_all[((tip_all$tip==tip_n$tip)&(tip_all$name==as.character(tip_n$name))),]
    vv=unique(subset(progn,select=nm));
    vv$r=runif(nrow(vv));vv=vv[order(vv$r),];zn=as.character(vv[1,nm])
    vibor=sozd$vibor;vibor[(vibor$vhod==0),nm]=zn;
    sozd$vibor=vibor;neir$sozd=sozd;bad=-1;
    }}
  
  if (bad==1){ #если не произошло сужения области рассмотрения
    tip_all=dannie$tip_all;tip_name=dannie$tip_name;params=dannie$id_params;
    sozd=neir$sozd;k=neir$k;
    #выбор, что именно уже прогнозируется
    vhod=sozd$vhod;vibor=sozd$vibor
    tip_n=vhod[(vhod$vhod==0),c('tip','name')]
    progn=tip_all[((tip_all$tip==tip_n$tip)&(tip_all$name==as.character(tip_n$name))),] 
    vibor=vibor[(vibor$vhod==0),]
    umn_param=c()
    
    for (nm in params){if (vibor[,nm]!='*'){vib=as.character(vibor[,nm]);
    progn=progn[(progn[,nm]==vib),];rm(vib)}else{umn_param=c(umn_param,nm)} };
    
    if (nrow(progn)>0){progn$stroka=1:nrow(progn)}
    
    #выбор названия случайного нового входа  tip_name=tip_name[order(tip_name$name),]
    if (nrow(vhod[(vhod$name=='Seats'),])>0){
      tip_name=tip_name[(substr(tip_name$name,1,5)!='Seats'),]} #нельзя добавлять места - 1 раз уже есть
    tip_name=tip_name[order(runif(nrow(tip_name))),]
    tip_n=as.integer(tip_name$tip_n[1])
    
    
    vozm=tip_all[(tip_all$tip_n==tip_n),]
    vibor=sozd$vibor;vibor_=vibor[0,];vibor_=vibor_[1,];vibor_$vhod="new"
    for (nm in umn_param){#не склеиваем по полю. в котором единственное возможное значение
      if (nrow(unique(subset(vozm,select=nm) ))==1){umn_param=setdiff(umn_param,nm)}}
    
    for (nm in params){ if (!is.na(vozm[1,nm])){vibor_[,nm]='*'}}
    
    #проверка. можно ли корректно перемножить, если нет - в цикле увеличить фильтр
    pro=merge(vozm,progn,by=umn_param);#возможен результат умножения - пустой
    
    if(nrow(pro)==0){pro=0}else{
      pro$ed=1;pro=aggregate(x=pro$ed,by=list(pro$stroka),FUN='sum');pro=max(pro$x)}
    
    if (pro!=1){
      pars=data.frame(name=params);pars$e=pars$name
      pars=pars[order(runif(nrow(pars))),];pars$ord=1:nrow(pars)
      bad=1;ord=0
      while (bad==1){
        ord=ord+1;nm=as.character(pars[(pars$ord==ord),'name'])
        vozm=vozm[order(runif(nrow(vozm))),];
        vibor_[,nm]=vozm[1,nm];
        vozm=vozm[(vozm[,nm]==vibor_[,nm]),]
        umn_param=setdiff(umn_param,nm)
        
        pro=merge(vozm,progn,by=umn_param);
        if(nrow(pro)==0){pro=0}else{
          pro$ed=1;pro=aggregate(x=pro$ed,by=list(pro$stroka),FUN='sum');pro=max(pro$x)}
        bad=0;if (pro!=1){bad=1}
      } }
    
    vid=as.character(unique(tip_all[(tip_all$tip_n==tip_n),'vid']))
    vhod_=vhod[0,];vhod_=vhod_[1,];vhod_$vid=vid; ###установили - вход типа X.а не M
    
    #приписать новый вход к списку имеющихся
    kol_vhod=k$x+k$m+1;new_vid=vhod_$vid
    if (vhod_$vid=='x'){ k$x=k$x+1}else{k$m=k$m+1}
    k$kol_vhod=kol_vhod;
    k$kol_ver=k$kol_vhod+k$kol_neir+1
    vibor_$vhod=kol_vhod
    vhod_$vhod=kol_vhod
    vhod_[,c('name','tip','tip_n')]=tip_name[(tip_name$tip_n==tip_n),c('name','tip','tip_n')]
    vhod_$tab=unique(tip_all[(tip_all$tip_n==tip_n),'tab'])
    
    #установка запаздываний - поезда, и до отправки поезда
    bd=1;while (bd==1){
      bef_otp=round(max(vozm$max_bef)*runif(1));
      before=min_before-bef_otp+round(-3*log(runif(1)))
      if ((before>=-1)&(bef_otp+before<=min_before+20)){bd=0}
      if ((bef_otp>=min_before)&(bef_otp<=min_before+20)&(runif(1)<0.3)){bd=0;before=0}
      vhod_$bef_otp=bef_otp;vhod_$before=before
      if (max(vozm$max_bef)==-1){vhod_$bef_otp=0;vhod_$before=0;bd=0}
    }
    
    
    #все уникальные значения поставить в условие выборки
    for (nm in params){if(!is.na(vibor_[1,nm])){
      if(vibor_[1,nm]=='*'){zn=unique(vozm[,nm]);
      if (nrow(data.frame(zn))==1){vibor_[1,nm]=zn}}}}
    
    vhod_$tip_n=NULL;vhod=rbind(vhod,vhod_);vibor=rbind(vibor,vibor_);rm(vhod_,vibor_)
    
    #постановка признака повторного поиска что поставить
    prov=vhod[(!is.na(vhod$tip)),];prov$ed=1;bad=0
    pr=aggregate(x=prov$ed,by=subset(prov,select=c('tip','name','before','bef_otp')),FUN='sum')
    if (max(pr$x)>1){bad=1}#нельзя одинаковые входы (? если отличаются подвыборками)
    pr=aggregate(x=prov$ed,by=subset(prov,select=c('tip','name')),FUN='sum')
    if (max(pr$x)>5){bad=1}#нельзя больше 5 однитипных входов
    if(popitka>20){bad=0}
  }}#завершение попыток
  
  if (bad==0){#если окончание цикла = именно добавление входов. а не сужение пространства
    new_ver=kol_vhod;
    #если новый - числовой, а прежние - массивы, то 
    if ((new_vid=='x')&(k$m>0)){
      vh=subset(vhod,select=c('vhod','vid'))
      vh=vh[order((vh$vid=='m'),vh$vhod),];
      #vh=vh[order(desc(vh$vid),vh$vhod),];
      vh$vh=0:kol_vhod;vh$vid=NULL
      vhod=merge(vhod,vh,by='vhod');vhod$vhod=vhod$vh;vhod$vh=NULL
      vibor=merge(vibor,vh,by='vhod');vibor$vhod=vibor$vh;vibor$vh=NULL
      new_ver=k$x}
    
    sozd$vibor=vibor;sozd$vhod=vhod;
    vhod_=vhod[(vhod$vid=='x'),];vhod_$before=vhod_$before+vhod_$bef_otp;
    vhod_=vhod_[(vhod_$before>0),];
    vhod_=vhod_[(!(vhod_$name %in% c('cena','cenv'))),];#цены, как и места, вне времени
    if (nrow(vhod_)>0){sozd$before=min(vhod_$before)}else{sozd$before=NA}
    
    #и далее рёбра - добавить новые, и перенумеровать вершины 
    rebro=neir$rebro;  
    rr=data.frame(r=1:nrow(rebro))
    rr$vh=rebro[,1];rr$vih=rebro[,2];rr$zn=rebro[,3];
    rr$vih=rr$vih+1;rr[(rr$vh>=new_ver),'vh']=rr[(rr$vh>=new_ver),'vh']+1
    
    rr_=rr[(rr$vh==-1),];rr_$vh=new_ver;rr_$zn=0;rr_$r=NA
    rr=rbind(rr,rr_);rr$z=0;rr[(rr$vh==0),'z']=1;rr[(rr$vh==-1),'z']=2;
    rr=rr[order(rr$vih,rr$z,rr$vh),];rr$r=1:nrow(rr)
    rebro=matrix(0,nrow(rr),3); 
    rebro[,1]=rr$vh;rebro[,2]=rr$vih;rebro[,3]=rr$zn;
    
    neir$rebro=rebro;k$kol_reb=nrow(rr);neir$sozd=sozd;neir$k=k;
  }
  
  if (!is.null(neir$id)){
    pred=list();pred$id=neir$id;pred$versia=neir$k$versia;
    neir$pred=pred;neir$id=NULL;}
  
  return(neir)
}













#прибавить к нейросети входов! Случайным образом
#   min_before=10
myPackage$trs.neir_plus_vhod <- function(dannie,neir,min_before) {  
  bad=1
  while (bad==1){
    
    #прибавить к нейросети входов! Случайным образом
    neir_=neural$trs.sozd_neir_plus(dannie,neir,min_before) 
    #собственно подготовка данных, пока без оптимизации процесса подготовки
    itog=neural$trs.sozd_neir_dann(dannie,neir_);
    
    if (nrow(itog$dann)>100){bad=0}
  }
  return(itog)  
}






######################################################################################
#ГЛАВНОЕ - АНАЛИЗ ПРОГНОЗОВ. ТАБЛИЦА ИТОГОВЫХ ПРОГНОЗОВ
#  prover=c(30,50,100);   name='sahalin'

neural$prognoz_itogi_new <- function(name,prover) {
  
  neir_hist_s_ =myPackage$trs.dann_load('neiroset','sokr')
  neir_hist_s=neir_hist_s_[(neir_hist_s_$activ==1),]
  neir_hist_s=neir_hist_s[(neir_hist_s$name==name),]
  neir_hist_s_=neir_hist_s_[(neir_hist_s_$name!=name)|(neir_hist_s_$activ!=1),]
  #статистики о нейросетях
  select=c('id','before','time','x','step')
  befores=subset(neir_hist_s,select=c('id'))
  for (nm in select){befores[,nm]=neir_hist_s[,nm]}
  
  #befores$train=neir_hist_s$Train;befores$skor=neir_hist_s$Skor;
  befores$prg=neir_hist_s$progn;#befores$sig=neir_hist_s$sigma;
  
  #прогнозы исходники
  progn =myPackage$trs.dann_load('progn','poln')
  progn$Date=as.Date(progn$Date)
  progn$progn=round(progn$progn)
  #progn$progn_neogr=round(progn$progn_neogr)
  progn=progn[(progn$id %in% befores$id),]
  
  #прогнозы - старые и новые  
  progn_new=progn[is.na(progn$Total),]
  progn=progn[!is.na(progn$Total),]
  progn$delt=round(progn$Total)-round(progn$progn)
  max_dt=max(progn$Date)
  progn_new=progn_new[(progn_new$Date>max_dt),]
  
  #tip=unique(progn_new$dann_tip)
  
  #первичные статистики
  col=c('id','Train','Type','delt')
  col=c('id','dann_tip','delt')
  progn_z=subset(progn,select=col)
  progn_z$delt=abs(progn_z$delt);progn_z$kol=1
  progn_z=aggregate(x =list(kol=progn_z$kol),
                    by = subset(progn_z,select=col), FUN = "sum")
  rm(progn)
  
  #блок подсчёта вероятностей превышения показателей
  progn_p=progn_z[1,];progn_p$prover=0;
  for (pr in prover){progn_z$prover=pr;progn_p=rbind(progn_p,progn_z)}
  progn_p$prov=0;progn_p[(progn_p$delt>progn_p$prover),'prov']=1
  
  progn_p=aggregate(x =list(col=progn_p$kol,prov=progn_p$kol*progn_p$prov),
                    by = subset(progn_p,select=c('id','dann_tip','prover')), FUN = "sum")
  
  progn_p=progn_p[(progn_p$prover>0),]
  progn_p=progn_p[(progn_p$col>10),]
  progn_p$proc=round(10000*progn_p$prov/progn_p$col)/100;progn_p$prov=NULL;progn_p$col=NULL
  prov=unique(subset(progn_p,select=c('id','dann_tip')))
  for (pr in prover){
    prov_=progn_p[(progn_p$prover==pr),]
    prov_[,paste('proc_',pr,sep='')]=prov_$proc
    prov_$prover=NULL;prov_$proc=NULL;
    prov=merge(prov,prov_,by=c('id','dann_tip')) }
  
  #итоги важных показателей по каждой нейросети
  zz=aggregate(x =list(err= ((progn_z$delt)**2)*progn_z$kol,col=progn_z$kol),
               by = subset(progn_z,select=c('id','dann_tip')), FUN = "sum")
  #zz=zz[(zz$col>10),]; #убрал здесь ограничение на минимум числа тестов
  zz$sigma=(zz$err/pmax((zz$col-(zz$col**0.5)),0.1))**0.5;
  #zz$sigma=(zz$err/zz$col)**0.5;
  
  zz$sigma=round(zz$sigma*100+0.5)/100
  zz=merge(zz,befores,by='id')
  zz=subset(zz,select=c('id','dann_tip','col','before','sigma','prg'))
  zz=merge(zz,prov,by=c('id','dann_tip')) 
  
  #Все прогнозы
  progn_new=merge(progn_new,zz,by=c('id','dann_tip'))
  
  prg=aggregate(x =list(col=progn_new$col),
                by = subset(progn_new,select=c('dann_tip','Date','prg')), FUN = "max")
  #prg=unique(subset(progn_new,select=c('dann_tip','Date','prg')))
  prg$min_col=pmin(pmax(prg$col-5,1),100)
  prg$id_prog=1:nrow(prg);prg$col=NULL
  progn_new=merge(progn_new,prg,by=c('Date','dann_tip','prg'))
  progn_new=progn_new[(progn_new$col>=progn_new$min_col),]
  progn_new$min_col=NULL
  
  #только наилучшие прогнозы
  min_pr=aggregate(x =list(min_sigma=progn_new$sigma),
                   by = list(id_prog=progn_new$id_prog), FUN = "min")
  max_pr=aggregate(x =list(max_sigma=progn_new$sigma),
                   by = list(id_prog=progn_new$id_prog), FUN = "max")
  
  progn_new=merge(progn_new,min_pr,by='id_prog')
  progn_new=merge(progn_new,max_pr,by='id_prog')
  bad=progn_new[(progn_new$sigma==progn_new$max_sigma),]
  bad$bad=1;bad=aggregate(bad ~id,data = bad, sum)
  
  best=progn_new[(progn_new$sigma<=progn_new$min_sigma*1.05),]
  best$best=0.1;
  best[(best$sigma<=best$min_sigma*1.02),'best']=0.5;
  best[(best$sigma==best$min_sigma),'best']=1;
  best=aggregate(best ~id,data = best, sum)
  
  progn_new=progn_new[(progn_new$sigma==progn_new$min_sigma),]
  
  best=merge(best,bad,by='id',all=TRUE)
  bad=best[(is.na(best$best)),];bad$best=-bad$bad;
  best=best[(!is.na(best$best)),];best=rbind(best,bad);best$bad=NULL
  
  
  neir_hist_s$best=NULL
  neir_hist_s=merge(neir_hist_s,best,by='id',all=TRUE)
  neir_hist_s_=myPackage$sliv(neir_hist_s,neir_hist_s_);
  neir_hist_s_[is.na(neir_hist_s_$best),'best']=0
  
  #убрал из списка удаляемых 'id','col','$id_prog'
  for (nm in c('Total','min_sigma','versia','max_sigma')){progn_new[,nm]=NULL}
  
  #приписать к итогам значения типов данных
  new=progn_new;
  dann_tip=myPackage$trs.dann_load('progn','dann_tip')
  new=merge(dann_tip,new,by='dann_tip')
  new$dann_tip=NULL;  progn_new=new
  new$time=Sys.time()
  
  progn_itog =myPackage$trs.dann_load('progn','itog')
  #if(!is.null(progn_itog)){progn_itog$time=as.character(progn_itog$time)}
  progn_itog=myPackage$sliv(progn_itog,new)
  progn_itog$progn=as.numeric(progn_itog$progn)
  myPackage$trs.Data_save(progn_itog, 'progn','itog',first=TRUE);
  myPackage$trs.Data_save(neir_hist_s_, 'neiroset','sokr',first=TRUE);
  
  return(progn_new)
}





######################################################################################
#ГЛАВНОЕ - АНАЛИЗ ПРОГНОЗОВ по итоговым уже готовым статистикам
#   name='sahalin'

neural$prognoz_itogi_stat <- function(name) {
  
  neir_hist_s_ =myPackage$trs.dann_load('neiroset','sokr')
  neir_hist_s=neir_hist_s_[(neir_hist_s_$activ==1),]
  neir_hist_s=neir_hist_s[(neir_hist_s$name==name),]
  neir_hist_s_=neir_hist_s_[(neir_hist_s_$name!=name)|(neir_hist_s_$activ!=1),]
  #статистики о нейросетях
  select=c('id','before','time','x','step')
  befores=subset(neir_hist_s,select=c('id'))
  for (nm in select){befores[,nm]=neir_hist_s[,nm]}
  
  #befores$train=neir_hist_s$Train;befores$skor=neir_hist_s$Skor;
  befores$prg=neir_hist_s$progn;#befores$sig=neir_hist_s$sigma;
  
  #прогнозы исходники
  progn =myPackage$trs.dann_load('progn','poln')
  stat =myPackage$trs.dann_load('progn','stat')
  dann_tip=myPackage$trs.dann_load('progn','dann_tip')
  
  #удаление id_ полей
  col=colnames(dann_tip);
  for(nm in col){nm_=paste('id_',nm,sep='');if (nm_ %in% col){dann_tip[,nm_]=NULL}}
  
  #Все прогнозы
  progn_new=merge(progn,stat,by=c('id','versia','dann_tip'))
  progn_new=merge(progn_new,subset(befores,select=c('id','prg','before')),by=c('id'))
  prg=unique(subset(progn_new,select=c('dann_tip','Date','prg')))
  prg$id_prog=1:nrow(prg);
  progn_new=merge(progn_new,prg,by=c('Date','dann_tip','prg'))
  
  
  #только наилучшие прогнозы
  min_pr=aggregate(x =list(min_sigma=progn_new$sigma),
                   by = list(id_prog=progn_new$id_prog), FUN = "min")
  max_pr=aggregate(x =list(max_sigma=progn_new$sigma),
                   by = list(id_prog=progn_new$id_prog), FUN = "max")
  
  progn_new=merge(progn_new,min_pr,by='id_prog')
  progn_new=merge(progn_new,max_pr,by='id_prog')
  bad=progn_new[(progn_new$sigma==progn_new$max_sigma),]
  bad$bad=1;bad=aggregate(bad ~id,data = bad, sum)
  
  best=progn_new[(progn_new$sigma<=progn_new$min_sigma*1.05),]
  best$best=0.1;
  best[(best$sigma<=best$min_sigma*1.02),'best']=0.5;
  best[(best$sigma==best$min_sigma),'best']=1;
  best=aggregate(best ~id,data = best, sum)
  
  progn_new=progn_new[(progn_new$sigma==progn_new$min_sigma),]
  
  best=merge(best,bad,by='id',all=TRUE)
  bad=best[(is.na(best$best)),];bad$best=-bad$bad;
  best=best[(!is.na(best$best)),];best=rbind(best,bad);best$bad=NULL
  
  
  neir_hist_s$best=NULL
  neir_hist_s=merge(neir_hist_s,best,by='id',all=TRUE)
  neir_hist_s_=myPackage$sliv(neir_hist_s,neir_hist_s_);
  neir_hist_s_[is.na(neir_hist_s_$best),'best']=0
  
  #убрал из списка удаляемых 'id','col','$id_prog'
  for (nm in c('min_sigma','versia','max_sigma')){progn_new[,nm]=NULL}
  
  #приписать к итогам значения типов данных
  new=progn_new;new=merge(dann_tip,new,by='dann_tip');new$dann_tip=NULL;progn_new=new
  new$time=Sys.time()
  
  progn_itog =myPackage$trs.dann_load('progn','itog')
  #if(!is.null(progn_itog)){progn_itog$time=as.character(progn_itog$time)}
  progn_itog=myPackage$sliv(progn_itog,new)
  progn_itog$progn=as.numeric(progn_itog$progn)
  myPackage$trs.Data_save(progn_itog, 'progn','itog',first=TRUE);
  myPackage$trs.Data_save(neir_hist_s_, 'neiroset','sokr',first=TRUE);
  
  return(progn_new)
}




#график достигнутой точности
neural$prognoz_itogi_graf <- function(prognoz_itogi){
  pr=prognoz_itogi;pr$col=0
  prr=NULL;
  pr$zn=pr$progn-pr$pr_m;pr$col=pr$col+1
  prr=myPackage$sliv(prr,subset(pr,select=c('progn','zn','col')))                  
  pr$zn=pr$progn+pr$pr_m;pr$col=pr$col+1
  prr=myPackage$sliv(prr,subset(pr,select=c('progn','zn','col')))                  
  pr$zn=pr$progn-pr$pr_1;pr$col=pr$col+1
  prr=myPackage$sliv(prr,subset(pr,select=c('progn','zn','col')))                  
  pr$zn=pr$progn+pr$pr_1;pr$col=pr$col+1
  prr=myPackage$sliv(prr,subset(pr,select=c('progn','zn','col')))
  pr$zn=pr$progn-pr$pr_5;pr$col=pr$col+1
  prr=myPackage$sliv(prr,subset(pr,select=c('progn','zn','col')))                  
  pr$zn=pr$progn+pr$pr_5;pr$col=pr$col+1
  prr=myPackage$sliv(prr,subset(pr,select=c('progn','zn','col')))
  pr$zn=pr$progn-pr$pr_20;pr$col=pr$col+1
  prr=myPackage$sliv(prr,subset(pr,select=c('progn','zn','col')))                  
  pr$zn=pr$progn+pr$pr_20;pr$col=pr$col+1
  prr=myPackage$sliv(prr,subset(pr,select=c('progn','zn','col')))
  plot (x=prr$zn,y=prr$progn,col=prr$col)
}      












#многократное дообучение всех нейросетей
neural$all_neir_new_podnastr_many <- function(dannie,by_time,vibor,by_core,razmnog) {
  print('Идёт многократное дообучение всех нейросетей')
  while (TRUE){neural$all_neir_new_podnastr_parallel(dannie,by_time,vibor,by_core,razmnog) }
}














#ДООБУЧЕНИЕ ВСЕХ НЕЙРОСЕТЕЙ - В ПАРАЛЛЕЛЬНОМ РЕЖИМЕ
#   by_time=10;     vibor=data.frame(name=name);   by_core=1;   razmnog=TRUE 
# - выбор - список только нужных полей, проверяется по равенствам (вхождениям), без интервалов значений

neural$all_neir_new_podnastr_parallel <- function(dannie,by_time,vibor,by_core,razmnog) {
  tm_beg=as.double(Sys.time())
  neural$by_time=by_time;
  
  #подвыбор лишь нужных нейросетей, расстановка по блокам вычислений
  neir_hist_s=myPackage$trs.dann_load('neiroset','sokr') #чтение списка всех нейросетей
  max_id=max(neir_hist_s$id)
  neir_hist_s=neir_hist_s[(neir_hist_s$activ==1),] #подвыборка активных
  
  #neir_hist_s[is.na(neir_hist_s$time),'time']=0
  #neir_hist_s[is.na(neir_hist_s$step),'step']=0
  
  #подвыбор лишь нужных нейросетей, по всем условиям выборки
  for (pole in colnames(vibor)){
    spis=unique(as.character(vibor[,pole]));
    neir_hist_s=neir_hist_s[(as.character(neir_hist_s[,pole]) %in% spis)|
                              ((is.na(neir_hist_s[,pole]))&(('' %in% spis))),]  }
  
  if (!('best' %in% colnames(neir_hist_s))){neir_hist_s$best=0}
  if (!('best_sigma' %in% colnames(neir_hist_s))){neir_hist_s$best_sigma=5}
  
  neir_hist_s[is.na(neir_hist_s$best),'best']=-1
  neir_hist_s[is.na(neir_hist_s$best_sigma),'best_sigma']=5
  #поднастраивать - только сколь-нибудь хорошие
  neir_hist_s=neir_hist_s[(neir_hist_s$best>0),]
  
  
  #размножение хороших нейросетей
  if (nrow(neir_hist_s)>0){
  neir_hist_s$plus=0;neir_hist_s$id_=NA;
  if (razmnog){
    plus=neir_hist_s[(neir_hist_s$best>=1),];#берутся только хорошие - макс на 5% хуже отличных
    plus=plus[(plus$sigma>plus$best_sigma),] # слишком хороших можно не размножать - излишне
    if(nrow(plus)>0){plus$plus=1;plus$id_=(1:nrow(plus))+max_id;plus$poln_nastr=0  };
    neir_hist_s$id_=0;
    neir_hist_s=rbind(neir_hist_s,plus)}
  
  if (is.null(neir_hist_s$poln_nastr)){neir_hist_s$poln_nastr=0}
  ##neir_hist_s=neir_hist_s[(neir_hist_s$poln_nastr==0),] #удаляем из поднастройки полностью настроеных
  neir_hist_s=neir_hist_s[order(-neir_hist_s$best,neir_hist_s$poln_nastr,neir_hist_s$id,neir_hist_s$id_), ];
  }
  
  kol_neir=nrow(neir_hist_s);
  if (kol_neir>0){neir_hist_s$order <- 1:kol_neir}
  
  
  if (kol_neir==0){ 
    print(paste("Всего в поднастройку ",kol_neir, " нейросетей. Конец работы "))}else{

      #подготовка кластеров для распараллеливания  
      cores=max(min(detectCores()-1,kol_neir),1) #число имеющихся в наличии ядер. одно оставляем в запасе
      neir_blok=cores*by_core #по скольку нейросетей рассматривапем в одном блоке вычислений
      neir_hist_s$blok=round(neir_hist_s$order/neir_blok +0.499999);
      kol_blok=max(neir_hist_s$blok)
      dt = round(as.double(Sys.time())-tm_beg);
      print(paste("Всего в поднастройку ",kol_neir, " нейросетей = ",kol_blok," блоков /(tm=",dt,"сек)",Sys.time(), sep = ""))

      clust <- makeCluster(getOption("cl.cores", cores)) #в кластер берём указанное число ядер
      clusterExport(clust, c("myPackage", "neural", "dannie")) #в кластер в каждое ядро экспортируем параметры
      dt = round(as.double(Sys.time())-tm_beg);
      print(paste("Создан рабочий кластер ",cores, " ядер (tm=",dt,"сек)",Sys.time(), sep = ""))

      #        blok=1;   ord=3  ;   id=1
      for (blok in 1:kol_blok){ # начало очередного блока поднастройки нейросетей
        
        neir_hist_blok=neir_hist_s[neir_hist_s$blok==blok,];blok_len=nrow(neir_hist_blok)
        dt = round(as.double(Sys.time())-tm_beg);
        print(paste("Блок ",blok, ", число нейросетей = ",blok_len," штук (tm=",dt,"сек) /",Sys.time(), sep = ""))
        
        #список всех нейросетей блока
        neir_hist=myPackage$trs.dann_load('neiroset','poln') #взять старые значения нейросетей 
        #print(paste("Блок_ ",blok, ", число нейросетей = ",blok_len," штук (tm=",dt,"сек)", sep = ""))
        
        
        #   for (ord in neir_hist_blok$order){}
        neirs <- lapply(FUN = function(ord) {
          blok = neir_hist_blok[(neir_hist_blok$order==ord),]
          id=blok$id;id_=blok$id_;plus=blok$plus;iz=0;
          neir=NULL;
          pack_=neir_hist[(neir_hist$id==id),];
          if (!is.null(pack_)){if (nrow(pack_)==1){pack = pack_$pack; #при существующей нейросети
          neir = myPackage$trs.unpack(pack);neir$plus=plus;neir$id_new=id_;}}
          return (neir)}, X = neir_hist_blok$order)
        rm(neir_hist,neir_hist_blok)
        
        
        print(paste("Блок ",blok, ", настройка = ",blok_len," штук (tm=",dt,"сек) /",Sys.time(), sep = ""))        
        #  for (neir in neirs){}  
        # Для каждой нейросети поднастройка. в параллельном режиме!!!
        tmbeg=as.double(Sys.time());
        neirs_ <- parLapplyLB(cl = clust, fun = function(neir) {
          if(!is.null(neir)){#бывает, что нейросеть безвозвратно испорчена, или задвоена...
            tmbeg0=as.double(Sys.time())
            #увеличение нейросети, либо числа входов
            plus=neir$plus;id_=neir$id_new;neir$plus=NULL;neir$id_new=NULL;
            if (plus==1){before=neir$sozd$before;
            if ((is.na(before))|(is.infinite(before))|(is.null(before)))
              {before=round(5+40*runif(1))};#инициализация произвольным, если не было вообще
            min_bef=max(before-3,3)
            neir=neural$trs.sozd_neir_plus(dannie,neir,min_bef);neir$id=id_} 
            
            by_time=neural$by_time;tmbeg=as.double(Sys.time())
            itog=neural$trs.sozd_neir_dann(dannie,neir);dann=itog$dann;neir=itog$neir;rm(itog)
            neir$k$versia=neir$k$versia+1; #увеличение номера версии нейросети
            
            neir$k$lend=0;progn='1';stat='1';activ=-1;if(nrow(dann)>0){
              #нормированние и массивы по новому, и инициализация всех параметров нейросети по необходимости
              dann_n=neural$normir_dann(neir,dann);
              neir=dann_n$neir;ddd=dann_n$dd;dd_all=dann_n$dd_all;rm(dann_n); 
              
              activ=1; #получение активности - если есть данные
              if ((nrow(ddd)<5*neir$k$kol_param) | (nrow(dann)-nrow(ddd)<2)){activ=-1}
              
              if (activ==1){
                neir=neural$neir_ispravl(neir,ddd) #ИСПРАВЛЕНИЕ НЕЙРОСЕТИ - ЛИШНИЕ НЕЙРОНы ПРЕОБРАЗОВАТЬ
                
                neir<-neural$neir_nastr_new(ddd,neir,-1) #настройка нейросети - первичное значение ошибки
                err1=neir$k$error;
                dt=(as.double(Sys.time())-tmbeg)
                neir<-neural$neir_nastr_new(ddd,neir,max(1,by_time-dt)) #настройка нейросети
                err2=neir$k$error;
                #  1.1==neural$k_povtor
                #if (err2*1.1<err1){neir<-neural$neir_nastr_new(ddd,neir,by_time)} #настройка нейросети ещё раз
                #progn=neural$neir_prognoz_narabot(neir,dd_all) #наработка прогноза
                progn=neural$neir_prognoz_narabot_stat(neir,dd_all) #наработка прогноза
                stat=progn$stat;progn=progn$progn
              }};neir$k$activ=activ;
            time_rab=(as.double(Sys.time())-tmbeg0)
            return(list(neir = neir, progn = progn, stat=stat, time_rab=time_rab))
          }}, X = neirs)
        
        dt = round(as.double(Sys.time())-tm_beg);
        t_nastr=cores*(as.double(Sys.time())-tmbeg);t_nastr2=0;
        print(paste(" Конец поднастройки блока  (tm=",dt,"сек) /",Sys.time(), sep = ""))
        
        
        #взять старую историю нейросетей и сокращений, и прогнозов
        neir_hist=myPackage$trs.dann_load('neiroset','poln')
        neir_hist_sokr=myPackage$trs.dann_load('neiroset','sokr')
        neir_progn=myPackage$trs.dann_load('progn','poln') #все старые прогнозы
        neir_stat=myPackage$trs.dann_load('progn','stat') #все старые статистики
        
        neir_progn_new=neir_progn[0,];neir_stat_new=NULL;
        set_id=c()
        
        #обновить прогнозы и нейросети по результату работы блока
        #  for (neir_ in neirs_){}
        for (neir_ in neirs_) {
          neir=neir_$neir;progn=neir_$progn;stat=neir_$stat;t_nastr2=t_nastr2+neir_$time_rab;
          activ=neir$k$activ; 
          set_id=c(set_id,neir$id)
          #if(activ==1)
          #{neir_progn=neural$neir_progn_pripiska(neir_progn,progn)    #приписать прогнозы 
          #}else{neir_progn=neir_progn[(neir_progn$id!=neir$id),]} #удалить прогнозы
          if(activ==1){neir_progn_new=myPackage$sliv(neir_progn_new,progn);
          neir_stat_new=myPackage$sliv(neir_stat_new,stat);}
          #приписать сокращение (с активностью)
          neir_sokr=neural$neir.sokr(neir);id=neir_sokr$id;neir_sokr$activ=activ;
          neir_hist_sokr[(neir_hist_sokr$id==id),'activ']='0';
          neir_hist_sokr=myPackage$sliv(neir_hist_sokr,neir_sokr);
          #создание строки - запакованной нейросети
          neir_h=data.frame( id=array(id,1))
          neir_h$pack=myPackage$trs.pack(neir);
          #приписать запакованную нейросеть (если пусто - вписать)
          neir_hist=neir_hist[(neir_hist$id!=id),];
          neir_hist=rbind(neir_hist,neir_h)
        }
        
        #теперь единым блоком приписать прогнозы
        if (!is.null(neir_progn)){
          neir_progn_old=neir_progn[(neir_progn$id %in% set_id),]
          neir_progn=neir_progn[(!(neir_progn$id %in% set_id)),]
          #min_dat=min(neir_progn_new$Date)
          #neir_progn_old=neir_progn_old[(as.Date(neir_progn_old$Date)<min_dat),];
          max_dat=as.Date(dannie$max_date)
          neir_progn_old=neir_progn_old[(as.Date(neir_progn_old$Date)<=max_dat),];
          neir_progn=myPackage$sliv(rbind(neir_progn,neir_progn_old),neir_progn_new);
          rm(neir_progn_old)}else
          {neir_progn=neir_progn_new}
        #теперь приписать статистики от прогнозов
        if (!is.null(neir_stat)){
          neir_stat=neir_stat[(!(neir_stat$id %in% set_id)),];
          neir_stat=myPackage$sliv(neir_stat,neir_stat_new);
        }else{neir_stat=neir_stat_new}
        
        
        kpd=round(1000*t_nastr2/t_nastr)/10;
        print(paste(" КПД процесса настройки =",kpd,"%", sep = ""))
        dt = round(as.double(Sys.time())-tm_beg);
        
        #обратные записи итогов работы блока
        myPackage$trs.Data_save(neir_hist,'neiroset','poln',TRUE) #запись нейросетей обратно
        myPackage$trs.Data_save(neir_hist_sokr,'neiroset','sokr',TRUE) #запись сокращений нейросетей обратно
        myPackage$trs.Data_save(neir_progn,'progn','poln',TRUE) #запись прогнозов обратно
        myPackage$trs.Data_save(neir_stat,'progn','stat',TRUE) #запись статистик прогнозов обратно
        rm(neir_hist,neir_hist_sokr,neir_progn,neir_,neirs_,neirs,neir,neir_sokr,neir_h,
           progn,neir_progn_new,neir_stat,neir_stat_new)
        
        print(paste(" Конец приписки к истории  (tm=",dt,"сек) /",Sys.time(), sep = ""))
        
      } #конец цикла по блокам
      stopCluster(clust)
      dt = round(as.double(Sys.time())-tm_beg);
      print(paste(" Конец записей  (tm=",dt,"сек) начало подведения итогов /",Sys.time(), sep = ""))
      
    }
  
  name=dannie$name
  prognoz_itogi=neural$prognoz_itogi_stat(name)
  dt = round(as.double(Sys.time())-tm_beg);
  print(paste(" Конец работы  (tm=",dt,"сек) /",Sys.time(), sep = ""))
}


















#ПОЧИНКА СЛУЧАЙНО УБИТОЙ ТАБЛИЦЫ ПРОГНОЗОВ
neural$pochinka_prognoz <- function(dannie) {
  neir_hist_s=myPackage$trs.dann_load('neiroset','sokr') #чтение списка всех нейросетей
  neir_hist_s[(neir_hist_s$activ==1),c('poln_nastr','best')]=0
  myPackage$trs.Data_save(neir_hist_s, 'neiroset','sokr',first=TRUE);
  vibor=data.frame(name='sahalin')
  neural$all_neir_new_podnastr_parallel(dannie,1,vibor,15) 
}












#создание множества однотипных нейросетей с разными прогнозами и запаздываниями
neural$trs.sozd_neir_many <- function(dannie,befores,prognozi) {
  for(progn in prognozi){
    for(before in befores){
      for(svoi in c(0,1)){ #0=частичная продажа в своём поезде, 1=полная продажа иного поезда
      neir=neural$trs.sozd_neir2(dannie,before,progn,svoi) 
      neir$k$kol_neir=3
      neir=neural$neir.save_to_hist(neir,NULL);#запись без прогнозов - не ставит глухую активность!
    }}}
}

#создание нейросети: входы = места, день недели и число уже проданных билетов 
neural$trs.sozd_neir2 <- function(dannie,before,progn,svoi) {
  
  name=dannie$name;tip_all=dannie$tip_all
  progn=tip_all[(tip_all$progn=='1')&(tip_all$name==progn),]#нет случайности в выборе прогнозируемого
  
  if (nrow(progn>0)){
    
    tip=progn$tip[1];params=dannie$params;
    
    #ВЫХОД УЖЕ ЕСТЬ, ТЕПЕРЬ ВОПРОС - ЧТО ВОЗМОЖНО НА ВХОД?
    nm=c('kp','Seats')
    tip_all$name_=tip_all$name;l=max(nchar(tip_all$name_))
    for (i in l:1){tip_all[(substr(tip_all$name,i,i)=='.'),'name_']=
      substr(tip_all[(substr(tip_all$name,i,i)=='.'),'name_'],1,i-1)}
    
    tip_isp=tip_all[(((tip_all$tip==tip)&(tip_all$name_ %in% nm))|(tip_all$name=='weekday')),]
    tip_isp=unique(subset(tip_isp,select=c('tip_n','name','max_bef','tip','tab','vid')))
    
    vhod=tip_isp;vhod=vhod[order((vhod$vid=='m'),vhod$max_bef,vhod$name),];
    vhod$vhod=1:nrow(vhod);
    #  before - указ на дату отправления/ bef_otp - за сколько дней до отправления
    vhod$bef_otp=before;vhod[(vhod$max_bef %in% c(0,-1)),'bef_otp']=0 
    vhod$before=0 
    if ((before>44)|(svoi=0)){vhod$before=vhod$bef_otp;vhod$bef_otp=0}
    
    #поиск, за сколько получилась нейросеть?
    before=vhod[(vhod$max_bef!=-1),]
    if (nrow(before)>0){before=min(before$before+before$bef_otp)}else{before=NA}
    vhod$max_bef=NULL;#vhod$vid='x'
    #vhod$vibor=1#индекс подвыбора - пока только 1:1, потом и иные
    
    #добавляем и выход - вход=0
    vh=unique(subset(progn,select=c('name','tip','tip_n','tab')))
    vh[,c('vhod','bef_otp','before')]=0;vh$vid='y';
    vhod=rbind(vh,vhod);
    
    #сперва что выбираем - парамерт выбора
    vibor=progn[1,];
    vibor=subset(vibor,select=params)
    for (nm in params){zn=unique(subset(progn,select=nm))
    if (nrow(zn)==1){vibor[,nm]=zn[1,nm]}else{vibor[,nm]='*'} }
    
    vibor$vhod=-1;vibori=vibor[0,]
    for (vh in vhod$vhod){vib=vibor;
    tip_n=vhod[(vhod$vhod==vh),'tip_n'];zn=tip_all[(tip_all$tip_n==tip_n),]
    if (nrow(zn)==1){for (nm in params){vib[,nm]=zn[,nm]}}
    vib$vhod=vh;
    vibori=rbind(vibori,vib); }
    vibor=vibori;rm(vib,vibori) 
    
    #постановка массивов - все изменяемые параметры, кроме номера поезда
    x=count(vhod$vid)
    k=list();k$ogran=0;k$versia=0;k$kol_neir=0;
    k$x=x[(x$x=='x'),'freq'];k$m=x[(x$x=='m'),'freq'];
    vib=vibor[(vibor$vhod==0),]
    for (nm in params){if (nm!='Train'){
      if (vib[1,nm]=='*'){k$m=k$m+1;vh=vhod[0,];vh=vh[1,]
      vh$name=nm;vh$vid='m';vh$vhod=k$x+k$m;vh$tab=0;vhod=rbind(vhod,vh) }
    }}
    vhod$tip_n=NULL
    sozd=list(name=name,vibor=vibor,vhod=vhod,before=before)
    neir=list(sozd=sozd);neir$k=k
    
  }else{neir=NULL}
  
  return(neir)
}














#конец файла нейросеть генетический алгоритм
