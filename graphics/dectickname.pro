function dectickname, value
;+
; NAME:
;   DECTICKNAME
; PURPOSE:
;   To generate proper labels for RA and DEC plots given tick values.
;
; CALLING SEQUENCE:
;   tickname = DECTICKNAME(tickvalue)
;
; INPUTS:
;   TICKVALUE -- Values of the labels on the DEC axis
;
; KEYWORD PARAMETERS:
;   None.
;
; OUTPUTS:
;   TICKNAME -- IDL strings containing properly formatted tick values.
;
; MODIFICATION HISTORY:
;       Documented and exported --
;       Tue Oct 16 12:56:35 2001, Erik Rosolowsky <eros@cosmic>
;-



hour = floor(value)
minute = floor((value - hour)*60)
sec = floor(((value-hour)*60-minute)*60)
a = string("140B)
b = string("042B)


format = bytarr(n_elements(value))+1

minpts = uniq(minute)+1

if n_elements(minpts) gt 1 then $
  format[minpts(0:n_elements(minpts)-2)] = 2
hrpts = uniq(hour)+1
if n_elements(hrpts) gt 1 then $
  format[minpts(0:n_elements(hrpts)-2)] = 3

format[0] = 3
;format[n_elements(value)-1] = 3
labels = strarr(n_elements(value))

for i = 0, n_elements(value)-1 do begin
  if format[i] eq 1 then labels[i] = $
    string(sec[i], format = "(i2.2)")+b
  if format[i] eq 2 then labels[i] = $
    string(minute[i], format = '(i2.2)')+a+string(sec[i], format = "(i2.2)")+b
  if format[i] eq 3 then labels[i] = $
    string(hour[i],  format = '(i2.2,"!9%!X")')+string(minute[i], $
           format = '(i2.2)')+a+string(sec[i], format = "(i2.2)")+b
endfor 


  return, labels
end
