function texthd, filename
;+
; NAME:
;   TEXTHD
; PURPOSE:
;   Read in a text file containing FITS info into a string array.
;
; CALLING SEQUENCE:
;   head_array = TEXTHD(file_name)
;
; INPUTS:
;   FILE_NAME -- Name of file.  Easy enough.
;
; KEYWORD PARAMETERS:
;   NONE
;
; OUTPUTS:
;   HEAD_ARRAY -- String array containing the FITS header info.
;
; MODIFICATION HISTORY:
;       Written -- 
;       Mon Jun 11 20:48:29 2001, Erik Rosolowsky <eros@cosmic>
;-

if not keyword_set(filename) then begin
  message, 'No filename specified', /con
  message, 'Usage ARRAY = TEXTHD ( FILENAME )', /con
  return, 0
endif

nl = numlines(filename)
header = strarr(nl)
openr, lun, filename, /get_lun
string = ''
for i = 0, nl-1 do begin
  readf, lun, string, format = "(A80)"
  stpos = strpos(string, ' ')
  while stpos eq 0 do begin
    string = strmid(string, 1)
    stpos = strpos(' ', string)
  endwhile
  
;  if endpos eq -1 then begin
;    string = strcompress(string)
;  endif else begin
;    string = strmid(string, 0, endpos)
;  endelse
  header[i] = string
endfor
close, lun
free_lun, lun
  return, header
end
