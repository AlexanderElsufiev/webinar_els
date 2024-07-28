
import requests
#import bs4
# в терминале инсталлировал = pip install numpy - для работы с большими объёмами однотианых данных
# показать список установленных пакетов (в терминале) = pip freeze


#генератор
numb = [1,2,3,4,5]
gnumb=(nn**2 for nn in numb)
print('gen=',gnumb)
#print(list(gnumb))
#print(list(gnumb))
print(9 in gnumb)
print(25 in gnumb)
print(25 in gnumb)

print('замыкание')
def outer():
    funcs = []
    for i in range(4):
        def func(a):
            print('aa=',a,'i=',i)
        funcs.append(func)
    return funcs

outer()[3](7)
print((outer()[2]))
v=input('введите число:')






s='sdKIhmjKLLjhvcVCCxxFG'
s=s.lower()
print(s)

d=[2,3]
a=6
d = d.append(1)
print(d)


v=input()

dict = {'s': 1 }
dict = {'a': 1 ,"b": 2 ,'c': 3}
v=0
for n,v in dict.items(): 	print(n,v)

for v in dict.values():
	print(v)

for v in dict:
	print(v)





v=input()
a=(1,2,3);
b=range(1,10,1)
#b=(1,10,2)
b=tuple(b)
#a=list(a);b=list(b)

c=[a,b]
print('a=',a)
print('b=',b)
print('c=',c)
c=tuple(c)
print('c2=',c)
c=set(c)
print('c=',c)
c=tuple(c)
print('c=',c)

v=input()


shopping_center = ("Галерея", "Санкт-Петербург", "Лиговский пр., 30", ["H&M", "Zara"])
list_id_before = id(shopping_center[-1])
p1=shopping_center[-1]

shopping_center[-1].append("Uniqlo")
list_id_after = id(shopping_center[-1])
p2=shopping_center[-1]

print(list_id_before, list_id_after)
print(list_id_before is list_id_after)
print(id(list_id_before), id(list_id_after))

print(p1,p2)

v=input()


a = 5
v = 6+2
b = 3+2
b=v
print(id(a),id(b),id(a)-id(b),':',a,b)

L = ['a', 'b', 'c']
#L=set(L)
LL=list(L)
print(id(L))

L.append('d')
print(id(L))
print(L)
print(LL)


#str1 = input("Введите числа через пробел:")
str1='1 2 3 4 5 6 7 8'
str2='2 4 6 8 10 12'
l1= set(str1.split()) # список строковых представлений чисел
l2= set(str2.split()) # список строковых представлений чисел
print('l1=',l1)
print('l2=',l2)
z=list(l1.symmetric_difference(l2))
print('z=',z)




v=input()
#a = input("Введите первую строку: ")
#b = input("Введите вторую строку: ")
a='1234523454';b='34567'
a_set, b_set = set(a), set(b) # используем множественное присваивание

#a_and_b = a_set.union(b_set)
a_and_b = a_set.intersection(b_set)
print('a_and_b',a_and_b)



print('1=',list(a))
print('2=',set(list(a)))
print('3=',list(set(list(a))))
print('4=',len(list(set(list(a)))))


print('1-=',set(a))
print('2-=',list(set(a)))
print('3-=',set(list(set(a))))
print('4-=',list(set(list(set(a)))))

print('1-o=',order(set(a)))
v=input()






str = "The Zen of PythonB"
#input('введите строку:',str)
#print('str=',str)
#print('l_str=',list(str))
set_str=set(str)
list_=list(set(str))
#print('set_str=',set_str)
#print('list_=',list)
print("Количество уникальных символов: ", len(list_))
print('==',set_str)

text = input("Введите текст:")

print('type_str=',type(str))


lett=[]
s=0;len=len(str)
while (s<len):
    lett.append(str[s])
    s+=1

print('lett=',lett)
print('type_lett=',type(lett))
#l = len(lett); print('l=',l)


lets=list(set(lett))
# ll= len(lets)

#letss=list(lets)
print('lets=', lets)
lets_='/'.join(lets)
# s = string(34)
print('lets_=',lets_)
print('type_lets_=',type(lets_))

l=len(lets_)
print('lets=',letss)
print('len=',l)

print('-============')


c=input()



title ='sdffd'
author='sdffdsfdsfsdf'
year='2532'


book = {'title' : title,'author' : author, 'year' : int(year)}
print('book=',book)

L = [5,1,1,2,3,2]
b = set(L)
print(b)
b_list = list(b)
print(b_list)
print(L)


print('===============')

d = {'day' : 22, 'month' : 6, 'year' : 2015}
print("||".join(d.keys()))
print("||".join(d))
print(d)
print('===============')

string = "1 1 2 3 5 8 13 21 34 55"
#
string = input("Введите числа через пробел:")

list_= string.split() # список строковых представлений чисел
list_= list(map(int, list_)) # cписок чисел
n=len(list_)
print(n,'==',list_[1:-1]) # sum() вычисляет сумму
list_[0],list_[n-1] = list_[n-1],list_[0]

list_.append(sum(list_))

print(list_) # sum() вычисляет сумму
print('============')


numbers = '1f 2 d3 4 5rfd r6 7'
num=numbers.split()


L = [3.3, 4.4, 5.5, 6.6]

# печатаем сам объект map
print(map(round, L)) # к каждому элементу применяем функцию округления
# <map object at 0x7fd7e86eb6a0>
# и результат его преобразования в список
print(list(map(round, L)))

L = ['3.3', '4.4', '5.5', '6.6']

print (list (map ( float , L)))
print('============')


L = ["а", "б", "в", 1, 2, 3, 4]
print (L[ 1:4 ])


int_num = int(input("Введите целое число: ")) # вводим, например, 256

print(int_num)
# 256
print(type(int_num))
str=input()
#=====================================

colors = 'red blue green'
print(colors.split())

colors = 'red green blue'
colors_split = colors.split() # список цветов по-отдельности
colors_joined = ' and '.join(colors_split)
print(colors_joined)

a = (2,65)
print('a=',a,'lken(a)=',len(a))
b = (3,8)
c = (a,b)
print(c)
print('c2=',c[0])
print('len(c)=',len(c))
#a.append(b)
print('c=',a)

print('===========')


a = [2,65]
b = [3,8]
c = [a,b]
print('c2=',c[0])
print('len(c)=',len(c))
a.append(b)
print('c=',a)



c=a.append(9)
print('c=',c)

a = {2, 65}
b = {3, 8}
#c = [a,b]
print('c=',c)
#c=a.append(b)
print('c=',c)
print('############################')


#################################################
a, b = "some_string_a", "some_string_b"
print('a=',a)
print('b=',b)


list_num = [5, 7, 9]
b=2
a=int(input('введите число А::'))
print(f'a+b={a}+{b} = {a+b}!')

aa, ba = int(input('введите число::')),int(input('второе число::'))
print('a=',a)
print('b=',b)
t = 5
print('t====',t)

a = 1; b = 4
print('выход')
print("Мама \nмыла раму!")
print(f'a+b={a}+{b} = {a+b}!')

a=int(input('введите число::'))
print(f'a+b={a}+{b} = {a+b}!')
print()


print('====================')
