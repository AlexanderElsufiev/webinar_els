###############################################################################
### ПОДГОТОВКА ДАННЫХ К СЛУЧАЙНОМУ ВЫБОРУ!
#   name='sahalin'

if (!require("data.table")) {
  install.packages("data.table")
}
library(data.table)

myPackage$trs.dannie_for_neir <- function(name) {
  str = c('Train','Type','Arenda','Napr','First','Skor')# список основных важных полей, кроме даты
  rezult = as.data.table(myPackage$trs.dann_load(name,'ext'))
  max_date = max(zoo::as.Date(unique(rezult[(!is.na(rezult$kp0)),Date])))
  for (nm in setdiff(str,colnames(rezult))) {
    rezult[,nm] = '-'
  }#поля, которых не было
  
  #введение временных параметров
  rezult$hh = round(rezult$Time / 30) / 2
  rezult$hh2 = round(rezult$hh / 2) * 2
  rezult$h_otp = round(rezult$Tm_otp / 60)
  rezult$h_prib = round((rezult$Tm_otp + rezult$Time) / 60)
  rezult$h_otp3 = round(rezult$h_otp / 3) * 3
  rezult$h_prib3 = round(rezult$h_prib / 3) * 3
  
  rezult$h_otp6 = round(rezult$h_otp / 6) * 6
  rezult$h_prib6 = round(rezult$h_prib / 6) * 6
  
  str = c(str,'hh','hh2','h_otp','h_prib','h_otp3','h_prib3','h_otp6','h_prib6')
  
  #сколько мест в вагоне
  rezult$vag = round(rezult$Seats / rezult$Kol_vag)
  vag = unique(rezult[, .(vag, Type)])
  vag = vag[, lapply(.SD, max), .SDcols = c('vag'), by = c('Type')]
  ind <- order(vag$Type)
  vag = vag[ind,]
  
  rezult_ = NULL
  rezult_s = NULL
  # 4 группы группируемых столбцов в 4 строки
  for (nm in c('kp','pkm','stoim','cena','kpv','cenv')) {
    rez_ = rezult[, .SD, .SDcols = c('Date', str)]
    rez_$name = nm
    rez_$iz = 0
    
    for (i in 0:44) {
      nnm = paste('zn',i,sep = '')
      tmp <- as.numeric(as.matrix(rezult[, .SD, .SDcols = paste(nm,i,sep = '')]))
      #преобразуем пассажирокилометры - делим на расстояние!!!
      if (nm == 'pkm') {
        tmp <- tmp / rezult[, Rasst]
      }
      #деньги - в тысячи руб
      if (nm %in% c('stoim','cena','cenv')) {
        tmp <- tmp / 10000
      }
      rez_[((tmp != 0) & (!is.na(tmp))), "iz"] <- 1
      rez_[,nnm] <- tmp
      rezult[,paste(nm,i,sep = '')] = NULL
    }
    rezult_ = myPackage$sliv(rezult_,rez_)
    rm(rez_)
  }
  rezult_ = rezult_[(rezult_$iz == 1),]
  rezult_$iz = NULL
  
  
  #ухудшение по числу предложенных мест
  rezult[(rezult$Arenda != '-'), c('Seats','Kol_vag')] <- NA
  rezult$pusto = ((rezult$Seats - rezult$kol_mest) * rezult$Kol_vag / rezult$Seats)
  rezult$pusto = pmax(round(rezult$pusto - 0.5),0)
  rezult[(is.na(rezult$pusto)),'pusto'] = 0
  rezult[(rezult$Type == '-'),'pusto'] = 0
  rezult = rezult[order(rezult$Date,rezult$Train,rezult$Type,rezult$Arenda),]
  #чисто случайная добавка мест заменена на псевдослучайную. фиксированную, по отсортированному множеству
  rezult$Seats_plus = round((rezult$Seats / rezult$Kol_vag) *
                              round(-rezult$pusto + 10 * myPackage$trs.runif(nrow(rezult))))
  rezult[(rezult$pusto == 0),'Seats_plus'] = 0
  
  #rezult$seats=rezult$Seats #старые неухудшенные значения
  rezult$Seats = rezult$Seats + rezult$Seats_plus
  
  rezult$Seats_plus = NULL
  rezult$pusto = NULL
  
  for (nm in c('Seats','kol_mest')) {
    rez_  <- rezult[, .SD, .SDcols = c('Date',str)]
    rez_$name <- nm
    rez_[,'zn'] <- as.numeric(as.matrix(rezult[, .SD, .SDcols = nm]))
    
    rezult[,nm] = NULL
    #rez_=rez_[(!is.na(rez_$zn)),]
    # убрал - чтобы было видно неизвестное будущее!
    rezult_s = myPackage$sliv(rezult_s,rez_)
    rm(rez_)
  }
  
  
  #поиск уникальных вариантов - выкинуть заведомо ненужные поля из списка всез возможных
  un = unique(rezult[, .SD, .SDcols = str])
  un$ed = 1
  delet = c()
  for (nm in str) {
    uu = unique(un[, .SD, .SDcols = c(nm,'ed')])
    k = nrow(uu)
    if (k == 1) {
      str = setdiff(str,nm)
      delet = c(delet,nm)
    }
  }
  
  for (nm in delet) {
    rezult[,nm] = NULL
    rezult_[,nm] = NULL
    rezult_s[,nm] = NULL
  }
  str_ = setdiff(str,c('Train','Type','Arenda')) # по каким параметрам можно подсуммировать
  #ДАЛЬНЕЙШАЯ ОБРАБОТКА
  #КОНКРЕТНО ДЛЯ САХАЛИНА - получение подсуммирований по каждому (ОДНОМУ)параметру
  
  summir = paste("zn", as.character(0:44) ,sep = "")
  by = c('Date',str,'name')
  
  rezz = rezult_
  rezz$ed = 1
  summs = c()
  for (nm in str_) {
    rez = rezz
    rez = rez[(!(rez$name %in% c('cena','cenv'))),]
    rez$name = paste(rez$name,nm,sep = '.')
    rez$Train = '-'
    
    for (nm2 in str_) {
      if (nm2 != nm) {
        rez[,nm2] = '-'
      }
    }
    #подсуммировать rez
    
    rez <- rez[, lapply(.SD, sum), .SDcols = c(summir, 'ed'), by = by]
    rz <- rez[, lapply(.SD, max), .SDcols = c('ed'), by = c('name')]
    rz <- rz[(rz$ed > 1),]
    rz$ed = NULL
    rez$ed = NULL
    rez = merge(rez,rz,by = 'name')
    if (nrow(rz) > 0) {
      rezult_ = rbind(rezult_,rez)
      summs = c(summs,nm)
    }
    rm(rez,rz)
  }
  rm(rezz)
  
  # По кому суммировалась rezult, по тем суммировать и rezult_s
  rezz = rezult_s
  
  for (nm in summs) {
    rez = rezz
    rez = rez[(rez$name != 'cena'),]
    rez$name = paste(rez$name,nm,sep = '.')
    rez$Train = '-'
    
    for (nm2 in str_) {
      if (nm2 != nm) {
        rez[,nm2] = '-'
      }
    }
    #подсуммировать rez
    rez <- rez[, lapply(.SD, sum), .SDcols = c('zn'), by = by]
    rezult_s = rbind(rezult_s,rez)
    rm(rez)
  }
  #блок - взять тех, у кого хоть раз есть реальные данные
  by_ = c(str,'name')
  rez = rezult_s[(!is.na(rezult_s$zn)),]
  rez = unique(rez[, .SD, .SDcols = by_])
  rezult_s = merge(rezult_s,rez,by = by_)
  rm(rezz,rez)
  
#   число мест - на будущее размножить - УДАЛЕНО
#   if (1 == 0) {
#     rezult_s$ss = 0
#     
#     rezult_s[(substr(rezult_s$name,1,5) == 'Seats') &
#                (as.Date(rezult_s$Date) > max_date),'ss'] = 1
#     rezult_s[(substr(rezult_s$name,1,5) == 'seats') &
#                (as.Date(rezult_s$Date) > max_date),'ss'] = -1
#     
#     rs = rezult_s[(rezult_s$ss == 1),]
#     rs = merge(rs,vag,by = 'Type')
#     
#     kol = data.frame(kol = -2:5)
#     rs = merge(rs,kol)
#     rs$zn = rs$zn + rs$vag * rs$kol
#     
#     rs = rs[(rs$zn >= rs$vag),]
#     rs$vag = NULL
#     rs$kol = NULL
#     rezult_s = rezult_s[(rezult_s$ss == 0),]#не берём истиные места из будущего
#     rezult_s = rbind(rezult_s,rs)
#     rm(rs)
#     rezult_s$ss = NULL
#     rs = rezult_s[(substr(rezult_s$name,1,5) == 'seats'),]
#     rezult_s = rezult_s[(substr(rezult_s$name,1,5) != 'seats'),]
#     rs$name = paste('S',substr(rs$name,2,nchar(rs$name)),sep = '')
#     rezult_s = rbind(rezult_s,rs)
#     rezult_s = unique(rezult_s)
#     rm(rs)
#   }
  
  #есть номер поезда - некоторые параметры не важны
  #rezult_[(rezult_$Train!='-'),str]='-'
  #rezult_s[(rezult_s$Train!='-'),str]='-'
  
  str_ = c()
  for (nm in str) {
    str_ = c(str_,paste(nm,'_',sep = ''))
  }
  
  #постановка таблицы возможных результатов
  rez1 = unique(rezult_[, .SD, .SDcols = c(str,'name')])
  rez1$tab = '1'
  
  rez2 = unique(rezult_s[, .SD, .SDcols = c(str,'name')])
  rez2$tab = '2'
  
  rez = rbind(rez1,rez2)
  rm(rez1,rez2)
  
  #Создание  ID на все поля возможных массивов (чтобы не было проблем с кодировками)
  #id_str=c()
  #for (nm in str){if(nm!='Train'){id_str=c(id_str,paste('id_',nm,sep=''))}}
  
  #ТИПЫ ДАННЫХ - СВЕРКА СО СТАРЫМИ, и запись в базу навсегда
  tip = unique(rez[, .SD, .SDcols = str])#все типы входных данных
  tip$name = name
  dann_tip = as.data.table(myPackage$trs.dann_load('progn','dann_tip'))
  if (is.null(dann_tip) || ncol(dann_tip) == 0) {
    tip$dann_tip = 1:nrow(tip)
    dann_tip = tip
  } else {
    col1 = colnames(dann_tip)
    col2 = colnames(tip)
    col = setdiff(col1,setdiff(col1,col2))
    tip = merge(dann_tip,tip,by = col,all = T)
    
    tip_ = tip[(is.na(tip$dann_tip)),]
    tip = tip[(!is.na(tip$dann_tip)),]
    if (nrow(tip_) > 0) {
      tip_$dann_tip = (1:nrow(tip_)) + max(tip$dann_tip)
      dann_tip = rbind(tip,tip_)
    }
    rm(col,col1,col2,tip_)
  }
  #заполнение id_полей  ############################################################################
  id_str = c()
  tip = dann_tip #  nm='Train' nm = 'Type'
  for (nm in str) {
    #if(nm!='Train'){
    nm_ = paste('id_',nm,sep = '')
    id_str = c(id_str,nm_)
    if (!(nm_ %in% colnames(tip))) {
      tip[, nm_] = 0
      tip[, nm_] = NA
    }
    tp = unique(tip[, .SD, .SDcols = c(nm,nm_)])
    
    tmp = tp[(!is.na(as.vector(t(tp[,nm, with = FALSE])))),]
    ind <- which(as.vector(t(tp[, nm, with = FALSE])) == '-') 
    tp[ind, nm_] = 0
    tp_ = unique(tp[(is.na(as.vector(t(tp[,nm_, with = FALSE])))),])
    k = 0
    tp = unique(tp[(!is.na(as.vector(t(tp[,nm_, with = FALSE])))),])
    
    tps = tp
    tps$zzz = tps[,nm_, with = FALSE]
    tps[,nm_] = NULL
    tp_ = merge(tp_,tps,by = nm,all = TRUE)
    tp_ = tp_[is.na(tp_$zzz),]
    tp_$zzz = NULL
    if (nrow(tp) > 0) {
      k = max(tp[,nm_, with = FALSE])
    }
    if (nrow(tp_) > 0) {
      tp_[,nm_] = (1:nrow(tp_)) + k
    }
    tp = rbind(tp,tp_)
    
    tip[,nm_] = NULL
    tip = merge(tip,tp,by = nm,all = TRUE)
  }
  #}
  dann_tip = tip
  #запись итогов в память навсегда
  myPackage$trs.Data_save(dann_tip, 'progn','dann_tip',TRUE)
  ind <- (dann_tip$name == name)
  tip = dann_tip[ind,]
  tip$name = NULL
  rm(dann_tip)
  
  
  for (nm in str) {
    nm_ = paste(nm,'_',sep = '')
    tip[,nm_] = '-'
    tip[(tip[,nm] != '-'), nm_] = '*'
  }
  tipp = unique(tip[, .SD, .SDcols = str_])
  tipp$tip = 1:nrow(tipp)
  tip = merge(tip,tipp,by = str_)
  tip = tip[, .SD, .SDcols = c(str,'tip','dann_tip',id_str)]
  
  rez = merge(rez,tip,by = str)
  tip_n = unique(rez[, .SD, .SDcols = c('name','tip')])
  tip_n$tip_n = 1:nrow(tip_n)
  tip_name = tip_n
  rez = merge(rez,tip_n,by = c('name','tip'))
  
  rezult_ = merge(rez,rezult_,by = c(str,'name'))
  rezult_s = merge(rez,rezult_s,by = c(str,'name'))
  
  #указатель - что именно вообще надо прогнозированть
  rez$progn = '1' #а далее вычёркиваем. кого не прогнозируем
  rez[(rez$name %in% c('cena','cenv','kpv','pkm')), 'progn'] = '0'
  rez[(substr(rez$name,1,5) == 'Seats'),'progn'] = '0'
  rez[(rez$First != '-') & (rez$Train == '-'),'progn'] = '0'
  rez$progn = '0'
  rez[(rez$name == 'kol_mest'), 'progn'] = '1'
  rez[(rez$Type == '-'),'progn'] = '0'
  rez[(rez$Arenda != '-'),'progn'] = '0'
  #rez[(substr(rez$name,1,5)!='stoim'),'progn']='0'
  ## наоборот - прогн только стоимости!!!
  #временная мера - не прогнозируем стоимость
  
  #ДЛЯ ОТЛАДКИ прогнозирования - ПРОГНОЗ ТОЛЬКО ПАССАЖИРОВ, БЕЗ ПОДСУММИРОВАНИЙ (кроме направления)
  #ostavl=c('kp','kp.Napr','kol_mest','kol_mest.Napr')
  #rez[(!(rez$name %in% ostavl)),'progn']='0'
  
  #глубина событий - за сколько до отправления
  rez$max_bef = 44
  rez[(rez$tab == '2'), 'max_bef'] = 0
  rez[(substr(rez$name,1,5) == 'Seats'),'max_bef'] = -1
  rez$vid = 'x'
  
  #данные массивов о праздниках и прочем
  dats = as.data.table(myPackage$prazd)
  # праздники
  dats$dat = as.Date(paste(substr(as.character(dats$Date),1,4),'-01-01',sep = ''))
  dats$week = pmin(round(((dats$Date - dats$dat) + 4) / 7),52)
  dats$dat = NULL
  # номер недели
  dats$weekday = as.integer(dats$Date) - round(as.integer(dats$Date) / 7) * 7 + 4
  #ровно день недели =1:7 пн-вс
  dats$month = as.integer(substr(as.character(dats$Date),6,7))
  
  
  #поставить прочие данные - случайный курс валюты, и возможны прочие поля
  kurs = dats[, .SD, .SDcols = 'Date']
  kurs$kurs = sin(as.integer(kurs$Date) / 12) + 2
  
  #kurs[(kurs$Date<'2015-10-01'),]#ограничение по дате уже известного
  
  #информация о столбцах обеих дополнительных таблиц
  rez_ = data.table(name = colnames(dats))
  rez_$tab = 3
  rez_$max_bef = -1
  rez_$vid = 'm'
  
  rez_2 = data.table(name = colnames(kurs))
  rez_2$tab = 4
  rez_2$max_bef = 0
  rez_2$vid = 'x'
  
  
  rezz = rbind(rez_,rez_2)
  rm(rez_,rez_2)
  
  rezz$progn = 0
  rezz = rezz[(rezz$name != 'Date'),]
  rezz$tip = 0
  tip_n = max(tip_name$tip_n)
  rezz$tip_n = (tip_n + 1):(tip_n + nrow(rezz))
  
  #приписать итоговую информацию
  rez = myPackage$sliv(rez,rezz)
  rezz = rezz[, .SD, .SDcols = c('name','tip','tip_n')]
  tip_name = rbind(tip_name,rezz)
  
  #удаление из итога ненужных полей
  for (nm in delet) {
    rezult[,nm] = NULL
    rezult_[,nm] = NULL
    rezult_s[,nm] = NULL
  }
  
  #ПОЛНЫЙ ИТОГ
  # rez->rez_dann0  , rez_dann->rez_dann1  , rez_dann_s->rez_dann2
  dannie = list(
    rez_dann0 = rezult, rez_dann1 = rezult_, rez_dann2 = rezult_s,
    rez_dann3 = dats,rez_dann4 = kurs,name = name,
    tip = tipp, tip_name = tip_name, tip_all = rez, dann_tip =  tip,
    params = str,id_params = id_str
  )
  
  #у краткой истории нейросетей удалить факт полной настроенности
  neir_hist_s = myPackage$trs.dann_load('neiroset','sokr') #чтение списка всех нейросетей
  if (!is.null(neir_hist_s)) {
    neir_hist_s[((neir_hist_s$activ == 1) &
                   (neir_hist_s$name == name)),'poln_nastr'] = 0
    myPackage$trs.Data_save(neir_hist_s, 'neiroset','sokr',first = TRUE)
  }#запись обратно
  
  #rm(rezult,rezult_,rezult_s,tipp,tip_n,tip,rez,progn,nm,nm_,nm2,i,str,str_,summir,by,dann,tip_n)
  return(dannie)
}