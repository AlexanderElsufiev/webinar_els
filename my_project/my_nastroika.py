
import numpy as np
import random
import pandas as pd
import copy






class my_prog:
    def __init__(self):
        self.col_x=[]
        self.koef={}
        self.err=None
        self.rez=None


    def __str__(self):
        # return f'len= {self.len},gor={self.gor}, x={self.x},y={self.y} zn=={self.zn}'
        return 1

    def print_koef(self):
        print(f'my_progn===== {self.rez}')
        # print(f'koef={self.koef}')
        # print(f'err={self.err}')
        # print(f'col_x=={self.col_x}')




    def nastr1(self,tab,col_x):

        ogr = np.array(tab['ogr'])
        y = np.array(tab['y'])

        colx=col_x[:-1]
        tb=np.array(tab[colx])
        tb_str=tb.shape[0] #  количество строк
        ed = np.ones((tb_str, 1))
        nol = ed*0
        # o=(y>ogr);ogr[o]=y[o] # исправление ограничителя
        tb = np.column_stack((tb, ogr))
        tb = np.column_stack((tb, ed))
        tb = np.column_stack((tb, ogr))
        tb = np.column_stack((tb, y))
        tb = np.column_stack((tb, nol))
        colx=colx+['x_ogr','ed']
        col_x=colx+['ogr','y','yy']
        # print(f'___col_x==={col_x}')

        # введение начальных коэффициентов
        koef={};bkoef={};vec={};step=0
        for nm in colx:koef[nm]=0;bkoef[nm]=0;vec[nm]=0
        b_err=sum(tb[:,-2]**2)
        rad=1;bad=True;err=0;

        while (step<10000 and rad>0.00000001):
            for nm in bkoef:
                if bad:vec[nm]=(random.random()-0.5)
                koef[nm]=bkoef[nm]+rad*vec[nm]

            tb[:,-1]=0
            for (i,nm) in enumerate(colx):
                zn=koef[nm]
                tb[:, -1]+=zn*tb[:,i]
            # **************************************************
            # ФРАГМЕНТ КОДА БЕЗ КОТОРОГО ПРОГРАММА СТАНОВИТСЯ БЕССМЫСЛЕННОЙ
            # **************************************************
            if err<b_err:
                for nm in bkoef:bkoef[nm]=koef[nm]
                b_err=err;rad=rad*2;bad=False
            else:rad=rad*0.9;bad=True
            step+=1


        rez={'koef':bkoef,'err':b_err,'rad':rad,'step':step}
        return rez

    def nastr(self, tab, col_x):
        self.col_x=col_x
        b_err=None;b_rez=None
        for t in range(3):
            rez=self.nastr1(tab, col_x)
            # print(f't=={t}    rez=={rez}')
            if b_err is None:
                b_rez=rez;b_err=rez['err']
            else:
                if b_err>rez['err']:
                    b_rez = rez;b_err = rez['err']
        self.koef=b_rez['koef']
        self.err=b_err
        self.rez=b_rez

    def prognoz(self,tab):
        col_x=self.col_x
        koef=self.koef
        # print(f'koef==={koef}')
        tb = copy.deepcopy(tab)
        # print(f'tb==\n{tb}')
        tb['yy_']=0
        for nm in koef:
            nm_=nm;
            if nm=='x_ogr':nm_='ogr'
            zz=koef[nm];
            # print(f'nm=={nm}  zz={zz}')
            if nm=='ed':tb['yy_']+=zz
            else:tb['yy_']+=zz*tb[nm_]
        tb['yy']=tb['yy_']
        o = (tb['yy'] > tb['ogr']);
        tb.loc[o, 'yy'] = tb.loc[o, 'ogr']
        rez=tb[['yy','yy_','ogr']]
        return tb #rez




