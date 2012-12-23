pro pwt, x, range,  wc = wc, inverse = inverse, _extra = ex
;+
; NAME:
;    PWT
; PURPOSE:
;    Subroutine to perform a single discrete wavelet 
;    transform on a time series.
;
; CALLING SEQUENCE:
;    coeffs = PWT(X [, range, /inverse, WC = WC])
;
; INPUTS:
;    X -- A 1-D or 2-D vector
;    RANGE -- Number of elements to be used in analysis (starting
;             from the first entry).
; KEYWORD PARAMETERS:
;    INVERSE -- Perform the inverse transform.
;    Extra Keywords passed to BUILDMAT
; OUTPUTS:
;   WC -- The wavelet Coefficients.
;
; MODIFICATION HISTORY:
;
;       Thu Mar 27 17:38:23 2003, Erik Rosolowsky <eros@cosmic>
;		Spilt off PWT to its own subroutine.
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


  signal = x
; First do images...  Note, the PWT only operates on the columns of
; the first image.  DWT must be used to transpose and get the
; remainder of the image.
  if size(signal, /n_dimensions) eq 2 then begin
    sz = size(signal)
    if n_elements(range) eq 0 then range = sz[1]
    if keyword_set(inverse) then begin
; First put smooth and difference components back together.
      signal = interleave(signal, range)
; Turn the image sparse
      cpt_mat = sprsin(signal)
      buildmat, range, m = m, /spa, _extra = ex, nbound = sz[1]
      m_inv = sprstp(m)
; Get a transform matrix and invert it.  NBOUND allows the operation
; to be conducted on the full matrix at once.
      subsig = sprsab(m_inv, cpt_mat)
      signal = fulstr(subsig)
; Multiply and then return to full storage
    endif else begin
; Get transform matrix
      buildmat, range, m = m, _extra = ex, nbound = sz[1], /spa
      s1 = signal
      s1 = sprsin(s1)
; Multiply against image.
      pw1 = sprsab(m, s1)
      s1 = fulstr(pw1)
; Separate the smooth and detail components.
      signal = interleave(s1, range, /inv)
    endelse
    wc = signal
  endif else begin
; This is the 1-D case
    nelts = n_elements(signal) 
    if n_elements(range) eq 0 then range = nelts

    if keyword_set(inverse) then begin
; For inverse, re-interleave the smooth and detail coeffs
      signal = interleave(signal, range)
; Build a transform matrix.
      buildmat, range, m = m, /spa, _extra = ex
; Invert it
      m_inv = sprstp(m)
; Multiply
      subsig = sprsax(m_inv, signal[0:range-1])
;Stick back in matrix.
      signal[0:range-1] = subsig
    endif else begin
; Build transform
      buildmat, range, m = m, /spa, _extra = ex
; Multiply
      subsig = sprsax(m, signal[0:range-1])
; Interleave out smooth and detail coefficients.
      signal[0:range-1] = interleave(subsig, /inv)
    endelse
    wc = signal
  endelse
  return
end



