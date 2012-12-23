pro curve_extract, data, x, y
;+
; NAME:
;   CURVE_EXTRACT
; PURPOSE:
;   Extract data from a scanned 2-D image.  The program transforms
;   from pixel coordinates via POLYWARP to data coordinates after the
;   user establishes a transform.  Not Robustified.
;
; CALLING SEQUENCE:
;   CURVE_EXTRACT, IMAGE, X, Y
;
; INPUTS:
;   IMAGE -- A 2-D array that contains the image.
;
; KEYWORD PARAMETERS:
;   None.
;
; OUTPUTS:
;   X, Y -- Names of variable to store X and Y values in.
;
; MODIFICATION HISTORY:
;
;       Mon Nov 17 00:25:11 2003, Erik Rosolowsky <eros@cosmic>
;		Written with great Venganace and FURIOUS Anger.
;
;-


  setcolors, /sys
  disp, data, reserve = 12



  ct = 0
  
  print, 'Establish Coordinate System!'
  redo:
  
  print, 'Left Click on Points with known X-Y values'
  print, 'Middle Click to eliminate closest pt. from Transformation'
  print, 'Right Click when finished'
  print, 'Included points will be shown in RED'

  !mouse.button = 0

  while (!mouse.button ne 4)  do begin

    cursor, xcl, ycl, 4
    if !mouse.button eq 1 then begin
      plots, xcl, ycl, ps = 4,  color = !red
      read, 'Enter X-value: ', x0
      read, 'Enter Y-value: ', y0
      if ct eq 0. then begin
        gridx = xcl
        gridy = ycl
        data_x = x0
        data_y = y0
      endif else begin 
        gridx = [gridx, xcl]
        gridy = [gridy, ycl]
        data_x = [data_x, x0]
        data_y = [data_y, y0]
      endelse
      print, xcl, ycl, ' Added to grid'
      ct = ct+1  
    endif  

    if !mouse.button eq 2 then begin

      dvec = sqrt((xcl-gridx)^2+(ycl - gridy)^2)
      distance = min(dvec, ind)
      print, gridx[ind], gridy[ind], ' Removed from grid'
      plots, gridx[ind], gridy[ind], ps = 4,  color = !white
      if ct gt 1 then begin
        ct = ct-1
        goodinds = where(indgen(n_elements(gridx)) ne ind)
        gridx = gridx[goodinds]
        gridy = gridy[goodinds]
        data_x = data_x[goodinds]
        data_y = data_y[goodinds]
      endif else begin
        ct = 0
        girddec = 0
        gridx = 0
        gridy = 0
        print, 'WARNING!! Grid Empty'
      endelse
    endif
  endwhile

  deg = sqrt(ct)-1
  if deg lt 1 then begin
    message, 'Need more points for Transform', /con
    goto, redo
  endif

  polywarp, data_x, data_y, gridx, gridy, 1, kx, ky 

  print, 'Left Click on points along the curve!'
  print, 'Middle Click to eliminate nearest point'
  print, 'Right Click to finish'

  !mouse.button = 0
  ct = 0
  while (!mouse.button ne 4)  do begin
    cursor, xcl, ycl, 4
    if !mouse.button eq 1 then begin
      if ct eq 0. then begin
        gridx = xcl
        gridy = ycl
      endif else begin 
        gridx = [gridx, xcl]
        gridy = [gridy, ycl]
      endelse
      print, xcl, ycl, ' Added to grid'
      plots, xcl, ycl, ps = 4,  color = !blue
      ct = ct+1  
    endif  

    if !mouse.button eq 2 then begin
      dvec = sqrt((xcl-gridx)^2+(ycl - gridy)^2)
      distance = min(dvec, ind)
      print, gridx[ind], gridy[ind], ' Removed from grid'
      plots, gridx[ind], gridy[ind], ps = 4,  color = !white
      if ct gt 1 then begin
        ct = ct-1
        gridx = gridx[where(indgen(n_elements(gridx)) ne ind)]
        gridy = gridy[where(indgen(n_elements(gridy)) ne ind)]
      endif else begin
        ct = 0
        girddec = 0
        gridx = 0
        print, 'WARNING!! Grid Empty'
      endelse
    endif
  endwhile

  print, 'Transforming ...'

  xout = 0
  yout = 0
  for i = 0, deg do begin
    for j = 0, deg do begin
      xout = xout+kx[i, j]*gridx^j*gridy^i
      yout = yout+ky[i, j]*gridx^j*gridy^i
    endfor
  endfor
  window, /free
  plot, xout, yout
  print, 'Press Any Key to Continue...'
  yorn = get_kbrd(1)
  wdelete

  x = xout
  y = yout

  return
end
