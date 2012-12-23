pro reversect
;+
; NAME:
;   REVERSECT
; PURPOSE:
;   Reverses the sense of the color table.
;
; CALLING SEQUENCE:
;   REVERSECT
;
; INPUTS:
;   none
;
; KEYWORD PARAMETERS:
;   none
;
; OUTPUTS:
;   none
;
; MODIFICATION HISTORY:
;      Documented. 
;       Wed Nov 21 12:20:42 2001, Erik Rosolowsky <eros@cosmic>
;
;		
;
;-


tvlct, r, g, b, /get
r = reverse(r)
g = reverse(g)
b = reverse(b)
tvlct, r, g, b

  return
end
