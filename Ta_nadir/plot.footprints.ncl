begin

; do pj=1,54
pj=51
print(""+pj)
perijove=addfile("../../3.0.Polar.vortex/Juno_MWR-Antenna_Temperatures-Swath-Perijove_"+sprinti("%0.2i",pj)+".h5","r")

if (pj.eq.2) then
continue
print("no such variable in PJ"+sprinti("%0.2i",pj))
end if

name="/s6/TA_Ch6"
TA:=perijove->$name$

name="/s6/latitude"
lat:=perijove->$name$

name="/s6/longitude"
lon:=perijove->$name$

lon_bound=perijove->/s6/lon_bound
lat_bound=perijove->/s6/lat_bound
nbound=toint(perijove->/s6/nbound)

; name="/PJ"+sprinti("%0.2i",pj)+"/spacecraft longitude"
; lon0:=perijove->$name$

; name="/PJ"+sprinti("%0.2i",pj)+"/spacecraft latitude"
; lat0:=perijove->$name$

; name="/PJ"+sprinti("%0.2i",pj)+"/range"
; range:=perijove->$name$

name="/s6/LZA"
angle:=perijove->$name$

printVarSummary(lon)

lon@_FillValue=-999.9
lat@_FillValue=-999.9

; lon=where(lon.eq."nan",lon@_FillValue,lon)
; lat=where(lat.eq."nan",lat@_FillValue,lat)

; lat=where(lat.lt.60,lat@_FillValue,lat)

; ind_valid:=ind((.not.ismissing(lat)).and. (.not. ismissing(lon)))
; lon:=lon(ind_valid)
; lat:=lat(ind_valid)
; lon0:=lon0(ind_valid)
; lat0:=lat0(ind_valid)
; range:=range(ind_valid)
; angle:=angle(ind_valid)

; TA_ch6:=TA(5,:)
; TA_ch6:=TA_ch6(ind_valid)






wks=gsn_open_wks("png","footprints.pj"+sprinti("%0.2i",pj)+"_ch06")
gsn_define_colormap(wks,"NCV_jet")
; plot=new(2,graphic)

res=True

res@gsnFrame=False
res@gsnDraw=False

;; north polar
res@mpGridPolarLonSpacingF=15.
res@mpGridAndLimbOn=True
res@mpGridLatSpacingF=5
res@mpGridLonSpacingF=15
; res@mpGridLineThicknessF=

res@mpGridLineDashPattern=2
res@mpLandFillColor="transparent"


res@mpProjection      = "LambertEqualArea"
res@mpCenterLatF      = 90
res@mpCenterLonF      = 0

res@mpLimitMode ="Angles"
res@mpLeftAngleF = 30
res@mpRightAngleF= 30
res@mpBottomAngleF= 30
res@mpTopAngleF= 30

map=gsn_csm_map(wks, res)

;; 75N
resmk=True
resmk@txFontColor="black"
resmk@txFontHeightF=0.01
tmlat11=gsn_add_text(wks, map, "60~S~o~N~N", -45, 60, resmk)
tmlat12=gsn_add_text(wks, map, "75~S~o~N~N", -45, 75, resmk)
tmlat13=gsn_add_text(wks, map, "NP", -45, 90, resmk)

tmlon11=gsn_add_text(wks, map, "0~S~o~N~E", 0, 68, resmk)
tmlon12=gsn_add_text(wks, map, "90~S~o~N~E", 90, 66.5, resmk)
tmlon13=gsn_add_text(wks, map, "180~S~o~N~E", 180, 68, resmk)
tmlon14=gsn_add_text(wks, map, "90~S~o~N~W", -90, 66.5, resmk)



; index=getind_latlon2d(lat, lon, 75, 0)
; iscan=index(0,0)
; npix=index(0,1)

respm=True
respm@gsMarkerColor="blue"
respm@gsMarkerIndex=1
respm@gsMarkerSizeF=0.015
mk1=gsn_add_polymarker(wks,map,lon,lat,respm)
printVarSummary(lon_bound)
; respm@gsMarkerColor="red"
; mk2=gsn_add_polymarker(wks,map,lon(iscan,:),lat(iscan,:),respm)

respl=True
respl@gsLineColor="red"
respl@gsMarkerColor="red"
respl@gsMarkerSizeF=0.03
respl@gsMarkerIndex=1
respl@gsLineDashPattern=0
respl@gsLineThicknessF=3


nlon=dimsizes(lon)
pl=new(nlon(0)*nlon(1),graphic)
org=new(nlon(0)*nlon(1),graphic)
ipl=0
do iscan=0,nlon(0),5
    do ipix=0,nlon(1),5
        nb=nbound(iscan,ipix)
        if(cos(3.1415926/180.*angle(iscan,ipix)).gt.0.6) then continue end if
        ; print(iscan+" "+ipix+" "+nb)  
        if (nb.eq.0) then continue end if
        pl(ipl)=gsn_add_polyline(wks, map, lon_bound(iscan,ipix,0:nb-1), lat_bound(iscan,ipix,0:nb-1), respl)
        org(ipl)=gsn_add_polymarker(wks,map,lon(iscan,ipix),lat(iscan,ipix),respl)
        print(lon(iscan,ipix)+" "+lat(iscan,ipix))

        ipl=ipl+1
    end do
end do


resP=True
resP@gsnPanelMainString="Juno/MWR observational geometry, PJ"+sprinti("%0.2i",pj)+", channel 06"
gsn_panel(wks,map,(/1,1/),resP)

end