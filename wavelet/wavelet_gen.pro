function wavelet_gen, nelts, _extra = ex, scaling = scaling
;+
; This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
; NAME:
;   WAVELET_GEN
; PURPOSE:
;   Generate the graph of a wavelet for examination.
;
; CALLING SEQUENCE:
;   result = WAVELET_GEN(N_ELEMENTS, [/COIF2,/COIF3,/HAAR,/DEB4,/DEB6])
;
; INPUTS:
;   N_ELEMENTS -- Number of elements in generated wavelet.  Program
;                 returns a vector with length equal to the smallest
;                 power of two that is greater or equal to N_ELEMENTS
;   
; KEYWORD PARAMETERS:
;   /SCALING -- Set this flag to generate the scaling function instead
;               of the wavelet.
;   /COIF2 -- Generate a Coiflet wavelet of order 2
;   /COIF3 -- Generate a Coiflet wavelet of order 3
;   /HAAR -- Generate a Haar wavelet
;   /DEB4 -- Generate a Debaucies wavelet of order 4
;   /DEB6 -- Generate a Debaucies wavelet of order 6
;   See documentation on GET_COEFFS for all possible wavelets.
; OUTPUTS:
;   RESULT -- The wavelet
;
; MODIFICATION HISTORY:
;
;       Mon Apr 19 14:39:15 2004, Erik Rosolowsky <eros@cosmic>
;		Written at Carl's Behest.

; LICENSE: This program is free software; you can redistribute it and/or
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

  coeffs = get_coeffs(_extra = ex)
  ncoeffs = n_elements(coeffs) 
  
  pow = ceil(alog(nelts)/alog(2))
  array = fltarr(2L^pow)
  pow2 = ceil(alog(ncoeffs)/alog(2))

  if keyword_set(scaling) then array[0] = 1 else array[2L^pow2] = 1
  dwt, array, /inv, wc = wc, _extra = ex

  return, wc
end
