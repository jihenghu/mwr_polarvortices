begin

res=True
res@gsnFrame=False
res@gsnDraw=False

res@cnFillOn=True
res@cnFillMode="AreaFill"
res@cnLinesOn = False
res@cnLineLabelsOn = False
res@lbBoxLinesOn                = False
res@lbLabelBarOn                = True; False ;

res@gsnAddCyclic=False

;;; MAPS
res@mpFillOn=True
;; north polar
res@mpGridPolarLonSpacingF=15.
res@mpGridAndLimbOn=True
res@mpGridLatSpacingF=5
res@mpGridLonSpacingF=15

res@mpGridLineDashPattern=14

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

;; cn
res@trGridType= "TriangularMesh"
res@cnMissingValFillColor="white"

res@gsnLeftString=""  
res@gsnRightString=""  

resmk=True
resmk@txFontColor="Black"
resmk@txFontHeightF=0.025
resmk@txFontThicknessF=3



;; ------------------ PNG -----------------------------------
wks=gsn_open_wks("png", "residuals_zz")


;;;; ----------------- PDF ----------------------------------------
; wks=gsn_open_wks("pdf", "fig1")
; PanelFigureStringsBackgroundFillColor="white"
; mucapthick=1

;;;; ----------------- Black Background ----------------------------------------
; wks=gsn_open_wks("png", "fig1-Dark")
; setvalues wks
; "wkForegroundColor" : (/1.,1.,1./)  ; white
; "wkBackgroundColor" : (/0.,0.,0./)  ; black
; end setvalues
; resmk@txFontColor="white"

;;;; plot-->>>
    pj=51
    ch=6

    ftprt:=addfile("TA_swath_ch"+sprinti("%0.2i",ch)+"_pj"+sprinti("%0.2i",pj)+".h5","r")

    ; TA:=ftprt->TA
    ; lat:=ftprt->latitude
    ; lon:=ftprt->longitude
    ; LZA:=ftprt->LZA


    lat=ftprt->ZZ_lat
    lon=ftprt->ZZ_lon
    TA=ftprt->ZZ_residual

    ; TA@long_name=""Residue CH06 PJ51" CH06 PJ51"
    res@gsnLeftString="T~B~b~N~ Residual CH06 PJ51"
    res@lbTitleOn=True
    res@lbTitleString="T~B~b~N~ Residual (K)"


    TA@_FillValue=-999.9
    ; LZA@_FillValue=-999.9
    lat@_FillValue=-999.9
    lon@_FillValue=-999.9

    lat@units="degree_north"
    lon@units="degree_east"

    lon=where(lon.eq."nan".or.lat.eq."nan".or.lat.lt.60,lon@_FillValue,lon)
    lat=where(ismissing(lon),lat@_FillValue,lat)
    TA=where(ismissing(lon),TA@_FillValue,TA)
    ; LZA=where(ismissing(lon),LZA@_FillValue,LZA)

    TA@lat2d=lat
    TA@lon2d=lon
    ; LZA@lat2d=lat
    ; LZA@lon2d=lon


;; antenna temp

    res@cnLevelSelectionMode="ManualLevels"
    res@cnMaxLevelValF=3
    res@cnMinLevelValF=-3
    res@cnLevelSpacingF=0.5

    ; res@cnLabelBarEndStyle="IncludeOuterBoxes"

    res@cnFillPalette:=read_colormap_file("CET-D01A")

    ; TM:=TA
    ; TM=TA-minus(ch-1)
    plot=gsn_csm_contour_map(wks, TA, res)


;;; Grid labels
    tmlat1=gsn_add_text(wks,  plot, "70~S~o~N~N", -45, 70, resmk)
    tmlat2=gsn_add_text(wks,  plot, "80~S~o~N~N", -45, 80, resmk)

    tmlon1=gsn_add_text(wks,  plot, "0~S~o~N~E", 0, 72, resmk)
    tmlon2=gsn_add_text(wks,  plot, "90~S~o~N~E", 90, 74, resmk)
    tmlon3=gsn_add_text(wks,  plot, "180~S~o~N~E", 180, 72, resmk)
    tmlon4=gsn_add_text(wks,  plot, "90~S~o~N~W", -90, 74, resmk)


draw(plot)
frame(wks)

end