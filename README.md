# mwr_polarvortices
The project to visualize MWR observations of Jupiter Circumpolar Cyclones and the related data analyzing work.

## Requirements
- MWR observations: `MWR_TA_perijove_20231014.h5`  
- JPL preprocessed package :`JunoMWR`

## Run
The python script receives a specified channel index and processes all MWR obervations from PJ51 to PJ54 to:
- convert the original 1D trajectory format to a 2D swath mesh grid, output a H5 file;
- call the NCL script to plot the observation over the North Pole, output a PNG image.  

Directly run the python script, with a specified `sys.argv[1]` - the index of channel to process (0 for channel 1, 5 for channel 6) 
```bash
> python mesh_plot.py 5 
```
By default, this script processes perijoves over PJ51 to PJ54, modify it if you need to work on perijoves beyond this period.

You can run the NCL script solely, if you already have the historcial H5 files ouput, by specifying the channel index and perijove index:
```bash
> ncl -Q plot.TA.channels.ncl ch=5 pj=51
```

## Panel plots
To plot all perjoves in a single panel:
```bash
> ncl -Q plot.fig1.ncl
> ncl -Q plot.fig2.ncl
> ncl -Q plot.fig3.ncl
```