
#сделать игру крестики-нолики 3*2  в режиме консоли
# ЗначениЯ 0=пусто. 1 игрок 1. 2=игрок 2
import random

zn=[0,1,2]
zn=['-','x','o']
zn='-xo'
rezult1=zn[1]*3;rezult2=zn[2]*3;
print('rezult==',rezult1,rezult2)
prov=[] # список всех строк, столбцов и диагоналей для проверки

#блок создания списка всех проверок
for i in range(3):
    vec=[]
    for j in range(3):vec.append([i,j])
    prov.append(vec)
    vec = []
    for j in range(3): vec.append([j, i])
    prov.append(vec)
vec=[]
for i in range(3):vec.append([i,i])
prov.append(vec)
vec=[]
for i in range(3):vec.append([i,2-i])
prov.append(vec)

#print(prov)
#for vec in prov:print(vec)


# Инициализация пустым значениями
matr=[[zn[0] for j in range(3)] for i in range(3)]
#Случайная инициализация начальной позиции
#matr=[[zn[random.randint(0, 2)] for j in range(3)] for i in range(3)]
# random.randint(1, 10)


def vivod():  #вывод текущей позиции на экран
    for v in matr:print(*v)


# решить есть ли уже выигрыш у какого то игрока
def resh():
    rez1=0;rez2=0 #результат каждого игрока
    rep1=0;rep2 = 0  # шанс каждого игрока
    resh1=[];resh2=[] #список возм ходов для выигрыша
    for vec in prov:
        rz1=0;rz2=0;pos=[]
        for vv in vec:
            z=matr[vv[0]][vv[1]]
            rz1+=(z==zn[1])
            rz2 += (z == zn[2])
            if (z==zn[0]):pos=vv
        rez1+=(rz1==3);rez2+=(rz2==3);
        rep1 += (rz1 == 2)and(rz2==0);
        rep2 += (rz2 == 2)and(rz1==0);
        if (rz1 == 2)and(rz2==0):resh1.append(pos)
        if (rz2 == 2) and (rz1 == 0): resh2.append(pos)

    var = [0, 1, 2];svob=0
    for i in var:
        for j in var:
            svob+=(matr[i][j]==zn[0])
    # print('rez1=',rez1,'  rez2=',rez2)
    # print('rep1=', rep1, '  rep2=', rep2)
    # print('resh1=', resh1, '  resh2=', resh2)
    return [svob,rez1,rez2,rep1,rep2,resh1,resh2]


def read_hod():
    #var=[i for i in range(3)];
    var=[0,1,2];iz=False
    while not iz:
        #vivod()
        i=int(input('введите i:'))
        j=int(input('введите j:'))
        zz=(i in var) and (j in var)
        #print('zz==',zz)
        if (i in var) and (j in var):
            #print('значение=',matr[i][j])
            iz= (matr[i][j]==zn[0]);#print('iz=',iz)
        if iz:return [i,j]
        print('неправильные координаты',i,j)

def any_hod():
    mm = [[random.randint(1, 100) for j in range(3)] for i in range(3)]
    mx=0;hod=0
    for i in range(3):
        for j in range(3):
            if matr[i][j]==zn[0] and mm[i][j]>mx:
                hod=[i,j];mx=mm[i][j]
    return hod


#new_hod=read_hod();print('ход=',new_hod)

def igra():
    print('НАЧИНАЕМ ИГРУ')
    vivod()
    rez = resh()
    while rez[0]>0:
        print('rez==',rez)
        if rez[1] > 0:
            print('ИГРА УЖЕ ЗАКОНЧЕНА. вы выиграли');return matr
        if rez[2] > 0:
            print('ИГРА УЖЕ ЗАКОНЧЕНА. Я выиграла');return matr
        if rez[0]==0:
            print('ИГРА УЖЕ ЗАКОНЧЕНА. Некуда ходить');return matr
        hod= read_hod()
        matr[hod[0]][hod[1]]=zn[1]
        vivod()
        rez = resh()
        if rez[1]>0:
            print('Вы выиграли');return matr
        if rez[0]==0:
            print('игра закончена. ходить негде');
            return matr
        vozm1=rez[3];vozm2=rez[4]
        resh1=rez[5];resh2 =rez[6]
        hod=None
        if vozm2>0:
            hod=resh2[0]
        if vozm2==0 and vozm1>0:
            hod = resh1[0]
        if vozm2 == 0 and vozm1== 0:
            hod=any_hod()
        print('мой ход=',hod)
        matr[hod[0]][hod[1]] = zn[2]
        vivod()
        rez = resh()
        if rez[2]>0:
            print('Я выиграла!!!');return matr

igra()











