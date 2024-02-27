# the main beam antenna temperature is:
# \begin{equation}
#     \bar{T}_{a,mb}(\nu) = \sum_{n=0}^N \frac{2\pi}{4n+1}a_{2n}b_{2n}P_{2n}(\nu)
# \end{equation}


import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import curve_fit
from scipy.special import legendre
import h5py
import pandas as pd


# import 40-order expansion coefficients of legrendre polynomials of Beam Pattern, an
# ch: starting from 0 for channel 1
def LoadBeamLegrendreAn(ch):
    global AN
    AN = np.loadtxt(f'../Beam_Legrendre_an/an_legrendre_{ord}ord_ch{ch}.txt') 
    return

# Define the function with Legendre polynomial bases
def Legendre_Polynomials(x, *coeffs):
    result = np.zeros_like(x)
    for i, coeff in enumerate(coeffs):
        result += coeff * legendre(i)(x)
    return result

# Define the function with Legendre polynomial bases
def Ta_func(x, *coeffs):
    result = np.zeros_like(x)
    for i, coeff in enumerate(coeffs):
        result += coeff * legendre(i)(x) *AN[i]*2.*np.pi/(2*i+1.)
    return result

def extract_Ta():
    global Ta,miu
    TA_file=h5py.File(f"../Ta_mu_pairs/Ta_mu_pairs_ch{ch+1:02d}_pj{pj:02d}.h5","r")
    Ta=TA_file['Ta'][:]
    miu=TA_file['miu'][:]

    # print(min(Ta),max(Ta))
    # print(min(miu),max(miu))

def Plot_Ta(mu,data,coeffs):
    fig, axes = plt.subplots(ncols=2,nrows=2,figsize=(20, 20))

    
    ax = axes[0,0]
    ax.scatter(mu, data, c='red' ,label="Ta")
    # ax.set_yscale('log')

    ax.plot(mu, Ta_func(mu, *coeffs), c='blue' ,label="Legendre expansion")
    # ax.plot(mu, Legendre_Polynomials(mu, *coeffs), c='blue' ,label="Legendre expansion")

    ax.legend(fontsize=16)
    ax.set_xlabel(f'$\mu$',fontsize=20)
    ax.set_ylabel(f'$Ta(\mu)$',fontsize=20)
    ax.set_xlim(1,-1)
    # ax.set_ylim(1E-100,1)
    ax.set_xticks([1.0,0.8,0.6,0.4,0.2,0.0,-0.2,-0.4,-0.6,-0.8,-1.0])
    ax.set_xticklabels([1.0,0.8,0.6,0.4,0.2,0.0,-0.2,-0.4,-0.6,-0.8,-1.0],fontsize=16)
    # ax.set_yticks([1E0,1E-1,1E-2,1E-3,1E-4,1E-5,1E-6,1E-7])
    # ax.set_yticklabels([],fontsize=16)
    ax.grid()
    ax.set_title(f'a. Ta CH{ch+1:02d}',fontsize=25,loc="left")


    ax = axes[0,1]
    x_pos = np.arange(len(coeffs))
    width = 0.4
    h = ax.bar(x_pos,coeffs, width=width,facecolor='orange',edgecolor='k',alpha=0.5,label='Bn') 
    h1 = ax.bar(x_pos,AN[:len(coeffs)], width=width,facecolor='Blue',edgecolor='k',alpha=0.5,label='An') 
    # ax.legend(fontsize=16)
    ax.set_xlabel(f'Order of Legendre Polynomials',fontsize=20)
    ax.set_ylabel(f'Coefficents',fontsize=20)
    ax.set_xlim(-2,21)
    ax.set_xticks([0,5,10,15,20])
    ax.set_xticklabels([0,5,10,15,20],fontsize=16)
    ax.grid()
    ax.set_title(f'b. Coefficents, $b_n$',fontsize=25,loc="left")

    ax3 = axes[1,0]
    noise=data-Ta_func(mu, *coeffs)
    x_pos = np.arange(len(noise))
    ax3.scatter(x_pos, noise, c='red' ,label="residual error")
    ax3.grid()
    ax3.set_title(f'c. Residual Error [K]',fontsize=25,loc="left")


    ax = axes[1,1]
    elevation_angles = np.linspace(0, 90, 91)
    mu0=np.cos(elevation_angles/180.*np.pi)  ## 1 -> -1
    ax.plot(mu0, Legendre_Polynomials(mu0, *coeffs), c='blue' ,label="Legendre expansion")
    # ax.legend(fontsize=16)
    ax.set_xlabel(f'$\mu$',fontsize=20)
    ax.set_ylabel(f'$T_b [K]$',fontsize=20)
    ax.set_xlim(1,0)
    # ax.set_xticks([0,5,10,15,20,25,30,35,40])
    # ax.set_xticklabels([0,5,10,15,20,25,30,35,40],fontsize=16)
    ax.grid()
    ax.set_title(f'd. $T_b [K]$',fontsize=25,loc="left")



    fig.savefig(f"Ta_expansion_bn_ch{ch+1:02d}.png",dpi=300)


def sort_mu_with_Ta(A, B):
    # Create a list of tuples where each tuple contains a pair (A[i], B[i])
    combined = list(zip(A, B))
    
    # Sort the combined list based on the values of B
    combined.sort(key=lambda x: x[1])
    
    # Extract the sorted values of A from the sorted combined list
    sorted_A = [pair[0] for pair in combined]
    
    # Extract the sorted values of B from the sorted combined list
    sorted_B = [pair[1] for pair in combined]
    
    return sorted_A, sorted_B


if __name__=="__main__":
    # ch=5 # 0 for channel 1
    for ch in range(1,6):
        pj=51

        ord=20
        LoadBeamLegrendreAn(ch)

        # print(AN)

        elevation_angles = np.linspace(0, 180, 181)
        mu=np.cos(elevation_angles/180.*np.pi)  ## 1 -> -1

        ## construct Bean pattern of function of polar angle or emission angle
        pattern_expansion=Legendre_Polynomials(mu,*AN)

        
        ## extract Ta
        extract_Ta()
        
        Ta1=Ta
        miu1=-miu
        # print(len(Ta))
        Ta=np.append(Ta,Ta1)
        miu=np.append(miu,miu1)
        # print(len(Ta))
        # print(miu)

        Ta,miu=sort_mu_with_Ta(Ta,miu)


        ## Legendre expansion of Ta
        initial_guess = np.float64([1.0] * ord)  # Initial guess for coefficients TO 20TH ORDER

        if ch==1:
           initial_guess=[350, 1, 200, 1, -100, 1, 60, 1, -20, 1, 10, 1, 10, 1, 30, 1, -25, 1, 30, 1]
        if ch==2:
           initial_guess=[280, 1, 140, 1, -100, 1, 60, 1, -40, 1, 20, 1, -4, 1, -5, 1,  10, 1, -5, 1]
        if ch==3:
           initial_guess=[200, 1, 107, 1,  -80, 1, 50, 1, -30, 1, 15, 1, -4, 1, -5, 1,  10, 1, -5, 1]
        if ch==4:
           initial_guess=[200, 1,  80, 1,  -60, 1, 40, 1, -30, 1, 15, 1, -5, 1, -5, 1,   5, 1, -2, 1]
        if ch==5:
           initial_guess=[100, 1,  50, 1,  -50, 1, 40, 1, -30, 1, 15, 1, -5, 1, -5, 1,   5, 1, -5, 1]


        # coeffs, covars = curve_fit(Legendre_Polynomials, miu, Ta, p0=initial_guess)
        coeffs, covars = curve_fit(Ta_func, np.float64(miu), np.float64(Ta), p0=initial_guess, bounds=(
                                        (  5, 0,    0, 0, -200, 0,   0, 0, -100, 0,  0, 0, -10, 0, -10, 0, -50, 0, -10, 0),
                                        (500, 2,  500, 2,    0, 2, 100, 2,    0, 2, 50, 2,  50, 2,  50, 2,  50, 2,  50, 2),
                                    ))

        covars=np.where(covars<1E-15, 0, covars)

        # print(coeffs)

        # Plot_Ta(miu,Ta,coeffs[0:20])
        # Plot_Ta(miu,Ta,coeffs)
    # coeffs
        # print (covars)

        df = pd.DataFrame(covars)       
        filename = f'covars_matrix_pj{pj:02d}_ch{ch:02d}.csv'
        df.to_csv(filename, index=False)


        dc = pd.DataFrame(coeffs)       
        filename = f'coeffs_bn_pj{pj:02d}_ch{ch:02d}.csv'
        dc.to_csv(filename, index=False)        