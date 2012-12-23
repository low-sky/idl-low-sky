function object_photometry, data, hd, error, props, diam_as, fluxerr = innerflux_err, nobg = nobg
;+
; NAME:
;   OBJECT_PHOTOMETRY
; PURPOSE:
;   Measure the flux density of a catalog object.  Make sure PPBEAM or
;   Beam parameters are set in the FITS header!!
; CALLING SEQUENCE:
;   fluxden = OBJECT_PHOTOMETRY(data, hdr, error, props, diameter,
;             fluxerr = fluxerr, /nobg)
;
; INPUTS:
;   DATA -- Bolocam map
;   HDR -- FITS Header
;   ERROR -- 2D array with an error estimate at each pixel coordinate
;            corresponding to DATA
;   PROPS -- Property structure
;   DIAMETER -- Diameter of region in arcseconds
;    
; KEYWORD PARAMETERS:
;   FLUXERR -- Named variable containing the error estimate from
;              statistics alone (i.e., not beam uncertainty)
;   /NOBG -- Set to skip background calculation, else BG is estimated
;            in an annulus with radii 2x and 3x of DIAMETER
; OUTPUTS:
;   FLUXDEN -- Flux density in units of the map DIVIDED by beam size,
;              hence a map in JY/BEAM gives a FLUXDEN in Jy.  
;
; MODIFICATION HISTORY:
;
;       Fri Dec 18 02:53:43 2009, Erik <eros@orthanc.local>
;
;		Docd.
;
;-

  bootiter = 100
  
  if n_elements(diam_as) eq 0 then diam_as = 40.0
  
  getrot, hd, rot, cd
  rdhd, hd, s = h
  if h.ppbeam eq 0 then ppbeam = 1.0 else ppbeam = h.ppbeam
  if string(sxpar(hd, 'BUNIT')) eq 'JY/PIX' then ppbeam = 1.0
  if sxpar(hd, 'PPBEAM') gt 0 then ppbeam = sxpar(hd, 'PPBEAM')
  rad_pix = diam_as/abs(cd[1]*3.6d3)/2.0 ; Convert from diam -> radius
  if n_elements(rad_pix) eq 1 then rad_pix = rebin([rad_pix], n_elements(props))
  sz = size(data)
  x = findgen(sz[1])#replicatE(1, sz[2])
  y = replicate(1, sz[1])#findgen(sz[2])
  innerflux = fltarr(n_elements(props))+!values.f_nan
  innerflux_err = fltarr(n_elements(props))+!values.f_nan

  for k = 0, n_elements(props)-1 do begin
; Do gcirc distance here?   
    dist = sqrt((x-props[k].maxxpix)^2+(y-props[k].maxypix)^2)

    bgind = where(dist ge rad_pix[k]*2 and dist le rad_pix[k]*4 and data eq data, ct)

    if ct lt 25 then continue
; Set BGs equal to zero!
;    mmm, data[bgind], background
;    if keyword_set(nobg) then background = 0.0
;    background = background < 0
    background = 0
    wtmask = dist le (rad_pix[k]-1)
    border = (dist le (rad_pix[k]+1))-wtmask
    ind = where(border)
    xborder = ind mod sz[1]
    yborder = ind / sz[1]
    border_wt = pixwt(props[k].maxxpix, props[k].maxypix, $
                      rad_pix[k], xborder, yborder)
    wtmask = float(wtmask)
    wtmask[ind] = border_wt
    ind = where(wtmask gt 0, inner_ct)

    innerflux[k] = total(wtmask[ind]*data[ind], /nan)-$
                   background*total(wtmask[ind])
    if ct lt 50 then continue


;;     bgrun = fltarr(bootiter)
;;     for i = 0, bootiter-1 do begin
;;       subsample = floor(randomu(seed, ct)*ct)
;;       mmm, data[bgind[subsample]], bg
;;       bgrun[i] = bg
;;     endfor
;;     bgerr = mad(bgrun)
    bgerr = 0.0
    if keyword_set(nobg) then bgerr = 0.0

; Calculate the error as the weighted error over the object * sqrt(nbeams)    
    innerflux_err[k] =  sqrt((((total(wtmask[ind]*error[ind])/$
                                total(wtmask[ind])))^2+bgerr^2)*$
                             (total(wtmask[ind])/ppbeam))
  endfor 
  innerflux = innerflux/ppbeam

  return, innerflux
end
