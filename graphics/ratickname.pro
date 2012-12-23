function ratickname, xtk
;+
; NAME:
;   RATICKNAME
; PURPOSE:
;   To convert RA tick values into properly formatted IDL strings for labels.
;
; CALLING SEQUENCE:
;   tickname = RATICKNAME(tickvalue)
;
; INPUTS:
;   TICKVALUE -- Values of the labels on the RA axis
;
; KEYWORD PARAMETERS:
;   None.
;
; OUTPUTS:
;    TICKNAME -- IDL strings containing properly formatted tick values.
;
; MODIFICATION HISTORY:
;       Documented and Exported.
;       Tue Oct 16 12:58:21 2001, Erik Rosolowsky <eros@cosmic>
;-



;if xtk[0] gt xtk[n_elements(xtk)-1] then xtk = reverse(xtk)


rtk = xtk*3600
hour = long(rtk)/(54000)
minute = long(rtk-54000*hour)/900
sec =  long(rtk-54000*hour-900*minute)/15
fsec = (rtk-54000*hour-900*minute)/15
flag = (total((sec-shift(sec, 1)) eq 0) gt 0)

format = bytarr(n_elements(xtk))+1

minpts = uniq(minute)+1

if n_elements(minpts) gt 1 then $
  format[minpts(0:n_elements(minpts)-2)] = 2
hrpts = uniq(hour)+1
if n_elements(hrpts) gt 1 then $
  format[minpts(0:n_elements(hrpts)-2)] = 3
format[0] = 3
;format[n_elements(xtk)-1] = 3
labels = strarr(n_elements(xtk))

for i = 0, n_elements(xtk)-1 do begin
if flag eq 0 then begin
  if format[i] eq 1 then labels[i] = string(decimals(fsec[i], 1), $
               format = "(a,'!Es!N')")
  if strpos(labels[i], '00') ne -1 then format[i] = 2
  if format[i] eq 2 then labels[i] = string(minute[i], sec[i], $
               format = "(i2.2, '!Em!N',i2.2,'!Es!N')")
  if format[i] eq 3 then labels[i] = string(hour[i], minute[i], sec[i], $
               format = "(i2.2,'!Eh!N', i2.2, '!Em!N',i2.2,'!Es!N')")
  continue
endif else begin

  if format[i] eq 1 then labels[i] = decimals(fsec[i], 1)+'!Es!N'
  if strpos(labels[i], '00') ne -1 then format[i] = 2
  if format[i] eq 2 then labels[i] = string(minute[i], $
                                            format = "(i2.2, '!Em!N')")+$
    sigfig(fsec[i], 3)+'!Es!N'
  if format[i] eq 3 then labels[i] = string(hour[i], minute[i],$
    format = "(i2.2,'!Eh!N', i2.2, '!Em!N')")+sigfig(fsec[i], 3)+'!Es!N'
endelse
endfor 
;xtk = reverse(xtk)
;labels = reverse(labels)
  return, labels
end
