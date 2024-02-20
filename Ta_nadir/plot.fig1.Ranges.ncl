begin

res=True
res@gsnFrame=False
res@gsnDraw=False

res@cnFillOn=True
res@cnFillMode="AreaFill"
res@cnLinesOn = False
res@cnLineLabelsOn = False
res@lbBoxLinesOn                = False
res@lbLabelBarOn                = False ;True;

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

plot=new(4,graphic)
tmlat1=new(4,graphic)
tmlat2=new(4,graphic)
tmlon1=new(4,graphic)
tmlon2=new(4,graphic)
tmlon3=new(4,graphic)
tmlon4=new(4,graphic)


PanelFigureStringsBackgroundFillColor="Transparent"
mucapthick=3


;; ------------------- PNG -----------------------------------

wks=gsn_open_wks("png", "plot.fig1._range")


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
do pj=51,54
    ch=6

    ftprt:=addfile("../Ta_swath/TA_swath_ch"+sprinti("%0.2i",ch)+"_pj"+sprinti("%0.2i",pj)+".h5","r")

    TA:=ftprt->TA
    lat:=ftprt->latitude
    lon:=ftprt->longitude
    LZA:=ftprt->LZA
    range:=ftprt->juno_range

    TA@_FillValue=-999.9
    LZA@_FillValue=-999.9
    range@_FillValue=-999.9
    lat@_FillValue=-999.9
    lon@_FillValue=-999.9

    lat@units="degree_north"
    lon@units="degree_east"

    lon=where(lon.eq."nan".or.lat.eq."nan".or.TA.lt.5,lon@_FillValue,lon)
    lat=where(ismissing(lon),lat@_FillValue,lat)
    TA=where(ismissing(lon),TA@_FillValue,TA)
    LZA=where(ismissing(lon),LZA@_FillValue,LZA)
    range=where(ismissing(lon),range@_FillValue,range)-69911.000  ;; KM
    range=range/1000.
    printMinMax(range, 0)

    TA@lat2d=lat
    TA@lon2d=lon
    LZA@lat2d=lat
    LZA@lon2d=lon
    
    range@lat2d=lat
    range@lon2d=lon


;;; emission angle
    res@cnLevelSelectionMode="ExplicitLevels"
    res@cnLevels=(/4,8,12,16,20,24,28,32,36,40/)
    ; res@cnLevelSpacingF=0.05
    ; res@lbLabelStride=2
    res@cnFillPalette:=read_colormap_file("CET-L04")
    ; ; res@cnLabelBarEndStyle="ExcludeOuterBoxes"

    plot(pj-51)=gsn_csm_contour_map(wks, range, res)

;;; Grid labels
    tmlat1((pj-51))=gsn_add_text(wks,  plot((pj-51)), "70~S~o~N~N", -45, 70, resmk)
    tmlat2((pj-51))=gsn_add_text(wks,  plot((pj-51)), "80~S~o~N~N", -45, 80, resmk)

    tmlon1((pj-51))=gsn_add_text(wks,  plot((pj-51)), "0~S~o~N~E", 0, 72, resmk)
    tmlon2((pj-51))=gsn_add_text(wks,  plot((pj-51)), "90~S~o~N~E", 90, 74, resmk)
    tmlon3((pj-51))=gsn_add_text(wks,  plot((pj-51)), "180~S~o~N~E", 180, 72, resmk)
    tmlon4((pj-51))=gsn_add_text(wks,  plot((pj-51)), "90~S~o~N~W", -90, 74, resmk)

end do   



;; Panels 
    resP=True
    resP@gsnPanelBottom=0.03
    resP@gsnPanelLabelBar=True
    resP@lbBoxEndCapStyle="TriangleBothEnds"
    resP@lbLabelFontHeightF=0.01
    resP@lbTitleOn=True
    resP@lbTitleFontHeightF=0.015
    resP@lbTitleString="Altitude [10~S~3~N~ km]"
    resP@lbLabelStride=1
    resP@pmLabelBarOrthogonalPosF=-0.03
    gsn_panel(wks,plot,(/4,1/),resP)

end