
; this script is do Levenberg–Marquardt fitting :
;;  the equation to regression is a quadratic logistic signal on the background of linear signal:
;;  Ta= (c0 + c1 * (1 - mu)) / (1 + np.exp(-1*(a * (mu + b))**2))

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
regessline_thick=3
txFontColor="Black"

;; ------------------- PNG -----------------------------------
wks=gsn_open_wks("png", "plot.fig3-LM_fitting")

;;;; ----------------- PDF ----------------------------------------
; wks=gsn_open_wks("pdf", "plot.fig3-LM_fitting")
; mucapthick=1
; regessline_thick=2

;;;; ----------------- Black Background ----------------------------------------
; wks=gsn_open_wks("png", "plot.fig3-LM_fitting-Dark")
; setvalues wks
; "wkForegroundColor" : (/1.,1.,1./)  ; white
; "wkBackgroundColor" : (/0.,0.,0./)  ; black
; end setvalues
; resxy@xyMarkerColor="black"
; txFontColor="white"
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

pltxtc1=new(20,graphic)
pltxtc0=new(20,graphic)
pltxta=new(20,graphic)
pltxtb=new(20,graphic)
pltrse=new(20,graphic)


latlevels=(/70,72,74,76,78,80,82,84,86,88,90/)
VALUE=      (/71,73,75,77,79,81,83,85,87,89/)
nlevel=dimsizes(VALUE)

plm=new(4*5*(nlevel),graphic)
cmap=read_colormap_file("CET-L04")

Ymax=(/500,360,270,210,150/)
Ymin=(/160,120,90,70,60/)
im=0

do pj=51,54
   do ch=2,6

    ftprt:=addfile("../Ta_swath/TA_swath_ch"+sprinti("%0.2i",ch)+"_pj"+sprinti("%0.2i",pj)+".h5","r")

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
    index:=ind((.not.ismissing(incident)).and.lat1d.gt.min(latlevels) )

    lat1d:=lat1d(index)
    miu:=cos(incident(index)*3.14159265/180.)
    ta1d:=ta1d(index)
    
    ;;-----------------------------------------------------------------------------------
    ;; do dummy xy marker plot, white points
    resxy@trYMaxF=Ymax(ch-2)
    resxy@trYMinF=Ymin(ch-2)
    plot((pj-51)*5+ch-2)=gsn_csm_xy(wks,miu,ta1d,resxy)



    
    ;;-----------------------------------------------------------------------------------
    ; pairsH5="Ta_mu_pairs/Ta_mu_pairs_ch"+sprinti("%0.2i",ch)+"_pj"+sprinti("%0.2i",pj)+".h5"
    ; if(fileexists(pairsH5)) then system("rm "+pairsH5) end if
    ; fout=addfile(pairsH5,"c")
    ; fout->Ta=ta1d
    ; fout->miu=miu

    ; continue
    ;; ------------------------------------------------------------------------------------------------------
    ;; call python to do Levenberg–Marquardt fitting and return the coeficent:
    ;;  the equation to regression is a quadratic logistic signal on the background of linear equation:
    ;;  Ta= (c0 + c1 * (1 - mu)) / (1 + np.exp(-1*(a * (mu + b))**2))
        retstring=systemfunc("cd .. ; python Quadratic_Logistic_LM_fitting.py "+sprinti("%0.2i",ch)+" "+sprinti("%0.2i",pj))
        retcoeff=todouble(retstring)
        ;; distribute the returned coefficients
        c0=retcoeff(0)
        c1=retcoeff(1)
        a =retcoeff(2)
        b =retcoeff(3)    
   

    ;; plot non-linear fits curve
        mu_dummy=fspan(0,1,100)
        Ta_dummy= (c0 + c1 * (1 - mu_dummy)) / (1 + exp(-1*(a * (mu_dummy + b))^2))

        regres=True
        regres@gsLineColor="Blue"
        regres@gsLineThicknessF=regessline_thick
        regres@gsLineDashPattern=0
        plreg((pj-51)*5+ch-2)=gsn_add_polyline(wks,  plot((pj-51)*5+ch-2),mu_dummy, Ta_dummy, regres)


;; plot markers in colors of leveled latitudes
        ta1d=ta1d*(1+exp(-1* (a*(miu+b))^2)) - (1-miu)*c1

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
    ;; report c0, c1, a, b on the plots
        ;; report Linear mode coeff. c0, c1
        xpos=0.75
        ypos0= (Ymax(ch-2)-Ymin(ch-2))*0.2+Ymin(ch-2)
        ypos1= (Ymax(ch-2)-Ymin(ch-2))*0.08+Ymin(ch-2)
        texta="c~H-13V2F35~D~FV-2H3~~B~0~N~ = "+sprintf("%5.2f",c0)
        textb="c~H-13V2F35~D~FV-2H3~~B~1~N~ = "+sprintf("%5.2f",c1)
        tcres=True
        tcres@txFontColor=txFontColor
        tcres@txFontHeightF=0.045
        pltxta((pj-51)*5+ch-2)=gsn_add_text(wks, plot((pj-51)*5+ch-2), texta,xpos,ypos0 , tcres) 
        pltxtb((pj-51)*5+ch-2)=gsn_add_text(wks, plot((pj-51)*5+ch-2), textb,xpos,ypos1 , tcres) 

        ;;; report the logistic coeff. a, b
        xpos=0.3
        ypos0= (Ymax(ch-2)-Ymin(ch-2))*0.2+Ymin(ch-2)
        ypos1= (Ymax(ch-2)-Ymin(ch-2))*0.08+Ymin(ch-2)
        textc0="a = "+ sprintf("%5.3f", a)
        textc1="b = "+ sprintf("%5.3f", b)
        pltxtc1((pj-51)*5+ch-2)=gsn_add_text(wks, plot((pj-51)*5+ch-2), textc0,xpos,ypos0 , tcres) 
        pltxtc0((pj-51)*5+ch-2)=gsn_add_text(wks, plot((pj-51)*5+ch-2), textc1,xpos,ypos1 , tcres) 

        ;;; report the root mean square error 
        ta1d_predict:= (c0 + c1 * (1 - miu)) / (1 + exp(-1*(a * (miu + b))^2))
        regall=regline_stats(ta1d,ta1d_predict)
        xpos=0.65
        ypos= (Ymax(ch-2)-Ymin(ch-2))*0.4+Ymin(ch-2)
        pltrse((pj-51)*5+ch-2)=gsn_add_text(wks, plot((pj-51)*5+ch-2), "RMSE = "+sprintf("%5.2f",regall@RSE)+" K",xpos,ypos, tcres) 

end do
end do

    ; manually add Row titles  
    Ytires=True
    Ytires@txFontHeightF=0.014
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