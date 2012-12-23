function lasso, x_in, y_in
;+
; NAME:
;   LASSO
; PURPOSE:
;   On an XY plots, selects indices in the plotting vector within a subregion
;
; CALLING SEQUENCE:
;   IDL> plot-command
;   IDL> index = LASSO(x, y)
;
; INPUTS:
;   X, Y -- the X and Y vectors used to make the plot.
; OUTPUTS:
;   INDEX -- The index vector within x and y of the selected region.
;
; MODIFICATION HISTORY:
;
;	Wed Aug  9 13:47:45 2006, Erik -- Finally documented.
;
;-



  null = defroi(!d.x_size, !d.y_size, xverts, yverts, /noregion)


; Build an ROI object
  roi = obj_new('IDLanROI', xverts, yverts)

; Convert input data to pixel coordinates.
  x = (x_in*!x.s[1]+!x.s[0])*!D.x_size
  y = (y_in*!y.s[1]+!y.s[0])*!D.y_size

; Run the ContainsPoints function on the input data points
  pttest = roi -> ContainsPoints(x, y)


; Lasso what's inside the border includes vertices and on border.
  indices = where(pttest ge 1, ct)

  return, indices
end
