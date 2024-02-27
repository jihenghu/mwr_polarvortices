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

maxmaps=(/880.,470.,338.,256.,200.,144./)
minmaps=(/760.,410.,314.,244.,188.,138./)
intermaps=(/10.,5.,2.,1.,1.,0.5/)

minus=(/820,440,326,250,194,141/)

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
wks=gsn_open_wks("png", "plot.fig1.Ta_nadir_stepwise")


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

   ftprt:=addfile("../Ta_swath/TA_swath_ch"+sprinti("%0.2i",ch)+"_pj"+sprinti("%0.2i",pj)+".h5","r")

   TA:=ftprt->TA
   lat:=ftprt->latitude
   lon:=ftprt->longitude
   LZA:=ftprt->LZA
   range:=ftprt->juno_range

   TA@_FillValue=-999.9
   LZA@_FillValue=-999.9
   lat@_FillValue=-999.9
   lon@_FillValue=-999.9
   range@_FillValue=-999.9

   lat@units="degree_north"
   lon@units="degree_east"

   lon=where(lon.eq."nan".or.lat.eq."nan".or.TA.eq."nan",lon@_FillValue,lon)
   lat=where(ismissing(lon),lat@_FillValue,lat)
   TA=where(ismissing(lon),TA@_FillValue,TA)
   LZA=where(ismissing(lon),LZA@_FillValue,LZA)
   range=where(ismissing(lon),range@_FillValue,range)
   range=where(range.eq.0,range@_FillValue,range)

   printMinMax(range,0)

   TA@lat2d=lat
   TA@lon2d=lon
   LZA@lat2d=lat
   LZA@lon2d=lon
   
   phi:=cos(asin(sin(LZA*3.14159265/180.)*69911.0/range))
   phi@lat2d=lat
   phi@lon2d=lon








   incident:=ndtooned(LZA)
   ta1d:=ndtooned(TA)
   range:=ndtooned(range)
   lat1d:=ndtooned(lat)
   index:=ind((.not.ismissing(incident)).and.lat1d.gt.70 )

   lat1d:=lat1d(index)
   incident:=incident(index)
   range:=range(index)
   ta1d:=ta1d(index)

   ; spheric_factor:=69911.0/range

   printMinMax(range,0)

   sinmu:=sin(incident*3.14159265/180.)*69911.0/range
   ; sinmu:=sin(incident*3.14159265/180.)/69911.0*range

   ; miu:=sqrt(1-spheric_factor*sin(incident*3.14159265/180.)*spheric_factor*sin(incident*3.14159265/180.))
   miu:=sqrt(1-sinmu*sinmu)

;; -------------------------------------------------------------------------------------------
;;                      RETRIEVE TA NADIR FROM VARIOUS EMISSION ANGLES
;; -------------------------------------------------------------------------------------------

;; STEPWISE REGRESSION : 
;; STEP 1: Linear regression, appiled over [1.0 - 0.6]
;;                model :  Ta_Linear(u)=c0+c1/0.2*(1-u)
;;                report: C0, c1.
    index:=ind(miu.gt.0.6)
    miufit:=miu(index)
    tafit:=ta1d(index)

    reg=regline_stats(miufit, tafit)
    intercept=reg@yintercept

    c0=reg+intercept
    c1=c0-(reg*0.8+intercept)

;; STEP 1.5: Extract the shape function: Shape(u)=Ta(u)/Ta_Linear(u)
    Ta_linear:=miu*reg+intercept
    shape:=ta1d/Ta_linear    

;; STEP 2: Quadratical-Logistic model, over [0.8 - 0.0], extrapolate to [1.0 - 0.0]
;;                        model: Shape(u)=1/[1+exp(-(a(u+b))^2)]

    index06:=ind(miu.lt.1.0.and.(.not.ismissing(shape)).and. shape.gt. 0.5.and. shape .lt. 1.1 )

    shape_logistic:=shape(index06)
    miu_logistic:=miu(index06)

    ;; to regress in an uniform weighted sample space, conduct beam averaged sampling
    miu_beam:=fspan(0.01,0.99,50)
    shape_beam:=new(dimsizes(miu_beam),double,-999.9)
    do ibeam=0,dimsizes(miu_beam)-1
        indbm:=ind(miu_logistic.gt. (miu_beam(ibeam)-0.01) .and. miu_logistic.le. (miu_beam(ibeam)+0.01))
        if(ismissing(indbm(0))) then continue end if
        shape_beam(ibeam)=avg(shape_logistic(indbm))
    end do

    ;use only 0~0.8 to regress
    shape_beam:=shape_beam(3:40)
    miu_beam:=miu_beam(3:40)
    shape_beam=where(shape_beam.ge.1,shape_beam@_FillValue, shape_beam)

    indvalid:=ind(.not.ismissing(shape_beam))
    shape_beam:=shape_beam(indvalid)
    miu_beam  :=miu_beam  (indvalid)

    ;;; linearize the nonlinear shape   =>      a(u+b)= sqrt[-ln(1/y -1)]             
    shape_beam=sqrt(log(1.0/shape_beam -1.0)*-1.0)
    logistic=regline_stats(miu_beam,shape_beam)

    ;; extract the shape coeff. in a quadratic logistic equation =>   y=1/(1+exp(-(a(u+b))^2))
    ;;  
    a=logistic
    b=logistic@yintercept/a

    ; print(sprintf("%5.2f",c0)+" "+sprintf("%5.2f",c1)+" "+ sprintf("%5.3f",a)+" "+sprintf("%5.3f",b))

;; INFER a Ta nadir (c0)
;;  find a c0 to with which a the present points satisfy the shape function decided with [a, b] and limb darkening c1.
    ; Ta(u)=[c0+c1/0.2(1-u)]/[1+exp(-(a(u+b))^2)] => Ta_nadir= {Ta(u)/[1+exp(-(a(u+b))^2)]}-5C1(1-u)
    ; Ta_nadir 
    ; miu*reg+intercept
    TA=TA*(1+exp(-1* (a*(phi+b))^2)) - phi*reg
    TA=reg+TA

    ; copy_VarCoords(TA, Ta_nadir)
    ; TA:=Ta_nadir
;;; ---------------------------------------------------------------------------------------------
;;; PLOT TA Nadir Polar region    
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

    printMinMax(TM, 0)

    ; copy_VarCoords(TA, TM)
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
    res@cnLevels=(/0.0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0/)*20
    res@cnLevelSpacingF=0.05
    res@lbLabelStride=2
    res@cnFillPalette:=read_colormap_file("CET-L04")
    ; res@cnLabelBarEndStyle="ExcludeOuterBoxes"

    phi=LZA-acos(phi)*180./3.141592

    plot((pj-51)*4+3)=gsn_csm_contour_map(wks, phi, res)
  
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
    lbres@lbTitleString="Nadir T~B~a~N~~S~'~N~ (K)"
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
    ; labels                     := (/"0","","0.2","","0.4","","0.6","","0.8","","1.0"/)  
    ; gsn_labelbar_ndc (wks,dimsizes(labels)-1,labels,0.743,0.05,lbres)
    gsn_labelbar_ndc (wks,dimsizes(labels)-1,levels_mu,0.743,0.05,lbres)

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