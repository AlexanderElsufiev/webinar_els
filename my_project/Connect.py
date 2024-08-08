
# Здесь будет связь с сервером

import psycopg2
import numpy as np
import pandas as pd


def conn_param():
    conn = psycopg2.connect(
        dbname="postgres",
        user="postgres",
        password="ELSUFIEV1974",
        host="localhost",  # или "127.0.0.1"
        port="5432"
    )
    return conn


# чтение всех данных из моей таблицы, превращение в матрицу
def dann_read():
    # Настройки подключения
    # conn = psycopg2.connect(
    #     dbname="postgres",
    #     user="postgres",
    #     password="ELSUFIEV1974",
    #     host="localhost",  # или "127.0.0.1"
    #     port="5432"
    # )
    conn = conn_param()  # ПАРАМЕТРЫ СОЕДИНЕНИЯ

    # Создание курсора для выполнения SQL-запросов
    cur = conn.cursor()

    # Выполнение SQL-запроса
    cur.execute("SELECT * FROM dannie ")
    # Извлечение всех строк результата
    rows = cur.fetchall()

    # Получение названий столбцов
    col_names = [desc[0] for desc in cur.description]


    # Закрытие курсора и соединения
    cur.close()
    conn.close()


    # Преобразование данных в массив numpy
    data = np.array(rows)
    data2 = pd.DataFrame(data, columns=col_names)
    # rez={'col':col_names,'data':data,'data2':data2}
    rez={'col':col_names,'data':data2}


    return rez




# чтение всех данных из моей таблицы, превращение в матрицу
def stat_read():
    conn = conn_param()  # ПАРАМЕТРЫ СОЕДИНЕНИЯ
    cur = conn.cursor()   # Создание курсора для выполнения SQL-запросов
    cur.execute("SELECT * FROM dannie2 ") # Выполнение SQL-запроса
    rows = cur.fetchall()  # Извлечение всех строк результата
    col_names = [desc[0] for desc in cur.description] # Получение названий столбцов
    cur.close();conn.close()  # Закрытие курсора и соединения
    # Преобразование данных в массив
    data = np.array(rows)
    data2 = pd.DataFrame(data, columns=col_names)
    # rez={'col':col_names,'data':data,'data2':data2}
    rez={'col':col_names,'data':data2}
    return rez









def dann_zapis(dann):  # программа записи в мою базу
    names = ['metod', 'x1', 'x2', 'ogr', 'tip', 'vid', 'y', 'spros', 'yy', 'spros_','time']
    names_str = ['metod']
    names_int = ['tip', 'vid']
    names_float = [ 'x1', 'x2', 'ogr', 'y', 'spros', 'yy', 'spros_','time']

    # print(f'zapis_dann==\n{dann}')

    l = len(dann)

    col = dann.columns
    # print(f'col=={col} len=={l}')
    inserts = []

    for (index, row) in dann.iterrows():
        str_ = []
        for nm in names:
            if nm in col:
                zn=row[nm];
                if nm in names_str:
                    str_.append(str(zn))
                if nm in names_int:
                    str_.append(int(zn))
                if nm in names_float:
                    str_.append(float(zn))

        str_ = tuple(str_)
        inserts.append(str_)

    names_ = '';
    vals = '';
    i = -1
    for nm in names:
        if nm in col:
            i += 1;
            if i == 0:
                names_ = nm;vals = '%s'
            else:
                names_ = f'{names_},{nm}';vals = vals + ', %s'
    comand = f'INSERT INTO dannie2({names_}) VALUES ({vals})'
    # print(f'comand==={comand}')

    conn = conn_param() #ПАРАМЕТРЫ СОЕДИНЕНИЯ

    # Создание курсора
    cur = conn.cursor()

    # inserts==[(2, 1, 3)]
    # Вставка данных в таблицу
    # cur.executemany('INSERT INTO dannie2(x1,tip,y) VALUES (%s, %s, %s)', inserts)
    cur.executemany(comand, inserts)
    # Сохранение изменений
    conn.commit()

    # # Проверка: чтение и вывод данных
    # cur.execute('SELECT * FROM dannie2');rows = cur.fetchall()
    # print("Записанные данные:")
    # for row in rows:print(row)

    # Закрытие соединения
    cur.close();
    conn.close()







