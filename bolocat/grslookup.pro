pro grslookup, str, bolo_hd, grs_dir = grs_dir, $
               objects = obj, data = data
;+
; NAME:
;   GRSLOOKUP
; PURPOSE:
;   Look up spectra in the GRS for each object in the catalog.
; CALLING SEQUENCE:
;   GRSLOOKUP, p, hdr, objects = objects, data = data [, grs_dir = grs_dir]
; INPUTS:
;   P -- A BOLOCAT structure or array of structures.
;   HDR -- The fits header for which the catalog was generated.
;   GRS_DIR -- Name of the directory where the GRS lives.
;   OBJECTS -- An object label map
;   DATA -- The original map
;
; OUTPUTS:
;  None.  This just adds the spectrum to the appropriate element of P.
;
; MODIFICATION HISTORY:
;
;       Tue May 29 12:34:25 2007, Erik <eros@yggdrasil.local>
;
;		Documented.
;
;-



  if n_elements(grs_dir) eq 0 then grs_dir = '~/cso/'

  extast, bolo_hd, bolo_astrom

  sz = size(data)

  order = sort(str.glon)

  lastfn = ''
  for k = 0, n_elements(str)-1 do begin
    i = order[k]
; Determine where BOLOCAM points land in GRS data
    ind = where(obj eq str[i].cloudnum)
    wts = data[ind]
    x_orig = ind mod sz[1]
    y_orig = ind / sz[1]
    xy2ad, x_orig, y_orig, bolo_astrom, ra, dec
    euler, ra, dec, glon, glat, 1
    wtorder = sort(glon)
    glon = glon[wtorder]
    glat = glat[wtorder]
    wts = wts[wtorder]
    fn = grs_dir+grs_namelookup(glon)
    v_std = fltarr(1000)
    runspec = fltarr(1000)
    for j = 0, n_elements(ind)-1 do begin 
      if not file_test(fn[j]) then continue
; Pick filename and load new if necessary
      if fn[j] ne lastfn then grs_data = readfits(fn[j], hd)
      lastfn = fn[j]
      if stregex(sxpar(hd, 'CTYPE1'), 'GLS', /bool) then begin
        ct1 = sxpar(hd, 'CTYPE1')
        ct2 = sxpar(hd, 'CTYPE2')
        pos = stregex(sxpar(hd, 'CTYPE1'), 'GLS')
        sxaddpar, hd, 'CTYPE2', strmid(ct2, 0, pos)+'SFL'
        sxaddpar, hd, 'CTYPE1', strmid(ct1, 0, pos)+'SFL'
      endif

      extast, hd, astrom
      rdhd, hd, s = h
      sz_grs = size(grs_data)
      ad2xy, glon[j], glat[j], astrom, x, y
; Look up spectrum
      if x lt 0 or x gt sz_grs[1]-1 or $
        y lt 0 or y gt sz_grs[2]-1 then continue
      spectrum = reform(grs_data[x, y, *])
; Interpolate to common velocity scale
      v_std = findgen(1000)*h.cdelt[2]/1e3-50.0
      specout = interpol(spectrum, h.v, v_std)
      specout[where(v_std lt min(h.v) or v_std gt max(h.v))] = !values.f_nan
      runspec = runspec+specout*wts[j]
    endfor
    specout = runspec/total(wts)

    str[i].grs_vel = v_std
    str[i].grs_spec = specout
  endfor 

  return
end
