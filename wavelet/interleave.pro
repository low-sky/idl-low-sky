function interleave, array, range, inverse = inverse
;+
; NAME:
;   INTERLEAVE
; PURPOSE:
;   For an 2N element array, the program interleaves the last N
;   elements with the first N elements.
;
; CALLING SEQUENCE:
;   output = INTERLEAVE(X, [, range, inverse = inverse])
;
; INPUTS:
;  X -- A vector to be operated upon
;  RANGE -- Perform INTERLEAVE on the first RANGE elements of the array.
; KEYWORD PARAMETERS:
;  INVERSE -- Instead of interleaving, separate every other element
;             and move to the back.
;
; NOTES:
;  For images, the interleaving is performed only on the columns of
;  the matrix (the second dimension).
; 
; OUTPUTS:
;  OUTPUT -- the interleaved array.
;
; MODIFICATION HISTORY:
;
;       Wed Mar 26 13:36:46 2003, Erik Rosolowsky <eros@cosmic>
;		Written for use with wavelets.
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


  if n_elements(range) eq 0 then begin
    if size(array, /n_dim) eq 2 then begin
      sz = size(array)
      range = sz[1]
    endif else range = n_elements(array) 
  endif
  
  if size(array, /n_dim) eq 2 then begin
    sz = size(array)
    output = array
    half = range/2
    front = lindgen(half)
    if keyword_set(inverse) then begin
      output[*, 0:half-1] = array[*, 2*front]
      output[*, half:2*half-1] = array[*, 2*front+1]
    endif else begin
      back = (lindgen(half)+half)
      output[*, 2*front] = array[*, front]
      output[*, 2*(back-half)+1] = array[*, back]
    endelse
  endif else begin
    output = array
    half = range/2
    front = lindgen(half)
    if keyword_set(inverse) then begin
      output[0:half-1] = array[2*front]
      output[half:2*half-1] = array[2*front+1]
    endif else begin
      back = lindgen(half)+half
      output[2*front] = array[front]
      output[2*(back-half)+1] = array[back]
    endelse
  endelse
  return, output
end

