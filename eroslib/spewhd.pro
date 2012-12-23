pro spewhd, header, name = name
;+
; NAME:
;   SPEWHD
; PURPOSE:
;   Spew header to text file for editing.
;
; CALLING SEQUENCE:
;   SPEWHD, header_array [, name= filename]
;
; INPUTS:
;   HEADER -- The header to Spewed
;
; KEYWORD PARAMETERS:
;   NAME -- the name of the file to be opened.  Defaults to hd.txt
;
; OUTPUTS:
;   None
;
; MODIFICATION HISTORY:
;       Written --
;       Mon Jun 11 20:36:26 2001, Erik Rosolowsky <eros@cosmic>
;-


if not keyword_set(name) then name = 'hd.txt'

ct = n_elements(header) 

openw, lun, name, /get_lun

for i = 0, ct-1 do begin
  str = header[i]
  endpos = strpos(str, '/', /reverse_search)
  if endpos eq -1 then begin
    string = strcompress(str)
  endif else begin
    string = strmid(str, 0, endpos+1)
  endelse
  printf, lun, string
endfor

close, lun
free_lun, lun
  return
end
