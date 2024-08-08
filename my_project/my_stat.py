


import psycopg2
import numpy as np
import pandas as pd
from sklearn.metrics import r2_score
import math

from Connect import *
from graf import *


rez=stat_read()

dann=rez['data']
dann=dann.loc[(dann['x1'].notnull()),] #только реальные данные настроек
# dd=dann.loc[(dann['metod']==met)&(dann['x1'].isnull()),]
# dd=dann.loc[(dann['metod']==met)&(dann['x1'].notnull()),]

# dann=dann.loc[(dann['tip']<6),]



l=len(dann)
col=dann.columns

print(f'len=={l}  col=={col}')

metod=sorted(list(set(dann['metod'])))
print(f'metod=={metod}')
rezult=[]

# met='0.My_progn     '
# met='1.LIN          '
for met in metod:
    print(f'metod=={met}')
    tips = sorted(list(set(dann['tip'])))
    # print(f'tips=={tips}')
    for tip in tips:
        # rz = {'tip': tip, 'metod': met} #, 'vid': 1, 'corr': corr1, 'r2': r2_1, 'mse': mse1,
        for vid in [1,2]:
            dd = dann.loc[(dann['metod'] == met)&(dann['tip']==tip)&(dann['vid']==vid),]
            y = (dd['y']);yy = (dd['yy']);
            time = list(dd['time']);time=time[0];time=math.log(time)/math.log(10)
            mse = np.mean((y - yy) ** 2)
            y=list(y);yy=list(yy)
            corr = float(np.corrcoef(y, yy)[0, 1])
            r2 = r2_score(y, yy);
            if r2<-1:r2=None
            m_spros = max(list(dd['spros']));
            m_ogr = max(list(dd['yy']))
            rz = {'tip': tip, 'metod': met,'vid':vid,'time':time, 'corr': corr, 'r2': r2, 'mse': mse,'max_spros':m_spros,'max_ogr':m_ogr}
            # теперь по спросу
            y = dd['spros'];yy = dd['spros_'];
            if not list(yy)[0] is None:
                mse = np.mean((y - yy) ** 2)
                y = list(y);yy = list(yy)
                corr = float(np.corrcoef(y, yy)[0, 1])
                r2 = r2_score(y, yy);
                if r2<-1:r2=None
                rz['corr_s']=corr;rz['r2_s']=r2;rz['mse_s']=mse
            rezult.append(rz)
# print(f'rezult==\n{rezult}')
for rz in rezult:print(f'rz=={rz}')




rezz=pd.DataFrame(rezult)
print(f'2_rezz===\n{rezz}')
graf_rezult(rezz)




# ВЫДАЧА ГРАФИКОВ ПРОГНОЗИРОВАНИЯ

rz_bad=rezz.loc[(rezz['tip']==1)&(rezz['vid']==2),].copy()


for index, rz in rz_bad.iterrows():
    rz=dict(rz)
    tip=rz['tip']
    met = rz['metod']
    vid=rz['vid']
    dd = dann.loc[(dann['metod'] == met) & (dann['tip'] == tip) & (dann['vid'] == vid),]
    graf(dd, met)  # ГРАФИК



#=================================================
# ПОДВЕДЕНИЕ РАНГОВ МЕСТ ПО АЛГОРИТМАМ
sravn={}

tips=list(set(rezz['tip']))
print(f'tips=={tips}')
for tip in tips:
    rz=rezz.loc[(rezz['tip']==tip)&(rezz['vid']==2),]
    rz=rz[['metod','mse']]
    rz = rz.sort_values('mse')  # сортировка
    rz=list(rz['metod'])
    rzz = rz[0] + rz[1] + rz[2]
    if rzz in sravn:sravn[rzz]+=1
    else:sravn[rzz]=1

print('ранжирование по mse')
for sr in sravn:
    print(f'sr={sr}  zn=={sravn[sr]}')




sravn={}

tips=list(set(rezz['tip']))
print(f'tips=={tips}')
for tip in tips:
    rz=rezz.loc[(rezz['tip']==tip)&(rezz['vid']==2),]
    rz=rz[['metod','corr']]
    # rz = rz.sort_values('mse')  # сортировка
    rz = rz.sort_values('corr', ascending=False)
    rz=list(rz['metod'])
    rzz = rz[0] + rz[1] + rz[2]
    if rzz in sravn:sravn[rzz]+=1
    else:sravn[rzz]=1

print('ранжирование по corr')
for sr in sravn:
    print(f'sr={sr}  zn=={sravn[sr]}')

