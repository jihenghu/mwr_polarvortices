import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import curve_fit
from scipy.special import legendre

def LoadBeamPattern(Freq):
    global BeamPattern,BeamPattern_norm
   
    BeamPattern = np.zeros((361,181))
   
    tmp = np.loadtxt('../../0.jpl.antenna.pattern/Beam/antenna_beam_pattern'+str(Freq)+'.txt')
    k=0
    for j in range(181):
        for i in range(361):
            BeamPattern[i,j] = tmp[k]
            k=k+1
           
    BeamPattern_norm = 10.0**(BeamPattern/10.0)
    BeamPattern-=BeamPattern.max()
    BeamPattern=10.0**(BeamPattern/10.0)
    return

# Define the function with Legendre polynomial bases
def func(x, *coeffs):
    result = np.zeros_like(x)
    for i, coeff in enumerate(coeffs):
        result += coeff * legendre(i)(x)
    return result


if __name__=="__main__":
    # ch=5 ## channel 6

    for ch in range(0,6):
        LoadBeamPattern(ch)

        # Plot XY curve of azimuth-averaged beam pattern
        Beam_theta=np.mean(BeamPattern, axis=0)
        Beam_theta_norm=np.mean(BeamPattern_norm, axis=0)
        elevation_angles = np.linspace(0, 180, 181)

        mu=np.cos(elevation_angles/180.*np.pi)

        for i, imu in enumerate(mu):
            if imu<0:
                Beam_theta[i]= Beam_theta[180-i]

        # Beam_theta=np.where(Beam_theta<1E-4,1E-4,Beam_theta)

        fig, axes = plt.subplots(ncols=2,nrows=1,figsize=(20, 10))

        ax = axes[0]

        ## the antenna pattern in 1 degree elevation angular resolution
        ax.scatter(mu, Beam_theta, marker='o',s=20,alpha=0.5,c='xkcd:forest green',label=f'Gain')

        ## the antenna pattern in 1 degree elevation angular resolution
        ax.scatter(mu, Beam_theta_norm, marker='o',s=20,alpha=0.5,c='xkcd:orange',label=f'Raw data')


        ## Legendre expansion
        initial_guess = [1.0] * 40  # Initial guess for coefficients TO 20TH ORDER
        coeffs, _ = curve_fit(func, mu, Beam_theta, p0=initial_guess)


        sum=np.float64(0)
        nubins=np.linspace(0, 1, 91)
        dnu=nubins[1]-nubins[0]
        for iu in range(0,len(nubins)-1):
            # print(iu)
            sum=sum+(func(np.float64(nubins[iu]), *coeffs)+func(np.float64(nubins[iu+1]), *coeffs))*0.5*dnu
        
        # print(sum)
        coeffs_norm=coeffs/sum/2./np.pi

        cofs=[]
        for i,cof in enumerate(coeffs_norm):
            if i%2==0:
                cofs.append(f'{cof:.4f}')
        
        print(list(map(np.float32,cofs)))



        # Plot the fitted function
        ax.plot(mu, func(mu, *coeffs), c='xkcd:forest green' , label="$40^{th}$ order Legendre polynomials")
        ax.plot(mu, func(mu, *coeffs_norm), c='red' , label="Normalized $40^{th}$ order Legendre polynomials")



        # Set y-axis to logarithmic scale
        ax.set_yscale('log')

        # Labeling and styling
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

    ###
        ax = axes[1]
        x_pos = np.arange(len(coeffs_norm))
        width = 0.4

        h = ax.bar(x_pos,coeffs_norm, width=width,facecolor='orange',edgecolor='k')#,label='Coefficents of Legendre Polynomials') 

        # ax.legend(fontsize=16)
        ax.set_xlabel(f'Order of Legendre Polynomials',fontsize=20)
        ax.set_ylabel(f'Coefficents',fontsize=20)
        ax.set_xlim(-2,41)
        ax.set_xticks([0,5,10,15,20,25,30,35,40])
        ax.set_xticklabels([0,5,10,15,20,25,30,35,40],fontsize=16)
        # ax.set_yticks([0,0.025,0.05,0.075,0.1,0.125,0.15,0.175,0.2]*0.1)
        # ax.set_yticklabels([0,0.025,0.05,0.075,0.1,0.125,0.15,0.175,0.2]*0.1,fontsize=16)
        ax.grid()
        ax.set_title(f'b. Normalized Coefficents',fontsize=25,loc="left")

        fig.savefig(f"Beam_legendre_40th_normalized_ch{ch+1:02d}.png",dpi=300)
    
