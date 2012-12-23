function levs, values, nlevelso
;+
; NAME:
;   LEVS
; PURPOSE:
;   To generate a bunch of levels evenly distributed through the data.
;   To be used as a supplement to contouring.  Try the CPROPS package instead.
; CALLING SEQUENCE:
;   levels = LEVS(values, n_levels)
;
; INPUTS:
;   VALUES -- Data through which the values are distributed.
;   N_LEVELS -- Number of desired levels.
; KEYWORD PARAMETERS:
;  None
;
; OUTPUTS:
;  A vector of values containing a dynamaically relevant set of levels.
;
; MODIFICATION HISTORY:
;       Documented.  This is a hold-over from my first attempts at coding.
;       I think that that necessitates an apology.
;       Wed Nov 21 12:09:59 2001, Erik Rosolowsky <eros@cosmic>
;-



  nlevels = nlevelso

tryagain:
  pass = (values ne 99999.0)*(finite(values))*(values eq values)
if (total(pass) eq 0.) then begin
  print, 'No Valid Data to plot.'
  return, 0
endif
values = float(values(where(pass)))
sortdata = values(uniq(values, sort(values)))
ndata = n_elements(sortdata)
center = sortdata(fix(0.1*ndata):fix(0.90*ndata))
moments = moment(center)
mn=moments(0)
disp = sqrt(moments(1))
sortdata = sortdata(where((sortdata gt mn-20*disp) and (sortdata lt mn+20*disp)))

;values=float(values)

narg = total(sortdata ne 99999.0)
levsubs = floor(findgen(nlevels)*(narg/nlevels))
levels=sortdata(levsubs)
sz = size(uniq(levels))

blow = min(levels)*0.9*(min(levels) gt 0)+min(levels)*1.1*(min(levels) lt 0)$
  +(min(levels) eq 0.)*(-0.1)
bhi = max(levels)*1.1*(max(levels) gt 0)+max(levels)*0.9*(max(levels) lt 0)$
  +(max(levels) eq 0.)*(0.1)

if sz(1) eq nlevels then goto, haha

if min(levels) eq max(levels) then begin
  levels = max(levels)
  return, interpol([blow, levels, bhi], nlevels)
endif


nlevels = sz(1)

print,'actual levels=',nlevels

goto, tryagain

haha:

levels = interpol([blow, levels, bhi], nlevelso)
nl=n_elements(levels)
change = abs((levels(0:nl-2)-levels(1:nl-1))/levels(0:nl-2))
levels = levels(where(change gt 0.01))
levels = levels(uniq(levels))
return, interpol([blow, levels, bhi], nlevelso)
end









