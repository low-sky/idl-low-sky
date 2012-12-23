pro gv, x, y
;+
; NAME:
;   GV
; PURPOSE:
;   To grab X and Y values from a position in a plot, no Z value is
;   given.  
;
; CALLING SEQUENCE:
;   GV
;
; INPUTS:
;   None (mouse control)
;
; KEYWORD PARAMETERS:
;   None (we're talking short and sweet here)
;
; OUTPUTS:
;   Print to screen
;
; MODIFICATION HISTORY:
;       Written with exasperation that it didn't already exist.
;       Wed Aug 15 10:38:38 2001, Erik Rosolowsky <eros@cosmic>
;
;-


message, 'Click on plot to return point value', /con

cursor, x, y, /data, /up

print, 'X value:', x
print, 'Y value:', y

return
end
