
; this script is aimed at ploting a curve of Ta versus cosine of emission angle
; linear regression of Ta between 1-0.6
; report c0, c1 

begin

resxy=True
resxy@gsnFrame=False
resxy@gsnDraw=False
resxy@xyMarkerColor="transparent"
resxy@xyMarkLineModes="Markers"
resxy@xyMarker=1

; resxy@tiXAxisString="~F8~m"
; resxy@tiYAxisString="Ta (K)"
resxy@gsnLeftString=""
resxy@trXReverse=True
resxy@vpHeightF=0.6
resxy@vpWidthF=0.75

resxy@tmXBLabelFontHeightF=0.05
resxy@tmYLLabelFontHeightF=0.05

resxy@tmYLLabelStride=2
; resxy@tmXBLabelStride=2

PanelFigureStringsBackgroundFillColor="Transparent"
mucapthick=3



;; ------------------- PNG -----------------------------------
wks=gsn_open_wks("png", "fig3")

;;;; ----------------- PDF ----------------------------------------
; wks=gsn_open_wks("pdf", "fig3")
; PanelFigureStringsBackgroundFillColor="white"
; mucapthick=1

;;;; ----------------- Black Background ----------------------------------------
; wks=gsn_open_wks("png", "fig3-Dark")
; setvalues wks
; "wkForegroundColor" : (/1.,1.,1./)  ; white
; "wkBackgroundColor" : (/0.,0.,0./)  ; black
; end setvalues
; resmk@txFontColor="white"

;;;; plot-->>>
plot=new(20,graphic)
latlevels=(/70,72,74,76,78,80,82,84,86,88,90/)
VALUE=      (/71,73,75,77,79,81,83,85,87,89/)
nlevel=dimsizes(VALUE)


Ymax=(/500,360,270,210,150/)
Ymin=(/160,120,90,70,60/)

plm=new(4*5*(nlevel),graphic)
cmap=read_colormap_file("CET-L04")
; cmap=read_colormap_file("NCV_jet")

im=0

do pj=51,54
   do ch=2,6

    ftprt:=addfile("./TA_swath_ch"+sprinti("%0.2i",ch)+"_pj"+sprinti("%0.2i",pj)+".h5","r")

    TA:=ftprt->TA
    lat:=ftprt->latitude
    lon:=ftprt->longitude
    LZA:=ftprt->LZA

    TA@_FillValue=-999.9
    LZA@_FillValue=-999.9
    lat@_FillValue=-999.9
    lon@_FillValue=-999.9

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

    cosine:=LZA
    cosine=cos(LZA*3.14/180.)

    incident:=ndtooned(LZA)
    ta1d:=ndtooned(TA)
    lat1d:=ndtooned(lat)
    index:=ind((.not.ismissing(incident)).and.lat1d.gt.min(VALUE) )

    lat1d:=lat1d(index)
    miu:=cos(incident(index)*3.14159265/180.)
    ta1d:=ta1d(index)
    
    resxy@trYMaxF=Ymax(ch-2)
    resxy@trYMinF=Ymin(ch-2)

    plot((pj-51)*5+ch-2)=gsn_csm_xy(wks,miu,ta1d,resxy)

    gsres=True
    gsres@gsMarkerIndex=1
    ; gsres@gsMarkerOpacityF=0.3

;   draw_color_palette(wks, cmap, 0)

    do ilevel=0,nlevel-1
        index:=ind(lat1d.gt.latlevels(ilevel) .and. lat1d.le.latlevels(ilevel+1))
   
        if(ismissing(index(0))) then continue end if
        y:= ta1d(index)
        x:= miu(index)

        icol = get_color_index("CET-D01A",latlevels(1:nlevel),VALUE(ilevel))
        gsres@gsMarkerColor=cmap(icol,:)        
        plm(im)=gsn_add_polymarker(wks,plot((pj-51)*5+ch-2),x,y,gsres)
        im=im+1
    end do
end do
end do

    ; manually add Row titles  
    Ytires=True
    Ytires@txFontHeightF=0.014
    Ytires@txAngleF=90.

    gsn_text_ndc(wks, "PJ51 T~B~a~N~~S~'~N~ (K)", 0.015, 0.735, Ytires)
    gsn_text_ndc(wks, "PJ52 T~B~a~N~~S~'~N~ (K)", 0.015, 0.585, Ytires)
    gsn_text_ndc(wks, "PJ53 T~B~a~N~~S~'~N~ (K)", 0.015, 0.435, Ytires)
    gsn_text_ndc(wks, "PJ54 T~B~a~N~~S~'~N~ (K)", 0.015, 0.285, Ytires)

    Xtires=True
    Xtires@txFontHeightF=0.014
    Xtires@txAngleF=0.

    gsn_text_ndc(wks, "1.25 GHz", 0.15, 0.815, Xtires)
    gsn_text_ndc(wks, "2.6 GHz", 0.34, 0.815, Xtires)
    gsn_text_ndc(wks, "5.2 GHz", 0.53, 0.815, Xtires)
    gsn_text_ndc(wks, "10 GHz", 0.72, 0.815, Xtires)
    gsn_text_ndc(wks, "22 GHz", 0.91, 0.815, Xtires)

    Xtires@txFontThicknessF=mucapthick
    gsn_text_ndc(wks, "~F8~m~F21~", 0.15, 0.185, Xtires)
    gsn_text_ndc(wks, "~F8~m~F21~", 0.34, 0.185, Xtires)
    gsn_text_ndc(wks, "~F8~m~F21~", 0.53, 0.185, Xtires)
    gsn_text_ndc(wks, "~F8~m~F21~", 0.72, 0.185, Xtires)
    gsn_text_ndc(wks, "~F8~m~F21~", 0.91, 0.185, Xtires)


    ;; manually ColorBars 
    lbres = True
    lbres@lbPerimOn            = False               ; no label bar box
    lbres@lbOrientation        = "Horizontal"        ; orientation
    lbres@vpWidthF             = 0.4                 ; size
    lbres@vpHeightF            = 0.06
    lbres@lbLabelFontHeightF   = 0.012               ; label font height
    lbres@lbBoxEndCapStyle="TriangleBothEnds"
    lbres@lbBoxLinesOn=False
    lbres@lbMonoFillPattern    = True                ; fill sold
    lbres@lbTitleOn=True

    lbres@lbTitleFontHeightF=0.014
    lbres@lbLabelAlignment="InteriorEdges"
    ;; ----------------------

    ; gsn_define_colormap(wks, "CET-D01A")
    lbres@lbTitleString="Planetocentric Latitude (~S~o~N~N)"
    lbres@lbTitleFontThicknessF=mucapthick
    lbres@lbFillColors         :=cmap(get_color_index("CET-D01A",latlevels,VALUE),:)    ; must be RGB triplets
    lbres@lbLabelAlignment="ExternalEdges"
    lbres@lbBoxEndCapStyle="RectangleEnds"
    lbres@lbLabelAutoStride=False
    lbres@lbLabelStride=2
    labels                     := latlevels+"~S~o"
    gsn_labelbar_ndc (wks,dimsizes(labels)-1,labels,0.32,0.16,lbres)

;; Panels 
    resP=True
    resP@gsnPanelMainFontHeightF=0.01
    ; resP@gsnPanelTop=0.97
    ; resP@gsnPanelBottom=0.07
    resP@gsnPanelLeft=0.035

    resP@gsnPanelFigureStrings=(/"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T"/)
    resP@gsnPanelFigureStringsBackgroundFillColor=PanelFigureStringsBackgroundFillColor
    resP@gsnPanelYWhiteSpacePercent=2
    resP@gsnPanelFigureStringsPerimOn=False
    resP@gsnPanelFigureStringsJust="BottomLeft"


    drawNDCGrid(wks)
    gsn_panel(wks,plot,(/4,5/),resP)

end