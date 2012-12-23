pro ipacdump, bgps

; DUMPS a Bolocat catalog in IPAC format
;  s = sort(bgps.glon)
;  barr = bgps[s]
  barr=bgps
  openw, lun, 'bgps_ipac.txt', /get_lun
  

  baderr = where(1b-finite(bgps.eflux_40), ct)
  if ct gt 0 then bgps[baderr].eflux_40 = bgps[baderr].flux_40
  for i = 0, n_elements(barr)-1 do begin
    b = barr[i]

 ; CHANGE THIS!!!!
    mommaj = float(round(b.mommaj_as*100))/100 
    mommin = float(round(b.mommin_as*100))/100
    paout=b.posang/!pi*180+90
    if paout gt 180 then paout=paout-180
    if paout lt 0 then paout=paout+180
    pa=round(paout)
;    pa = round(b.posang/!pi*180)
    f = round(b.flux*1e3)/1e3
    ef = sqrt((2/33.*b.flux)^2+(sqrt(b.npix/23.8)*b.rms)^2)
    if ef ne ef then ef = 0.00
    ef = round(ef*1e3)/1e3

    f80 = round(b.flux_80*1e3)/1e3
    ef80 = b.eflux_80
    if ef80 ne ef80 then ef80 = 0.00
    ef80 = round(ef80*1e3)/1e3

    f120 = round(b.flux_120*1e3)/1e3
    ef120 = b.eflux_120
    if ef120 ne ef120 then ef120 = 0.00
    ef120 = round(ef120*1e3)/1e3

    f40 = round(b.flux_40*1e3)/1e3
    ef40 = b.eflux_40
    if ef40 ne ef40 then ef40 = 0.00
    ef40 = round(ef40*1e3)/1e3

    radius = decimals(b.rad_as, 2)
    sl = strlen(radius)
    if sl eq 5 then radius = ' '+radius
    if sl eq 4 then radius = '  '+radius
    
    ind = where(b.rad_as ne b.rad_as, ct)
    if ct gt 0 then radius = '  null'

    
; END CHANGE
    printf, lun, b.cloudnum, b.name, b.glon_max, b.glat_max, b.maxra, b.maxdec, b.glon, b.glat, $
            mommaj, mommin, pa, radius, f40, ef40, f80, ef80, f120, ef120, f, ef, $
            format = '(I6,2x,A20,2x,F13.7,2x,F13.7,2x,'+$
            'F13.7,2x,F13.7,2x, '+$
            'F13.7,2x,F13.7,2x, '+$
            'F6.2,2x,F6.2,8x,I4,2x,A6,2x,F7.3,6x,F7.3,'+$
            '2x,F7.3,6x,F7.3,2x,F7.3,6x,F7.3,2x,F7.3,6x,F7.3)'
  endfor 

  close, lun
  free_lun, lun

  return
end
