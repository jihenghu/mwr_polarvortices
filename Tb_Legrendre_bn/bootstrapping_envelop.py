import numpy as np
import pandas as pd
from scipy.special import legendre
import matplotlib.pyplot as plt

def Legendre_Polynomials(x, *coeffs):
    result = np.zeros_like(x)
    for i, coeff in enumerate(coeffs):
        result += coeff * legendre(i)(x)
    return result


if __name__=="__main__":
    scale = np.random.normal(loc=0,scale=1., size=[1000,20])
    mu=np.linspace(1,0,100)
    pj=51

    for ch in range(2,6):

        bn0 = pd.read_csv(f'coeffs_bn_pj{pj:02d}_ch{ch+1:02d}.csv').values.transpose()[0]
        std = np.sqrt(pd.read_csv(f'variance_pj{pj:02d}_ch{ch+1:02d}.csv').values.transpose()[0])

        Min=[1000]*len(mu)
        Max=[0]*len(mu)

        for i in range(0,1000):
            print(i)
            x=scale[i][:]
            bn=bn0+std*x
            

            tb=Legendre_Polynomials(mu, *bn)
            Min=np.where(tb<Min,tb,Min)
            Max=np.where(tb>Max,tb,Max)
            
        # print(Min,Max)
        # exit()
        plt.figure(figsize=(8, 6))
        # plt.scatter(mu, tb, c='red' ,label="Ta")
        # ax.set_yscale('log')

        plt.plot(mu, Legendre_Polynomials(mu, *bn0), c='blue' ,label="Legendre prediction")
        # ax.plot(mu, Legendre_Polynomials(mu, *coeffs), c='blue' ,label="Legendre expansion")
        plt.fill_between(mu, Min, Max, color='purple', alpha=0.3)
        plt.legend(fontsize=16)
        plt.xlabel(f'$\mu$',fontsize=20)
        plt.ylabel(f'$Tb(\mu)$',fontsize=20)
        plt.xlim(1,0)
        # ax.set_ylim(1E-100,1)
        plt.xticks([1.0,0.8,0.6,0.4,0.2,0.0])
        # plt.xticklabels([1.0,0.8,0.6,0.4,0.2,0.0,-0.2,-0.4,-0.6,-0.8,-1.0],fontsize=16)
        # ax.set_yticks([1E0,1E-1,1E-2,1E-3,1E-4,1E-5,1E-6,1E-7])
        # ax.set_yticklabels([],fontsize=16)
        plt.grid()
        plt.title(f'Tb CH{ch+1:02d}',fontsize=25,loc="left")

        plt.savefig(f"Tb_envelop_ch{ch+1:02d}.png",dpi=300)




