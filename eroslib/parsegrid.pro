pro parsegrid, filename, ra, dec
;+
; NAME:
;    parsegrid
; PURPOSE:
;    To read in a MIRIAD/BIMA grid file into RA and DEC arrays.
;
; CALLING SEQUENCE:
;    PARSEGRID, filename, ra, dec
;
; INPUTS:
;    FILENAME - string containing the name (+path) of the grid file.
;    RA - name of output array containing the RA of the grid.
;    DEC - name of output array containing the DEC of the grid.
; KEYWORD PARAMETERS:
;    none
;
; OUTPUTS:
;    RA, DEC
;
; MODIFICATION HISTORY:
;
;       Initial Documentation - Thu Oct 5 22:01:43 2000, Erik
;                               Rosolowsky <eros@cosmic>
;
;-


var = strarr(1)
openr, lun, filename, /get_lun
readf, lun, var
close, lun
free_lun, lun
pos1 = strpos(var(0), '(')
pos2 = strpos(var(0), ')')
dar = strmid(var(0), pos1+1, pos2-1-pos1)

count = 1
j = 0
while j lt strlen(dar)-(strlen(dar)-rstrpos(dar, ',')) do begin
  index = strpos(dar, ',', j+1)
  count = count+1 
  j = index
endwhile

dar1 = fltarr(count)
reads, dar, dar1

pos1 = strpos(var(0), '(', pos2+1)
pos2 = strpos(var(0), ')', pos2+1)
ddec = strmid(var(0), pos1+1, pos2-1-pos1)
ddec1 = fltarr(count)
reads, ddec, ddec1

pos1 = strpos(var(0), '(', pos2+1)
pos2 = strpos(var(0), ')', pos2+1)
ns = strmid(var(0), pos1+1, pos2-1-pos1)
ns1 = fltarr(count)
if ns eq '' then goto, skip
reads, ns, ns1
skip:
ra = dar1
dec = ddec1
return
end

