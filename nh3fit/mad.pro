function mad, x, window = window, finite = finite, dimension = dim
;+
; NAME:
;   MAD
; PURPOSE:
;   To calculate the Median Absolute Deviataion of a set of data in
;   order to calucate the RMS of the noise.
;
; CALLING SEQUENCE:
;   sigma = MAD(X)
;
; INPUTS:
;   X -- A data array
;
; KEYWORD PARAMETERS:
;   None
;
; OUTPUTS:
;   Sigma -- The standard deviation of the data.
;
; MODIFICATION HISTORY:
;
;       Fri Feb 4 16:40:17 2011, erosolo <erosolo@>
;
;		Added in Adam Ginsburg's addition of the dimension
;
;       Mon Oct 4 2004, Adam Leroy <aleroy@astro>
;               Altered MAD to consider only finite values if
;               the finite keyword is on. NB: you may not always want this.
;
;       Tue Oct 7 15:59:16 2003, Erik Rosolowsky <eros@cosmic>
;		Added Compatibility for distributions with non-zero
;		mean (oops).
;
;       Mon Oct 6 13:26:11 2003, Erik Rosolowsky <eros@cosmic>
;		Written.
;
;
;-


  if n_elements(dim) ne 0 then begin
     medarr = rebin(median(x,dim=dim),size(x,/dim),/sample)
     mad = median(abs(x-medarr),dim=dim)/0.6745
  endif else if (n_elements(window) eq 0) then begin
     if (keyword_set(finite)) then begin
        ind = where(finite(x) eq 1)
        mad = median(abs(x[ind]-median(x[ind])))/0.6745
     endif else $
        mad = median(abs(x-median(x)))/0.6745
  endif else begin
     mad = dblarr(n_elements(x))
     mad = median(abs(x-median(x, window)), window)/0.6745
  endelse

  return, mad
end

