function mrs, decomp,  thresh = thresh
;+
; NAME:
;   MRS
; PURPOSE:
;   Return the Multi-Resolution support for a given threshold or array
;   of thresholds.
;
; CALLING SEQUENCE:
;   support = MRS( decomp [, thresh = thresh])
;
; INPUTS:
;   DECOMP -- An a trous image decomposition from the function ATROUS.PRO
;
; KEYWORD PARAMETERS:
;   THRESH -- The threshold to calculate the support of structure.  It
;             can be set to an N-element array containing the
;             threshold for each value of the scale.
;             
;
; OUTPUTS:
;   SUPPORT -- The multiresolution support, a byte array with
;              containing the number of scales at which that pixel is
;              significant. 
;
; MODIFICATION HISTORY:
;
;       Mon Oct 6 21:46:34 2003, Erik Rosolowsky <eros@cosmic>
;		Written
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

  sz = size(decomp)
  n_scales = sz[3]-1

  if n_elements(thresh) eq 1 and n_scales gt 1 then $
    thresh = replicate(thresh, n_scales)
  if n_elements(thresh) eq 0 then thresh = replicate(3, n_scales)
  if n_elements(thresh) lt n_scales then $
    thresh = [thresh, replicate(thresh[n_elements(thresh)-1], $
                                n_scales-n_elements(thresh))]

  support = bytarr(sz[1], sz[2])
  for k = 0, n_scales-1 do begin
    coeffs = decomp[*, *, k+1]
    sigma = mad(coeffs)
    support = support+(abs(coeffs) gt (thresh*sigma)[0])
  endfor

  return, support
end
