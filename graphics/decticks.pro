function decticks, axis, index, value
;+
; NAME:
;    raticks
; PURPOSE:
;    Tick format to plot DEC values in plots.  Interfaces with PLOT command.
;
; CALLING SEQUENCE:
;    set PLOT keyword [XY]TICKFORMAT='DECTICKS'
;
; INPUTS:
;    Handled by PLOT
;
; MODIFICATION HISTORY:
;
;       Initial Documentation -- Thu Oct 5 23:03:00 2000, Erik
;                                Rosolowsky <eros@cosmic>
;
;		
;
;-


hour = floor(value)
minute = floor((value - hour)*60)
sec = floor(((value-hour)*60-minute)*60)
a = string("140B)
b = string("042B)
stop
return, string(hour,  format = '(i2.2,"!9%!X")')+string(minute,$
  format = '(i2.2)')+a+string(sec, format = "(i2.2)")+b
end
