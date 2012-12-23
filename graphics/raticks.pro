function raticks, axis, index, value
;+
; NAME:
;    raticks
; PURPOSE:
;    Tick format to plot RA values in plots.  Interfaces with PLOT command.
;
; CALLING SEQUENCE:
;    set PLOT keyword [XY]TICKFORMAT='RATICKS'
;
; INPUTS:
;    Handled by PLOT
;
; MODIFICATION HISTORY:
;
;       Initial Documentation -- Thu Oct 5 23:02:16 2000, Erik
;                                Rosolowsky <eros@cosmic>
;-

value = value*3600
hour = long(value)/(54000)
minute = long(value-54000*hour)/900
sec =  long(value-54000*hour-900*minute)/15

;if index eq 0 then  return, string(hour, minute, sec, $
;       format = "(i2.2,'!Eh!N', i2.2, '!Em!N',i2.2,'!Es!N')") 

return, string(hour, minute, sec, $
               format = "(i2.2,'!Eh!N', i2.2, '!Em!N',i2.2,'!Es!N')")
end
