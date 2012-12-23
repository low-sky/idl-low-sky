function pvcut, cube, start_pix = sp, stop_pix = ep, length = length, $
                inerror = inerror, outerror = outerror

;+
; NAME:
;    pvcut
; PURPOSE:
;    Extract a position-velocity cut from a data cube (pos-pos-vel).
;    Old code -- suggest using cuberot.pro instead.
; CALLING SEQUENCE:
;    cut = PVCUT(data_cube, start_pix=[x0,y0], stop_pix=[x1,y1] [,
;    length=length, inerror=inerror, outerror=outerror])
;
; INPUTS:
;    DATA_CUBE - A data cube containing spectral information
;    
; KEYWORD PARAMETERS:
;    START_PIX - A 2 element vector containing the pixel coordinates
;                of the beginning of the cut.
;    STOP_PIX - A 2 element vector containing the pixel coordinates of
;              the end of the cut.
;    LENGTH - Set this keyword to force the length to be a set number
;             of pixels.
;    INERROR - A 2 dimensional array containing the errors in each
;              spectrum at the corresponding position in the cube.
;    OUTERROR - Set this keyword to return a 1 dimensional array with
;               each element corresponding to the error in each pixel.
; OUTPUTS:
;    CUT - A two dimensional array containing position in the first
;          dimesion and velocity in the second dimension.
;
; MODIFICATION HISTORY:
;
;       Added error estimations/propagations
;       Wed Oct 17 14:21:45 2001, Erik Rosolowsky <eros@cosmic>
;
;       Written - Mon Nov 27 19:27:09 2000, Erik Rosolowsky
;       <eros@cosmic>
;-
  if not keyword_set(sp) and not keyword_set(ep) then begin 
    message, 'Both START_PIX and END_PIX keywords must be set.', /con
    return, 0
  endif
  bange = !except 
  !except = 0
  sp = float(sp)
  ep = float(ep)
  if not keyword_set(length) then length = (sqrt(total((sp-ep)^2)))
  uvec = (ep-sp)/length
  sz = size(cube)
  if not keyword_set(inerror) then inerror = fltarr(sz[1], sz[2])
  ecube = fltarr(sz[1], sz[2], sz[3])

  output = fltarr(length, sz[3])
  outerror = fltarr(length)
  ct = 0
  endpix = (0.5+findgen(length))#uvec+replicate(1., length)#([0.5, 0.5]+sp)
  loc = sp-0.5*uvec+[0.5, 0.5]

  while ct lt floor(length)  do begin

    cur_pix = floor(loc)
; Check to see if the pixel is in the data cube
    test = 1-(((cur_pix[0] lt 0)+(cur_pix[0] gt sz[1]-1))+$
              ((cur_pix[1] lt 0)+(cur_pix[1] gt sz[1]-1)) gt 0)
    if test then begin
      cur_spec = cube[cur_pix[0], cur_pix[1], *]
      cur_err = inerror[cur_pix[0], cur_pix[1]]
    endif else begin
      cur_spec = fltarr(sz[3])
      cur_err = 0.
    endelse
; Create Length vector [l_top,l_bot,l_left,l_right,l_end]
    lengths = [ (endpix[ct, 0]-loc[0])/(uvec[0]), $
                (endpix[ct, 1]-loc[1])/(uvec[1]), $
                (cur_pix[1]+1-loc[1])/uvec[1], $
                (cur_pix[1]-loc[1])/uvec[1], $
                (cur_pix[0]-loc[0])/uvec[0], $
                (cur_pix[0]+1-loc[0])/uvec[0]]            
    index = where(lengths gt 0)
    hold = min(lengths[where(lengths gt 0)], ind2, /nan)
    ind = index[ind2]
    output[ct, *] = output[ct, *]+$
      lengths[ind]*cur_spec
    outerror[ct] = outerror[ct]+lengths[ind]*cur_err
    loc = loc+uvec*lengths[ind]
    if (ind eq 0) or (ind eq 1) then ct = ct+1
  endwhile
  kill = check_math()
  !except = bange
  if sz[0] eq 2 then output = output[*, 0] ; Check for a 2-D input and convert.
  return, output
end

