function fakeclouds, sz, xpos = xpos, ypos = ypos, vpos = vpos, $
                     nclouds = nclouds, amps = amps, xwidth = xwidth, $
                     ywidth = ywidth, vwidth = vwidth, peanut = peanut, $
                     dpeanut = dpeanut
;+
; NAME:
;  fakeclouds.pro
;
; PURPOSE:
;  To generate a cube of fake clouds.
;
; CALLING SEQUENCE:
;
; cube = FAKECLOUDS(sz)
;
; INPUTS:
; sz -- An IDL size structure (or 4 elt array) indicating the size of
;       the data cube.
;
;
; KEYWORD PARAMETERS:
;  XPOS, YPOS, VPOS -- N element vectors giving the position of the N clouds
;  AMPS -- N-element amplitude vector.
;  XWIDTH, YWIDTH, VWIDTH -- N-element vectors giving the widths (in
;                            pixels) of the N clouds.
;  PEANUT -- Generate a typical peanut with PEANUT pixels between the
;            centers.  
;  DPEANUT -- Offset between peanut in units of peanut width (default=1)
; OUTPUTS:
;
;  CUBE -- A data cube containing the fake clouds.  
;
; MODIFICATION HISTORY:
;
;       Tue Jul 5 15:39:43 2005, Erik Rosolowsky
;       <erosolow@transit.cfa.harvard.edu>
;
;		Documented.
;
;-

  output = fltarr(sz[1], sz[2], sz[3])
  v = findgen(sz[3])
  x = findgen(sz[1])
  y = findgen(sz[2])
  if not keyword_set(nclouds) then nclouds = 20
  if not keyword_set(amps) then amps = replicate(5, nclouds) 
  if n_elements(xpos) eq 0  then xpos = (randomu(seed, nclouds)*0.8+0.1)*sz[1]
  if n_elements(ypos) eq 0 then ypos = (randomu(seed, nclouds)*0.8+0.1)*sz[2]
  if n_elements(vpos) eq 0 then vpos = (randomu(seed, nclouds)*0.8+0.1)*sz[3]
  if n_elements(xwidth) eq 0 then xwidth = replicate(1.5, nclouds)
  if n_elements(ywidth) eq 0 then ywidth = replicate(1.5, nclouds)
  if n_elements(vwidth) eq 0 then vwidth = replicate(1.5, nclouds)

  if n_elements(peanut) gt 0 then begin
    if n_elements(dpeanut) eq 0 then dpeanut = 1.0
    peanut = float(peanut)
    nclouds = 2
    amps = [1., 1.]
    xpos = sz[1]/2+[-peanut, peanut]*dpeanut
    ypos = sz[2]/2*[1, 1]
    vpos = sz[3]/2*[1, 1]
    xwidth = [peanut, peanut]/2
    ywidth = xwidth
    vwidth = ywidth
    
  endif
  for i = 0, n_elements(amps)-1 do begin
    vvec = reform(exp(-(v-vpos[i])^2/(2*vwidth[i]^2)), [1, 1, sz[3]])
    xvec = reform(exp(-(x-xpos[i])^2/(2*xwidth[i]^2)), [sz[1], 1, 1])
    yvec = reform(exp(-(y-ypos[i])^2/(2*ywidth[i]^2)), [1, sz[2], 1])
    vamp = rebin(vvec, sz[1], sz[2], sz[3])
    xamp = rebin(xvec, sz[1], sz[2], sz[3])
    yamp = rebin(yvec, sz[1], sz[2], sz[3])    
    clump = amps[i]*xamp*yamp*vamp
    output = output+clump
  endfor 
  
  return, output
end
