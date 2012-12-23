pro eplot, x, y, xerror = xerror, yerror = yerror, _extra = extra, $
           ethick = ethick, ecolor = ecolor, elinestyle = elinestyle, $
           overplot = overplot, capwidth = capwidth
;+
; NAME:
;   EPLOT
; PURPOSE:
;   Error bar plotting which goes in BOTH directions.  Boo-yah.
;
; CALLING SEQUENCE:
;   eplot, x, y [, xerror = xerror, yerror = yerror,
;           ethick = ethick, ecolor = ecolor, elinestyle = elinestyle]
;
; INPUTS:
;   X, Y -- The X and Y points of a plot.
;
; KEYWORD PARAMETERS:
;   XERROR, YERROR -- error in the X, Y coordinate
;   ECOLOR -- Color of the error bars, defaults to !P.COLOR
;   ELINESTYLE -- Linestyle of the error bars
;   ETHICK -- Thickness of the error bars
;   OVERPLOT -- Overplots instead of PLOTs
;   CAPWIDTH -- Scaling of cap bars.  Defaults to 1 ticklength
;   All other plot keywords passed to PLOT.  
;   
; OUTPUTS:
;   Pretty Pictures!
;
; MODIFICATION HISTORY:
;
;       Thu May 22 14:14:00 2003, <eros@master>
;		Simplified checking for LOG keywords.  Added
;		overplotting capability.
;
;       Thu Apr 3 14:25:19 2003, Erik Rosolowsky <eros@cosmic>
;	     Corrected log plots with error bars, again.
;	
;       Stopped
;       plotting out of bound points.  Tue Jan 15 00:28:35 2002, Erik
;       Rosolowsky <eros@cosmic>
;      
;       Modified to accept log plots.
;       Tue Oct 2 16:38:46 2001, Erik Rosolowsky <eros@cosmic>
;
;	Kickin'
;       ass and takin' names -- Wed Aug 22 13:49:02 2001, Erik
;       Rosolowsky <eros@cosmic>
;-

if not keyword_set(ethick) then ethick = !p.thick
if not keyword_set(elinestyle) then elinestyle = 0
if n_elements(capwidth) eq 0 then capwidth = !p.ticklen/4
if not keyword_set(overplot) then $
  plot, x, y, _extra = extra else oplot, x, y, _extra = extra

if not keyword_set(ecolor) then ecolor = !p.color

if n_elements(yerror) eq 0 and n_elements(xerror) eq 0 then return

ybot = !y.type ? 1e1^!y.crange[0] : !y.crange[0]
ytop = !y.type ? 1e1^!y.crange[1] : !y.crange[1]
xbot = !x.type ? 1e1^!x.crange[0] : !x.crange[0]
xtop = !x.type ? 1e1^!x.crange[1] : !x.crange[1]

if n_elements(xerror) gt 0 then begin
  if n_elements(x) ne n_elements(xerror) then begin
    message, 'X and X_ERR arrays must have the same size', /con
    return
  endif
  for i = 0, n_elements(xerror)-1 do begin 
    if x[i] lt xbot or x[i] gt xtop or y[i] lt ybot or y[i] gt ytop $
      then continue
    plots, ((x[i]-xerror[i]) > xbot) , y[i], /data
    plots, ((x[i]+xerror[i]) < xtop) , y[i], /con, /data, $
      thick = ethick, color = ecolor, linestyle = elinestyle
    if capwidth gt 0 then begin
      normx0 = !x.type ? !x.s[1]*alog10(x[i]-xerror[i])+!x.s[0] : $
                (!x.s[1]*(x[i]-xerror[i])+!x.s[0])
      normx1 = !x.type ? !x.s[1]*alog10(x[i]+xerror[i])+!x.s[0] : $
                (!x.s[1]*(x[i]+xerror[i])+!x.s[0])
      normy0 = !y.type ? !y.s[1]*alog10(y[i])+!y.s[0] : $
                (!y.s[1]*(y[i])+!y.s[0])

      if (x[i]-xerror[i]) gt xbot then begin
        plots, normx0, normy0-capwidth, /normal
        plots, normx0, normy0+capwidth, /con, /normal, $
               thick = ethick, color = ecolor, linestyle = elinestyle
      endif
      if (x[i]+xerror[i]) lt xtop then begin
        plots, normx1, normy0-capwidth, /normal
        plots, normx1, normy0+capwidth, /con, /normal, $
               thick = ethick, color = ecolor, linestyle = elinestyle
      endif

;      plots, [normx0, normx0], [normy0-capwidth, normy0+capwidth]
;      plots, [normx1, normx1], [normy0-capwidth, normy0+capwidth]
    endif
  endfor
endif

if n_elements(yerror) gt 0 then begin
  if n_elements(y) ne n_elements(yerror) then begin
    message, 'Y and Y_ERR arrays must have the same size', /con
    return
  endif
  for i = 0, n_elements(yerror)-1 do begin 
    if x[i] lt xbot or x[i] gt xtop or y[i] lt ybot or y[i] gt ytop $
      then continue
    plots, x[i], ((y[i]-yerror[i]) > ybot), /data
    plots, x[i], ((y[i]+yerror[i]) < ytop) , /con, /data, $
      thick = ethick, color = ecolor, linestyle = elinestyle
    if capwidth gt 0 then begin

      normy0 = !y.type ? !y.s[1]*(alog10((y[i]-yerror[i])))+!y.s[0] : $
                !y.s[1]*(y[i]-yerror[i])+!y.s[0]
      normy1 = !y.type ? !y.s[1]*(alog10(y[i]+yerror[i]))+!y.s[0] : $
                !y.s[1]*(y[i]+yerror[i])+!y.s[0]
      normx0 = !x.type ? !x.s[1]*alog10(x[i])+!x.s[0] : $
                (!x.s[1]*(x[i])+!x.s[0])
      if (y[i]-yerror[i]) gt ybot then begin
        plots, normx0-capwidth, normy0, /normal
        plots, normx0+capwidth, normy0, /con, /normal, $
               thick = ethick, color = ecolor, linestyle = elinestyle

      endif
      if (y[i]+yerror[i]) lt ytop then begin
        plots, normx0-capwidth, normy1, /normal
        plots, normx0+capwidth, normy1, /con, /normal, $
               thick = ethick, color = ecolor, linestyle = elinestyle
      endif
    endif


  endfor
endif

oplot, x, y, _extra = extra

  return
end





