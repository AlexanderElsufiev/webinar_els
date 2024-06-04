
import random

#Случайная инициализация начальной позиции
print('Подождите, идёт случайная расстановка кораблей, иногда долго')
dlina_f=6

zz='О123'
zz='О■TX'
zz=['О','■','T','X']
#matr=[[zn[random.randint(0, 2)] for j in range(3)] for i in range(3)]
#print(matr)
#print(max(matr))
# random.randint(1, 10)




def hod():
    hod=False
    while not hod:
        try:
            (x,y)=(int(input('введите x:')),int(input('введите y:')))
        except ValueError as e:
            print('Вы ввели неправильное число')
        else:
            if 1<=x<=dlina_f and 1<=y<=dlina_f:
                hod=True;print(f'Ваш ход: x={x} y={y}')
            else:print('ВЫ ошиблись в размере')
    return (x,y)





class ship:
    def __init__(self, len):
        self.dlina=dlina_f
        self.len= len
        self.dell = 0 #количество убитых клеток
        self.gor = -1
        self.x = -1
        self.y = -1
        self.zn=[[-1,-1] for i in range(len)]

    def __str__(self):
        return f'len= {self.len},gor={self.gor}, x={self.x},y={self.y} zn=={self.zn}'

    def rand(self):
        k=0
        while True:
            k+=1
            self.gor = random.randint(0, 1)
            self.x = random.randint(0, self.dlina-1)
            self.y = random.randint(0, self.dlina-1)
            if self.gor==1 and self.x+self.len<=self.dlina:break
            if self.gor == 0 and self.y + self.len <= self.dlina: break
        for i in range(self.len):
            self.zn[i][0]=self.x +self.gor*i
            self.zn[i][1] = self.y+(1-self.gor)*i
        #print('число попыток=',k)


#sh=ship(4)
#sh.rand()
#print(sh.gor,sh.zn)
#print(sh)
#print('-----------------------')

# ships=[ship(3),ship(2),ship(2),ship(1),ship(1),ship(1),ship(1)]
# for sh in ships:sh.rand()
# for sh in ships:print(sh)

class desc:
    def __init__(self):
        self.dlina = dlina_f
        self.vec=[j for j in range(self.dlina)]
        #self.vec2 = [j for j in range(self.dlina+1)]
        self.matr = [[0 for j in range(self.dlina)] for i in range(self.dlina)]
        #self.matr2 = [[0 for j in range(self.dlina+1)] for i in range(self.dlina+1)]
        self.ships=[ship(3),ship(2),ship(2),ship(1),ship(1),ship(1),ship(1)]
        self.kol_pol=0
        for sh in self.ships:
            self.kol_pol+=sh.len


    def rand(self):
        kol=0
        vec2=[j for j in range(2*self.dlina + 2)]
        while True:
            kol+=1;mx=0
            matr2 = [[0 for j in vec2] for i in vec2]
            for sh in self.ships: sh.rand()
            for sh in self.ships:
                x=sh.x;y=sh.y;gor=sh.gor;len=sh.len
                for xx in range(2*x,2*x+2*(len-1)*gor+4):
                    for yy in range(2*y, 2*y + 2*(len-1)*(1-gor)+4):
                        matr2[xx][yy]+=1


            for x in vec2:
                for y in vec2:
                    mx=max(mx,matr2[x][y])
            #print('--------------')
            #for m in matr2:print(m)

            if mx==1:break
            if kol>100000:break
        print(f'число сделанных попыток для позиции={kol}, max={mx}')
        self.matr = [[0 for j in range(self.dlina)] for i in range(self.dlina)]
        for sh in self.ships:
            for pt in sh.zn:
                self.matr[pt[0]][pt[1]]=1

    def ships(self):
        for sh in self.ships:print(sh)

    def desc(self):
        for m in self.matr:print(m)

    def kill(self,pt): #pt=точка удара
        #print('Проверка точки попадания=',pt)
        ships=self.ships
        for sh_i in range(len(ships)):
            sh=ships[sh_i]
            dell=sh.dell
            for pp in sh.zn:
                if pp[0]+1==pt[0] and pp[1]+1==pt[1]:
                    sh.dell+=1;#print('корабль попал=',sh_i)
                    if sh.len==sh.dell:print('УБИЛ!')
            ships[sh_i]=sh
            if sh.dell==sh.len:
                for pp in sh.zn:
                    x=pp[0];y=pp[1]
                    for xx in range(x-1,x+2):
                        for yy in range(y - 1, y + 2):
                            if (0<=xx<=5) and (0<=yy<=5) and (self.matr[xx][yy]==0):
                                self.matr[xx][yy]=2
        self.ships = ships


    def hod(self):
        hod_=False
        while not hod_:
            hh=hod()
            if self.matr[hh[0]-1][hh[1]-1]<2:hod_=True
            else:print('Это поле уже битое, введите заново')
        self.matr[hh[0] - 1][hh[1] - 1]+=2
        z=self.matr[hh[0] - 1][hh[1] - 1]
        if z==2:print('Промах')
        else:
            self.kol_pol-=1
            print(f'Попадание!!! Осталось целых {self.kol_pol} клеток')
            self.kill(hh)


    def hod_rand(self):
        hod_=False
        while not hod_:
            hh=[random.randint(1, self.dlina) for j in range(2)]
            if self.matr[hh[0]-1][hh[1]-1]<2:hod_=True
        print('Мой случайный выстрел=',hh)
        self.matr[hh[0] - 1][hh[1] - 1] += 2
        z=self.matr[hh[0] - 1][hh[1] - 1]
        if z==2:print('Промах')
        else:
            self.kol_pol-=1
            print(f'Попадание!!! Осталось целых {self.kol_pol} клеток')
            self.kill(hh)


    def desc2(self):
        strr='='
        for i in self.vec:strr=strr+'|'+str(i+1)
        print(strr);i=0
        for m in self.matr:
            i+=1;strr=str(i)
            for mm in m:strr=strr+'|'+zz[mm]
            print(strr)




def igra_desc(dd1:desc,dd2:desc):
    zz1=list(zz);
    zz2=list(zz);
    zz1[1]=zz1[0]
    strr = '==='
    for i in range(dd1.dlina): strr = strr + '|' + str(i + 1)
    print(strr+'    Ваше поле');

    i = 0
    for (m1,m2) in zip(dd1.matr, dd2.matr):
        i += 1;
        strr = str(i)+'=='
        for mm in m1: strr = strr + '|' + zz1[mm]
        strr+='    '
        for mm in m2: strr = strr + '|' + zz2[mm]
        print(strr)


def igra(dd1:desc,dd2:desc):
    print('НАЧАЛО ИГРЫ')
    igra_desc(dd1, dd2)
    game=True
    while game:
        dd1.hod()
        dd2.hod_rand()
        igra_desc(dd1, dd2)
        k1=dd1.kol_pol
        k2 = dd2.kol_pol
        if k1==0:
            print('ВЫ УЖЕ ВЫИГРАЛИ!!!')
            game=False
        if k2==0:
            print('Я УЖЕ ВЫИГРАЛ!!!')
            game=False



#
#
# dd=desc()
# dd.rand();dd.desc2()
# dd.hod();dd.desc2()
# dd.hod();dd.desc2()
# dd.hod();dd.desc2()
# dd.hod();dd.desc2()
# dd.hod();dd.desc2()
# dd.hod();dd.desc2()
# dd.hod();dd.desc2()
# dd.hod();dd.desc2()
# dd.hod();dd.desc2()
# dd.hod();dd.desc2()
# dd.hod();dd.desc2()
#
# dd.hod_rand();dd.desc2()






dd1=desc()
dd1.rand()
print('Подсказка моё поле!!!');dd1.desc2()

dd2=desc()
dd2.rand()
print('Это ваше поле!!!');dd2.desc2()
print('--------------------------------')
igra(dd1,dd2)

#
# dd1.hod()
# dd2.hod_rand()
# igra_desc(dd1,dd2)
#
# def igra(dd1:desc,dd2:desc):
#     print('НАЧАВЛО ИГРЫ')
#     igra_desc(dd1, dd2)
#     game=True
#     while game:
#         dd1.hod()
#         dd2.hod_rand()
#         igra_desc(dd1, dd2)
#         k1=dd1.kol_pol
#         k2 = dd2.kol_pol
#         if k1==0:
#             print('ВЫ УЖЕ ВЫИГРАЛИ!!!')
#             game=False
#         if k2==0:
#             print('Я УЖЕ ВЫИГРАЛ!!!')
#             game=False




#
# dd=desc()
# dd.rand()
# dd.desc2()
# dd.hod()
# dd.desc2()
# dd.hod_rand()
# dd.desc2()






