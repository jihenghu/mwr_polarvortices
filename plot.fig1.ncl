begin

res=True
res@gsnFrame=False
res@gsnDraw=False

res@cnFillOn=True
res@cnFillMode="AreaFill"
res@cnLinesOn = False
res@cnLineLabelsOn = False
res@lbBoxLinesOn                = False
res@lbLabelBarOn                = False ;True

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

; maxmaps=(/880.,470.,338.,253.,198.,144./)
; minmaps=(/760.,410.,314.,229.,182.,136./)
; intermaps=(/10.,5.,2.,2.,1.,0.5/)

; minus=(/820,440,326,241,190,140/)


maxmaps=(/880.,470.,338.,253.,198.,120./)
minmaps=(/760.,410.,314.,229.,182.,80./)
intermaps=(/10.,5.,2.,2.,1.,0.5/)

minus=(/820,440,326,241,190,100/)

plot=new(16,graphic)
tmlat1=new(16,graphic)
tmlat2=new(16,graphic)
tmlon1=new(16,graphic)
tmlon2=new(16,graphic)
tmlon3=new(16,graphic)
tmlon4=new(16,graphic)

PanelFigureStringsBackgroundFillColor="Transparent"
mucapthick=3


;; ------------------- PNG -----------------------------------
wks=gsn_open_wks("png", "fig1-limb")


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
   do ch=4,6

    ftprt:=addfile("Ta_swath/TA_swath_ch"+sprinti("%0.2i",ch)+"_pj"+sprinti("%0.2i",pj)+".h5","r")

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

;; antenna temp
    maxlev=maxmaps(ch-1)-minus(ch-1)
    minlev=minmaps(ch-1)-minus(ch-1)
    lintrv=intermaps(ch-1)   

    res@cnLevelSelectionMode="ManualLevels"
    res@cnMaxLevelValF=maxlev
    res@cnMinLevelValF=minlev
    res@cnLevelSpacingF=lintrv

    res@cnLabelBarEndStyle="IncludeOuterBoxes"

    if(ch.eq.6) then res@lbLabelStride=10 end if
    res@cnFillPalette:=read_colormap_file("CET-D01A")
    ; res@cnFillPalette:=read_colormap_file("BlueDarkRed18")

    TM:=TA
    TM=TA-minus(ch-1)
    plot((ch-4)+(pj-51)*4)=gsn_csm_contour_map(wks, TM, res)

    if (ch.eq.4) then 
        pm=plot((ch-4)+(pj-51)*4)
        getvalues pm@contour
        "cnLevels"               : levels_ch4
        "cnFillColors"           : colors_ch4
        end getvalues
    end if

    if (ch.eq.5) then 
        pm=plot((ch-4)+(pj-51)*4)
        getvalues pm@contour
        "cnLevels"               : levels_ch5
        "cnFillColors"           : colors_ch5
        end getvalues
    end if

    if (ch.eq.6) then 
        pm=plot((ch-4)+(pj-51)*4)
        getvalues pm@contour
        "cnLevels"               : levels_ch6
        "cnFillColors"           : colors_ch6
        end getvalues
    end if

;;; grid labels
    ; tmlat1((pj-51)*4+(ch-4))=gsn_add_text(wks, plot((pj-51)*4+(ch-4)), "70~S~o~N~N", -45, 70, resmk)
    ; tmlat2((pj-51)*4+(ch-4))=gsn_add_text(wks, plot((pj-51)*4+(ch-4)), "80~S~o~N~N", -45, 80, resmk)
    ; tmlon1((pj-51)*4+(ch-4))=gsn_add_text(wks, plot((pj-51)*4+(ch-4)), "0~S~o~N~E", 0, 72, resmk)
    ; tmlon2((pj-51)*4+(ch-4))=gsn_add_text(wks, plot((pj-51)*4+(ch-4)), "90~S~o~N~E", 90, 74, resmk)
    ; tmlon3((pj-51)*4+(ch-4))=gsn_add_text(wks, plot((pj-51)*4+(ch-4)), "180~S~o~N~E", 180, 72, resmk)
    ; tmlon4((pj-51)*4+(ch-4))=gsn_add_text(wks, plot((pj-51)*4+(ch-4)), "90~S~o~N~W", -90, 74, resmk)

;;; emission angle
    res@cnLevelSelectionMode="ExplicitLevels"
    res@cnLevels=(/0.0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0/)
    res@cnLevelSpacingF=0.05
    res@lbLabelStride=2
    res@cnFillPalette:=read_colormap_file("CET-L04")
    ; res@cnLabelBarEndStyle="ExcludeOuterBoxes"

    plot((pj-51)*4+3)=gsn_csm_contour_map(wks, cosine, res)
  
    pm=plot(3)
    getvalues pm@contour
        "cnLevels"               : levels_mu
        "cnFillColors"           : colors_mu
    end getvalues

;;; Grid labels
    tmlat1((pj-51)*4+3)=gsn_add_text(wks,  plot((pj-51)*4+3), "70~S~o~N~N", -45, 70, resmk)
    tmlat2((pj-51)*4+3)=gsn_add_text(wks,  plot((pj-51)*4+3), "80~S~o~N~N", -45, 80, resmk)

    tmlon1((pj-51)*4+3)=gsn_add_text(wks,  plot((pj-51)*4+3), "0~S~o~N~E", 0, 72, resmk)
    tmlon2((pj-51)*4+3)=gsn_add_text(wks,  plot((pj-51)*4+3), "90~S~o~N~E", 90, 74, resmk)
    tmlon3((pj-51)*4+3)=gsn_add_text(wks,  plot((pj-51)*4+3), "180~S~o~N~E", 180, 72, resmk)
    tmlon4((pj-51)*4+3)=gsn_add_text(wks,  plot((pj-51)*4+3), "90~S~o~N~W", -90, 74, resmk)

    end do   
end do   

; manually add Row titles  
    Ytires=True
    Ytires@txFontHeightF=0.016
    Ytires@txAngleF=90.

    gsn_text_ndc(wks, "PJ 51", 0.05, 0.86, Ytires)
    gsn_text_ndc(wks, "PJ 52", 0.05, 0.635, Ytires)
    gsn_text_ndc(wks, "PJ 53", 0.05, 0.41, Ytires)
    gsn_text_ndc(wks, "PJ 54", 0.05, 0.185, Ytires)

;  manually add Column titles  
    Xtires=True
    Xtires@txFontHeightF=0.016
    Xtires@txAngleF=0.

    gsn_text_ndc(wks, "5.2 GHz", 0.18, 0.985, Xtires)
    gsn_text_ndc(wks, "10 GHz", 0.41, 0.985, Xtires)
    gsn_text_ndc(wks, "22 GHz", 0.63, 0.985, Xtires)
    Xtires@txFontHeightF=0.012
    gsn_text_ndc(wks, minus(3)+"K", 0.18+0.08, 0.984, Xtires)
    gsn_text_ndc(wks, minus(4)+"K", 0.41+0.075, 0.984, Xtires)
    gsn_text_ndc(wks, minus(5)+"K", 0.63+0.08, 0.984, Xtires)
  
    Xtires@txFontHeightF=0.016
    Xtires@txFontThicknessF=mucapthick
    gsn_text_ndc(wks, "~F8~m", 0.85, 0.985, Xtires)

;; manually ColorBars 
    lbres = True
    lbres@lbPerimOn            = False               ; no label bar box
    lbres@lbOrientation        = "Horizontal"        ; orientation
    lbres@vpWidthF             = 0.22                 ; size
    lbres@vpHeightF            = 0.05
    lbres@lbLabelFontHeightF   = 0.012               ; label font height
    lbres@lbBoxEndCapStyle="TriangleBothEnds"
    lbres@lbBoxLinesOn=False
    lbres@lbMonoFillPattern    = True                ; fill sold
    lbres@lbTitleOn=True
    lbres@lbTitleString="T~B~a~N~~S~'~N~ (K)"
    lbres@lbTitleFontHeightF=0.014
    lbres@lbLabelAlignment="InteriorEdges"
    ;; ----------------------
    lbres@lbFillColors         = colors_ch4      ; must be RGB triplets
    labels                     = "" + levels_ch4    
    gsn_labelbar_ndc (wks,dimsizes(labels)+1,labels,0.063,0.05,lbres)
    ;; ----------------------
    lbres@lbFillColors         := colors_ch5      ; must be RGB triplets
    labels                     := "" + levels_ch5    
    gsn_labelbar_ndc (wks,dimsizes(labels)+1,labels,0.291,0.05,lbres)
    ;; ----------------------
    lbres@lbFillColors         := colors_ch6      ; must be RGB triplets
    labels                     := "" + levels_ch6    
    gsn_labelbar_ndc (wks,dimsizes(labels)+1,labels,0.517,0.05,lbres)
     ;; ----------------------
    lbres@lbTitleString="~F8~m"
    lbres@lbTitleFontThicknessF=mucapthick
    lbres@lbFillColors         := colors_mu(1:)      ; must be RGB triplets
    lbres@lbLabelAlignment="ExternalEdges"
    lbres@lbBoxEndCapStyle="RectangleEnds"
    lbres@lbLabelAutoStride=False
    labels                     := (/"0","","0.2","","0.4","","0.6","","0.8","","1.0"/)  
    gsn_labelbar_ndc (wks,dimsizes(labels)-1,labels,0.743,0.05,lbres)

;; Panels 
    resP=True
    resP@gsnPanelMainFontHeightF=0.01
    resP@gsnPanelTop=0.97
    resP@gsnPanelBottom=0.07
    resP@gsnPanelLeft=0.03

    resP@gsnPanelFigureStrings=(/"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P"/)
    resP@gsnPanelFigureStringsBackgroundFillColor=PanelFigureStringsBackgroundFillColor

    resP@gsnPanelFigureStringsPerimOn=False
    resP@gsnPanelFigureStringsJust="TopRight"

    ; drawNDCGrid(wks)
    gsn_panel(wks,plot,(/4,4/),resP)

end