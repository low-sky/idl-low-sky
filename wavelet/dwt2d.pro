pro dwt2d, x, _extra = ex, wc = wc

;+
; NAME:
;   DWT2D 
; PURPOSE:
;   Wrapper program to perform a 2-D DWT on an image.
;
; CALLING SEQUENCE:
;    DWT2D, X , wc = wc /trim, /expand, /pad, /inverse])
;
; INPUTS:
;    X -- A 2-D image
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
;       Tue Apr 13 14:01:10 2004, Erik Rosolowsky <eros@cosmic>
;		Written to do the transpose right...
; ; LICENSE: This program is free software; you can redistribute it and/or
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

  if keyword_set(inverse) then begin
    wc1 = transpose(x)
    dwt, wc1, _extra = ex, wc = wc2, /inverse
    wc2 = transpose(wc2)
    dwt, wc2, _extra = ex, wc = wc, /inverse
  endif else begin
    dwt, x, _extra = ex, wc = wc2
    wc2 = transpose(wc2)
    dwt, wc2, _extra = ex, wc = wc
    wc = transpose(wc)
  endelse
  

  return
end
