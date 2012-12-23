pro dwt, x, trim = trim, expand = expand, pad = pad, wc = wc, $
         inverse = inverse, min = mn, max = mx, _extra = ex
;+
; NAME:
;    DWT
; PURPOSE:
;    Subroutine to perform a discrete wavelet transform on a time series.
;
; CALLING SEQUENCE:
;    DWT, X , wc = wc /trim, /expand, /pad, /inverse])
;
; INPUTS:
;    X -- A 1-D or 2-D image
;
; KEYWORD PARAMETERS:
;    TRIM, EXPAND, PAD -- determine what to do if the time series is
;                         not of length 2^n.  TRIM cuts to next lowest
;                         power, EXPAND CONGRIDS to next highest
;                         power, PAD fills with zeros.
;    INVERSE -- Perform an inverse transform
;    MIN, MAX -- Minimum and maximum scales to analyze.  Defaults to
;                the smallest power encomapssing the wavelet for MIN
;                and the entire array for MAX. Measured in pixels
;    Wavelet Names -- /COIF2, /COIF3, /DEB4, /DEB6, or /HAAR
; OUTPUTS:
;   WC -- The wavelet Coefficients.  This is a keyword set.
;
; EXAMPLE:
;   To perform the Coiflet wavelet transform of order 3 on a time
;   series:
;    IDL> t = findgen(1024)      ; generate time vector
;    IDL> x = sin(t/10)          ; generate time series
;    IDL> dwt, x, wc = wc, /coif3; Perform transform
;    IDL> plot, wc               ; Plots the wavelet coefficients
;
;   To perform the inverse transform on wavelet coefficents WC
;    IDL> dwt, wc, wc = x2, /coif3 ; Perform inv. transform
;    IDL> plot, t, x2              ; Plot inv. transformed data
;
; RESTRICTIONS:
;   Does everything with doubles.  Hope that's okay.  Passes extra
;   keywords to GET_COEFFS (ultimately) so that the flag moderated
;   GET_COEFFS doesn't need a lot of string matching.
;
; MODIFICATION HISTORY:
;
;       Mon Jul 19 13:35:54 2004, Erik Rosolowsky <eros@cosmic>
;		Removed extraneous assignment definition that hampered
;		keywords.  Thanks to Harish Gadhavi for pointing this out.
;
;       Wed Mar 26 12:17:52 2003, Erik Rosolowsky <eros@cosmic>
;		Written at beginning.
;; LICENSE: This program is free software; you can redistribute it and/or
; modify it under the terms of the GNU General Public License
; as published by the Free Software Foundation; either version 2
; of the License, or (at your option) any later version.

; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.

; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
;-

; Set default to COIF2 wavelet.
  if n_elements(ex) eq 0 then ex = {COIF2:1b}
  ndim = size(x, /n_dim)
  nelts = size(x, /n_dim) eq 2 ? (size(x))[1] : n_elements(x) 
  pow = alog(double(nelts))/alog(2d0)
  targpow = ceil(pow)

  
  if not keyword_set(pad) or keyword_set(expand) then trim = 1b
; Handle arrays that aren't 2^N
  if ndim eq 2 then begin
; 2-D case
    if targpow ne pow then begin
      if keyword_set(pad) then begin
        signal = dblarr(2L^targpow, 2L^targpow)
        signal[0:nelts-1, 0:nelts-1] = x
      endif
      if keyword_set(trim) then signal = x[0:2L^(targpow-1)-1, $
                                           0:2L^(targpow-1)-1]
      if keyword_set(expand) then signal = congrid(x, 2L^targpow, 2L^targpow)
    endif else signal = x
  endif else begin
;1-D case
    if targpow ne pow then begin
      if keyword_set(pad) then begin
        signal = dblarr(2L^targpow)
        signal[0:n_elements(x)-1] = x
      endif
      if keyword_set(trim) then signal = x[0:2L^(targpow-1)-1]
      if keyword_set(expand) then signal = congrid(x, 2L^targpow)
    endif else signal = x
  endelse
; Now that that's done, reset some parameters.
  nelts = size(signal, /n_dim) eq 2 ? (size(signal))[1] : $
          n_elements(signal) 
  pow = alog(nelts)/alog(2d0)

; Calculate the number of transforms to perform by the range of powers
; of 2 between the MIN and MAX.  
  n_coeffs = n_elements(get_coeffs(_extra = ex)) 
  if n_elements(mn) eq 0 then mn = 2d0^(ceil(alog(n_coeffs)/alog(2))-1)
  if n_elements(mx) eq 0 then mx = nelts
  niters = (alog(mx)-alog(mn))/alog(2d0)

  if keyword_set(inverse) then begin
; Perform inverse transform from MIN scale by powers of 2 to MAX scale.
    range = mn
    for i = 0, niters-1 do begin
      range = 2*range
      print, range
      pwt, signal, range, wc = wc, /inv, _extra = ex
      signal = wc
    endfor
  endif else begin
; Otherwise, do regular transform from MAX by powers of 2 to MIN.
    range = mx
    for i = 0, niters-1 do begin
      print, range
      pwt, signal, range, wc = wc, _extra = ex
      signal = wc
      range = range/2
    endfor
  endelse
  
; That's all folks
  wc = signal


  return
end



