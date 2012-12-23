function bin, data, key, _extra = extra, average = average, total = total, $
              x = x, min = min, max = max
;+
; NAME:
;   BIN
; PURPOSE:
;   To bin a data vector according to the values found in the KEY vector.
;
; CALLING SEQUENCE:
;   binned_vector = BIN(data, key [, average = average, total = total,
;                       x = x])
;
; INPUTS:
;   DATA -- The data vector to be binned.
;   KEY -- The vector on which to key the binning.
; KEYWORD PARAMETERS:
;   AVERAGE -- Average together all the values in a bin.
;   TOTAL -- Total all the values in a bin. (DEFAULT)
;   X -- Contains the abcissa values of the bins.
; OUTPUTS:
;   BINNED_VECTOR -- Contains the binned result.
;
; MODIFICATION HISTORY:
;       Written --
;       Tue Nov 20 09:29:15 2001, Erik Rosolowsky <eros@cosmic>
;-


if n_elements(data) ne n_elements(key) then begin
  message, 'DATA and KEY vectors must have the same length', /con
endif 

if not keyword_set(average) then total = 1 else total = 0
if not keyword_set(min) then min = min(key)
if not keyword_set(max) then max = max(key)

h = histogram(key, min = min, max = max, _extra = extra, rev = ri)
nelts = n_elements(h) 
binned_vector = fltarr(nelts)
for i = 0, nelts-1 do begin
  if ri[i] eq ri[i+1] then continue
  index = ri[ri[i]:ri[i+1]-1]
  binvals = data[index]
  bv = total(binvals)
  if not keyword_set(total) then bv = bv/n_elements(binvals) 
  binned_vector[i] = bv
endfor 
x = findgen(nelts)*(max-min)/nelts+min
  return, binned_vector
end


