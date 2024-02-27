import numpy as np
import matplotlib.pyplot as plt
# import proplot as pplt
from matplotlib.ticker import FuncFormatter

def LoadBeamPattern(Freq):
    global BeamPattern
   
    BeamPattern = np.zeros((361,181))
   
    tmp = np.loadtxt('../../0.jpl.antenna.pattern/Beam/antenna_beam_pattern'+str(Freq)+'.txt')
    k=0
    for j in range(181):
        for i in range(361):
            BeamPattern[i,j] = tmp[k]
            k=k+1
           
    # BeamPattern = 10.0**(BeamPattern/10.0)
    BeamPattern-=BeamPattern.max()
    return


if __name__=="__main__":
    ch=5 ## channel 6
    LoadBeamPattern(ch)

    # Plot the heatmap
    # plt.figure(figsize=(10, 5))
    # plt.imshow(BeamPattern, cmap='jet', origin='lower', extent=[0, 360, -90, 90])
    # plt.colorbar(label='Gain (dB)')
    # plt.xlabel('Azimuth (degrees)')
    # plt.ylabel('Elevation (degrees)')
    # plt.title('Beam Pattern Heatmap')
    # plt.grid(True)
    # plt.savefig(f"BeamPattern_ch{ch+1:02d}.png")

    # Plot XY curve of azimuth-averaged beam pattern

    Beam_theta=np.mean(BeamPattern, axis=0)
    elevation_angles = np.linspace(0, 180, 181)
    mu=np.cos(elevation_angles/180.*np.pi)
    plt.plot(mu, Beam_theta,c='k',lw=2,label='Azimuth-Averaged')
    plt.plot(mu, BeamPattern[0,:],c='xkcd:blue',lw=2,label='$\phi$=$0^o$')
    # plt.plot(mu, BeamPattern[30,:],c='xkcd:red',lw=2,label='phi=30')
    plt.plot(mu, BeamPattern[45,:],c='xkcd:red',lw=2,label='$\phi$=$45^o$')
    plt.plot(mu, BeamPattern[90,:],c='xkcd:orange',lw=2,label='$\phi$=$90^o$')
    plt.xlabel('Cosine of Elevation Angle')
    plt.ylabel('Gain (dB)')
    plt.title(f'Beam Pattern CH{ch+1:02d}')
    # Set x-axis range from 0 to 180 degrees
    plt.xlim(1, 0)
    plt.ylim(-70,0)

    plt.xticks([1.0,0.8,0.6,0.4,0.2,0.0]) 
    plt.legend(loc='best',ncol=1)#,frameon=False)

    plt.grid(True)     
    plt.savefig(f"BeamCurve_axialsymmetic_ch{ch+1:02d}.png",dpi=300) 





    # Convert beam pattern data to polar coordinates
    theta = np.linspace(0, 2*np.pi, 361)
    r_degrees = np.linspace(0, 180, 181)  # degrees
    theta, r = np.meshgrid(theta, np.radians(r_degrees))  # convert degrees to radians
    z_dB = BeamPattern.T  # Transpose the beam pattern data
    # z_dB = 10 * np.log10(z_linear)  # Convert to dB

    # Plot the heatmap using polar coordinates
    plt.figure(figsize=(8, 8))
    ax = plt.subplot(111, polar=True)
    cax = ax.contourf(theta, r, z_dB, cmap='inferno',levels=15)
    plt.colorbar(cax, label='Gain (dB)')

    # Format radial axis labels to show degrees
    def degrees_formatter(x, pos):
        return f'{int(np.degrees(x))}$^\circ$'

    ax.yaxis.set_major_formatter(FuncFormatter(degrees_formatter))
    plt.title(f'Beam Pattern in dB, CH{ch+1:02d}')
    plt.savefig(f"BeamPattern_ch{ch+1:02d}.png")



