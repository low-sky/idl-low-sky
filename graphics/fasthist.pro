pro fasthist, data2, log = log
;+
; NAME:
;   FASTHIST
; PURPOSE:
;   To create a fast, dumb histogram of the data to determine the
;   basic properties of the data.
;
; CALLING SEQUENCE:
;   FASTHIST, data
;
; INPUTS:
;   DATA -- The data to be histogrammed.
;
; KEYWORD PARAMETERS:
;   LOG -- Set the values to show the logarithm of the histogram.
;          This is the only keyword because it's damn useful.
;
; OUTPUTS:
;   A nice histogram of the data.
;
; MODIFICATION HISTORY:
;       Concieved in frustration --
;       Fri Jun 1 22:14:38 2001, Erik Rosolowsky <eros@cosmic>
;-		



  if n_elements(data2) eq 0 then begin
    message, 'Variable contains no elements.  Foo!', /con
    return
  endif

  ind = where(finite(data2), nelts)
;  data = data2[where(data2 eq data2)]

  if nelts eq 0 then begin
    message, 'No valid data.  Foo!.', /con
    return
  end

  data = data2[ind]


  min = min(data, /nan)
  max = max(data, /nan)

  nbins = ceil(sqrt(float(nelts)))

  binsize = float(max-min)/nbins
  if binsize eq 0 then begin
    message, 'All data are the same and have value: '+string(max), /con
    return
  endif
  x = (findgen(nbins+1))*binsize+min+binsize/2
  h = histogram(float(data), min = min, max = max, binsize = binsize)
  x = [min(x)-binsize, x, max(x)+binsize]
  h = [0, h, 0]
  if keyword_set(log) then $
    plot, x, h, psym = 10, xtitle = 'Data Values', ytitle = 'Counts', $
          /ylog, yrange = [7e-1, 1.1*max(h)], /yst else $
    plot, x, h, psym = 10, xtitle = 'Data Values', ytitle = 'Counts'
  return
end


