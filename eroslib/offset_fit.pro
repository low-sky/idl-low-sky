function offset_fit, x, y, error = error, eoffset = eoffset
;+
; NAME:
;   OFFSET_FIT
; PURPOSE:
;   Least-squares est. of  a constant offset between two data sets.
;
; CALLING SEQUENCE:
;   offset = OFFSET_FIT(X, Y, [error = error])
;
; INPUTS:
;   X, Y -- Two sets of DATA
;
; KEYWORD PARAMETERS:
;   ERROR -- Error in the Y-value
;
; OUTPUTS:
;   OFFSET -- The offset of Y above X.
;   EOFFSET -- Error in derived offset.
; MODIFICATION HISTORY:
;
;       Mon Oct 18 12:28:28 2004, <eros@master>
;		Written.
;
;-

   if n_elements(error) eq n_elements(x) then $
     wt = 1/error^2 else wt = replicate(1, n_elements(x))

   oset = (total(wt*y)-total(wt*x))/(total(wt))

   eoffset = sqrt(1/total(wt))

  return, oset
end
