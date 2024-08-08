
import numpy as np
import psycopg2
import time
import random

from sklearn.linear_model import LinearRegression
from sklearn.metrics import r2_score

from sklearn.preprocessing import StandardScaler
from statsmodels.genmod.generalized_linear_model import GLM
from statsmodels.genmod.families import Binomial

from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense
from tensorflow.keras.optimizers import Adam


import pandas as pd
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split
import matplotlib.pyplot as plt

import matplotlib.pyplot as plt
# from sklearn.model_selection import train_test_split


from Connect import *
from graf import *
from my_nastroika import *


rezults=[] # все будущие результаты
# is_graf=True
is_graf=False
is_sigmoid=True
is_my_prog=False

rez=dann_read()
data_ish=rez['data']

tip=data_ish['tip']
tips={}
for tp in tip:
    if tp in tips:tips[tp]+=1
    else:tips[int(tp)]=1

# tips={36:1000}
print(f'tips=={tips}')
if len(tips)>1:is_graf=False


col=rez['col']
print(f'col={col}')
col_x=[nm for nm in col if nm not in ('id','y','spros','tip')]
col_xy=['id']+col_x+['y']
col_xyv=col_xy+['vid']
print(f'col_xy={col_xy}   col_x={col_x}')

for tip in tips:
    o =(data_ish['tip']==tip)
    tab=data_ish.loc[o,]

    l=len(tab) #range(tab.shape[0] ) #количество строк

    z = [1 if i < l / 2 else 2 for i in range(l)]
    # tab['vid']= [1 if i < l / 2 else 2 for i in range(l)] #сделали одно на всех разбиение на 1=настройка и 2=тестовые
    tab.loc[:, 'vid'] = [1 if i < l / 2 else 2 for i in range(l)]  # То же самое, но не должно потом давать предупреждений
    tab=tab.sort_values('ogr')  #сортировка
    tab['id']=range(1, len(tab) + 1) #новая нумерация от 1
    data=np.array(tab[col_xyv])

    nom=np.array(tab['id'])
    ogr=tab['ogr'];x = tab[col_x];y = tab['y'];spros=np.array(tab['spros'])
    # tab.drop('spros', axis=1, inplace=True)  #УДАЛЕНИЕ ПОЛЯ ПО НАЗВАНИЮ
    tab1=tab[(tab['vid']==1)];tab2=tab[(tab['vid']==2)];
    tab1 = tab1.copy();tab2 = tab2.copy()


    #=======================================================================================
    metod = '1.LIN'
    tab1_=tab1.copy();tab2_=tab2.copy()
    ogr1=tab1_['ogr'];x1 = tab1_[col_x];y1 = tab1_['y'];spros1=tab1_['spros']
    ogr2=tab2_['ogr'];x2 = tab2_[col_x];y2 = tab2_['y'];spros2=tab2_['spros']

    print(f'={metod}==================================')
    # Создание модели линейной регрессии
    model = LinearRegression()

    tm= time.time()
    # Обучение модели
    model.fit(x1, y1)
    tm= time.time()-tm
    print(f'lin  time==={tm}')


    yy1 = model.predict(x1) # Предсказание значений Y
    yy2 = model.predict(x2)  # Предсказание значений Y


    # Вычисление корреляции между истинными значениями Y и предсказанными значениями YY
    corr1 = float(np.corrcoef(y1, yy1)[0, 1])
    r2_1 = r2_score(y1, yy1) # Вычисление R^2
    corr2 = float(np.corrcoef(y2, yy2)[0, 1])
    r2_2 = r2_score(y2, yy2) # Вычисление R^2
    mse1 = np.mean((y1-yy1) ** 2);mse2 = np.mean((y2-yy2) ** 2);# Оценка модели

    print(f"Корреляция между Y и YY:1: corr:{corr1}   R^2:{r2_1}  mse:{mse1}    2: corr:{corr2}   R^2:{r2_2}  mse:{mse2} ")
    rz = {'tip': tip, 'kol': tips[tip], 'metod': metod,'vid':1, 'corr': corr1, 'r2': r2_1, 'mse': mse1, 'time': tm}
    rezults.append(rz)  # запись итога на будущее
    rz = {'tip': tip, 'kol': tips[tip], 'metod': metod,'vid':2, 'corr': corr2, 'r2': r2_2, 'mse': mse2, 'time': tm}
    rezults.append(rz)  # запись итога на будущее


    #ЗАПИСЬ В БАЗУ ДЛЯ ОБРАБОТКИ
    tab1_['yy']=yy1;tab1_['metod']=metod
    tab2_['yy'] = yy2;tab2_['metod']=metod
    tab1_['time']=tm;tab2_['time']=tm;
    dann_zapis(tab1_);dann_zapis(tab2_);

    if is_graf:graf(tab2_,metod) # ГРАФИК





    #===========================================================================
    # model GLM
    metod = '2.GLM'
    tab1_=tab1.copy();tab2_=tab2.copy()
    ogr1=tab1_['ogr'];x1 = tab1_[col_x];y1 = tab1_['y'];spros1=tab1_['spros']
    ogr2=tab2_['ogr'];x2 = tab2_[col_x];y2 = tab2_['y'];spros2=tab2_['spros']
    print(f'={metod}==================================')
    # Стандартизация входных данных
    scaler = StandardScaler()
    # Применяем нормализацию ко всем столбцам DataFrame
    # x1_scaled = pd.DataFrame(scaler.fit_transform(x1), columns=x1.columns, index=x1.index)
    x1_scaled = pd.DataFrame(scaler.fit_transform(x1), columns=x1.columns, index=x1.index)
    x2_scaled = pd.DataFrame(scaler.transform(x2), columns=x2.columns, index=x2.index)
    yl1=y1/ogr1
    # Обучение GLM модели
    tm= time.time()
    model = GLM(yl1, x1, family=Binomial())
    results = model.fit()
    tm = time.time() - tm
    print(f'GLM time==={tm}')

    # Прогнозирование
    yy1 = results.predict(x1_scaled) * list(ogr1)
    yy2 = results.predict(x2_scaled) * list(ogr2)

    corr1 = float(np.corrcoef(y1, yy1)[0, 1])
    r2_1 = r2_score(y1, yy1) # Вычисление R^2
    corr2 = float(np.corrcoef(y2, yy2)[0, 1])
    r2_2 = r2_score(y2, yy2) # Вычисление R^2
    mse1 = np.mean((y1-yy1) ** 2);mse2 = np.mean((y2-yy2) ** 2);# Оценка модели

    print(f"Корреляция GLM между Y и YY:1: corr:{corr1}   R^2:{r2_1}  mse:{mse1}    2: corr:{corr2}   R^2:{r2_2}  mse:{mse2} ")
    rz = {'tip': tip, 'kol': tips[tip], 'metod': metod,'vid':1, 'corr': corr1, 'r2': r2_1, 'mse': mse1, 'time': tm}
    rezults.append(rz)  # запись итога на будущее
    rz = {'tip': tip, 'kol': tips[tip], 'metod': metod,'vid':2, 'corr': corr2, 'r2': r2_2, 'mse': mse2, 'time': tm}
    rezults.append(rz)  # запись итога на будущее


    #ЗАПИСЬ В БАЗУ ДЛЯ ОБРАБОТКИ
    tab1_['yy']=yy1;tab1_['metod']=metod
    tab2_['yy'] = yy2;tab2_['metod']=metod
    tab1_['time'] = tm;tab2_['time'] = tm;
    dann_zapis(tab1_);dann_zapis(tab2_);

    if is_graf:graf(tab2_,metod) # ГРАФИК



    #===========================================================================
    ######### model sigmoid

    if is_sigmoid:
        metod='3.SIGMOID'
        tab1_=tab1.copy();tab2_=tab2.copy()
        ogr1=tab1_['ogr'];x1 = tab1_[col_x];y1 = tab1_['y'];spros1=tab1_['spros']
        ogr2=tab2_['ogr'];x2 = tab2_[col_x];y2 = tab2_['y'];spros2=tab2_['spros']
        yl1=y1/ogr1;yl2=y2/ogr2

        print(f'={metod}==================================')
        scaler = StandardScaler()
        x1_scaled = pd.DataFrame(scaler.fit_transform(x1), columns=x1.columns, index=x1.index)
        x2_scaled = pd.DataFrame(scaler.transform(x2), columns=x2.columns, index=x2.index)

        tm = time.time()
        # Создание модели нейронной сети
        model = Sequential([
            Dense(64, activation='relu', input_shape=(3,)),
            Dense(32, activation='relu'),
            Dense(16, activation='relu'),
            Dense(1, activation='sigmoid') ])
        # Компиляция модели
        model.compile(optimizer=Adam(learning_rate=0.001), loss='mse')
        # Обучение модели
        model.fit(x1_scaled, yl1, epochs=100, batch_size=32, validation_split=0.2, verbose=0)
        tm = time.time() - tm
        print(f'SIGMOID time==={tm}')

        # Прогнозирование
        yy1 = (model.predict(x1_scaled).flatten())*ogr1
        yy2 = (model.predict(x2_scaled).flatten()) * ogr2

        corr1 = float(np.corrcoef(y1, yy1)[0, 1])
        r2_1 = r2_score(y1, yy1)  # Вычисление R^2
        corr2 = float(np.corrcoef(y2, yy2)[0, 1])
        r2_2 = r2_score(y2, yy2)  # Вычисление R^2
        mse1 = np.mean((y1 - yy1) ** 2);
        mse2 = np.mean((y2 - yy2) ** 2);  # Оценка модели

        print(f"Корреляция GLM между Y и YY:1: corr:{corr1}   R^2:{r2_1}  mse:{mse1}    2: corr:{corr2}   R^2:{r2_2}  mse:{mse2} ")
        rz = {'tip': tip, 'kol': tips[tip], 'metod': metod, 'vid': 1, 'corr': corr1, 'r2': r2_1, 'mse': mse1,'time': tm}
        rezults.append(rz)  # запись итога на будущее
        rz = {'tip': tip, 'kol': tips[tip], 'metod': metod, 'vid': 2, 'corr': corr2, 'r2': r2_2, 'mse': mse2,'time': tm}
        rezults.append(rz)  # запись итога на будущее

        #ЗАПИСЬ В БАЗУ ДЛЯ ОБРАБОТКИ
        tab1_['yy']=yy1;tab1_['metod']=metod
        tab2_['yy'] = yy2;tab2_['metod']=metod
        tab1_['time'] = tm;tab2_['time'] = tm;
        dann_zapis(tab1_);dann_zapis(tab2_);

        if is_graf:graf(tab2_,metod) # ГРАФИК




    #===========================================================================
    # model RandomForest
    metod='4.RandomForest'
    tab1_=tab1.copy();tab2_=tab2.copy()
    ogr1=tab1_['ogr'];x1 = tab1_[col_x];y1 = tab1_['y'];spros1=tab1_['spros']
    ogr2=tab2_['ogr'];x2 = tab2_[col_x];y2 = tab2_['y'];spros2=tab2_['spros']
    print(f'={metod}==================================')
    tm= time.time()
    # Обучение модели случайного леса
    rf_model = RandomForestRegressor(n_estimators=100, random_state=42)
    # xx=x.values.reshape(-1, 1)
    rf_model.fit(x1, y1)
    # Прогнозирование на тестовой выборке
    yy1 = rf_model.predict(x1);yy2 = rf_model.predict(x2)
    tm = time.time()-tm
    print(f'RandomForest time==={tm}')


    #спрогнозируем и спрос тоже
    ogr=max(list(x1['ogr'])+list(x2['ogr']));x1.loc[:,'ogr']=ogr;x2.loc[:,'ogr']=ogr
    yy_1 = rf_model.predict(x1);yy_2 = rf_model.predict(x2)


    corr1 = float(np.corrcoef(y1, yy1)[0, 1])
    r2_1 = r2_score(y1, yy1)  # Вычисление R^2
    corr2 = float(np.corrcoef(y2, yy2)[0, 1])
    r2_2 = r2_score(y2, yy2)  # Вычисление R^2
    mse1 = np.mean((y1 - yy1) ** 2);
    mse2 = np.mean((y2 - yy2) ** 2);  # Оценка модели

    print(f"Корреляция RandomForest между Y и YY:1: corr:{corr1}   R^2:{r2_1}  mse:{mse1}    2: corr:{corr2}   R^2:{r2_2}  mse:{mse2} ")

    corr_s1 = float(np.corrcoef(spros1, yy_1)[0, 1]) #коррелляция спроса и прогноза спроса
    corr_s2 = float(np.corrcoef(spros2, yy_2)[0, 1])  # коррелляция спроса и прогноза спроса
    r2_s1 = r2_score(spros1, yy_1)  # Вычисление R^2
    r2_s2 = r2_score(spros2, yy_2)  # Вычисление R^2
    mse_s1 = np.mean((spros1 - yy_1) ** 2)
    mse_s2 = np.mean((spros2 - yy_2) ** 2)
    print(f"+++++Корреляция между спросом и неограниченным прогнозом (RandomForest)1: =={corr_s1}  R^2=={r2_s1} mse=={mse_s1}   2: =={corr_s2}  R^2=={r2_s2} mse=={mse_s2}")
    rz = {'tip': tip, 'kol': tips[tip], 'metod': metod,'vid':1, 'corr': corr1, 'r2': r2_1, 'mse': mse1,'corr_s':corr_s1,'r2_s':r2_s1,'mse_s':mse_s1, 'time': tm}
    rezults.append(rz)  # запись итога на будущее
    rz = {'tip': tip, 'kol': tips[tip], 'metod': metod,'vid':2, 'corr': corr2, 'r2': r2_2, 'mse': mse2,'corr_s':corr_s2,'r2_s':r2_s2,'mse_s':mse_s2, 'time': tm}
    rezults.append(rz)  # запись итога на будущее

    #ЗАПИСЬ В БАЗУ ДЛЯ ОБРАБОТКИ
    tab1_['yy']=yy1;tab1_['spros_']=yy_1;tab1_['metod']=metod
    tab2_['yy'] = yy2;tab2_['spros_'] = yy_2;tab2_['metod']=metod
    tab1_['time'] = tm;tab2_['time'] = tm;
    dann_zapis(tab1_);dann_zapis(tab2_);

    if is_graf:graf(tab2_,metod) # ГРАФИК




    #===========================================================================
    #Далее моя программа настройки
    metod='0.My_progn'
    tab1_=tab1.copy();tab2_=tab2.copy()
    ogr1=tab1_['ogr'];x1 = tab1_[col_x];y1 = tab1_['y'];spros1=tab1_['spros']
    ogr2=tab2_['ogr'];x2 = tab2_[col_x];y2 = tab2_['y'];spros2=tab2_['spros']


    print(f'={metod}==================================')
    bcorr=-1;bprg=0

    tm= time.time()
    prog = my_prog()
    prog.nastr(tab1, col_x)
    # prog.print_koef()
    prg1 = prog.prognoz(tab1)
    prg2 = prog.prognoz(tab2)
    tm = time.time()-tm
    print(f'my_prog   time==={tm}')
    yy_1=prg1['yy_'];yy1=prg1['yy'];yy_2 = prg2['yy_'];yy2 = prg2['yy']; # только нужные поля


    corr1 = float(np.corrcoef(y1, yy1)[0, 1])
    r2_1 = r2_score(y1, yy1)  # Вычисление R^2
    corr2 = float(np.corrcoef(y2, yy2)[0, 1])
    r2_2 = r2_score(y2, yy2)  # Вычисление R^2
    mse1 = np.mean((y1 - yy1) ** 2);
    mse2 = np.mean((y2 - yy2) ** 2);  # Оценка модели


    corr_s1 = float(np.corrcoef(spros1, yy_1)[0, 1]) #коррелляция спроса и прогноза спроса
    corr_s2 = float(np.corrcoef(spros2, yy_2)[0, 1])  # коррелляция спроса и прогноза спроса
    r2_s1 = r2_score(spros1, yy_1)  # Вычисление R^2
    r2_s2 = r2_score(spros2, yy_2)  # Вычисление R^2
    mse_s1 = np.mean((spros1 - yy_1) ** 2)
    mse_s2 = np.mean((spros2 - yy_2) ** 2)

    print(
        f"Корреляция my_progn между Y и YY:1: corr:{corr1}   R^2:{r2_1}  mse:{mse1}    2: corr:{corr2}   R^2:{r2_2}  mse:{mse2} ")
    rz = {'tip': tip, 'kol': tips[tip], 'metod': metod,'vid':1, 'corr': corr1, 'r2': r2_1, 'mse': mse1,'corr_s':corr_s1,'r2_s':r2_s1,'mse_s':mse_s1, 'time': tm}
    rezults.append(rz)  # запись итога на будущее
    rz = {'tip': tip, 'kol': tips[tip], 'metod': metod,'vid':2, 'corr': corr2, 'r2': r2_2, 'mse': mse2,'corr_s':corr_s2,'r2_s':r2_s2,'mse_s':mse_s2, 'time': tm}
    rezults.append(rz)  # запись итога на будущее

    #ЗАПИСЬ В БАЗУ ДЛЯ ОБРАБОТКИ
    tab1_['yy']=yy1;tab1_['spros_']=yy_1;tab1_['metod']=metod
    tab2_['yy'] = yy2;tab2_['spros_'] = yy_2;tab2_['metod']=metod
    tab1_['time'] = tm;tab2_['time'] = tm;
    dann_zapis(tab1_);dann_zapis(tab2_);

    if is_graf or is_my_prog:
        graf(tab2_,metod) # ГРАФИК







print('===================================================')

# print(f'rezults==\n{rezults}')
for rz in rezults:
    print(f'rz=={rz}')
#
# rezz=pd.DataFrame(rezults)
# print(f'2_rezz===\n{rezz}')


# dann_zapis(rezz)

# graf_rezult(rezz)








