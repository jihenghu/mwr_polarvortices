import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import h5py
from scipy.special import legendre
from scipy.optimize import curve_fit
import matplotlib
matplotlib.rcParams['font.size'] = 24.0


shape_func = pd.read_csv('./shape_fuc_ch6.csv')
mu_=shape_func['mu'][:].values
shape_=shape_func['shape'][:].values

## fit the shape
coeff0=[1.0]*2

def Polynomials(x, a,b):
    # result = np.zeros_like(x)
    # for i, coeff in enumerate(coeffs):
        # result += coeff * legendre(i)(x)
    # return result
    return 1/(1+np.exp(-1*a**2*(x+b)**2))

# print(mu_)
coeffs,pcor=curve_fit(Polynomials,mu_,shape_,p0=coeff0)


## read in ZZ tb in channel 6
tb_file=h5py.File(f"PJ51_Freq5.h5","r")
c0_0=tb_file['ModelTypeupdate1_MultiPJ_Mode2/Iter2/c0'][:]
c1=tb_file['ModelTypeupdate1_MultiPJ_Mode2/Iter2/c1'][:]
c2=tb_file['ModelTypeupdate1_MultiPJ_Mode2/Iter2/c2'][:]

## the north polar 
c0=c0_0[-1]
c1=c1[-1]
c2=c2[-1]

mu=np.linspace(1,0,100)
base=c0-c1*(1-mu)/0.2+0.5*c2*(mu-0.2)*(1-mu)/0.04
shapes=Polynomials(mu,*coeffs)
tb=base*shapes

fig, axes = plt.subplots(ncols=2,nrows=2,figsize=(20, 20))

ax = axes[0,0]
ax.set_xlim(1,0)
ax.scatter(mu_, shape_, c='blue' ,label=" _ch6")
ax.plot(mu,shapes, c='blue' ,label="fitted _ch6 ")
ax.grid()
ax.legend()
ax.set_title(f'a. Shape function CH6',fontsize=25,loc="left")


ax = axes[0,1]
lats=np.linspace(0,180,180)-89.5
ax.plot(lats, c0_0, c='red' ,label="C0 _ch6")
ax.grid()
ax.legend()
ax.set_title(f'b. C0 PJ51 CH6',fontsize=25,loc="left")


ax = axes[1,0]
ax.set_xlim(1,0)
ax.plot(mu,base, c='blue' ,label=" _ch6 ")
ax.grid()
ax.legend()
ax.set_title(f'c. Base function north pole',fontsize=25,loc="left")


ax = axes[1,1]
ax.set_xlim(1,0)
ax.plot(mu,tb, c='blue' ,label="Tb _ch6 ")
ax.grid()
ax.legend()
ax.set_title(f'd. Tb PJ51 CH6 north pole',fontsize=25,loc="left")



fig.savefig(f"tb_zz_ch6_pj51.png",dpi=300)

