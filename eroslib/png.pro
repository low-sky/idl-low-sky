pro png, plotname

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
  write_png, plotname, image

  return
end
