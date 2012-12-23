pro buildmat, n, m = matrix, sparse = sparse, _extra = ex, nbound = nbound
;+
; NAME:
;   BUILDMAT
; PURPOSE:
;   To build the wavelet transform matrix for a given transform and scale.
;
; CALLING SEQUENCE:
;   BUILDMAT, size, m = m, /SPARSE, nbound = nbound
;
; INPUTS:
;   SIZE -- The (1-D) size of a matrix to fill
;
; KEYWORD PARAMETERS:
;   NBOUND -- The size of the matrix to insert the transform matrix
;             inside (NBOUND > SIZE).  The remainder of the matrix is
;             filled with the identity matrix.
;   /SPARSE -- Set this matrix to make sparse matrices.
; OUTPUTS:
;   M -- The transform matrix.
;
; MODIFICATION HISTORY:
;
;       Tue Apr 13 13:55:33 2004, Erik Rosolowsky <eros@cosmic>
;		Documented, but still obfuscated.
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

  if n_elements(nbound) eq 0 then nbound = n

  coeffs = get_coeffs(_extra = ex)
  modulation = shift( -1+2*(indgen(n_elements(coeffs)) mod 2), 1)
  smooth = coeffs
  detail = modulation*reverse(coeffs)
  if keyword_set(sparse) then begin
    rows = lindgen(n)#replicate(1L, n_elements(coeffs))
    columns = (2*floor(rows/2)+replicate(1, n)#lindgen(n_elements(coeffs))) $
              mod n
    values = (replicate(1, n)#smooth)*(1b-(rows mod 2))+$
             (replicate(1, n)#detail)*(rows mod 2)
    if nbound gt n then begin
      pad = (lindgen(nbound-n)+n)
      rows = [rows[*], pad]
      columns = [columns[*], pad]
      values = [values[*], intarr(n_elements(pad))+1]
    endif
      matrix = sprsin(columns, rows, values, nbound, /double)
  endif else begin 
    smoothrow = [smooth, dblarr(n-n_elements(coeffs))]
    detailrow = [detail, dblarr(n-n_elements(coeffs))]
    matrix = dblarr(nbound, nbound)
    for i = 0, n-1 do begin
      if i mod 2 then matrix[0:n-1, i] = shift(detailrow, 2*(fix(i)/2)) else $
        matrix[0:n-1, i] = shift(smoothrow, 2*(fix(i)/2))
    endfor
    if nbound gt n then begin
      pad = (lindgen(nbound-n)+n)
      matrix[pad, pad] = 1
    endif
  endelse
  return
end
