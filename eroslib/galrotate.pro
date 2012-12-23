pro galrotate, fl, map = map, header = header

  data = readfitS(fl, hdr)
  hdr = degls(hdr)
  hdold = hdr
  heuler, hdr, /galactic
  extast, hdr, astrom
  sz = size(data)

  hypot = sqrt(sz[1]^2+sz[2]^2)
  bdr = ceil(0.5*(hypot-(sz[1] < sz[2])))
  hborder, data, hdr, npixel = bdr, value = !values.f_nan

  sz = size(Data)
  xy2ad, sz[1]/2, sz[2]/2, astrom, x00, y00
  xy2ad, sz[1]/2+1, sz[2]/2, astrom, x10, y10
  xy2ad, sz[1]/2, sz[2]/2+1, astrom, x01, y01

  dx0 = x10-x00
  dy0 = y10-y00
  dx1 = x01-x00
  dy1 = y01-y00

  rmat = [[dx0, dy0], $
          [dx1, dy1]]
  rmat = rmat/sqrt(abs(determ(rmat)))

  rotangle = atan(rmat[0, 0], rmat[1, 0])
  hrot, data, hdr, data2, hd2, (3*!pi/2-rotangle)*!radeg, sz[1]/2, sz[2]/2, 1

  mask = (data2 eq data2) and data ne 0.000

  xproj = total(mask, 2) gt 1
  yproj = total(mask, 1) gt 1

  minx = min(where(xproj))-1
  maxx = max(where(xproj))+2
  miny = min(where(yproj))-1
  maxy = max(where(yproj))+2

  hextract, data2, hd2, minx, maxx, miny, maxy

  map = data2
  header = hd2
  

  return
end
