
# задекорировать самому



def f(n):
   return n * 123456789


def prov_f(func):
    #zn = set()
    cache_dict = set()
    count = 0

    def wrapper(*args, **kwargs):
        nonlocal cache_dict
        nonlocal count
        rez = func(*args, **kwargs)
        p = (*args, rez)
        count += 1
        leng = len(cache_dict)
        cache_dict.add(p)
        leng2 = len(cache_dict)
        print(f"Функция {func} была вызвана {count} раз")
        if leng == leng2:
            print('значение уже было')
        else:
            print('значение новое, словарь=',cache_dict)
        return rez

    return wrapper

ff=prov_f(f)

print(ff(1))
print(ff(2))
print(ff(1))
print('===============')


def cache(func):
   cache_dict = {}
   #cache_dict = set()
   def wrapper(num):
       nonlocal cache_dict
       if num not in cache_dict:
           cache_dict[num] = func(num)
           print(f"Добавление результата в кэш: {cache_dict[num]}")
       else:
           print(f"Возвращение результата из кэша: {cache_dict[num]}")
       print(f"Кэш {cache_dict}")
       return cache_dict[num]
   return wrapper

ff2=cache(f)

print(ff2(1))
print(ff2(2))
print(ff2(1))

v=input()









import time

def decorator_time(fn):
   def wrapper():
       print(f"Запустилась 100 раз функция {fn}")
       t0 = time.time()
       for i in range(10000):
           result = fn()
       dt = time.time() - t0
       print(f"Функция выполнилась. Время: {dt:.10f}")
       return dt  # задекорированная функция будет возвращать время работы
   return wrapper


def pow_2():
   return 10000000 ** 2


def in_build_pow():
   return pow(10000000, 2)


pow_2_ = decorator_time(pow_2)
in_build_pow_ = decorator_time(in_build_pow)

pow_2()
pow_2_()
# Запустилась функция <function pow_2 at 0x7f938401b158>
# Функция выполнилась. Время: 0.0000011921

in_build_pow()
in_build_pow_()
# Запустилась функция <function in_build_pow at 0x7f938401b620>
# Функция выполнилась. Время: 0.0000021458

v=input()








def make_adder(x):
   def adder(n):
       return x + n
   return adder

p=make_adder(5)
print(p(7),p(13))


v=input()

def count(start=1, step=1):
    counter = start
    while True:
        yield counter
        counter += step


counter_gen = count()
z = next(counter_gen)
print('z=',z)
z = next(counter_gen)
print('z=',z)

for i in count():
    if i>=3: break
    print('i=',i)

for i in count():
    if i>=6: break
    print('ii=',i)

#
# while z<10:
#     z=int(count())
#
#     print('z=',z)

z=count(1,1)
print('z=',z)
print(count(1,1))
print(count())
print(count())
print(count())










v=input()


#написать обход графа от данной вершины до всех прочих. с поиском кратчайших растояний

import random

random_sequence = [random.randint(0, 2) for _ in range(10)]  # Генерация списка из 10 случайных целых чисел от 1 до 100

#То же самое. но для удобства с названиями
kol_ver=10;
kol_reb=20;
z1=[random.randint(0, kol_ver-1) for _ in range(kol_reb)]
z2=[random.randint(0, kol_ver-1) for _ in range(kol_reb)]
ves=[random.randint(1, 100) for _ in range(kol_reb)]

vess=sum(ves)*2
#print('vess=',vess)

reb=[];rast=[]
for i in range(kol_reb):
    rr={'vh':z1[i],'vih':z2[i],'rast':ves[i],'nom':i};
    reb.append(rr)
for i in range(kol_ver):
    rast.append({'rast':None,'smotr':-1,'pred':-1,'nom':i})

rast[0].update({'rast':0,'smotr':1,'pred':0})


print('reb==',reb)
print('rast==',rast)

# сам алгоритм поиска

new=True;prov=0
while new:
    new=False;prov+=1;
    for ver in rast:
        if ver['smotr']==1:break
    rb=[]
    for r in reb:
        if r['vh']==ver['nom']:rb.append(r)

    for r in rb:#перебор по рёбрам исходящим из вершины
        vh=r['vh'];vih=r['vih'];ves=r['rast']+ver['rast']
        ver2=rast[vih]
        if ver2['rast'] is None or ver2['rast']>ves:
            ver2.update({'rast':ves,'smotr':0,'pred':vh});rast[vih]=ver2;
    ver['smotr']=2;nomv=ver['nom']
    rast[nomv]=ver
    nomv=-1;rst=-1
    for ver in rast:
        if ver['smotr']==0:
            if (rst==-1 or ver['rast']<rst):
                nomv=ver['nom'];rst=ver['rast'];
    if nomv>-1:
        rast[nomv].update({'smotr':1});new=True

print('prov==',prov)
print('rasts=',rast)










v=input()

##################################################
kol_ver=10;
kol_reb=20;
z1=[random.randint(0, kol_ver-1) for _ in range(kol_reb)]
z2=[random.randint(0, kol_ver-1) for _ in range(kol_reb)]
ves=[random.randint(1, 100) for _ in range(kol_reb)]

vess=sum(ves)*2
print('vess=',vess)

reb=[];rast=[]
for i in range(kol_reb):
    rr=[z1[i],z2[i],ves[i]];reb.append(rr)
for i in range(kol_ver):
    rast.append([None,-1,-1,i])
    #расстояние до вершины;
    # признак обработки вершины (-1= неизв, 0=некое расст, 1=текущий рассматриваемый минимум из (0), 2=уже оптимум
    # предыдущая вершина до максимума
    # номер вершины

rast[0]=[0,1,0,0]
print('reb=',reb);print('rast=',rast)

new=True;prov=0
while new:
    new=False;prov+=1;plus=0
    for ver in rast:
        if ver[1]==1:break
    print('ver==',ver)
    rb=[]
    for r in reb:
        if r[0]==ver[3]:rb.append(r)
    print('len_rb==',len(rb),'rb==',rb)
    for r in rb:#перебор по рёбрам исходящим из вершины
        v1=r[0];v2=r[1];vs=r[2]+ver[0]
        ver2=rast[v2]
        if ver2[0] is None or ver2[0]>vs:
            ver2=[vs,0,v1,ver2[3]];rast[v2]=ver2;plus+=1
    print('plus=',plus)
    ver[1]=2;vv=ver[3]
    rast[vv]=ver
    vv=-1;rst=-1
    for ver in rast:
        if ver[1]==0 and (rst==-1 or ver[0]<rst):
            vv=ver[3];rst=ver[0];

    if vv>-1:
        rast[vv][1]=1;new=True

print('prov==',prov)
print('rasts=',rast)

print('ver=',ver)




v=input()










# почему выдаёт ошибку программа:
#
# z= float(1/17)
# print(z)
# v=input()
print('name==', __name__ )

#Задание - написать калькулятор вычисляющий значение строки, без скобок


stroka='12+45+23-64*((45+45)/64*32)-5'

#stroka='12+(45-23)*2/2'
#vhod='12+45+23-64*(90/64*32)-5'

#vhod='12+2/4'


print('stroka=', stroka)

def funk_kalk(vhod):
    print('name==', __name__ , 'vhod=',vhod)
    prov=['+','-','*','/','(',')']
    opers=['+','-','*','/']
    rez=[];ll=0;i=0;
    if isinstance(vhod, str): #проверка что работаем со строкой
        for pr in prov:
            z_vhod =vhod.split(pr);ll=len(z_vhod)
            if ll>1: break #прекращаем цикл по pr
        if ll == 1 :
            if z_vhod[0].isdigit():return [int(z_vhod[0])]
            return [z_vhod[0]] #return [None]
        for vh in z_vhod:
            i+=1;rez_=funk_kalk(vh)
            for rr in rez_:
                if rr!='':rez.append(rr)
            if i<ll:rez.append(pr)
        return rez


    if isinstance(vhod, list):
        ll = len(vhod);
        if ll==1:
            return vhod[0]
        if '(' in vhod: # неправильная скобочная структура, переделать!!!
            #print('(vhod)==',vhod)
            i = vhod.index('(');k=0

            for j in range(i,ll):
               if vhod[j] == '(': k+=1
               if vhod[j] == ')': k -=1
               if k==0:break

            rr=vhod[i+1:j]
            zn=funk_kalk(rr)
            rez=vhod[0:i]
            #print('(1)==',rez)
            #print('((2))==', rr, '==',zn)
            rez.append(zn)
            rez.extend(vhod[j+1:ll])
            #print('(3=itog)==', rez)
            #print('()/rez=', rez)
            rez=funk_kalk(rez)
            return rez
        for oper in opers:
            if oper in vhod:break #выбрали нужную операцию перовую из списка очерёдности
        if oper in vhod:
            i = vhod.index(oper)
            if oper=='-':
                for i in range(ll-1,-1,-1):
                    if vhod[i]=='-':break
            #print('oper==',oper,'pos=',i,'zn==',vhod)
            vh1=vhod[0:i]
            vh2 = vhod[i+1:ll]
            rez1=funk_kalk(vh1)
            rez2 = funk_kalk(vh2)
            #print('oper==', oper, 'pos=', i, 'zn==', vhod, '===',vh1,'***',vh2,'===',rez1,rez2)
            if oper=='+':rez=rez1+rez2
            if oper=='-':rez = rez1 - rez2
            if oper=='*':rez = rez1 * rez2
            if oper=='/':rez = (rez1 / rez2) #rez = float(rez1 / rez2)
            #print('oper====',oper,'zn==',vhod,'rez=',rez)
            return(rez)



    return rez


vhod=stroka
rez=funk_kalk(stroka)
print('==vhod==',vhod,'rez==', rez)
vhod=rez
# vhod_=vhod[::-1]
# print('vhod_==',vhod)
# v=input()
rez=funk_kalk(vhod)
print('==vhod==',vhod,'rez==', rez)

print('znach==',eval(stroka))
print(rez)

v=input()








# задание себе - написать разделитель строки
# на числа, если она через запятые,
# пробелы и точки с запятой одновременно


#for i in range(2,round(3**0.5)):print(i)

#
# ss='43g'
# zs=ss.isdigit()
# print('zs=',zs)

str1='243 45f2 53 ,354,23 ;32;45,5;4 65 6 ;76'
str2='87,3,74,768,g32 75 53;45;76;235 56,675,665'
str3='45,65,86,97;32;86,42;87'
str4='7;324;76;98'
vh=[str1,[str2,str3],str4]
#vh=str1
print('работа')



def funk_spisok(vhod):
    prov=[' ',',',';']
    rez=[]
    if isinstance(vhod, str):
        for pr in prov:
            z_vhod =vhod.split(pr)
            ll=len(z_vhod)
            if ll>1: break
        if ll == 1 :
            #print(z_vhod[0],z_vhod[0].isdigit())
            if z_vhod[0].isdigit():return [int(z_vhod[0])]
            return [None]
        for vh in z_vhod:
            rez_=funk_spisok(vh)
            for rr in rez_:rez.append(rr)
        return rez


    if isinstance(vhod, list):
        for vh in vhod:
            rez_=funk_spisok(vh)
            for rr in rez_:
                if not rr is None: rez.append(rr)
    return rez

print('vhod=',vh)
rez=funk_spisok(vh)
print('итог=',rez)
summ=0;maxx=rez[0]
prost=[]
for rr in rez:
    summ+=rr;pr=1;i=2
    if maxx<rr:maxx=rr

    while i<=rr**0.5:
        if (rr % i)==0:pr=0
        i+=1
    if pr==1:prost.append(rr)
print('sum=',summ,'max=',maxx)
print('prost=',prost)


v=input()

def sort_spisok(vhod):
    l=len(vhod);rez=[]
    #print('len=',l,'vhod=',vhod)
    if l>1:
        l1=round(l/2);l2=l-l1
        vh1=vhod[0:l1];vh2=vhod[l1:l]
        vh1 = sort_spisok(vh1)
        vh2 = sort_spisok(vh2)
        i1=0;i2=0
        while (i1<l1)*(i2<l2):
            if vh1[i1]<vh2[i2]:
                rez.append(vh1[i1]);i1+=1
            else:rez.append(vh2[i2]);i2+=1
        while (i1 < l1): rez.append(vh1[i1]);i1 += 1
        while (i2 < l2): rez.append(vh2[i2]);i2 += 1
        #print('vihod===',rez)
        return rez
    else:return vhod

srez=sort_spisok(rez)
print(srez)

strr='cism cnHgghnvchjJJjfLLGTlk'
print(strr)
print(strr.upper())
print(strr.lower())

#str_='35y'
#print('is_str=',str_.isdigit():)
#z=int(str_)
#print('str_=',z)


# def funk_spisok(vhod):
#     rez='12'
#     if isinstance(vhod, str):
#         print('строка=',vhod)
#     if isinstance(vhod, list):
#         print("Это список",vhod)
#     return rez
#
# funk_spisok(str)

v=input()

z_str=str.split()
print(z_str)