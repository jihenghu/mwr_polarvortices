begin
; pj=53
ftprt=addfile("./TA_swath_ch"+sprinti("%0.2i",ch)+"_pj"+sprinti("%0.2i",pj)+".h5","r")

TA=ftprt->TA
lat=ftprt->latitude
lon=ftprt->longitude
LZA=ftprt->LZA

range=ftprt->juno_range
lon0=ftprt->juno_longitude
lat0=ftprt->juno_latitude

TA@_FillValue=-999.9
LZA@_FillValue=-999.9
lat@_FillValue=-999.9
lon@_FillValue=-999.9


range@_FillValue=-999.9
lat0@_FillValue=-999.9
lon0@_FillValue=-999.9


lat@units="degree_north"
lon@units="degree_east"

lon=where(lon.eq."nan".or.lat.eq."nan".or.TA.lt.5,lon@_FillValue,lon)
lat=where(ismissing(lon),lat@_FillValue,lat)
TA=where(ismissing(lon),TA@_FillValue,TA)
LZA=where(ismissing(lon),LZA@_FillValue,LZA)


TA@lat2d=lat
TA@lon2d=lon
LZA@lat2d=lat
LZA@lon2d=lon

cosine=LZA
cosine=cos(LZA*3.14/180.)

plot=new(3,graphic)
wks:=gsn_open_wks("png", "TA"+sprinti("%0.2i",ch)+"_PJ"+sprinti("%0.2i",pj))
gsn_define_colormap(wks, "CET-D01A")
res=True
res@gsnFrame=False
res@gsnDraw=False

res@cnFillOn=True
; res@cnFillMode="CellFill"
res@cnFillMode="AreaFill"
res@cnLinesOn = False
res@lbBoxLinesOn                = False
res@lbLabelBarOn                = True
res@lbBoxEndCapStyle="TriangleBothEnds"
res@lbOrientation="vertical"
res@pmLabelBarHeightF=0.6
res@pmLabelBarWidthF=0.12

res@lbLabelAutoStride=False
res@lbLabelStride=4
if(ch.eq.6) then res@lbLabelStride=10 end if
; res@pmLabelBarHeightF=0.1
; res@pmLabelBarWidthF=0.55
res@lbTitleOn=False
; res@lbTitleFontHeightF=0.015
; res@lbTitleString="Anntena Temperature (K)"


res@gsnAddCyclic=False

res@mpFillOn=True
;; north polar
res@mpGridPolarLonSpacingF=15.
res@mpGridAndLimbOn=True
res@mpGridLatSpacingF=5
res@mpGridLonSpacingF=15

res@mpGridLineDashPattern=2

res@mpProjection      = "LambertEqualArea"
res@mpCenterLatF      = 90
res@mpCenterLonF      = 0

res@mpLimitMode ="Angles"
res@mpLeftAngleF = 20
res@mpRightAngleF= 20
res@mpBottomAngleF= 20
res@mpTopAngleF= 20
res@mpLandFillColor="transparent"
res@mpGeophysicalLineColor="transparent"

maxmaps=(/880.,470.,340.,253.,198.,144./)
minmaps=(/720.,410.,320.,227.,182.,138./)
intermaps=(/5.,2.,0.5,0.5,0.5,0.1/)

minus=(/800,440,320,240,190,141/)


maxlev=maxmaps(ch-1)-minus(ch-1)
minlev=minmaps(ch-1)-minus(ch-1)
lintrv=intermaps(ch-1)

;; antenna temp
res@cnLevelSelectionMode="ManualLevels"
res@cnMaxLevelValF=maxlev
res@cnMinLevelValF=minlev
res@cnLevelSpacingF=lintrv

res@trGridType= "TriangularMesh"

res@cnMissingValFillColor="white"
res@gsnLeftString=""  

res@gsnLeftString="TA anomaly (K)" 
res@gsnRightString="ref: ~F8~m" +"=0.8"

res@lbTitleString="Antenna Temperature (K)" 
TM=TA
TM=TA-minus(ch-1)
plot(0)=gsn_csm_contour_map(wks, TM, res)
res@gsnRightString=""  
;;; emission angle
; res@cnLevelSelectionMode="AutomaticLevels"
res@cnMinLevelValF=0.05
res@cnMaxLevelValF=0.95
res@cnLevelSpacingF=0.05
res@lbLabelStride=2


res@cnFillPalette=read_colormap_file("CET-L04")
res@gsnLeftString="~F8~m"  
res@lbTitleString="~F8~m"
plot(1)=gsn_csm_contour_map(wks, cosine, res)


;; grid label
resmk=True
resmk@txFontColor="black"
resmk@txFontHeightF=0.015
tmlat11=gsn_add_text(wks, plot(0), "65~S~o~N~N", -45, 65, resmk)
tmlat12=gsn_add_text(wks, plot(0), "75~S~o~N~N", -45, 75, resmk)
tmlat13=gsn_add_text(wks, plot(0), "85~S~o~N~N", -45, 85, resmk)
tmlon11=gsn_add_text(wks, plot(0), "0~S~o~N~E", 0, 72, resmk)
tmlon12=gsn_add_text(wks, plot(0), "90~S~o~N~E", 90, 72, resmk)
tmlon13=gsn_add_text(wks, plot(0), "180~S~o~N~E", 180, 72, resmk)
tmlon14=gsn_add_text(wks, plot(0), "90~S~o~N~W", -90, 72, resmk)

tmlat21=gsn_add_text(wks, plot(1), "65~S~o~N~N", -45, 65, resmk)
tmlat22=gsn_add_text(wks, plot(1), "75~S~o~N~N", -45, 75, resmk)
tmlat23=gsn_add_text(wks, plot(1), "85~S~o~N~N", -45, 85, resmk)
tmlon21=gsn_add_text(wks, plot(1), "0~S~o~N~E", 0, 72, resmk)
tmlon22=gsn_add_text(wks, plot(1), "90~S~o~N~E", 90, 72, resmk)
tmlon23=gsn_add_text(wks, plot(1), "180~S~o~N~E", 180, 72, resmk)
tmlon24=gsn_add_text(wks, plot(1), "90~S~o~N~W", -90, 72, resmk)

;; limb darkening

resxy=True
resxy@gsnFrame=False
resxy@gsnDraw=False
resxy@xyMarkerColor="transparent"
resxy@xyMarkLineModes="Markers"
resxy@xyMarker=1

resxy@tiXAxisString="~F8~m"
resxy@tiYAxisString="Ta (K)"
resxy@gsnLeftString="Limb darkening (Lat>70~S~o~N~)"
resxy@trXReverse=True
resxy@vpHeightF=0.6
resxy@vpWidthF=0.75


incident=ndtooned(LZA)
ta1d=ndtooned(TA)
lat1d=ndtooned(lat)
index=ind((.not.ismissing(incident)).and.lat1d.gt.70 )
; index=ind((.not.ismissing(incident)).and.lat1d.gt.70 .and.incident.lt.40)

miu=cos(incident(index)*3.14159265/180.)
ta1d:=ta1d(index)

plot(2)=gsn_csm_xy(wks,miu,ta1d,resxy)




nlevel=toint((maxmaps(ch-1)-minmaps(ch-1))/lintrv)+1
levels=fspan(minmaps(ch-1),maxmaps(ch-1),nlevel)
plm=new(nlevel+1,graphic)

gsres=True
gsres@gsMarkerIndex=1

; cmap=read_colormap_file("NCV_jet")
cmap=gsn_retrieve_colormap(wks)

do ilevel=0,nlevel
    if (ilevel.eq.0) then
        index:=ind(ta1d.ge.10 .and. ta1d.lt.levels(0))
        half=0.5*(10+levels(0))      
    end if 

    if (ilevel.eq.nlevel) then 
        index:=ind(ta1d.ge.levels(nlevel-1))
        ; half=levels(nlevel-1)+20

        half=0.5*(levels(nlevel-1) +levels(nlevel-2))
    end if   

    if (ilevel.lt.nlevel.and.ilevel.gt.0) then 
        index:=ind(ta1d.ge.levels(ilevel-1) .and. ta1d.lt.levels(ilevel))
        half=0.5*(levels(ilevel-1) +levels(ilevel))
    end if

    if(ismissing(index(0))) then continue end if

    y:= ta1d(index)
    x:= miu(index)
    icol = get_color_index("CET-D01A",levels,half)

    gsres@gsMarkerColor=cmap(icol,:)
    plm(ilevel)=gsn_add_polymarker(wks,plot(2),x,y,gsres)
end do

resP=True
resP@gsnPanelMainString="Perijove "+sprinti("%0.2i",pj) + " Channel "+sprinti("%0.2i",ch)
resP@gsnPanelMainFontHeightF=0.01
resP@gsnPanelTop=1.
resP@gsnPanelYWhiteSpacePercent=2

gsn_panel(wks,plot,(/3,1/),resP)

end