
import redis
redis.PubSubError




def fib():
    a, b = 0, 1
    yield a
    yield b
    while True* (b<100000):
        a, b = b, a+b
        yield b
for i in fib():
    print(i)

v=input()

def fibb():
    a, b = 0, 1
    yield a
    yield b
    while True* (b<100000):
        a, b = b, a+b
        yield b
for i in fibb():
    print('i========',i)
    while i < 10:
        print(i);i+=1

v = input()


def fibonacci(n):
    fib1, fib2 = 0, 1
    for _ in range(n):
        fib1, fib2 = fib2, fib1 + fib2
        rez=[fib1,fib2]
        yield rez
i=0
for ii in fibonacci(30):
    i+=1
    print('i=',i,'ii=',ii)

#
# %%time
# z=[ii+2 for ii in fibonacci(30)]
# print('z=',z)



v=input()

str='2,6 8'
s=str.split(' ',',')
print('s=',s)

v=input()


#
# print('замыкание')
# def outer():
#     funcs = []
#     for i in range(4):
#         def func(a):
#             print('aa=',a,'i=',i)
#         funcs.append(func)
#     return funcs
#
#  outer()[3]()
#  print((outer()[2]))
# v=input('введите число:')