function propgen, data, hd, obj, err, smoothmap= smoothmap
;+
; NAME:
;    PROPGEN
; PURPOSE:
;    Calculates properties of objects in BOLOCAM maps
; CALLING SEQUENCE:
;    p = PROPGEN( data, hdr, object, err )
;
;
; INPUTS:
;   DATA -- Original data map
;   HDR -- FITS header from original data
;   OBJECT -- Object label map such that the Ith label corresponds to
;             the Ith object in the map.
;   ERR -- Map of uncertainty.
;
; OUTPUTS:
;   P -- array of structures corresponding to the properties for each
;        object.  
; MODIFICATION HISTORY:
;
;       Tue May 29 12:29:23 2007, Erik <eros@yggdrasil.local>
;
;		Documented.
;
;-

; Header parsing
  galhd = hd
  heuler, galhd, /galactic
  heuler, hd, /celestial
  extast, hd, astrom
  extast, galhd, galastrom
  getrot, galhd, angle, cdelt
  rdhd, galhd, s = h  


; CONSTANTS

  if h.ppbeam eq 0 then ppbeam = 1.0 else ppbeam = h.ppbeam
  if sxpar(hd, 'PPBEAM') gt 0 then ppbeam = sxpar(hd, 'PPBEAM')
  if string(sxpar(hd, 'BUNIT')) eq 'JY/PIX' then ppbeam = 1.0
  bmsize = sqrt((sxpar(hd, 'BMAJ')*sxpar(hd, 'BMIN')))*3600d0
  if bmsize eq 0 then bmsize = 31.2
  psize = sqrt(abs(cdelt[0]*cdelt[1]))
  bmpix = bmsize/psize/3600d0/sqrt(8*alog(2))

  rms2rad = 2.4

  s = replicate({bolocat}, max(obj))

  vectorify, data, mask = obj, id = id, $
    x = x, y = y, t = t
  vectorify, err, mask = obj, id = id, $
    x = x, y = y, t = evec
  if n_elements(smoothmap) ne n_elements(data) then smmap = smooth(Data, 5, /nan) else smmap = smoothmap
  vectorify, smmap, mask = obj, id = id, $
    x = x, y = y, t = smooth_t

  maxo = max(obj)
  for i = 0, maxo-1 do begin
    useind = where(id eq i+1)
    s[i].cloudnum = i+1
    s[i].npix = n_elements(useind) 
    xuse = x[useind]
    yuse = y[useind]
    vuse = replicate(1, n_elements(useind)) 
    tuse = t[useind] > 0 ; Added >0 
    errs = evec[useind]
;    mom = cloudmom(xuse, yuse, vuse, tuse, targett = targett)
    null = max(smooth_t[useind], /nan, maxind)
    xmax = xuse[maxind]
    ymax = yuse[maxind]

; Calculate the maximum position with more detail:
; Skip for now.
     stamp = data[min(xuse):max(xuse), min(yuse):max(yuse)]
     mask = (obj eq i+1)[min(xuse):max(xuse), min(yuse):max(yuse)]
;;     euclidean = (xuse-xmax)^2+(yuse-ymax)^2
;;     local_ind = where(Euclidean le 4)
;;     local_wts = tuse[local_ind]
;;     local_wts = (local_wts-min(local_wts))/(max(local_wts)-min(local_wts))
;;     nullx = wt_moment(xuse[local_ind], local_wts)
;;     nully = wt_moment(yuse[local_ind], local_wts)
;;     xmax = nullx.mean
;;     ymax = nully.mean

    momx = wt_moment(xuse, tuse, errors = errs)
    momy = wt_moment(yuse, tuse, errors = errs)

;    mom_noex = cloudmom(xuse, yuse, vuse, tuse, targett = targett, $
;                        /noextrap)
;   FIND THE MAJOR AXIS AND ROTATE THEN MEASURE MAJOR/MINOR AXES
    x0 = xuse-momx.mean
    y0 = yuse-momy.mean
    pa = pa_moment(x0, y0, tuse)

    xrot = x0*cos(pa)+y0*sin(pa)
    yrot = -x0*sin(pa)+y0*cos(pa)    
;    mom_rot = $ 
;      cloudmom(xrot, yrot, vuse, tuse, targett = targett)
;    mom_noex_rot = $
;      cloudmom(xrot, yrot, vuse, tuse, targett = targett, /noextrap)

    mommaj = wt_moment(xrot, tuse, errors = errs)
    mommin = wt_moment(yrot, tuse, errors = errs)
    s[i].xdata = momx.mean
    s[i].ydata = momy.mean
    s[i].xdata_err = momx.errmn
    s[i].ydata_err = momy.errmn
    s[i].xerror_as = momx.errmn*abs(cdelt[0])*3600
    s[i].yerror_as = momy.errmn*abs(cdelt[1])*3600

    s[i].momxpix = momx.stdev
    s[i].momypix = momy.stdev
    s[i].momxpix_err = momx.errsd
    s[i].momypix_err = momy.errsd
    s[i].mommajpix = mommaj.stdev > mommin.stdev
    s[i].momminpix = mommaj.stdev < mommin.stdev
    s[i].mommaj_as = s[i].mommajpix*psize*3.6d3
    s[i].mommin_as = s[i].momminpix*psize*3.6d3
    s[i].posang = pa+(!pi/2*(mommaj.stdev lt mommin.stdev))
    s[i].posang = s[i].posang - !pi*(s[i].posang gt !pi)

    s[i].maxxpix = xmax
    s[i].maxypix = ymax

    edist = sqrt((xrot-mommaj.mean)^2/(mommaj.stdev)^2+$
                 (yrot-mommin.mean)^2/(mommin.stdev)^2)
    sind = sort(edist)
    l_cumulative = total(tuse[sind], /cum)/total(tuse)
    r50 = interpol(edist[sind], l_cumulative, 0.5)
    r90 = interpol(edist[sind], l_cumulative, 0.9)
    s[i].concen = r90/r50
    xy2ad, s[i].xdata, s[i].ydata, astrom, ra, dec
    xy2ad, s[i].xdata, s[i].ydata, galastrom, glon, glat
    xy2ad, s[i].maxxpix, s[i].maxypix, astrom, ramax, decmax
    xy2ad, s[i].maxxpix, s[i].maxypix, galastrom, glon_max, glat_max

    glon = (glon+360) mod 360
    glon_max = (glon_max+360) mod 360

    
    s[i].ra = ra
    s[i].dec = dec
    s[i].glon = glon
    s[i].glat = glat
    if glon_max lt 0 then glon_str = decimals(360-glon_max, 3) else $
       glon_str = decimals(glon_max, 3)
    if glon_max lt 10 then glon_str = '0'+glon_str
    if glon_max lt 100 then glon_str = '0'+glon_str
    glat_str = decimals(abs(glat_max), 3)
    if abs(glat_max) lt 10 then glat_str = '0'+glat_str
    if glat ge 0 then glat_str = '+'+glat_str else glat_str = '-'+glat_str
    s[i].name = 'G'+glon_str+glat_str
    s[i].maxra = ramax
    s[i].maxdec = decmax
    s[i].glon_max = glon_max
    s[i].glat_max = glat_max
    s[i].flux = total(tuse/ppbeam)
; ?? Do we use this or non-smooth values
    s[i].max = max(smooth_t[useind])
    s[i].rad_pix_nodc = rms2rad*sqrt(s[i].mommajpix*s[i].momminpix)
    s[i].rad_pix = rms2rad*sqrt(sqrt(s[i].mommajpix^2-bmpix^2)*$
                   sqrt(s[i].momminpix^2-bmpix^2))
    s[i].rad_as = s[i].rad_pix*(psize*3.6d3)
    s[i].rad_as_nodc = s[i].rad_pix_nodc*(psize*3.6d3)
    s[i].rms = median(errs)
    s[i].ppbeam = ppbeam
    s[i].rms2rad = rms2rad
    s[i].pk_s2n = max(tuse/errs)
    s[i].mn_s2n = mean(tuse/errs)
    xv = findgen(max(xuse)-min(xuse)+1)+min(xuse)
    yv = findgen(max(yuse)-min(yuse)+1)+min(yuse)
    xmat = xv#replicate(1, n_elements(yv))
    ymat = replicate(1, n_elements(xv))#yv
    a = [0.0, s[i].max, s[i].mommajpix >1.84, s[i].momminpix >1.84, $
         s[i].maxxpix, s[i].maxypix, s[i].posang]

    pinfo = {fixed:0b, limited:[0b, 0b], limits:[0.0, 0.0], value:0.0}
    pinfo = replicate(pinfo, n_elements(a)) 

    pinfo[0].fixed = 1b
    pinfo[1].limited[0] = 1b

    pinfo[2].limited = [1b, 0b]
    pinfo[2].limits[0] = 1.3;1.84
    

    pinfo[3].limited = [1b, 0b]
    pinfo[3].limits[0] = 1.3;1.84

    pinfo[4].limited = 1b
    pinfo[4].limits[0] = min(xuse)
    pinfo[4].limits[1] = max(xuse)
    pinfo[5].limits = 1b
    pinfo[5].limits[0] = min(yuse)
    pinfo[5].limits[1] = max(yuse)

    ain = a
    estamp = err[min(xuse):max(xuse), min(yuse):max(yuse)]
    params = mpfit2dfun('gauss2dfun',  xmat, ymat, stamp*mask, estamp, a, parinfo = pinfo, quiet = 1b)
    fit = gauss2dfun(xmat, ymat, params)
    


    s[i].gauss_amp = params[1]
    s[i].gauss_maj=(params[2] > params[3])*psize*3600.
    s[i].gauss_min=(params[3] <params[2])*psize*3600.
    s[i].gauss_xc=params[4]
    s[i].gauss_yc=params[5]
    s[i].gauss_pa=params[6]-!pi/2*(params[3] gt params[2])
    s[i].gauss_flux = 2*!pi*params[2]*params[3]*params[1]/ppbeam
    hitz = where(mask, ndat)
    
    s[i].gauss_chisq = total(((fit[hitz]-stamp[hitz])^2/estamp[hitz]^2))/(ndat-6)
    counter, i+1, maxo, 'Determining source properties for source '
  endfor 

  

  return, s
end
