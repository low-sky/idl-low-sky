pro oplotbeam, xpos = xpos, ypos = ypos, $
               header = h, fit = beamstructure, color = color, $
               outline = outline, label = label, _extra = ex, $
               scale = scale, radec = radec,  offset = offset
;+
; NAME:
;   oplotbeam
; PURPOSE:
;   Plots the beam on a displayed image.
;
; CALLING SEQUENCE:
;   OPLOTBEAM, [fit  = beamstructure, header=header, xpos =
;   xpos, ypos = ypos, /outline, color = color]   
;
; INPUTS:
;   XPOS, YPOS - The X, Y position in fraction of the plot window of the
;          location of the beam.
;   HEADER - Structure containing processed header information from
;            the RDHD program.
;   BEAMSTRUCTURE - A structure containing information about the beam
;                   output by the program BEAMFIT.PRO with the
;                   /STRUCTURE flag set.
;
; KEYWORD PARAMETERS:
;   LABEL -- Label displayed next to beam with extra keywords passed
;            to XYOUTS.
;   RADEC -- Set if plot is an RA/DEC plot to rescale the x-coordinate
;            of the beam by 1/COS(DEC)
;   OFFSET -- Set if plot is an offset plot to have equal scales (the default).
;
; OUTPUTS:
;   None.
;
; MODIFICATION HISTORY:
;
;       Wed Aug 18 13:49:56 2010, Erik Rosolowsky <erosolo@A302357>
;           Added RA/DEC scaling and some guesswork to make it function.
;		
;       Added Labelling (crudely) Fri Jan 10 16:26:53 2003,
;       <eros@master>
;
;       Fixed position angle bug.
;       Tue Apr 10 02:02:49 2001, Erik Rosolowsky <eros@cosmic>
;
;       Written -- Wed Oct 18 10:57:36 2000, Erik Rosolowsky
;                  <eros@cosmic>
;-

  if n_elements(color) eq 0 then color = byte(!d.table_size/1.5)
  if n_elements(outline) eq 0 then outline = !p.color
  if n_elements(scale) eq 0 then scale = 1


  if keyword_set(h) then begin
    if n_elements(xpos) eq 0 then xpos = 0.1
    if n_elements(ypos) eq 0 then ypos = 0.1
    

    dec = ypos*(!y.crange[1]-!y.crange[0])+!y.crange[0]
    if keyword_set(radec) then radecscale = 1/cos(dec*!dtor) else radecscale = 1
    if !x.crange[1]*!x.crange[0] gt 0 then begin
      message, 'Assuming you are making an RA/DEC plot.  Scaling x-coord.', /info
      radecscale =  1/cos(dec*!dtor)
    endif

    if keyword_set(offset) then radecscale = 1

    sf = 0.5/3600*scale               ;0.5*(dist/206265.)
    phi = 2*!pi*findgen(101)/100
    bpa = h.bpa+90
    x = sf*h.bmaj*cos(phi)
    y = sf*h.bmin*sin(phi)
    xnew = (x*cos(bpa*!dtor)+y*sin(bpa*!dtor)) * radecscale
    ynew = y*cos(bpa*!dtor)-x*sin(bpa*!dtor)
    x = xnew
    y = ynew
    xvec =  x+$
      xpos*(!x.crange[1]-!x.crange[0])+!x.crange[0]
    yvec =  y+ypos*$
      (!y.crange[1]-!y.crange[0])+!y.crange[0]

    polyfill, x+$
      xpos*(!x.crange[1]-!x.crange[0])+!x.crange[0], $
      y+ypos*$
      (!y.crange[1]-!y.crange[0])+!y.crange[0], /data, $
      color = color
    plots,  x+$
      xpos*(!x.crange[1]-!x.crange[0])+!x.crange[0], $
      y+ypos*$
      (!y.crange[1]-!y.crange[0])+!y.crange[0]
    plots, x+$
      xpos*(!x.crange[1]-!x.crange[0])+!x.crange[0], $
      y+ypos*$
      (!y.crange[1]-!y.crange[0])+!y.crange[0], /continue, $
      color = outline

    if keyword_set(label) then begin

      if (!x.crange[1]-!x.crange[0]) lt 0 then x0 = min(xvec) else x0 = max(xvec)
      if (!y.crange[1]-!y.crange[0]) gt 0 then y0 = min(yvec) else y0 = max(yvec)
      xyouts, x0+0.02*(!x.crange[1]-!x.crange[0]), $
        y0+0*(!y.crange[1]-!y.crange[0]), label, _extra = ex
    endif

  endif else begin

    if beamstructure.units eq 'DEGREES' then uscale = 1.
    if beamstructure.units eq 'ARCMIN' then uscale = 1./60
    if beamstructure.units eq 'ARCSEC' then uscale = 1./3600
    phi = 2*!pi*findgen(201)/200.
    ellipse_x0 = 0.5*beamstructure.fwhm_maj*cos(phi)*uscale
    ellipse_y0 = 0.5*beamstructure.fwhm_min*sin(phi)*uscale
    xlen = !x.crange[1]-!x.crange[0]
    x0 = !x.crange[0]+2*max(ellipse_x0)*xlen/(abs(xlen))
    ylen = !y.crange[1]-!y.crange[0]
    y0 = !y.crange[0]+2*max(ellipse_y0)*ylen/(abs(ylen))

    theta = -beamstructure.posn_ang*!dtor
    ellipse_x = ellipse_x0*cos(theta)+ellipse_y0*sin(theta)
    ellipse_y = -ellipse_x0*sin(theta)+ellipse_y0*cos(theta)

;x0 = !x.crange[0]+max(ellipse_x)
;xlen = !x.crange[1]-x0
;y0 = !y.crange[0]-min(ellipse_y)
;ylen = !y.crange[1]-y0
;x0 = x0+0.05*xlen
;y0 = y0+0.03*ylen
    bangp = !p
    if n_elements(color) ne 0 then begin
      !p.color = color
      polyfill, ellipse_x+x0, ellipse_y+y0, $
        pattern = replicate(byte(color), 3, 3)
    endif else begin
      polyfill, ellipse_x+x0, ellipse_y+y0, $
        pattern = replicate(!d.n_colors/1.5, 3, 3)
    endelse
    !p = bangp
    plots, ellipse_x[0]+x0, ellipse_y[0]+y0
    plots, ellipse_x+x0, ellipse_y+y0, /continue
    
    if keyword_set(label) then begin

      xyouts, ellipse_x[0]+x0+0.02*(!x.crange[1]-!x.crange[0]), $
        ellipse_y[0]+y0, label, _extra = ex
    endif
    

  endelse


  return
end

