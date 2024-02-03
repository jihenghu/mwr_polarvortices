
; this script is aimed at ploting a curve of Ta versus cosine of emission angle
; linear regression of Ta between 1-0.6
; report c0, c1 
; use a piecewise logistic function to regress the shape function

begin

resxy=True
resxy@gsnFrame=False
resxy@gsnDraw=False
resxy@xyMarkerColor="white"
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
regessline_thick=4
txFontColor="Black"
FontThickness=2
;; ------------------- PNG -----------------------------------
wks=gsn_open_wks("png", "plot.fig3-Ta_stepwise")

;;;; ----------------- PDF ----------------------------------------
; wks=gsn_open_wks("pdf", "fig3-LOG")
; mucapthick=1
; regessline_thick=2
; FontThickness=1

;;;; ----------------- Black Background ----------------------------------------
; wks=gsn_open_wks("png", "fig3-LOG-Dark")
; setvalues wks
; "wkForegroundColor" : (/1.,1.,1./)  ; white
; "wkBackgroundColor" : (/0.,0.,0./)  ; black
; end setvalues
; txFontColor="white"
; resxy@xyMarkerColor="black"
; ; resxy@tmXMajorGrid=True
; ; resxy@tmYMajorGrid=True
; resxy@tmYMajorGridThicknessF=1
; resxy@tmXMajorGridThicknessF=1
; resxy@tmYMajorGridLineDashPattern=2
; resxy@tmXMajorGridLineDashPattern=2
; resxy@tmGridDrawOrder="PreDraw"




;;;; plot-->>>
plot=new(20,graphic)
plreg=new(20,graphic)
plreg1=new(20,graphic)
pltlogi=new(20,graphic)

pltxtc1=new(20,graphic)
pltxtc0=new(20,graphic)
pltxta0=new(20,graphic)
pltxtb0=new(20,graphic)

plregmark=new(20,graphic)
pltrse=new(20,graphic)



latlevels=(/70,72,74,76,78,80,82,84,86,88,90/)
VALUE=      (/71,73,75,77,79,81,83,85,87,89/)
nlevel=dimsizes(VALUE)

plm=new(4*5*(nlevel),graphic)
cmap=read_colormap_file("CET-L04")

Ymax=(/500,360,270,210,150/)
Ymin=(/160,120,90,70,60/)
im=0


intersect=1.0

do pj=51,54
   do ch=2,6

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

    lon=where(lon.eq."nan".or.lat.eq."nan".or.TA.eq."nan",lon@_FillValue,lon)
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
    index:=ind((.not.ismissing(incident)).and.lat1d.gt.min(latlevels) )

    lat1d:=lat1d(index)
    miu:=cos(incident(index)*3.14159265/180.)
    ta1d:=ta1d(index)
 
    ;;-----------------------------------------------------------------------------------
    ; plot Ta in colors of latttudes
    resxy@trYMaxF= Ymax(ch-2)
    resxy@trYMinF= Ymin(ch-2)
    plot((pj-51)*5+ch-2)=gsn_csm_xy(wks,miu,ta1d,resxy)

    ;;-----------------------------------------------------------------------------------
    ;; plot markers in leveled colors
    gsres=True
    gsres@gsMarkerIndex=1
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


    ;;--------------------------------------------------------------------------------------------------------------------- 
    ;; linear fits between 1~0.6
        miufit:=miu(ind(miu.gt.0.6))
        tafit:=ta1d(ind(miu.gt.0.6))
        reg=regline_stats(miufit, tafit)
        intercept=reg@yintercept
        Ta_linear:=miu*reg+intercept

        c0=reg+intercept
        c1=c0-(reg*0.8+intercept)
        ;;; plot the linear regression part over 1.0 ~ 0.6
        ; regres=True
        ; regres@gsLineColor="Blue"
        ; regres@gsLineThicknessF=regessline_thick
        ; regres@gsLineDashPattern=0
        ; plreg((pj-51)*5+ch-2)=gsn_add_polyline(wks,  plot((pj-51)*5+ch-2), (/1.0,intersect/), (/1,1/), regres)

        ; regres@gsLineColor=txFontColor
        ; regres@gsLineDashPattern=2       
        ; regres@gsLineThicknessF=regessline_thick-1  
        ; plreg1((pj-51)*5+ch-2)=gsn_add_polyline(wks,  plot((pj-51)*5+ch-2), (/intersect,intersect/), (/0.,1.1/), regres)

        ;; report Linear mode coeff.
        xpos=0.75
        ypos0= (Ymax(ch-2)-Ymin(ch-2))*0.2+Ymin(ch-2)
        ypos1= (Ymax(ch-2)-Ymin(ch-2))*0.08+Ymin(ch-2)
        texta="c~H-13V2F35~D~FV-2H3~~B~0~N~ = "+sprintf("%5.2f",c0)
        textb="c~H-13V2F35~D~FV-2H3~~B~1~N~ = "+sprintf("%5.2f",c1)
        tcres=True
        tcres@txFontColor=txFontColor
        tcres@txFontHeightF=0.045
        pltxta0((pj-51)*5+ch-2)=gsn_add_text(wks, plot((pj-51)*5+ch-2), texta,xpos,ypos0 , tcres) 
        pltxtb0((pj-51)*5+ch-2)=gsn_add_text(wks, plot((pj-51)*5+ch-2), textb,xpos,ypos1 , tcres) 

    ;;---------------------------------------------------------------------------------------------------------------------         
    ;; extract shape
        shape:=ta1d/Ta_linear    

    ;; report a2,b2  0.6-0
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

        ;use only 0~0.8 to regess
        shape_beam:=shape_beam(3:40)
        miu_beam:=miu_beam(3:40)
        shape_beam=where(shape_beam.ge.1,shape_beam@_FillValue, shape_beam)

        indvalid:=ind(.not.ismissing(shape_beam))
        shape_beam:=shape_beam(indvalid)
        miu_beam  :=miu_beam  (indvalid)

        ;; plot markers as the interval means used to regress
        ; resremk=True
        ; resremk@gsMarkerIndex=1
        ; resremk@gsMarkerSizeF=0.02
        ; resremk@gsMarkerColor="RED"
        ; plregmark((pj-51)*5+ch-2)=gsn_add_polymarker(wks, plot((pj-51)*5+ch-2), miu_beam, shape_beam, resremk)

        ;;; linearize the nonlinear shape    
        shape_beam=sqrt(log(1.0/shape_beam -1.0)*-1.0)
        logistic=regline_stats(miu_beam,shape_beam)

        ;; extract the shape coeff. in a quadratic logistic equation:
        ;;  y=1/(1+exp(-(a(u+b))^2))
        a=logistic
        b=logistic@yintercept/a

        ;;; report the logistic coeff. in the plots
        xpos=0.3
        ypos0= (Ymax(ch-2)-Ymin(ch-2))*0.2+Ymin(ch-2)
        ypos1= (Ymax(ch-2)-Ymin(ch-2))*0.08+Ymin(ch-2)
        textc0="a = "+ sprintf("%5.3f", a)
        textc1="b = "+ sprintf("%5.3f", b)
        tares=True
        tares@txFontColor=txFontColor
        tares@txFontHeightF=0.045
        pltxtc1((pj-51)*5+ch-2)=gsn_add_text(wks, plot((pj-51)*5+ch-2), textc0,xpos,ypos0 , tares) 
        pltxtc0((pj-51)*5+ch-2)=gsn_add_text(wks, plot((pj-51)*5+ch-2), textc1,xpos,ypos1 , tares) 


        ;; plot the quadratic logistic fitting curve.
        xlogi=fspan(0,1.0,100)
        ;; logistic mode
        ylogi=1.0/(1+exp(-1*(a*(xlogi+b))^2))
        ;; linear mode
        yline=xlogi*reg+intercept
        ;; nonlinear regression model
        ylogi=yline*ylogi

        logires=True
        logires@gsnFrame=False
        logires@gsnDraw=False
        logires@xyLineColor="Blue"
        logires@xyMarkLineMode="Lines"
        logires@xyLineThicknessF=regessline_thick
        logires@xyDashPattern=0
        logires@xyCurveDrawOrder="PostDraw"
        pltlogi((pj-51)*5+ch-2)=gsn_csm_xy(wks, xlogi,ylogi, logires)
        overlay(plot((pj-51)*5+ch-2),pltlogi((pj-51)*5+ch-2))

        ;; report the RMSE of the complex model;
        ta1d_predic:= (miu*reg+intercept)/(1+exp(-1*(a*(miu+b))^2))
        regall=regline_stats(ta1d,ta1d_predic)

        xpos=0.7
        ypos= (Ymax(ch-2)-Ymin(ch-2))*0.4+Ymin(ch-2)
        pltrse((pj-51)*5+ch-2)=gsn_add_text(wks, plot((pj-51)*5+ch-2), "RMSE = "+sprintf("%5.2f",regall@RSE)+" K",xpos,ypos, tares) 

end do
end do

    ; manually add Row titles  
    Ytires=True
    Ytires@txFontHeightF=0.014
    Ytires@txFontThicknessF=FontThickness
    Ytires@txAngleF=90.

    gsn_text_ndc(wks, "PJ51 T~B~a~N~ (K)", 0.015, 0.735, Ytires)
    gsn_text_ndc(wks, "PJ52 T~B~a~N~ (K)", 0.015, 0.585, Ytires)
    gsn_text_ndc(wks, "PJ53 T~B~a~N~ (K)", 0.015, 0.435, Ytires)
    gsn_text_ndc(wks, "PJ54 T~B~a~N~ (K)", 0.015, 0.285, Ytires)

    Xtires=True
    Xtires@txFontHeightF=0.014
    Xtires@txAngleF=0.

    gsn_text_ndc(wks, "1.25 GHz", 0.15, 0.815, Xtires)
    gsn_text_ndc(wks, "2.6 GHz", 0.34, 0.815, Xtires)
    gsn_text_ndc(wks, "5.2 GHz", 0.53, 0.815, Xtires)
    gsn_text_ndc(wks, "10 GHz", 0.72, 0.815, Xtires)
    gsn_text_ndc(wks, "22 GHz", 0.91, 0.815, Xtires)

    Xtires@txFontThicknessF=mucapthick
    gsn_text_ndc(wks, "~F8~m~F21~", 0.145, 0.185, Xtires)
    gsn_text_ndc(wks, "~F8~m~F21~", 0.341, 0.185, Xtires)
    gsn_text_ndc(wks, "~F8~m~F21~", 0.532, 0.185, Xtires)
    gsn_text_ndc(wks, "~F8~m~F21~", 0.725, 0.185, Xtires)
    gsn_text_ndc(wks, "~F8~m~F21~", 0.915, 0.185, Xtires)

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

    ; gsn_text_ndc(wks,  "Intersection= "+intersect, 0.45, 0.85, Xtires)
;; Panels 
    resP=True
    ; resP@gsnPanelMainFontHeightF=0.01
    ; resP@gsnPanelTop=0.97
    ; resP@gsnPanelBottom=0.07
    resP@gsnPanelLeft=0.035

    resP@gsnPanelFigureStrings=(/"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T"/)
    resP@gsnPanelFigureStringsFontHeightF=0.015
    resP@gsnPanelFigureStringsBackgroundFillColor=PanelFigureStringsBackgroundFillColor
    resP@gsnPanelYWhiteSpacePercent=2
    resP@gsnPanelFigureStringsPerimOn=False
    resP@gsnPanelFigureStringsJust="TopRight"

    ; drawNDCGrid(wks)
    gsn_panel(wks,plot,(/4,5/),resP)

end