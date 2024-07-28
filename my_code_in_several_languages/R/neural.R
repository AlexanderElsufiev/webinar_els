
#ВНАЧАЛЕ ПОДКЛЮЧИТЬ БИБЛИОТЕКУ ПАРАЛЛЕЛЬНЫХ ВЫЧИСЛЕНИЙ
if (!require("parallel")) {install.packages("parallel")};
library("parallel")

#функции нейронов для нейросети, и их производных
neural=list();
neural$f2 <- function (v) {return ( v**2)}
neural$pr2 <- function (v) {return ( 2*v)}

neural$f1 <- function (v) {return ( abs(v))}
neural$pr1 <- function (v) {return ( sign(v))}

neural$f0 <- function (v) {return ( v)}
neural$pr0 <- function (v) {return ( 1)}

#f1 <- function (v) {return ( v**2)}
#pr1 <- function (v) {return ( 2*v)}
#f0 <- function (v) {return ( v)}
#pr0 <- function (v) {return ( 1)}

#M = matrix(sample(0:127,16*12,replace=TRUE), c(16,12))




#mff=matrix(c(1,2,3, 11,12,13),ncol=2,nrow=3)
#mff2=matrix(c(1,2,3, 11,12,13),ncol=2,nrow=3, byrow=TRUE)
#mff2=matrix(c(1,2,3, 11,12,13,3,654,4,3,2,5),ncol=2, byrow=TRUE)


#двуверный массив данные разнотипные
# colnames(dd) - список назщаний столбцов
#  nrow(dd) ncol(dd) - число строк и столбцов в матрице
# случайные функции rnorm, runif, rexp ...

#инициализация размеров нейросетевых данных
#k=data.frame(x=1,m=1,len=100,mm=0,ogran=1,ogr_k=0.1)

#инициализация данных через фрейм
neural$init_dann_frame<- function(k){
dd=data.frame( y=array(0,k$len),ves=array(1,k$len),dann=array('1',k$len),zap=array('dfg',k$len));
  #, x=matrix(0,k$len,k$x),m=matrix(0,k$len,k$m)
  #убрал массивы - если длина X =1 тобудет не X.1 а только X (и М так же)               
mz=matrix(rnorm(k$len*(k$m+1)),k$len,k$m+1);
for (i in 1:k$len){
  if(k$x>0){for (j in 1:k$x){ zz=rnorm(1)*(5);dd[i,paste('x',j,sep='.')]=zz;dd$y[i]=dd$y[i]+zz}}
  if(k$m>0){for (j in 1:k$m){ zz=round(runif(1)*(j+2));dd[i,paste('m',j,sep='.')]=zz;
    dd$y[i]=dd$y[i]+mz[zz+1,j]}}  
  zz=runif(1);if(zz<0.1){dd$dann[i]='0';dd$y[i]=NA} #нет данных
  if(zz>0.8){dd$dann[i]='2'} #данные тестовые, не участвуют в настройке
  };
if (k$ogran>0){dd[,'ym.1']<- -runif(k$len)*50;dd[,'ym.2']=runif(k$len)*50;
  dd[,'y']=pmax(pmin(dd[,'y'],dd[,'ym.2']),dd[,'ym.1']);}
return(dd)}










# изменяет структуру DD - добавляет 3 поля. И создаёт значение Y - тестовое (=сумма Х  +сумма F(M)) (F затирается)
# и заодно создаёт массив MM - список всех вариантов массива - теперь не массив, а фрейм
neural$normir_dann<- function(neir,dd){
  dd$order <- 1:nrow(dd)
  k=neir$k;k$len=nrow(dd);
  iz_old=1;if(is.null(neir$rebro)){iz_old=0}#определяем, была ли прежде нейросеть
  
  k$mm=0;
  mm=data.frame(v1=array(0,1));mm$v2='';mm$v3=0;mm$v4=0;
  maxx=data.frame(vhod=array(0,k$x+1));maxx$min=NA;maxx$max=NA;maxx$vhod=0:k$x;
  
  #создание матрицы возможных значений
  if(k$m>0){
    for(j in 1:k$m){
      un=array(data=sort(unique(dd[,paste("m",j,sep=".")])))
      len=nrow(un);#mm_=matrix(0,len,4);
      mm_=data.frame(v1=array(j,len));mm_$v2=un;mm_$v3=0;mm_$v4=0.5;
      #for (i in 1:len){mm_[i,1]=j;mm_[i,2]=un[i]}
      mm=rbind(mm,mm_);rm(mm_,un);}
    mm=mm[(mm$v1>0),];
    k$mm=nrow(mm);
    
    if(iz_old==1){mm_old=neir$mm;kmm_old=neir$k$mm; 
    for (i in 1:k$mm){for (j in 1:kmm_old){
      if ((mm[i,'v1']==mm_old[j,'v1'])&(mm[i,'v2']==mm_old[j,'v2'])){mm[i,'v4']=mm_old[j,'v4']}
    }}}
    
    for(j in 1:k$mm){mm[j,'v3']=j}
    
    for(j in 1:k$m){
      mm_=mm[(mm[,'v1']==j),];
      mm_[,paste('m',j,sep='.')]=mm_$v2;mm_[,paste('mm',j,sep='.')]=mm_$v3;
      mm_$v1=NULL;mm_$v2=NULL;mm_$v3=NULL;mm_$v4=NULL;by=paste('m',j,sep='.');
      dd<- merge(dd, mm_, by = by);#здесь теоретически может нарушиться сортировка dd
    }
  }
  
  #поиск макс-мин значений, и создание нормализованных полей
  if (iz_old==1){ maxx_=neir$maxx;
  for(vh in maxx_$vhod){
    maxx[(maxx$vhod==vh),c('min','max')]=maxx_[(maxx_$vhod==vh),c('min','max')]
  }  }
  if(k$x>0){
    for (vh in 1:k$x){
      mx=maxx[(maxx$vhod==vh),]
      if ((mx$min==mx$max)|(is.na(mx$min))) {
        mx$min=min(dd[,paste("x",vh,sep=".")], na.rm=T);
        mx$max=max(dd[,paste("x",vh,sep=".")], na.rm=T);
        maxx=maxx[(maxx$vhod!=vh),];maxx=rbind(maxx,mx)}
      if(mx$min==mx$max){dd[,paste("xx",vh,sep=".")]=0}else
      {dd[,paste("xx",vh,sep=".")]=(dd[,paste("x",vh,sep=".")]-mx$min)/(mx$max-mx$min)}
    }  }
  #поиск макс-мин целевого значения, и его нормализация
  vh=0;mx=maxx[(maxx$vhod==vh),]
  if ((iz_old==0)|(is.na(mx$min))){
    mx$min=min(dd$y, na.rm=T);mx$max=max(dd$y, na.rm=T);
    maxx=maxx[(maxx$vhod!=vh),];maxx=rbind(maxx,mx)   }
  dd$yy=(dd$y-mx$min)/(mx$max-mx$min);
  if (k$ogran>0){dd$yym.1=NA;dd$yym.2=NA;
  if ('ym.1' %in% colnames(dd)){dd$yym.1=(dd$ym.1-mx$min)/(mx$max-mx$min);}
  if ('ym.2' %in% colnames(dd)){dd$yym.2=(dd$ym.2-mx$min)/(mx$max-mx$min);}}  
  
  #если ещё не было разбивки, на настройку. тест и прогноз, то разбиваем здесь, но без теста!
  if (!('dann' %in% colnames(dd))){dd$dann='1';dd[(is.na(dd$y)),'dann']=0;}
  #и, если ещё не был указан вес = то стабильно =1
  if (is.null(dd$ves)){dd$ves=1}
  
  # В новую базу берутся только настроечные значения, а не тестовые и не прогнозные
  k$lend=sum(dd$dann=='1');k$lenp=sum(dd$dann=='0');k$lent=sum(dd$dann=='2');
  k$vesd=sum((dd$dann=='1')*dd$ves);k$vesp=sum((dd$dann=='0')*dd$ves);k$vest=sum((dd$dann=='2')*dd$ves);
  
  #выборка в рабочую таблицу только нужных столбцов
  stb=c('dann','ves','yy')
  if(k$x>0){for (j in 1:k$x){stb=c(stb,paste("xx",j,sep="."))  }}
  if(k$m>0){for (j in 1:k$m){stb=c(stb,paste("mm",j,sep="."))  }}
  if(k$ogran>0){stb=c(stb,'yym.1','yym.2')}
  ddd=subset(dd,select=stb);
  ddd=ddd[(ddd$dann=='1'),];
  ddd$dann=NULL;
  
  neir$maxx=maxx;neir$mm=mm;neir$k=k;
  #и сразу создание рёбер нейросети (собственно структуры)
  if (iz_old==0){neir_=neural$init_neir(neir$k);
  neir$k=neir_$k;neir$rebro=neir_$rebro;}
  
  rr=neir$rebro;rr=rr[(rr[,1]>=0),];neir$k$kol_param=nrow(rr)+nrow(neir$mm)
  dd <- dd[order(dd$order), ];dd$order <- NULL
  
  return(list(neir=neir,dd=ddd,dd_all=dd))
}














#трёхмерный массив =
#q <- array(dim = c(10, 10, 10), data = 1)
#q[1, 1, ]
#q[, , 1]

##сортировки 
#order(mp) order(mp[,1])


#Разные действия со временем
#as.double(Sys.time()) - as.double(Sys.Date())
#Sys.Date()
#as.double(Sys.time())


#ff=unique(dann[,2]) - уникальные значения из массива


#f <- list()
#for (i in 1:10) {f[[1]] <- function(){return(i)} }
#f[[1]]
#f <- lapply(FUN = function(i){function(){return(i)}}, X = 1:10)
#f[1]
#    [[1]]
#    function () 
#    {
#    return(i)
#    }
#
#
#

#количество внутренних нейронов, пока =0; только 1 уровень нейронов, не многоуровневое

#инициализация структуры нейросети и начального нулевого решения
neural$init_neir<-function(k){
  k$error=-1;k$alef=0.1;k$step=0;k$time=0;
  kol_neir=k$kol_neir;
  mass=array(0.5,k$mm);#веса для массива
  kol_vhod=k$x+k$m;kol_ver=kol_vhod+kol_neir+1;k$kol_vhod=kol_vhod;k$kol_ver=kol_ver;
  kol_reb=(kol_neir+1)*(kol_vhod+2)+kol_neir;k$kol_reb=kol_reb;
  rebro=matrix(0,kol_reb,3);reb=0;
  rebro[,3]=rnorm(kol_reb);#изначально ненулевые случайные веса
  if(kol_neir>0) {for (nn in 1:kol_neir){
    for(n1 in 1:kol_vhod){reb=reb+1;rebro[reb,1]=n1;rebro[reb,2]=kol_vhod+nn;}
    reb=reb+1;rebro[reb,1]=0;rebro[reb,2]=kol_vhod+nn;
    reb=reb+1;rebro[reb,1]=-1;rebro[reb,2]=kol_vhod+nn;rebro[reb,3]=1;
    }}
  for(n1 in 1:(kol_vhod+kol_neir)){reb=reb+1;rebro[reb,1]=n1;rebro[reb,2]=kol_vhod+kol_neir+1;}
  reb=reb+1;rebro[reb,1]=0;rebro[reb,2]=kol_vhod+kol_neir+1;
  reb=reb+1;rebro[reb,1]=-1;rebro[reb,2]=kol_vhod+kol_neir+1;rebro[reb,3]=0;  
    return(list(k=k,rebro=rebro,mass=mass))}  








#Процедура получения прогноза по нейросети и объёму данных (всех или настроечных)
neural$neir_prognoz<-function(dd,neir){#просто кусок процедуры neir_proizv - производная
  k=neir$k;mm=neir$mm;rebro=neir$rebro;
  kol_ver=k$kol_ver;kol_reb=k$kol_reb;
  if(k$m>0){for(j in 1:k$m){
    dd[,paste("xx",k$x+j,sep=".")]=mm[dd[,paste("mm",j,sep=".")],4]  }}
  
  dd$z=0;
  for(reb in 1:kol_reb){
    zn_r=rebro[reb,3];vx=rebro[reb,1];vix=rebro[reb,2];
    if (vx>0){dd$z=dd$z+ (dd[,paste("xx",vx,sep=".")]*zn_r)}
    if (vx==0){dd$z=dd$z+zn_r }
    if (vx==-1){
      if (zn_r==0){dd$pr=neural$pr0(dd$z);dd$z=neural$f0(dd$z)}
      if (zn_r==1){dd$pr=neural$pr1(dd$z);dd$z=neural$f1(dd$z)}
      if (zn_r==2){dd$pr=neural$pr2(dd$z);dd$z=neural$f2(dd$z)}
      if (zn_r==3){dd$pr=neural$pr3(dd$z);dd$z=neural$f3(dd$z)}
      if (zn_r==4){dd$pr=neural$pr4(dd$z);dd$z=neural$f4(dd$z)}
      
      dd[,paste("xx",vix,sep=".")]=dd$z;
      dd[,paste("xp",vix,sep=".")]=dd$pr;
      dd$z=0}}
  for (j in 1:kol_ver){dd[,paste("er",j,sep=".")]=0}
  #добавка ограничений входных данных
  dd[,'xz']=dd[,paste("xx",kol_ver,sep=".")]
  if(k$ogran>0){xp=paste("xp",kol_ver,sep=".");xz='xz';dd[,xp]=1
  #vhod=neir$sozd$vhod;
  #ogr1=nrow(vhod[(vhod$vid=='ym.1'),]);ogr2=nrow(vhod[(vhod$vid=='ym.2'),]);
  if(k$ogr_min==1){
    dd[,xp] = dd[,xp]+(k$ogr_k-1)*(dd[,xz]<dd[,'yym.1']);
    dd[,xz]=dd[,xz]+(k$ogr_k-1)*(dd[,xz]<dd[,'yym.1'])*(dd[,xz]-dd[,'yym.1']);}    
  if(k$ogr_max==1){
    dd[,xp] = dd[,xp]+(k$ogr_k-1)*(dd[,xz]>dd[,'yym.2']);
    dd[,xz]=dd[,xz]+(k$ogr_k-1)*(dd[,xz]>dd[,'yym.2'])*(dd[,xz]-dd[,'yym.2']);}    
  #    dd[,paste("xp",kol_ver,sep=".")] = 
  #        (k$ogr_k+(1-k$ogr_k)*(dd[,'xz']<dd[,'yym.2'])*(dd[,'xz']>dd[,'yym.1'])  );
  #    dd[,'xz']=dd[,'xz']+(k$ogr_k-1)*((dd[,'xz']>dd[,'yym.2'])*(dd[,'xz']-dd[,'yym.2'])
  #                                     +(dd[,'xz']<dd[,'yym.1'])*(dd[,'xz']-dd[,'yym.1']));  
  }
  
  
  #выдача итоговых прогнозов
  # z=прогноз с учётом ограничений / zp=прогноз до ограничения (спрос)
  ll=nrow(dd);prog=data.frame( z=array(0,ll));
  mx=neir$maxx;mx=mx[(mx$vhod==0),]
  prog$z=mx$min+dd[,paste("xx",kol_ver,sep=".")]*(mx$max-mx$min);
  prog$zp=prog$z;
  if(k$ogran>0){prog$z=mx$min+dd[,'xz']*(mx$max-mx$min);}
  return(prog)}










#процедура получения производной нейросети в точке, и значение ошибки
neural$neir_proizv<-function(k,dd,mm,rebro,mmv,b_err){
  kol_ver=k$kol_ver;kol_reb=k$kol_reb;
  if(k$m>0){for(j in 1:k$m){
    dd[,paste("xx",k$x+j,sep=".")]=mmv[dd[,paste("mm",j,sep=".")]]  }}
  
  dd$z=0;
  for(reb in 1:kol_reb){zn_r=rebro[reb,3];vx=rebro[reb,1];
  if (vx>0){dd$z=dd$z+ (dd[,paste("xx",vx,sep=".")]*zn_r)}
  if (vx==0){dd$z=dd$z+zn_r }
  if (vx==-1){
    if (zn_r==0){dd$pr=neural$pr0(dd$z);dd$z=neural$f0(dd$z)}
    if (zn_r==1){dd$pr=neural$pr1(dd$z);dd$z=neural$f1(dd$z)}
    if (zn_r==2){dd$pr=neural$pr2(dd$z);dd$z=neural$f2(dd$z)}
    if (zn_r==3){dd$pr=neural$pr3(dd$z);dd$z=neural$f3(dd$z)}
    if (zn_r==4){dd$pr=neural$pr4(dd$z);dd$z=neural$f4(dd$z)}
    dd[,paste("xx",rebro[reb,2],sep=".")]=dd$z;
    dd[,paste("xp",rebro[reb,2],sep=".")]=dd$pr;
    dd$z=0}}
  for (j in 1:kol_ver){dd[,paste("er",j,sep=".")]=0}
  
  #добавка ограничений входных данных
  dd[,'xz']=dd[,paste("xx",kol_ver,sep=".")]
  if(k$ogran>0){
    xp=paste("xp",kol_ver,sep=".");xz='xz';dd[,xp]=1
    #vhod=neir$sozd$vhod;
    #ogr1=nrow(vhod[(vhod$vid=='ym.1'),]);ogr2=nrow(vhod[(vhod$vid=='ym.2'),]);
    if(k$ogr_min==1){
      dd[,xp] = dd[,xp]+(k$ogr_k-1)*(dd[,xz]<dd[,'yym.1']);
      dd[,xz]=dd[,xz]+(k$ogr_k-1)*(dd[,xz]<dd[,'yym.1'])*(dd[,xz]-dd[,'yym.1']);}    
    if(k$ogr_max==1){
      dd[,xp] = dd[,xp]+(k$ogr_k-1)*(dd[,xz]>dd[,'yym.2']);
      dd[,xz]=dd[,xz]+(k$ogr_k-1)*(dd[,xz]>dd[,'yym.2'])*(dd[,xz]-dd[,'yym.2']);}    
    
    #    dd[,paste("xp",kol_ver,sep=".")] = (k$ogr_k+(1-k$ogr_k)*(dd[,'xz']<dd[,'yym.2'])*(dd[,'xz']>dd[,'yym.1'])  );
    #    dd[,'xz']=dd[,'xz']+(k$ogr_k-1)*((dd[,'xz']>dd[,'yym.2'])*(dd[,'xz']-dd[,'yym.2'])
    #                                     +(dd[,'xz']<dd[,'yym.1'])*(dd[,'xz']-dd[,'yym.1'])); 
    
  }
  dd[,paste("er",kol_ver,sep=".")]=dd[,'xz']-dd$yy;
  error=sum((dd[,paste("er",kol_ver,sep=".")]**2)*dd[,'ves']);
  
  rpro=array(0,kol_reb);mmpro=array(0,k$mm);
  
  if((b_err<0)|(error<=b_err)){
    #далее поиск производной обратным распространением: 
    #если ошибка уже велика (более достигнутой) то и производную можно не считать
    dd[,paste("xp",kol_ver,sep=".")]=dd[,paste("xp",kol_ver,sep=".")]*2*dd[,'ves'];
    
    for(reb in kol_reb:1){vx=rebro[reb,1];vix=rebro[reb,2];
    if (vx==-1){
      dd[,paste("er",vix,sep=".")]=dd[,paste("er",vix,sep=".")]*dd[,paste("xp",vix,sep=".")]}
    if (vx==0){rpro[reb]=sum(1*dd[,paste("er",vix,sep=".")])}
    if (vx>0){rpro[reb]=sum(dd[,paste("xx",vx,sep=".")]*dd[,paste("er",vix,sep=".")]);
    if (vx>k$x){
      dd[,paste("er",vx,sep=".")]=dd[,paste("er",vx,sep=".")]+rebro[reb,3]*dd[,paste("er",vix,sep=".")]}
    }}
    
    #этот кусочек из 2 строк заменить на иной!!!
    if(k$m>0){for (j in 1:k$mm){vx=mm[j,1];vix=vx+k$x;
    mmpro[j]=sum( (dd[,paste("mm",vx,sep=".")]==j)* dd[,paste("er",vix,sep=".")])}}
    #новый вариант. Непонятно почему - вдесятеро медленнее!!!
    #if(k$m>0){for (j in 1:k$m){vx=j;vix=vx+k$x;
    #zz=aggregate(x = dd[,paste("er",vix,sep=".")], by = list(dd[,paste("mm",vx,sep=".")]), FUN = "sum")
    #mmpro2[zz[,1]]=zz[,2]}}
  }
  return(list(rpro = rpro, mmpro = mmpro, error=error))}










#all_time=10;dd=ddd;

#настройка нейросети
neural$neir_nastr<-function(dd,neir,all_time){tm_beg=as.double(Sys.time());
  # all_time>0 = время в секундах, <0 = количество итераций. =0 - 1000 итераций 
    #(а вообще то только выдача прогноза, и здесь таким не должно оказаться)
  kol_step=1000;if(all_time<0){kol_step=-all_time};
  k=neir$k;rebro=neir$rebro;mm=neir$mm;
  alef=k$alef;mass=array(0,k$mm);mass=mm[,4];
  proizv=neural$neir_proizv(k,dd,mm,rebro,mass,-1);

  rpro=proizv$rpro;mmpro=proizv$mmpro;error=proizv$error;rebro2=rebro;k_step=0;z_step=0;
  while(z_step==0){
#  for (step in 1:kol_step){
    k_step=k_step+1;
    rebro2[,3]=rebro[,3]-alef*rpro;mass2=mass-alef*mmpro;
    proizv2=neural$neir_proizv(k,dd,mm,rebro2,mass2,error);
    rpro2=proizv2$rpro;mmpro2=proizv2$mmpro;error2=proizv2$error;
    
    if (error2<error) {alef=alef*1.1;
    rebro=rebro2;mass=mass2;rpro=rpro2;mmpro=mmpro2;error=error2}else
    {alef=max(alef/2,0.0000000001)    }
    tm=as.double(Sys.time());
    #условия окончания настройки
    if (all_time>0){if(tm>tm_beg+all_time){z_step=1}}else{if(k_step>=kol_step){z_step=1}};
    if (alef<0.0000000001){z_step=1};
  }
  k$alef=alef;k$error=error;k$step=k$step+k_step;k$time=k$time+(tm-tm_beg);
  mm[,4]=mass;
  return(list(k=k,rebro=rebro,mm=mm))
}





#настройка нейросети НОВАЯ - на каждом шаге 2 проверки - по основному alrf, и по новому рассчитанному
neural$neir_nastr_new<-function(dd,neir,all_time){tm_beg=as.double(Sys.time());
# all_time>0 = время в секундах, <0 = количество итераций. =0 - 1000 итераций 
kol_step=1000;if(all_time<0){kol_step=-all_time};
k=neir$k;rebro=neir$rebro;mm=neir$mm;
k$poln_nastr=0;alef=min(k$alef*100,0.01);#увеличить размах, но не сильно
kol_ver=k$kol_ver;kol_reb=k$kol_reb;
mass=array(0,k$mm);mass=mm[,4];
proizv=neural$neir_proizv(k,dd,mm,rebro,mass,-1);
rpro=proizv$rpro;mmpro=proizv$mmpro;
error=proizv$error;

vect_r=array(0,kol_reb);vect_m=array(0,k$mm);
rebro2=rebro;rebro3=rebro;k_step=0;z_step=0;  

while(z_step==0){
  k_step=k_step+2;
  
  summr=(sum(rpro**2))**0.5;vect_r=rpro/summr;
  if (k$m>0){summm=(sum(mmpro**2))**0.5;vect_m=mmpro/summr;}
  #здесь ПОТОМ - иногда взять лишь некоторые компоненты векторов производной!!!
  
  rebro2[,3]=rebro[,3]-alef*vect_r;mass2=mass-alef*vect_m;
  proizv2=neural$neir_proizv(k,dd,mm,rebro2,mass2,error);
  rpro2=proizv2$rpro;mmpro2=proizv2$mmpro;error2=proizv2$error;
  
  razn_iz=error-error2;
  razn_must=(sum(vect_r*rpro)+sum(vect_m*mmpro))*alef;
  #вычисление более оптимального alef
  if(razn_must<razn_iz){alef2=2*alef}else
  {alef2=alef*razn_must/(2*(razn_must-razn_iz))}
  
  #Изредка - добавить чисто случайный шаг!
  if(k_step==round(k_step/13)*13){
    alef2=alef;vect_m=rnorm(k$mm)/(k$mm**0.5);
    kk=0;for (j in 1:kol_reb){if (rebro[j,1]>=0) {kk=kk+1;vect_r[j]=rnorm(1)}}
    vect_r=vect_r/(kk**0.5)}
  
  rebro3[,3]=rebro[,3]-alef2*vect_r;mass3=mass-alef2*vect_m;
  proizv3=neural$neir_proizv(k,dd,mm,rebro3,mass3,error);
  rpro3=proizv3$rpro;mmpro3=proizv3$mmpro;error3=proizv3$error;
  
  if ((error2<=error)&(error2<=error3)) {alef=alef*1.1;
  rebro=rebro2;mass=mass2;rpro=rpro2;mmpro=mmpro2;error=error2}else
  {if ((error3<=error) & (error3<=error2)) {alef=alef2;
  rebro=rebro3;mass=mass3;rpro=rpro3;mmpro=mmpro3;error=error3;}else
  {if(alef2<alef){alef=alef2};alef=alef/2}}
  
  tm=as.double(Sys.time());
  #условия окончания настройки
  if (all_time>0){if(tm>tm_beg+all_time){z_step=1}}else{if(k_step>=kol_step){z_step=1}};
  if (alef<0.0000000001){z_step=1;k$poln_nastr=1};
}
k$alef=alef;k$error=error;k$step=k$step+k_step;mm[,4]=mass;k$time=k$time+(tm-tm_beg);

mx=neir$maxx;mx=mx[(mx$vhod==0),]
sigma=((error/k$lend)**0.5)*(mx$max-mx$min);k$sigma=sigma;
neir$k=k;neir$mm=mm;neir$rebro=rebro;
return(neir)
}







#запись списка нейросетей
# заменено на myPackage$trs.Data_save(neir_hist_sokr,'neiroset','sokr',TRUE) 
#neural$neir_hist.save <- function(matrix, dbName) {
  # Сохраняет базу агрегированных данных
  # Args:   matrix: база данных
  #   dbName: имя базы
#  dbPath <- paste("./data/neir_hist/", dbName, ".csv", sep = "")
#  write.csv(x = matrix, file = dbPath)}


#теперь надо обратно прочитать файл нейросети, по имени

#neural$neir_hist.load <- function(dbName) {
  # Загружает базу агрегированных данных
  # Args: dbName: имя базы
  # Returns:  базу данных
#  dbPath <- paste("./data/neir_hist/", dbName, ".csv", sep = "")
#  if (!file.exists(dbPath)) {
#    aggrdb <- NULL} else {aggrdb <- read.csv(dbPath, header = TRUE)[, -1]}
#  return(aggrdb)}







#СОЗДАТЬ ИЗ НЕЙРОСЕТИ ЕЁ КРАТКОЕ ОПИСАНИЕ - ТОЖЕ ФРЕЙМ
neural$neir.sokr <- function(neir) {
  sozd=neir$sozd;k=neir$k;id=neir$id
  if(is.null(id)) {id=-1}
  
  neir_sokr=data.frame(id=id,versia=0)
  list=colnames(sozd)
  for (name in list){neir_sokr[name]=sozd[name]}
  if (typeof(sozd)=='list'){
    neir_sokr$name=sozd$name;neir_sokr$before=sozd$before
    vhod=sozd$vhod
    neir_sokr$progn=as.character(vhod[(vhod$vhod==0),'name']) #убрал ещё был min()
  }
  
  list=c("x","m","ogran","ogr_k","kol_neir","error","step","time","versia","sigma","lend","kol_param","poln_nastr","best_sigma")
  for (name in list){neir_sokr[name]=k[name]}
  neir_sokr$pred_id=neir$pred$id;neir_sokr$pred_versia=neir$pred$versia;
  neir_sokr$activ=1
  return(neir_sokr)
}









#запись нейросети в полную и сокращённую структуры, и плюс прогноз - сперва создать. потом записать
neural$neir.save_to_hist <- function(neir,dann) {
  #создание сокращения от нейросети
  neir$k$versia=neir$k$versia+1;
  neir_sokr=neural$neir.sokr(neir);id=neir_sokr$id;
  
  #взять старую историю нейросетей и сокращений, и прогнозов
  neir_hist=myPackage$trs.dann_load('neiroset','poln')
  neir_hist_sokr=myPackage$trs.dann_load('neiroset','sokr')
  
  #если новый id=-1 - то есть ещё не было номера у нейросети
  if(id==-1) {id=1;
  if(!is.null(neir_hist_sokr)){id=max(neir_hist_sokr$id)+1}}
  neir$id=id;neir_sokr$id=id;
  
  #получение активности - если есть данные
  activ=1
  if (!(is.null(dann))){
    #progn=neural$neir_prognoz_narabot(neir,dann) #наработка прогноза
    if ((nrow(dann[(!is.na(dann$y)),])<5*neir$k$kol_param) | (nrow(dann[is.na(dann$y),])<2))
    {activ=-1}  }
  
  #приписать сокращение (с активностью)
  if(is.null(neir_hist_sokr)){neir_hist_sokr=neir_sokr}else{
    neir_sokr$activ=activ;
    neir_hist_sokr[(neir_hist_sokr$id==id),'activ']='0';
    neir_hist_sokr=myPackage$sliv(neir_hist_sokr,neir_sokr)}
  
  #создание строки - запакованной нейросети
  neir_h=data.frame( id=array(id,1))
  neir_h$pack=myPackage$trs.pack(neir);
  
  #приписать запакованную нейросеть (если пусто - вписать)
  if(is.null(neir_hist)){neir_hist=neir_h}else{
    neir_hist=neir_hist[(neir_hist$id!=id),];
    neir_hist=rbind(neir_hist,neir_h)}
  
  #запись данных в директорию нейросетей
  myPackage$trs.Data_save(neir_hist,'neiroset','poln',TRUE) 
  myPackage$trs.Data_save(neir_hist_sokr,'neiroset','sokr',TRUE) 
  
  if (!(is.null(dann))){ # &(activ==1)){
    neir_progn=myPackage$trs.dann_load('progn','poln') #все старые прогнозы
    neir_stat=myPackage$trs.dann_load('progn','stat') #все старые прогнозы
    
    if (activ==1){
      progn=neural$neir_prognoz_narabot_stat(neir,dd_all) #наработка прогноза
      stat=progn$stat;progn=progn$progn
      neir_progn=neural$neir_progn_pripiska(neir_progn,progn)    #приписать прогнозы 
      neir_stat=neir_stat[(neir_stat$id!=id),]    
      neir_stat=myPackage$sliv(neir_stat,stat)
    } else{neir_progn=neir_progn[(neir_progn$id!=id),]
    neir_stat=neir_stat[(neir_stat$id!=id),]}
    myPackage$trs.Data_save(neir_progn,'progn','poln',TRUE) #запись прогнозов обратно
    myPackage$trs.Data_save(neir_stat,'progn','stat',TRUE) #запись статистики обратно
    
  }
  
  return(neir)
}








#НАРАБОТКА ПРОГНОЗА ПО НЕЙРОСЕТИ
neural$neir_prognoz_narabot <- function(neir,dann) {
  progn=neural$neir_prognoz(dann,neir);
  dann$progn=progn$z;dann$progn_neogr=progn$zp;dann$Total=dann$y;
  #только нужные поля
  dann$id=neir$id;dann$versia=neir$k$versia;
  list=c('id','versia','Train','Date','Type','Seats','Total','progn','progn_neogr','dann_tip');
  if (is.null(colnames(neir$sozd))){#для новой нейросети нужно много меньше
    list=c('id','versia','Date','Total','progn','dann_tip');}
  col=colnames(dann)
  if (!is.null(neir$hran)){nm=neir$hran;
  if ((substr(nm,1,6)=='Seats.')&(!('Seats' %in% col))){dann$Seats=dann[,nm];nm='Seats'}
  list=c(list,nm)}
  col=colnames(dann)
  for (nm in list){if(!(nm %in% col)){list=setdiff(list,nm)}  }
  dann=subset(dann, select = list);
  dann$Date=as.Date(dann$Date);
  return(dann)} 





#НАРАБОТКА ПО НЕЙРОСЕТИ ИМЕННО ПРОГНОЗА И СТАТИСТИКИ ОДНОВРЕМЕННО
neural$neir_prognoz_narabot_stat <- function(neir,dann) {
  progn=neural$neir_prognoz(dann,neir);
  dann$progn=round(1000*progn$z)/1000;dann$progn_neogr=progn$zp;dann$Total=dann$y;
  #только нужные поля
  dann$id=neir$id;dann$versia=neir$k$versia;
  list=c('id','versia','Date','Total','progn','dann_tip');
  col=colnames(dann)
  if (!is.null(neir$hran)){nm=neir$hran;
  if ((substr(nm,1,6)=='Seats.')&(!('Seats' %in% col))){dann$Seats=dann[,nm];nm='Seats'}
  list=c(list,nm)}
  col=colnames(dann);for (nm in list){if(!(nm %in% col)){list=setdiff(list,nm)}}
  dann=subset(dann, select = list);
  dann$Date=as.Date(dann$Date);
  progn=dann[(is.na(dann$Total)),];progn$Total=NULL;
  stat=dann[(!is.na(dann$Total)),];stat$err=-round(1000*abs(stat$Total-stat$progn))/1000;
  stat=subset(stat,selec=c('dann_tip','err'))
  stat$ed=1;stat$err2=stat$err**2
  stat_=aggregate(x=subset(stat,select=c(err2,ed)),by=subset(stat,select=c(dann_tip)),FUN='sum')
  stat_$kol=stat_$ed
  koll=100;# отладочно 300 потом=100 - минимальное число элементов в множестве
  #stat_$iz=1;stat_[(stat_$ed<koll),'iz']=0;
  stat_$tip=stat_$dann_tip;stat_[(stat_$ed<koll),'tip']=0
  st=stat_[(stat_$tip==0),]
  if (nrow(st)>0){
    st=aggregate(x=subset(st,select=c(err2,ed)),by=subset(st,select=c(tip)),FUN='sum')
    stat_[(stat_$tip==0),c('ed','err2')]=st[,c('ed','err2')]}
  stat_$ed_=round(stat_$ed-(stat_$ed)**0.5);
  stat_=stat_[(stat_$ed>koll),]
  stat_$sigma=round(((stat_$err2/stat_$ed_)**0.5)*1000)/1000
  for (tip in unique(stat_$tip)){
    st=stat_[(stat_$tip==tip),];kol=st[1,'ed_']
    st=stat[(stat$dann_tip %in% unique(st$dann_tip)),];
    st=st[order(st$err),]
    stat_[(stat_$tip==tip),'pr_m']=-st[1,'err'];
    stat_[(stat_$tip==tip),'pr_1']=-st[round(max(1,kol*1/100)),'err'];
    stat_[(stat_$tip==tip),'pr_5']=-st[round(max(1,kol*5/100)),'err'];
    stat_[(stat_$tip==tip),'pr_10']=-st[round(max(1,kol*10/100)),'err'];
    stat_[(stat_$tip==tip),'pr_20']=-st[round(max(1,kol*20/100)),'err'];  }
  
  if (nrow(stat_)>0){
    progn=progn[(progn$dann_tip %in% unique(stat_$dann_tip)),]
    stat_=subset(stat_,select=c('dann_tip','kol','sigma','pr_m','pr_1','pr_5','pr_10','pr_20'))
    stat_$id=neir$id;stat_$versia=neir$k$versia;
  }else{stat_=NULL;progn=NULL;}
  return(list(progn=progn,stat=stat_))
} 







#приписать прогнозы к фрейму уже имеющихся прогнозов (если пусто - вписать)
neural$neir_progn_pripiska <- function(neir_progn,progn) {
  if(is.null(neir_progn)){neir_progn=progn}else{
    neir_progn$Date=as.Date(neir_progn$Date);progn$Date=as.Date(progn$Date);#приведение форматов полей
    min_dat=max(progn[,'Date'])
    id=unique(progn$id)
    neir_progn_old=neir_progn[(neir_progn$id==id),];
    neir_progn_old=neir_progn_old[(neir_progn_old$Date<min_dat),];
    neir_progn=neir_progn[(neir_progn$id!=id),];
    neir_progn=myPackage$sliv(rbind(neir_progn,neir_progn_old),progn);
  }
  return(neir_progn)
}




#ДООБУЧЕНИЕ ВСЕХ НЕЙРОСЕТЕЙ - порядок сортировки - начиная с наименее обученных
#by_time=10#сколько времени тратить на настройку каждой нейросети
#name="sahalin" #какие именно нейросети просматривать

neural$all_neir_podnastr <- function(by_time,name) {tm_beg=as.double(Sys.time())
#взять старую историю нейросетей и сокращений, и прогнозов
neir_hist=myPackage$trs.dann_load('neiroset','poln')
#подвыбор лишь нужных нейросетей
neir_hist_sokr=myPackage$trs.dann_load('neiroset','sokr')
neir_hist_sokr=neir_hist_sokr[(neir_hist_sokr$activ==1),]
neir_hist_sokr=neir_hist_sokr[(neir_hist_sokr$name==name),]
neir_hist_sokr <- neir_hist_sokr[order(neir_hist_sokr$step), ];#сортировка - по числу шагов, а не времени
neir_hist_sokr$order <- 1:nrow(neir_hist_sokr)

idd_=0
print(paste("Всего в поднастройку ", nrow(neir_hist), " нейросетей", sep = ""))

for (id_ord in 1:nrow(neir_hist_sokr)){idd_=idd_+1;dt=round(as.double(Sys.time())-tm_beg);
idd=neir_hist_sokr[(neir_hist_sokr$order=id_ord),'id']
print(paste("Настраивается ", idd_, " нейросеть из ",nrow(neir_hist)," штук (tm=",dt,")", sep = ""))
pack=neir_hist[(neir_hist$id==idd),'pack']
neir= myPackage$trs.unpack(pack);rm(pack);
sozd=neir$sozd;

dn=myPackage$trs.neir_dannie(sozd);
dann=dn$dann;dn_k=dn$k;rm(dn);
#ДОБАВИТЬ брать нейросети неподряд, а сортированно по созданию, 
#  чтобы потом делать подвыбор всегда, а создавать изредка
dann=myPackage$trs.neir_dannie.vibor(dann,sozd);
#нормированние и массивы по новому, и инициализация всех параметров нейросети по необходимости
dann_n=neural$normir_dann(neir,dann);
neir=dann_n$neir;ddd=dann_n$dd;dd_all=dann_n$dd_all;rm(dann_n);


#настройка нейросети
system.time(neir<-neural$neir_nastr_new(ddd,neir,by_time))
#график коррелляции после настройки
#  progn=neural$neir_prognoz(dd_all,neir);dd_prog=dd_all;dd_prog$z=progn$z;dd_prog$zp=progn$zp;
#  plot (x=dd_prog$y,y=dd_prog$z,col=dd_prog$dann)

#запись нейросети в базу истории нейросети, и полную и сокращённую
neir=neural$neir.save_to_hist(neir,dd_all);
}
}









#СОЗДАНИЕ НОВЫХ НЕЙРОСЕТЕЙ - по образу и подобию одной

#by_time=10  #сколько времени тратить на настройку каждой нейросети

#sozd=data.frame(name='sahalin',before=10,plus_napr="2",hist='1',by_day=5,Type="К",Skor="",Napr="",First="",Train="");

neural$sozd_neir_many <- function(by_time,sozd) {
  for(before in 4:20){
    for(plus_napr in c(0,2)){
    for(hist in 0:1){
      for(by_day in c(0,5,10)){
      sozd$before=before;sozd$plus_napr;sozd$hist=hist;sozd$by_day=by_day;
      
      dn=myPackage$trs.neir_dannie(sozd);
      dann=dn$dann;dn_k=dn$k;rm(dn);
      dann=myPackage$trs.neir_dannie.vibor(dann,sozd);
      
      neir=list();k=data.frame(versia=0,x=dn_k$x,m=dn_k$m,ogran=1,ogr_k=0.2,kol_neir=0);
      neir$k=k;neir$sozd=sozd;
      
      
      #нормированние и массивы по новому, и инициализация всех параметров нейросети по необходимости
      dann_n=neural$normir_dann(neir,dann);
      neir=dann_n$neir;ddd=dann_n$dd;dd_all=dann_n$dd_all;rm(dann_n);
      
      #настройка нейросети
      system.time(neir<-neural$neir_nastr_new(ddd,neir,by_time))
      #запись нейросети в базу истории нейросети, и полную и сокращённую
      neir=neural$neir.save_to_hist(neir,dd_all);
      } } } }
}




#СОЗДАТЬ много нейросетей! по аналогии с созданием. и с перебором вариантов
#sozd=data.frame(name='sahalin',before=10,bef_end=25,plus_napr="2",hist='1',by_day=5,
#                Type="К",Skor="",Napr="",First="",Train="",vhod='kp,pkm',progn='kol_mest'
#                ,day_f='week,prazd');


#perebor=list(
#  progn= c('kp','kol_mest','pkm'), before=c(2,3,5,7,10,15),  bef_end=c(10,20,45),
#  by_day=c(5,10,20),  vhod=c('kp','pkm','kp,pkm'),
#  day_f=c('','month','week','prazd','week,prazd'),
#  Skor=c('','0','1'),  hist=c('0','1'),  plus_napr=c('0','1','2')  )
#perebor=list(name='sapsan',Type='',
#             progn= c('kp','kol_mest','pkm'), before=c(2,5,7,10,15,25,40),  bef_end=c(10,20,45),
#             by_day=c(5,10,20),  vhod=c('kp','pkm','kp,pkm'),
#             day_f=c('','month','week','prazd','week,prazd'),Napr=c('','','0','1'),
#             Skor=c(''),  hist=c('0','1'),  plus_napr=c('0','1','2')  )

neural$sozd_neir_many_50 <- function(sozd,perebor,kol=50) {
  
  neir_hist_s=myPackage$trs.dann_load('neiroset','sokr')
  ns=neir_hist_s[1,];ns=ns[2,];
  
  for (nm in colnames(sozd)){ns[,nm]=sozd[,nm]}
  dop=data.frame(ogran='1',ogr_k=0.2,kol_neir=0,step=0,time=0,activ=1,versia=0,id=0);
  for (nm in colnames(dop)){ns[,nm]=dop[,nm]}
  
  sozd_=ns;szd=sozd_;
  for (ii in 1:kol){
    for (nm in names(perebor)){
      zn=perebor[nm];for (z in zn){
        zz=array(z);l=nrow(zz);p= round(runif(1)*l+0.5)
        zzn=zz[p];szd[nm]=zzn;}}
    szd$id=szd$id+1;sozd_=rbind(sozd_,szd)}
  
  sozd_=sozd_[(sozd_$id>0),];max_id=max(neir_hist_s$id);sozd_$id=sozd_$id+max_id
  neir_hist_s=rbind(neir_hist_s,sozd_)
  myPackage$trs.Data_save(neir_hist_s,'neiroset','sokr',TRUE) #запись сокращений нейросетей обратно
}













#ВЫБОР ТОЛЬКО НАИЛУЧШИХ НЕЙРОСЕТЕЙ
neural$neir.only_best <- function(){
  nn=myPackage$trs.dann_load('neiroset','sokr');
  nn=nn[(nn$activ==1),];
  
  nn[(is.na(nn[,'hist'])),'hist']="0"
  by_=c('name','before','plus_napr','hist','by_day','Type','Train','Napr','Skor','First','ogran','ogr_k')
  for(name in by_ ) {nn[(is.na(nn[,name])),name]="-" }
  #nn$sigma=as.double(nn$sigma)
  
  by =subset(nn, select = by_)
  # by =subset(nn, select = c(before,plus_napr,hist,by_day,Type,Train,Napr,Skor,First,ogran,ogr_k))
  nn_=aggregate(x = nn$sigma, by = by, FUN = "min");
  nn_$min_sigma=nn_$x;nn_$x=NULL;
  
  nn=merge(nn, nn_, by = by_);nn$good=as.integer(nn$sigma==nn$min_sigma)
  nn=nn[(nn$good==1),];
  idd =subset(nn, select =c(id))
  rm(nn,nn_)

  #взять старую историю нейросетей и сокращений, и прогнозов
  nn=myPackage$trs.dann_load('neiroset','sokr')
  nn=merge(nn, idd, by = 'id');
  myPackage$trs.Data_save(nn,'neiroset','sokr',TRUE)
  
  #взять сами нейросети
  nn=myPackage$trs.dann_load('neiroset','poln')
  nn=merge(nn, idd, by = 'id');
  myPackage$trs.Data_save(nn,'neiroset','poln',TRUE)
  
  #взять прогнозы нейросетей
  nn=myPackage$trs.dann_load('progn','poln')
  nn=merge(nn, idd, by = 'id');
  myPackage$trs.Data_save(nn,'progn','poln',TRUE)
}






#ИЗМЕНЕНИЕ ИСТОРИИ НЕЙРОСЕТЕЙ И СОКРАЩЁННОЙ ИСТОРИИ - ДОБАВКА ЭЛЕМЕНТОВ
neural$neir_hist_dobavka <- function() {
  
  neir_hist_sokr=myPackage$trs.dann_load('neiroset','sokr')
  neir_hist_sokr$bef_end=45;
  myPackage$trs.Data_save(neir_hist_sokr,'neiroset','sokr',TRUE) 

  neir_hist=myPackage$trs.dann_load('neiroset','poln')
  list_id=neir_hist$id
  for (id in list_id){
    nh=neir_hist[(neir_hist$id==id),];
    pack=nh$pack;
    neir= myPackage$trs.unpack(pack);
    neir$sozd$bef_end=45;
    nh$pack=myPackage$trs.pack(neir);
    
    neir_hist=neir_hist[(neir_hist$id!=id),];
    neir_hist=rbind(neir_hist,nh)
  }
  rm(neir,pack,nh,list_id)
  
  myPackage$trs.Data_save(neir_hist,'neiroset','poln',TRUE) 
}


#РАЗМНОЖЕНИЕ НЕЙРОСЕТЕЙ - добавка функции даты МЕСЯЦ
#trains=unique(dann$Train)

neural$neir_hist_dobavka_2 <- function(trains) {
  mons=c('month')
  neir_hist_s_=myPackage$trs.dann_load('neiroset','sokr')
  max_id=max(neir_hist_s_$id)
  neir_hist_s=neir_hist_s_[(neir_hist_s_$activ==1),]
  
  #neir_hist_s=neir_hist_s[is.na(neir_hist_s$Skor),]
  #neir_hist_s=neir_hist_s[is.na(neir_hist_s$First),]
  #neir_hist_s=neir_hist_s[is.na(neir_hist_s$Napr),]
  #neir_hist_s=neir_hist_s[is.na(neir_hist_s$Train)|(neir_hist_s$Train==''),]
  neir_hist_s=neir_hist_s[is.na(neir_hist_s$day_f),]
  
  #neir_hist=myPackage$trs.dann_load('neiroset','poln')
  #list_id=neir_hist_s$id
  #for (id in list_id){
  #pack=neir_hist[(neir_hist$id==id),'pack'];
  #neir= myPackage$trs.unpack(pack);
  
  for (mon in mons){
    neir_hist_s$day_f=mon;neir_hist_s$step=0;neir_hist_s$sigma=NA;neir_hist_s$time=0;
    neir_hist_s$versia=0
    neir_hist_s$id=(max_id+1):(max_id+nrow(neir_hist_s))
    max_id=max_id+nrow(neir_hist_s)
    neir_hist_s_=rbind(neir_hist_s_,neir_hist_s)
  }
  #запись данных в директорию нейросетей
  myPackage$trs.Data_save(neir_hist_s_,'neiroset','sokr',TRUE) 
  
}








#РАЗМНОЖЕНИЕ НЕЙРОСЕТЕЙ - ДОБАВКА ПОЕЗДА, ПРИ ОТСУТСТВИИ МНОГИХ ИНЫХ ПАРАМЕТРОВ
#    trains=unique(dann$Train)
neural$neir_hist_dobavka_3 <- function(trains) {
  
  neir_hist_s=myPackage$trs.dann_load('neiroset','sokr')
  max_id=max(neir_hist_s$id)
  neir_hist_s=neir_hist_s[(neir_hist_s$activ==1),]
  
  neir_hist_s=neir_hist_s[is.na(neir_hist_s$Skor),]
  neir_hist_s=neir_hist_s[is.na(neir_hist_s$First),]
  neir_hist_s=neir_hist_s[is.na(neir_hist_s$Napr),]
  neir_hist_s=neir_hist_s[is.na(neir_hist_s$Train)|(neir_hist_s$Train==''),]
  
  neir_hist=myPackage$trs.dann_load('neiroset','poln')
  list_id=neir_hist_s$id
  for (id in list_id){
    pack=neir_hist[(neir_hist$id==id),'pack'];
    neir= myPackage$trs.unpack(pack);
    
    for (train in trains){max_id=max_id+1;
    neir$id=max_id;neir$sozd$Train=train;
    neir=neural$neir.save_to_hist(neir,NULL);#запись без прогнозов
    }
  }
}


#РАЗМНОЖЕНИЕ НЕЙРОСЕТЕЙ - прогноз числа мест вместо числа пассажиров

neural$neir_hist_dobavka_4 <- function(trains) {
  
  neir_hist_s=myPackage$trs.dann_load('neiroset','sokr')
  max_id=max(neir_hist_s$id)
  neir_hist_s=neir_hist_s[(neir_hist_s$activ==1),]
  
  neir_hist_s=neir_hist_s[(neir_hist_s$progn=='kp'),]
  
  neir_hist=myPackage$trs.dann_load('neiroset','poln')
  list_id=neir_hist_s$id
  for (id in list_id){
    pack=neir_hist[(neir_hist$id==id),'pack'];
    neir= myPackage$trs.unpack(pack);
    
    max_id=max_id+1;
    neir$id=max_id;neir$sozd$progn='kol_mest';
    neir=neural$neir.save_to_hist(neir,NULL);#запись без прогнозов
    
  }
}














#ДООБУЧЕНИЕ ВСЕХ НЕЙРОСЕТЕЙ - В ПАРАЛЛЕЛЬНОМ РЕЖИМЕ
#   by_time=10;k_povtor=1.5
#vibor=data.frame(name='sahalin',progn=c('kol_mest','kp_'),Skor=c(0,1),bef_end=10)
# - выбор - список только нужных полей, проверяется по равенствам (вхождениям), без интервалов значений
# k_povtor - если ошибка за проход улучшилась лболее чем в k раз - повторить заново!
neural$all_neir_podnastr_parallel <- function(by_time,vibor,k_povtor) {
  tm_beg=as.double(Sys.time())
  if (is.null(k_povtor)){k_povtor=1.5};k_povtor=max(k_povtor,1.01)
  
  #подвыбор лишь нужных нейросетей, расстановка по блокам вычислений
  neir_hist_s=myPackage$trs.dann_load('neiroset','sokr') #чтение списка всех нейросетей
  neir_hist_s=neir_hist_s[(neir_hist_s$activ==1),] #подвыборка активных
  
  neir_hist_s[is.na(neir_hist_s$time),'time']=0
  neir_hist_s[is.na(neir_hist_s$step),'step']=0
  
  #подвыбор лишь нужных нейросетей, по всем условиям выборки
  for (pole in colnames(vibor)){
    spis=unique(as.character(vibor[,pole]));
    neir_hist_s=neir_hist_s[(as.character(neir_hist_s[,pole]) %in% spis)|
                              ((is.na(neir_hist_s[,pole]))&(('' %in% spis))),]  }
  kol_neir=nrow(neir_hist_s)  
  
  if (kol_neir==0){ 
    print(paste("Всего в поднастройку ",kol_neir, " нейросетей. Конец работы "))}else{
      
      if (!('best' %in% colnames(neir_hist_s))){neir_hist_s$best=0}
      neir_hist_s[is.na(neir_hist_s$best),'best']=0
      neir_hist_s=neir_hist_s[order(-neir_hist_s$best,neir_hist_s$time), ];#сортировка - по числу шагов, а не времени
      #neir_hist_s=neir_hist_s[order(neir_hist_s$step), ];#сортировка - по НОМЕРУ НЕЙРОСЕТИ
      
      neir_hist_s$order <- 1:kol_neir
      
      #подготовка кластеров для распараллеливания  
      cores=max(min(detectCores()-1,kol_neir),1) #число имеющихся в наличии ядер. одно оставляем в запасе
      neir_blok=cores*3 #по скольку нейросетей рассматривапем в одном блоке вычислений
      clust <- makeCluster(getOption("cl.cores", cores)) #в кластер берём указанное число ядер
      clusterExport(clust, c("myPackage", "neural")) #в кластер в каждое ядро экспортируем параметры
      
      neir_hist_s$blok=round(neir_hist_s$order/neir_blok +0.499999)
      kol_blok=max(neir_hist_s$blok)
      
      print(paste("Всего в поднастройку ",kol_neir, " нейросетей = ",kol_blok," блоков", sep = ""))
      #        blok=2;   ord=3  ;   id=1
      for (blok in 1:kol_blok){ # начало очередного блока поднастройки нейросетей
        
        neir_hist_blok=neir_hist_s[neir_hist_s$blok==blok,];blok_len=nrow(neir_hist_blok)
        dt = round(as.double(Sys.time())-tm_beg);
        print(paste("Блок ",blok, ", число нейросетей = ",blok_len," штук (tm=",dt,"сек)", sep = ""))
        
        #список всех нейросетей блока
        neir_hist=myPackage$trs.dann_load('neiroset','poln') #взять старые значения нейросетей 
        neirs <- lapply(FUN = function(ord) {
          id = neir_hist_blok[(neir_hist_blok$order==ord),'id']
          pack_=neir_hist[(neir_hist$id==id),];pack = pack_$pack;made=0 
          if (!is.null(pack_)){
            if (nrow(pack_)>0){ #при существующей нейросети
              neir = myPackage$trs.unpack(pack);made=1}}
          if (made==0) { #вариант новой нейросети
            nr=neir_hist_blok[(neir_hist_blok$order==ord),]
            
            list_k=c("versia","x","m","ogran","ogr_k","kol_neir","len","mm","lend",
                     "lenp","lent","vesd","vesp","vest","error","alef","step","time","kol_vhod","kol_ver","kol_reb","sigma" )
            k=data.frame(id=id);sozd=k;
            for (nm in colnames(nr)){  if (nm %in% list_k){k[,nm]=nr[,nm]}else{sozd[,nm]=nr[,nm]}   }
            k$id=NULL;k$versia=0;k$time=0;k$step=0;
            sozd$id=NULL;sozd$order=NULL;sozd$blok=NULL
            for (nn in colnames(sozd)){sozd[,nn]=as.character(sozd[,nn])}
            neir=list();neir$k=k;neir$sozd=sozd;neir$id=id
          }
          neir$by_time=by_time;neir$k_povtor=k_povtor # время настройки и коэф повтора передаём отдельно, а в параметры нейросети
          return (neir)
        }, X = neir_hist_blok$order)
        rm(neir_hist,neir_hist_blok)
        
        #  for (neir in neirs){}  
        # Для каждой нейросети поднастройка. в параллельном режиме!!!
        neirs_ <- parLapplyLB(cl = clust, fun = function(neir) {
          by_time=neir$by_time;neir$by_time=NULL
          k_povtor=neir$k_povtor;neir$k_povtor=NULL
          sozd=neir$sozd;dn=myPackage$trs.neir_dannie(sozd);
          dann=dn$dann;dn_k=dn$k;rm(dn);
          if (neir$k$versia==0){neir$k$x=dn_k$x;neir$k$m=dn_k$m}
          #ДОБАВИТЬ брать нейросети неподряд, а сортированно по созданию, 
          #  чтобы потом делать подвыбор всегда, а создавать изредка
          neir$k$versia=neir$k$versia+1; #увеличение номера версии нейросети
          dann=myPackage$trs.neir_dannie.vibor(dann,sozd);
          #######добавить что делать при пустом множестве
          neir$k$lend=0;progn='1';if(nrow(dann)>0){
            #нормированние и массивы по новому, и инициализация всех параметров нейросети по необходимости
            dann_n=neural$normir_dann(neir,dann);
            neir=dann_n$neir;ddd=dann_n$dd;dd_all=dann_n$dd_all;rm(dann_n);  # neir$mm
            
            neir<-neural$neir_nastr_new(ddd,neir,-1) #настройка нейросети - первичное значение ошибки
            err1=neir$k$error;z='1';k=0
            while (z=='1'){k=k+1;
            neir<-neural$neir_nastr_new(ddd,neir,by_time) #настройка нейросети в цикле
            err2=neir$k$error;
            if (err2*k_povtor>err1){z='0'};err1=err2;
            }
            progn=neural$neir_prognoz_narabot(neir,dd_all) #наработка прогноза
          }
          return(list(neir = neir, progn = progn))
        }, X = neirs)
        
        
        #взять старую историю нейросетей и сокращений, и прогнозов
        neir_hist=myPackage$trs.dann_load('neiroset','poln')
        neir_hist_sokr=myPackage$trs.dann_load('neiroset','sokr')
        neir_progn=myPackage$trs.dann_load('progn','poln') #все старые прогнозы
        
        #обновить прогнозы и нейросети по результату работы блока
        for (neir_ in neirs_) {
          neir=neir_$neir;progn=neir_$progn;
          if(typeof(progn)!="character"){neir_progn=neural$neir_progn_pripiska(neir_progn,progn)}    #приписать прогнозы 
          
          #приписать сокращение (с активностью)
          neir_sokr=neural$neir.sokr(neir);id=neir_sokr$id;neir_sokr$activ=1;
          neir_sokr[(neir_sokr$lend==0),'activ']=0 #убить нейросеть с отсутствующими данными
          neir_hist_sokr[(neir_hist_sokr$id==id),'activ']='0';
          neir_hist_sokr=myPackage$sliv(neir_hist_sokr,neir_sokr);
          
          #создание строки - запакованной нейросети
          neir_h=data.frame( id=array(id,1))
          neir_h$pack=myPackage$trs.pack(neir);
          #приписать запакованную нейросеть (если пусто - вписать)
          neir_hist=neir_hist[(neir_hist$id!=id),];
          neir_hist=rbind(neir_hist,neir_h)
        }
        #обратные записи итогов работы блока
        myPackage$trs.Data_save(neir_hist,'neiroset','poln',TRUE) #запись нейросетей обратно
        myPackage$trs.Data_save(neir_hist_sokr,'neiroset','sokr',TRUE) #запись сокращений нейросетей обратно
        myPackage$trs.Data_save(neir_progn,'progn','poln',TRUE) #запись прогнозов обратно
        rm(neir_hist,neir_hist_sokr,neir_progn,neir_,neirs_,neirs,neir,neir_sokr,neir_h,progn)
        
      } #конец цикла по блокам
      stopCluster(clust)
      dt = round(as.double(Sys.time())-tm_beg);
      print(paste(" Конец работы  (tm=",dt,"сек)", sep = ""))
      
    }}

















######################################################################################
#ГЛАВНОЕ - АНАЛИЗ ПРОГНОЗОВ. ТАБЛИЦА ИТОГОВЫХ ПРОГНОЗОВ
#  prover=c(30,50);   name='sahalin'

neural$prognoz_itogi <- function(name,prover) {
  #neir_hist_s=neural$neir_hist.load('neir_hist_sokr')
  neir_hist_s_ =myPackage$trs.dann_load('neiroset','sokr')
  neir_hist_s=neir_hist_s_[(neir_hist_s_$activ==1),]
  neir_hist_s=neir_hist_s[(neir_hist_s$name==name),]
  neir_hist_s_=neir_hist_s_[(neir_hist_s_$name!=name)|(neir_hist_s_$activ!=1),]
  #статистики о нейросетях
  befores=subset(neir_hist_s,select=c('id','before','time','x','step','day_f','vhod'))
  befores$train=neir_hist_s$Train;befores$skor=neir_hist_s$Skor;
  befores$prg=neir_hist_s$progn;#befores$sig=neir_hist_s$sigma;
  
  #прогнозы исходники
  #progn=neural$neir_hist.load('neir_progn');
  progn =myPackage$trs.dann_load('progn','poln')
  progn$Date=as.Date(progn$Date)
  progn$progn=round(progn$progn)
  progn$progn_neogr=round(progn$progn_neogr)
  progn=progn[(progn$id %in% befores$id),]
  
  #прогнозы - старые и новые  
  progn_new=progn[is.na(progn$Total),]
  progn=progn[!is.na(progn$Total),]
  progn$delt=round(progn$Total)-round(progn$progn)
  max_dt=max(progn$Date)
  progn_new=progn_new[(progn_new$Date>max_dt),]
  
  #первичные статистики
  progn_z=subset(progn,select=c('id','Train','Type','delt'))
  progn_z$delt=abs(progn_z$delt);progn_z$kol=1
  progn_z=aggregate(x =list(kol=progn_z$kol),
                    by = subset(progn_z,select=c('id','Train','Type','delt')), FUN = "sum")
  rm(progn)
  
  #блок подсчёта вероятностей превышения показателей
  progn_p=progn_z[1,];progn_p$prover=0;
  for (pr in prover){progn_z$prover=pr;progn_p=rbind(progn_p,progn_z)}
  progn_p$prov=0;progn_p[(progn_p$delt>progn_p$prover),'prov']=1
  progn_p=aggregate(x =list(col=progn_p$kol,prov=progn_p$kol*progn_p$prov),
                    by = subset(progn_p,select=c('id','Train','Type','prover')), FUN = "sum")
  progn_p=progn_p[(progn_p$prover>0),]
  progn_p=progn_p[(progn_p$col>10),]
  progn_p$proc=round(10000*progn_p$prov/progn_p$col)/100;progn_p$prov=NULL;progn_p$col=NULL
  prov=unique(subset(progn_p,select=c('id','Train','Type')))
  for (pr in prover){
    prov_=progn_p[(progn_p$prover==pr),]
    prov_[,paste('proc_',pr,sep='')]=prov_$proc
    prov_$prover=NULL;prov_$proc=NULL;
    prov=merge(prov,prov_,by=c('id','Train','Type')) }
  
  #итоги важных показателей по каждой нейросети
  zz=aggregate(x =list(err= ((progn_z$delt)**2)*progn_z$kol,col=progn_z$kol),
               by = subset(progn_z,select=c('id','Train','Type')), FUN = "sum")
  zz=zz[(zz$col>10),];zz$sigma=(zz$err/zz$col)**0.5;
  zz$sigma=round(zz$sigma*100+0.5)/100
  zz=merge(zz,befores,by='id')
  zz=subset(zz,select=c('id','Train','Type','col','before','sigma','prg'))
  zz=merge(zz,prov,by=c('id','Train','Type')) 
  
  #Все прогнозы
  progn_new=merge(progn_new,zz,by=c('id','Train','Type'))
  prg=unique(subset(progn_new,select=c('Train','Date','Type','prg')))
  prg$id_prog=1:nrow(prg)
  progn_new=merge(progn_new,prg,by=c('Train','Date','Type','prg'))
  
  #только наилучшие прогнозы
  min_pr=aggregate(x =list(min_sigma=progn_new$sigma),
                   by = list(id_prog=progn_new$id_prog), FUN = "min")
  max_pr=aggregate(x =list(max_sigma=progn_new$sigma),
                   by = list(id_prog=progn_new$id_prog), FUN = "max")
  
  progn_new=merge(progn_new,min_pr,by='id_prog')
  progn_new=merge(progn_new,max_pr,by='id_prog')
  bad=progn_new[(progn_new$sigma==progn_new$max_sigma),]
  
  progn_new=progn_new[(progn_new$sigma==progn_new$min_sigma),]
  
  best=progn_new;best$best=1;best=aggregate(best ~id,data = best, sum)
  bad$bad=1;bad=aggregate(bad ~id,data = bad, sum)
  best=merge(best,bad,by='id',all=TRUE)
  for (id in best$id){
    if (is.na(best[(best$id==id),'best']))
    {best[(best$id==id),'best']=-best[(best$id==id),'bad'] } };
  best$bad=NULL
  
  neir_hist_s$best=NULL
  neir_hist_s=merge(neir_hist_s,best,by='id',all=TRUE)
  neir_hist_s_=myPackage$sliv(neir_hist_s,neir_hist_s_);
  neir_hist_s_[is.na(neir_hist_s_$best),'best']=0
  
  progn_new$min_sigma=NULL;progn_new$id=NULL;progn_new$id_prog=NULL;
  progn_new$Total=NULL;progn_new$versia=NULL;progn_new$col=NULL;
  
  
  new=progn_new;new$time=Sys.time()
  
  progn_itog =myPackage$trs.dann_load('progn','itog')
  #if(!is.null(progn_itog)){progn_itog$time=as.character(progn_itog$time)}
  progn_itog=myPackage$sliv(progn_itog,new)
  myPackage$trs.Data_save(progn_itog, 'progn','itog',first=TRUE);
  myPackage$trs.Data_save(neir_hist_s_, 'neiroset','sokr',first=TRUE);
  
  return(progn_new)
}




#по номеру нейросети возвращает из памяти саму нейросеть
neural$get_neir_id <- function(id) {
  neirs=myPackage$trs.dann_load('neiroset','poln') #чтение списка всех нейросетей
  neirs=neirs[(neirs$id==id),]
  neir = myPackage$trs.unpack(neirs$pack)
  return(neir)
}  







#-------------------------------------------------------------------------




#neir=list();


#инициализация размера фрейма, инициализация данных через фрейм
#k=data.frame(x=0,m=3,len=1000,ogran=0,ogr_k=0.1,kol_neir=0);
#neir=list(k=k);rm(k); #эта строка если нейросети ещё не существовало
#neir$k=k;rm(k); #эта строка, если нейросеть уже была хоть какая-то

#if (is.null(neir$k)){neir=list(k=k)} else
  #{neir$k$x=k$x;neir$k$m=k$m;neir$k$len=k$len;neir$k$ogran=k$ogran;
  #neir$k$ogr_k=k$ogr_k;neir$k$kol_neir=k$kol_neir;}

#dd=neural$init_dann_frame(neir$k);


#нормированние и массивы по новому, и инициализация всех параметров нейросети по необходимости
#dann_n=neural$normir_dann(neir,dd);
#neir=dann_n$neir;ddd=dann_n$dd;dd_all=dann_n$dd_all;rm(dann_n);



#настройка нейросети
#system.time(nastr<-   neural$neir_nastr(ddd,neir,10))
#system.time(nastr<-neural$neir_nastr_new(ddd,neir,10))
#neir$rebro=nastr$rebro;neir$mm=nastr$mm;neir$k=nastr$k;rm(nastr);
#error=neir$k$error;alef=neir$k$alef;k=neir$k;
#sigma=((error/neir$k$lend)**0.5)*(neir$maxx[k$x+1,2]-neir$maxx[k$x+1,1]);
#k$ogr_k=0.01


#progn=neural$neir_prognoz(dd_all,neir);dd_prog=dd;dd_prog$z=progn$z;
#if(k$ogran>0){dd_prog$z=progn$zp;}
#подсчёт итоговых отличий, независимой сверкой
#zz=aggregate(x =list(err= (dd_prog$y-dd_prog$z)**2,col=1), by = list(dd_prog$dann), FUN = "sum")
#zz$sig=(zz$err/zz$col)**0.5; #получилось хорошо - совпадает!
#график коррелляции 
#plot (x=dd_prog$y,y=dd_prog$z,col=dd_prog$dann)









#поиск диапазонов значений входов внутренних нейронов
neural$neir_vnutri<-function(neir,ddd){
  dd=ddd;
  k=neir$k;rebro=neir$rebro;mm=neir$mm;
  mmv=array(0,k$mm);mmv=mm[,4];
  #proizv=neural$neir_proizv(k,dd,mm,rebro,mass,-1);
  
  rezz=matrix(k$kol_ver,4,data=NA)
  
  kol_ver=k$kol_ver;kol_reb=k$kol_reb;
  if(k$m>0){for(j in 1:k$m){
    dd[,paste("xx",k$x+j,sep=".")]=mmv[dd[,paste("mm",j,sep=".")]]  }}
  
  dd$z=0;
  for(reb in 1:kol_reb){zn_r=rebro[reb,3];vx=rebro[reb,1];
  if (vx>0){dd$z=dd$z+ (dd[,paste("xx",vx,sep=".")]*zn_r)}
  if (vx==0){dd$z=dd$z+zn_r }
  if (vx==-1){min_=min(dd$z);max_=max(dd$z);
  if (zn_r==0){dd$pr=neural$pr0(dd$z);dd$z=neural$f0(dd$z)}
  if (zn_r==1){dd$pr=neural$pr1(dd$z);dd$z=neural$f1(dd$z)}
  if (zn_r==2){dd$pr=neural$pr2(dd$z);dd$z=neural$f2(dd$z)}
  if (zn_r==3){dd$pr=neural$pr3(dd$z);dd$z=neural$f3(dd$z)}
  if (zn_r==4){dd$pr=neural$pr4(dd$z);dd$z=neural$f4(dd$z)}
  
  rezz[rebro[reb,2],1]=min_;rezz[rebro[reb,2],2]=max_;
  dd[,paste("xx",rebro[reb,2],sep=".")]=dd$z;
  dd[,paste("xp",rebro[reb,2],sep=".")]=dd$pr;
  min_=min(dd$z);max_=max(dd$z);
  rezz[rebro[reb,2],3]=min_;rezz[rebro[reb,2],4]=max_;
  dd$z=0}}
  
  return(rezz)}







#ИСПРАВЛЕНИЕ НЕЙРОСЕТИ - ЛИШНИЕ НЕЙРОНЫ ПРЕОБРАЗОВАТЬ
neural$neir_ispravl <- function(neir,ddd) {
  dd=ddd;
  k=neir$k;rebro=neir$rebro;mm=neir$mm;
  mmv=array(0,k$mm);mmv=mm[,4];
  
  ispr=FALSE
  for(i in 1:k$kol_reb){if((rebro[i,1]==-1)&(rebro[i,3]==1)){ispr=TRUE}}
  #далее при условии ispr
  if (ispr) {
    
    rezz=matrix(k$kol_ver,5,data=NA)
    
    kol_ver=k$kol_ver;kol_reb=k$kol_reb;
    if(k$m>0){for(j in 1:k$m){
      dd[,paste("xx",k$x+j,sep=".")]=mmv[dd[,paste("mm",j,sep=".")]]  }}
    
    dd$z=0;
    for(reb in 1:kol_reb){zn_r=rebro[reb,3];vx=rebro[reb,1];vix=rebro[reb,2];
    if (vx>0){dd$z=dd$z+ (dd[,paste("xx",vx,sep=".")]*zn_r)}
    if (vx==0){dd$z=dd$z+zn_r }
    if (vx==-1){rezz[vix,5]=zn_r;
    min_=min(dd$z);max_=max(dd$z);rezz[vix,1]=min_;rezz[vix,2]=max_;
    if (zn_r==0){dd$pr=neural$pr0(dd$z);dd$z=neural$f0(dd$z)}
    if (zn_r==1){dd$pr=neural$pr1(dd$z);dd$z=neural$f1(dd$z)}
    if (zn_r==2){dd$pr=neural$pr2(dd$z);dd$z=neural$f2(dd$z)}
    if (zn_r==3){dd$pr=neural$pr3(dd$z);dd$z=neural$f3(dd$z)}
    if (zn_r==4){dd$pr=neural$pr4(dd$z);dd$z=neural$f4(dd$z)}
    
    dd[,paste("xx",vix,sep=".")]=dd$z;
    dd[,paste("xp",vix,sep=".")]=dd$pr;
    #min_=min(dd$z);max_=max(dd$z);rezz[vix,3]=min_;rezz[vix,4]=max_;
    dd$z=0}}
    
    #исправление нейросети только по модулям (нейрон=1)
    reb=data.frame(rebro);reb$n=1:nrow(reb)
    for (vix in 1:k$kol_ver){if ((rezz[vix,5]==1)&(!is.na(rezz[vix,5]))){
      if ((rezz[vix,1]<0)&(rezz[vix,2]<0)){#исправление по модулю вход
        #for (i in 1:kol_reb){if ((rebro[i,2]==vix)&(rebro[i,1]!=-1)){rebro[i,3]=-rebro[i,3]}}
        reb$k=1;reb[((reb$X2==vix)&(reb$X1!=-1)),'k']=-1;reb$X3=reb$X3*reb$k;reb$k=NULL
        c=rezz[vix,1];rezz[vix,1]=-rezz[vix,2];rezz[vix,2]=-c}
      #исправление структуры - зануление выхода плохого нейрона  
      if((rezz[vix,1]>0)&(rezz[vix,2]>0)){
        
        reb_=reb[(reb$X2==vix)&(reb$X1!=-1),]
        rebb=reb[(reb$X1==vix),]
        rebb$umn=rebb$X3;rebb$vix=rebb$X2;rebb=subset(rebb,select=c('umn','vix'))
        rr=merge(reb_,rebb)
        rr$plus=rr$X3*rr$umn;rr$X2=rr$vix;rr=subset(rr,select=c('X1','X2','plus'))
        reb=merge(reb,rr,by=c('X1','X2'),all=TRUE)
        reb[is.na(reb$plus),'plus']=0;reb$X3=reb$X3+reb$plus;reb$plus=NULL
        reb[(reb$X1==vix),'X3']=0
        reb_=reb[(reb$X2==vix)&(reb$X1!=-1),];rr=reb[(reb$X2!=vix)|(reb$X1==-1),]
        reb_$X3=rnorm(nrow(reb_)) #постановка нового случайным
        reb=rbind(reb_,rr)
      }  
    }}
    if (nrow(reb[is.na(reb$n),])==0){rebro[reb$n,3]=reb$X3;neir$rebro=rebro}
  }  #конец if по ispr
  return(neir)
}







#конец файла нейросеть изначальная

