
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np


def graf(tab,name):
    if name=='my_prog':print(f'gr_tab_vhod===\n{tab}')

    nom=tab['id'];ogr=tab['ogr'];y = tab['y'];yy=tab['yy'];spros=tab['spros']

    # # Вычисление суммы квадратов разностей
    err=np.sum((y-yy)**2)
    sred_otkl =(err / len(y)) ** 0.5
    print(f'ГРАФИК {name} err=={err} sred_otkl====={sred_otkl}')
    # =================================

    #
    # # Построение графика самого простого
    # plt.figure(figsize=(10, 6))
    # plt.plot(y, yy, marker='o', linestyle='', color='blue', label='Yy(y)')
    #
    # # Добавление подписей к осям и заголовка
    # plt.xlabel('y_исходное');plt.ylabel('прогноз');
    # plt.title(f'График {name} зависимости Yy от y , сред отклонение={sred_otkl}')
    # plt.legend();plt.grid(False) # Добавление сетки и легенды
    # # Отображение графика
    # plt.show()




    # # Построение графика
    # plt.figure(figsize=(10, 6))
    # # plt.plot(y, yy, marker='o', linestyle='-', color='b', label='Y(X)')
    # plt.plot(y, yy, marker='o', linestyle='', color='blue', label='Yy(y)')
    # plt.plot(y, y, marker='o', linestyle='', color='green', label='Yy=y')
    # plt.plot(y, spros, marker='.', linestyle='', color='red', label='spros(y)')
    # plt.plot(y, ogr, marker='o', linestyle='', color='black', label='ogr(y)')
    #
    # # Добавление подписей к осям и заголовка
    # plt.xlabel('y_исходное');plt.ylabel('прогноз');
    # plt.title(f'График {name} зависимости Yy от y , сред отклонение={sred_otkl}')
    # plt.legend();plt.grid(False) # Добавление сетки и легенды
    # # Отображение графика
    # plt.show()


    # =================================
    # График по времени
    plt.figure(figsize=(10, 6))
    # Рисуем X2(X1) с линиями (синий цвет)
    plt.plot(nom, yy, color='blue', marker='o', label='прогноз', linestyle='')
    # Рисуем X3(X1) без линий (красный цве7т)
    plt.scatter(nom, y, color='green', marker='o', label='реально')
    # Рисуем ogr(X1) без линий (черный цвет)
    plt.plot(nom, ogr, color='black', marker='.', label='limiter', linestyle='-')
    # Рисуем X3(X1) без линий (красный цвет)
    plt.scatter(nom, spros, color='red', marker='.', label='spros')

    # Настройка графика
    plt.xlabel('nom');plt.ylabel('прогноз');plt.title(f'График {name}, сред отклонение={sred_otkl}')
    plt.legend();plt.grid(True)
    # Отображаем график
    plt.show()
    # =================================




# Построение графика результатов
def graf_rezult(rezz):
    rz = rezz.loc[(rezz['metod'].str[0] == '0') & (rezz['vid']==1), ['tip', 'corr']]
    rz = rz.sort_values('corr')  # сортировка
    rz['tp']=range(rz.shape[0])
    rezz.loc[:,'tp']=0
    # rezz['tp']=range(rezz.shape[0])
    # print(f'gr__rz=={rz}')
    for tip in rz['tip']:
        tp= rz.loc[(rz['tip']==tip),'tp']
        tp = int(tp.iloc[0])
        rezz.loc[(rezz['tip'] == tip), 'tp'] =tp


    rezz = rezz.sort_values('tp')  # сортировка
    # print(f'gr2_rezz=\n{rezz}')

    # rz_str=rz.shape[0] #  количество строк
    metod=sorted(list(set(rezz['metod'])))
    metods={};i=-1
    colors = ["red", "green", "yellow", "black", "blue", "cyan", "magenta", "gray", "orange", "purple", "brown", "pink",
              "lime", "navy", "teal", "olive", "maroon", "aqua", "silver"]

    for i,mod in enumerate(metod):metods[mod]=colors[i]

    for param in ['r2','r2_s','corr','corr_s','mse','mse_s','time']:
        plt.figure(figsize=(10, 6))
        for mod in metods:
            col = metods[mod]
            rez=rezz.loc[(rezz['metod']==mod) ,] #&(rezz[param]>0)
                         # &(rezz['r2']>0),]
            rez1 = rez.loc[(rez['vid'] == 1),]
            rez2 = rez.loc[(rez['vid'] == 2),]
            rez_=rez[['tip','corr','r2','tp','corr_s']]
            plt.plot(rez1['tp'], rez1[param], marker='.', linestyle='-', color=col, label=mod)
            plt.plot(rez2['tp'], rez2[param], marker='o', linestyle='-', color=col, label=mod)

        plt.xlabel('tip');plt.ylabel('r2');plt.legend();plt.grid(True)  # Добавление сетки и легенды
        plt.title(f'График {param} от tip');
        plt.show()




#
#
# # Построение графика результатов
# def graf_stat(rezz):
#     rz = rezz.loc[(rezz['metod'].str[0] == '0') & (rezz['vid']==1), ['tip', 'corr']]
#     rz = rz.sort_values('corr')  # сортировка
#     rz['tp']=range(rz.shape[0])
#     rezz.loc[:,'tp']=0
#     # rezz['tp']=range(rezz.shape[0])
#     print(f'gr__rz=={rz}')
#     for tip in rz['tip']:
#         tp= rz.loc[(rz['tip']==tip),'tp']
#         tp = int(tp.iloc[0])
#         rezz.loc[(rezz['tip'] == tip), 'tp'] =tp
#
#
#     rezz = rezz.sort_values('tp')  # сортировка
#     print(f'gr2_rezz=\n{rezz}')
#
#     # rz_str=rz.shape[0] #  количество строк
#     metod=sorted(list(set(rezz['metod'])))
#     metods={};i=-1
#     colors = ["red", "green", "blue", "yellow", "black", "cyan", "magenta", "gray", "orange", "purple", "brown", "pink",
#               "lime", "navy", "teal", "olive", "maroon", "aqua", "silver"]
#
#     for i,mod in enumerate(metod):metods[mod]=colors[i]
#
#     for param in ['r2','r2_s','corr','corr_s','mse','mse_s']:
#         plt.figure(figsize=(10, 6))
#         for mod in metods:
#             col = metods[mod]
#             rez=rezz.loc[(rezz['metod']==mod) #&(rezz[param]>0)
#                          &(rezz['r2']>0),]
#             rez1 = rez.loc[(rez['vid'] == 1),]
#             rez2 = rez.loc[(rez['vid'] == 2),]
#             # rez_=rez[['tip','corr','r2','tp','corr_s']]
#             plt.plot(rez1['tp'], rez1[param], marker='.', linestyle='-', color=col, label=mod)
#             plt.plot(rez2['tp'], rez2[param], marker='o', linestyle='-', color=col, label=mod)
#
#         plt.xlabel('tip');plt.ylabel('r2');plt.legend();plt.grid(True)  # Добавление сетки и легенды
#         plt.title(f'График {param} от tip');
#         plt.show()
#
#









