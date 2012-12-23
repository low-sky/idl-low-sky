pro plotindex, x, y, index = index, _extra = ex, overplot = overplot, $
               label = label
;+
; NAME:
;   PLOTINDEX
; PURPOSE:
;   To plot X vs. Y with the symbol being the index of the input vector.
;
; CALLING SEQUENCE:
;   PLOTINDEX, x, y, [,index = index]
;
; INPUTS:
;   X,Y -- two vectors of equal length
;
; KEYWORD PARAMETERS:
;   INDEX -- Indices to be used for labelling.  Defaults to the index
;            of Y.
;   /OVERPLOT -- set this keyword to overplot on an existing window
;   LABEL -- Vector of labels to use in lieu of index
;   Also accepts all regular plotting keywords.
; OUTPUTS:
;   A plot
;
; MODIFICATION HISTORY:
;       Graduated to library.
;       Sun Jul 14 12:47:48 2002, Erik Rosolowsky <eros@cosmic>
;-


  if not keyword_set(index) then index = indgen(n_elements(x))
  if not keyword_set(label) then label =  strcompress(string(index), /rem)
  if not keyword_set(overplot) then $ 
    plot, x, y, _extra = ex, /nodata

  for i = 0, n_elements(index)-1 do begin
    xyouts, x[index[i]], y[index[i]], label[i] $
     , align = 0.5, _extra = ex
  endfor
  return
end
