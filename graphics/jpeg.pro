pro JPEG, plotname
;+
; NAME:
;   JPEG
; PURPOSE:
;   Writes the current 'X' plotting window to a JPEG file.
;
; CALLING SEQUENCE:
;   JPEG, filename
;
; INPUTS:
;   filename -- the filename to be written.
;
; KEYWORD PARAMETERS:
;   none.
;
; OUTPUTS:
;   A gif filename.
;
; MODIFICATION HISTORY:
;       Written --
;       Tue Apr 9 01:26:27 2002, Erik Rosolowsky <eros@cosmic>
;
;		
;
;-

  if n_elements(plotname) eq 0 then plotname = 'figure.png'

  tvlct, r, g, b, /get
  r = congrid(r, 256)
  g = congrid(g, 256)
  b = congrid(b, 256)
  
  im = float(tvrd())
  im = byte((im/max(im))*255)
  image = bytarr(3, !d.x_size, !d.y_size)
  image[0, *, *] = r[im]
  image[1, *, *] = g[im]
  image[2, *, *] = b[im]
  write_png, 'temp', image
  spawn, 'convert temp jpeg:'+plotname
  spawn, 'rm temp', /sh
  return
end
