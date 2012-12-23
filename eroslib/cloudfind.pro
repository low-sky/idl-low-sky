pro cloudfind, cube, level, ax = ax, az = az
;+
; NAME:
;   CLOUDFIND
; PURPOSE:
;   A simple bundle to plot an isosurface of a data cube IN 3D!!!
;
; CALLING SEQUENCE:
;   CLOUDFIND, datacube, level
;
; INPUTS:
;   DATACUBE -- Datacube to be analyzed
;   LEVEL -- Isosurface level to be plotted.
;   AX, AZ -- Changes perspective.  See documentation on SCALE3 in IDL.
; KEYWORD PARAMETERS:
;  NONE
;
; OUTPUTS:
;  Pretty Pictures.
;
; MODIFICATION HISTORY:
;       Addex AX and AZ keywords.
;       Wed Jun 5 14:34:57 2002, Erik Rosolowsky <eros@cosmic>
;       Documented.
;       Wed Nov 21 11:34:03 2001, Erik Rosolowsky <eros@cosmic>
;-

  sz = size(cube)

  if n_elements(az) eq 0 then az = 30
  if n_elements(ax) eq 0 then ax = 30

  nelts = max([n_elements(ax), n_elements(az)]) 
  shade_volume, cube, level, vert, poly

  if n_elements(ax) lt nelts then $
    ax = [ax, replicate(ax[n_elements(ax)-1], nelts-n_elements(ax))]


  if n_elements(az) lt nelts then $
    az = [az, replicate(az[n_elements(az)-1], nelts-n_elements(az))]


  for i = 0, nelts-1 do begin
    scale3, xrange = [0, sz[1]], yrange = [0, sz[2]], zrange = [0, sz[3]], $
            ax = ax[i], az = az[i]
    tv, polyshade(vert, poly, /t3d)
    nx = sz[1]
    ny = sz[2]
    nz = sz[3]
    plots, 0, 0, 0, /t3d
    plots, [nx, nx, 0, 0], [0, ny, ny, 0], fltarr(4), /t3d, /continue
    plots, 0, 0, nz, /t3d
    plots, [nx, nx, 0, 0], [0, ny, ny, 0], replicate(nz, 4), /t3d, /continue
    plots, 0, 0, 0, /t3d
    plots, 0, 0, nz, /t3d, /continue
    plots, nx, 0, 0, /t3d
    plots, nx, 0, nz, /t3d, /continue
    plots, 0, ny, 0, /t3d
    plots, 0, ny, nz, /t3d, /continue
    plots, nx, ny, 0, /t3d
    plots, nx, ny, nz, /t3d, /continue
  endfor
  return
end
