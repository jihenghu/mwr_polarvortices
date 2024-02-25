
import os
import sys
import numpy as np
import matplotlib.pyplot as plt
import h5py
from JunoMWR.IO import default_files
from JunoMWR.SampledMeasurements import SampledMeasurements

def mesh(pj,ch):
    ## set the 0-degree emission angle as the most centered footprint in a spin
    center_emission_angle=0.0
    ## open TA observations
    TA_file=h5py.File("/data/jihenghu/juno-mwr-deconv-research/0.jpl.package/input/MWR_TA_perijove_20231014.h5",'r')
    ft_file=h5py.File(f"/data/jihenghu/juno-mwr-deconv-research/0.jpl.package/input/footprints/footprints(PJ={pj:2d},pct=10).h5",'r')
    ZZ_file=h5py.File(f"PJ51_Freq5.h5",'r')
    
  
    lon_bound=ft_file['longitudes, footprint boundary'][ch]
    lat_bound=ft_file['latitudes, footprint boundary'][ch]

    maxbound=0
    for ilonb in range(len(lon_bound)):
        if maxbound<len(lon_bound[ilonb]):
            maxbound=len(lon_bound[ilonb])


    nb=np.zeros([len(lon_bound)])
    latb=np.zeros([len(lon_bound),maxbound])
    lonb=np.zeros([len(lon_bound),maxbound])

    for ilonb in range(len(lon_bound)):
        
        nb0=len(lon_bound[ilonb])
        nb[ilonb]=nb0
        if nb0==0:
            latb[ilonb][:]=-999.9
            lonb[ilonb][:]=-999.9
        else:
            # print(nb0,ilonb,len(lon_bound))
            latb[ilonb][0:nb0]=lat_bound[ilonb][0:nb0]
            lonb[ilonb][0:nb0]=lon_bound[ilonb][0:nb0]
            latb[ilonb][nb0:maxbound]=-999.9
            lonb[ilonb][nb0:maxbound]=-999.9


    sm=SampledMeasurements(perijove=pj,channel=ch)
    ## the number of scans, or spins
    npartition=len(sm.spin_partition) 

    # print(npartition)
    # print(f'found {npartition} npartitions -->{npartition-1} scans/spins')## 加些余量
    nscan=npartition-1

    max_fp=0
    ## do loop in every single scan, to obtain the pixels (footprints) 
    for iscan in range(npartition-1):
        lentmp=sm.spin_partition[iscan+1]-sm.spin_partition[iscan]
        if max_fp<lentmp and lentmp<500 :
            max_fp= lentmp

    # print(f'found most pixels per scan: {max_fp}')## 加些余量
    TA_swath =np.zeros([nscan,max_fp])
    lat_swath=np.zeros([nscan,max_fp])
    lon_swath=np.zeros([nscan,max_fp])
    LZA_swath=np.zeros([nscan,max_fp])

    ZZ_lat=np.zeros([nscan,max_fp])
    ZZ_lon=np.zeros([nscan,max_fp])
    ZZ_residual=np.zeros([nscan,max_fp])
    # ZZ_c0=np.zeros([nscan,max_fp])
    # ZZ_c1=np.zeros([nscan,max_fp])
    # ZZ_c2=np.zeros([nscan,max_fp])
    




    height_sc=np.zeros([nscan,max_fp])
    lat_sc=np.zeros([nscan,max_fp])
    lon_sc=np.zeros([nscan,max_fp])
    height=TA_file[f'PJ{pj:02d}']['range']
    
    nb_swath=np.zeros([nscan,max_fp])
    latb_swath=np.zeros([nscan,max_fp,maxbound])
    lonb_swath=np.zeros([nscan,max_fp,maxbound])




    for iscan in range(npartition-1):
        lentmp=sm.spin_partition[iscan+1]-sm.spin_partition[iscan]
        if lentmp>500:
            TA_swath[iscan]=-999.9
            lat_swath[iscan]=-999.9
            lon_swath[iscan]=-999.9
            LZA_swath[iscan]=-999.9

            ZZ_lat=-999.9
            ZZ_lon=-999.9
            ZZ_residual=-999.9
            # ZZ_c0=-999.9
            # ZZ_c1=-999.9
            # ZZ_c2=-999.9

            height_sc[iscan]=-999.9
            lat_sc[iscan]=-999.9
            lon_sc[iscan]=-999.9
        else:
            # idx_1d=np.arange(sm.spin_partition[iscan], sm.spin_partition[1+iscan])

            # idx_1d=np.arange(sm.spin_partition[iscan], sm.spin_partition[1+iscan])

            ## find the center-most footprint, whose emission_angle is 0-degree
            # icenter=np.nanargmin(np.abs(sm.emission_angle[idx_1d]-center_emission_angle))
            # icenter_1d=idx_1d[icenter]

            # print(f'icenter_1d: {icenter_1d}')

            ist= sm.spin_partition[iscan]
            iend=sm.spin_partition[1+iscan]
            
            if ist<0: 
                continue
            
            if iend>len(height): 
                continue

            TA_swath[iscan][0:iend-ist]=TA_file[f'PJ{pj:02d}']['antenna temperature'][ch][ist:iend]

            ZZ_lat[iscan][0:iend-ist]=ZZ_file[f'latpc_obs'][ist:iend]
            ZZ_lon[iscan][0:iend-ist]=ZZ_file[f'lonpc_obs'][ist:iend]
            ZZ_residual[iscan][0:iend-ist]=ZZ_file[f'ModelTypeupdate1_MultiPJ_Mode2/Iter2/residual'][ist:iend]
            # ZZ_c0[iscan][0:iend-ist]=ZZ_file[f'ModelTypeupdate1_MultiPJ_Mode2/Iter2/c0'][ist:iend]
            # ZZ_c1[iscan][0:iend-ist]=ZZ_file[f'ModelTypeupdate1_MultiPJ_Mode2/Iter2/c1'][ist:iend]
            # ZZ_c2[iscan][0:iend-ist]=ZZ_file[f'ModelTypeupdate1_MultiPJ_Mode2/Iter2/c2'][ist:iend]
            
            if ch==0:
                lat_swath[iscan][0:iend-ist]=TA_file[f'PJ{pj:02d}']['footprint latitude, channel 1'][ist:iend]
                lon_swath[iscan][0:iend-ist]=TA_file[f'PJ{pj:02d}']['footprint longitude, channel 1'][ist:iend]
                LZA_swath[iscan][0:iend-ist]=TA_file[f'PJ{pj:02d}']['emission angle, channel 1'][ist:iend]
            else:                    
                lat_swath[iscan][0:iend-ist]=TA_file[f'PJ{pj:02d}']['footprint latitude, channels 2-6'][ist:iend]
                lon_swath[iscan][0:iend-ist]=TA_file[f'PJ{pj:02d}']['footprint longitude, channels 2-6'][ist:iend]
                LZA_swath[iscan][0:iend-ist]=TA_file[f'PJ{pj:02d}']['emission angle, channels 2-6'][ist:iend]

            height_sc[iscan][0:iend-ist]=TA_file[f'PJ{pj:02d}']['range'][ist:iend]
            lat_sc[iscan][0:iend-ist]=TA_file[f'PJ{pj:02d}']['spacecraft latitude'][ist:iend]
            lon_sc[iscan][0:iend-ist]=TA_file[f'PJ{pj:02d}']['spacecraft longitude'][ist:iend]

            nb_swath[iscan][0:iend-ist]=nb[ist:iend]
            latb_swath[iscan][0:iend-ist][:]=latb[ist:iend][:]
            lonb_swath[iscan][0:iend-ist][:]=lonb[ist:iend][:]


        
    fout=f'TA_swath_ch{(ch+1):02d}_pj{pj:02d}.h5'
    print(f'output mesh data file {fout}')
    hf = h5py.File(fout, 'w')  

    TA=hf.create_dataset('TA', data=TA_swath)
    lat=hf.create_dataset('latitude', data=lat_swath)
    lon=hf.create_dataset('longitude', data=lon_swath)
    LZA=hf.create_dataset('LZA', data=LZA_swath)

    TA.attrs["units"] = "K"
    TA.attrs["long_name"] = f"Antenna temperature, channel {(ch+1)}"

    LZA.attrs["units"] = "degree"
    LZA.attrs["long_name"] = f"Local zenith angle, channel {(ch+1)}"

    lat.attrs["units"] = "degree_north"
    lat.attrs["long_name"] = f"Latitude, channel {(ch+1)} "

    lon.attrs["units"] = "degree_east"
    lon.attrs["long_name"] = f"Longitude, channel {(ch+1)} "


    hf.create_dataset('ZZ_lat', data=ZZ_lat)
    hf.create_dataset('ZZ_lon', data=ZZ_lon)
    hf.create_dataset('ZZ_residual', data=ZZ_residual)
    # hf.create_dataset('ZZ_c0', data=ZZ_c0)
    # hf.create_dataset('ZZ_c1', data=ZZ_c1)
    # hf.create_dataset('ZZ_c2', data=ZZ_c2)

    nbb=hf.create_dataset('nb', data=nb_swath)
    latbn=hf.create_dataset('latbn', data=latb_swath)
    lonbn=hf.create_dataset('lonbn', data=lonb_swath)

    # nbb.attrs["units"] = "km"
    nbb.attrs["long_name"] = "footprint boundary number"
    latbn.attrs["long_name"] = "footprint boundary latitude"
    latbn.attrs["units"] = "degree_north"
    lonbn.attrs["long_name"] = "footprint boundary longitude"
    lonbn.attrs["units"] = "degree_east"

    range0=hf.create_dataset('juno_range', data=height_sc)
    lon0=hf.create_dataset('juno_longitude', data=lon_sc)
    lat0=hf.create_dataset('juno_latitude', data=lat_sc)

    range0.attrs["units"] = "km"
    range0.attrs["long_name"] = "Height of spacecraft"

    lat0.attrs["units"] = "degree_north"
    lat0.attrs["long_name"] = "Latitude of spacecraft "

    lon0.attrs["units"] = "degree_east"
    lon0.attrs["long_name"] = "Longitude of spacecraft "

    hf.close()
    TA_file.close()



if __name__=="__main__":
    ch=5
    pj=51
    mesh(pj,ch)   

