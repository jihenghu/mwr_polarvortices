# the main beam antenna temperature is:
# \begin{equation}
#     \bar{T}_{a,mb}(\nu) = \sum_{n=0}^N \frac{2\pi}{4n+1}a_{2n}b_{2n}P_{2n}(\nu)
# \end{equation}


import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import curve_fit
from scipy.special import legendre

# import 40-order expansion coefficients of legrendre polynomials of Beam Pattern, an
# ch: starting from 0 for channel 1
def LoadBeamLegrendreAn(ch):
    global AN
    AN = np.loadtxt(f'../Beam_Legrendre_an/an_legrendre_40ord_ch{ch}.txt') 
    return

# Define the function with Legendre polynomial bases
def Legendre_Polynomials(x, *coeffs):
    result = np.zeros_like(x)
    for i, coeff in enumerate(coeffs):
        result += coeff * legendre(i)(x)
    return result

def Plot():
    fig, axes = plt.subplots(ncols=2,nrows=1,figsize=(20, 10))
    ax=axes[0]
    ax.plot(mu, pattern_expansion, c='red' ,label="Legendre expansion of Beam")
    ax.set_yscale('log')
    ax.legend(fontsize=16)
    ax.set_xlabel(f'$\mu$',fontsize=20)
    ax.set_ylabel(f'$G(\mu)$',fontsize=20)
    ax.set_xlim(1,-1)
    # ax.set_ylim(1E-100,1)
    ax.set_xticks([1.0,0.8,0.6,0.4,0.2,0.0,-0.2,-0.4,-0.6,-0.8,-1.0])
    ax.set_xticklabels([1.0,0.8,0.6,0.4,0.2,0.0,-0.2,-0.4,-0.6,-0.8,-1.0],fontsize=16)
    ax.set_yticks([1E0,1E-1,1E-2,1E-3,1E-4,1E-5,1E-6,1E-7])
    ax.set_yticklabels([1,'$10^{-1}$','$10^{-2}$','$10^{-3}$','$10^{-4}$','$10^{-5}$','$10^{-6}$','$10^{-7}$'],fontsize=16)
    ax.grid()
    ax.set_title(f'a. Gain pattern CH{ch+1:02d}',fontsize=25,loc="left")
    
    ax = axes[1]
    x_pos = np.arange(len(AN))
    width = 0.4
    h = ax.bar(x_pos,AN, width=width,facecolor='orange',edgecolor='k')#,label='Coefficents of Legendre Polynomials') 
    # ax.legend(fontsize=16)
    ax.set_xlabel(f'Order of Legendre Polynomials',fontsize=20)
    ax.set_ylabel(f'Coefficents',fontsize=20)
    ax.set_xlim(-2,41)
    ax.set_xticks([0,5,10,15,20,25,30,35,40])
    ax.set_xticklabels([0,5,10,15,20,25,30,35,40],fontsize=16)
    ax.grid()
    ax.set_title(f'b. Normalized Coefficents, $a_n$',fontsize=25,loc="left")
    fig.savefig(f"Beam_legendre_ch{ch+1:02d}.png",dpi=300)

if __name__=="__main__":
    ch=0 # 0 for channel 1
    # for ch in range(0,6):

    LoadBeamLegrendreAn(ch)

    elevation_angles = np.linspace(0, 180, 181)
    mu=np.cos(elevation_angles/180.*np.pi)  ## 1 -> -1

    ## construct Bean pattern of function of polar angle or emission angle
    pattern_expansion=Legendre_Polynomials(mu,*AN)

    ## plot the Beam curve
    Plot()