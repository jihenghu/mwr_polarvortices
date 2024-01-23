# mwr_polarvortices
The project to visualize MWR observations of Jupiter Circumpolar Cyclones and the related data analyzing work.

## requirements
- MWR observation: `MWR_TA_perijove_20231014.h5`  
- JPL preprocessed package :`JunoMWR`

## Run
Directly run the python script, with a specified `sys.argv[1]` - the index of channel to process (0 for channel 1, 5 for channel 6)`  
```
> python mesh_plot.py 5 
```

