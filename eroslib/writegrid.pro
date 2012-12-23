pro writegrid, gridra, griddec, name = gridname
;+
; NAME:
;     writegrid
; PURPOSE:
;     To write a MIRIAD/BIMA compatible gridfile given an arrays of RA
;     and DEC offset.
;
; CALLING SEQUENCE:
;     WRITEGRID, gridra, griddec [, name = gridname]
;
; INPUTS:
;     GRIDRA - Vector containing the RAs of the mosaic pointings.
;     GRIDDEC - Vector Containing the DECs of the mosaic pointings.
;
; KEYWORD PARAMETERS:
;     NAME - String name of the ouput grid file.  Defaults to 'grid.txt'
;
; OUTPUTS:
;     none
;
; MODIFICATION HISTORY:
;
;       Initial Documentation. -- Thu Oct 5 21:57:25 2000, Erik
;       Rosolowsky <eros@cosmic>
;
;-

if n_elements(gridname) eq 0 then gridname = 'grid.txt'

ngpts = n_elements(gridra) 
if ngpts le 1 then begin
  message, 'Inputs must have 2 values.', /con
  return
endif

ng = strtrim(string(ngpts-1), 2)
stgridra = strtrim(string(gridra), 2)
stgriddec = strtrim(string(griddec), 2)
openw, lun, gridname, /get_lun
printf, lun, (stgridra), stgriddec,$
format = '("dra(",'+ng+'(A7,", "),A7,"),ddec(",'+ng+'(A7,", "),A7,")")'
close, lun
free_lun, lun

  return
end

