function select_pts, xin, yin
;+
; NAME:
;   SELECT_PTS
; PURPOSE:
;   To find out the index of points on a plot interactively.
;
; CALLING SEQUENCE:
;   indices = SELECT_PTS(X,Y)
;
; INPUTS:
;   X,Y -- The X and Y values of the current plot.
;
; KEYWORD PARAMETERS:
;  None so far
;
; OUTPUTS:
;  The indices of the selected points.
;
; MODIFICATION HISTORY:
;       Fixed bug to make distances evaluated in NORMAL and not DATA
;       coordinates, so interface is more intuitive when axes don't
;       have same order of magnitude.
;       Wed Aug 22 14:22:40 2001, Erik Rosolowsky <eros@cosmic>
;
;       I made this!  
;       Tue Aug 21 14:43:31 2001, Erik Rosolowsky <eros@cosmic>
;-

x = !x.s[1]*xin+!x.s[0] ; convert to normalized coordinates.
y = !y.s[1]*yin+!y.s[0]

phi = findgen(30)/30*360*!dtor

usersym, cos(phi), sin(phi)
!mouse.button= 0
print, 'Left Click to include nearest point'
print, 'Middle Click to eliminate nearest point'
print, 'Right Click to finish'

indarr = [-1]

while (!mouse.button ne 4)  do begin
  cursor, xcl, ycl, 4, /normal
  if !mouse.button eq 1 then begin
    hold = min((xcl-x)^2+(ycl-y)^2, ind)
    plots, xin[ind], yin[ind], ps = 8, symsize = 2, color = !p.color
    if total(where(indarr eq ind)) gt 0 then continue
    indarr = [indarr, ind]  
  endif
  if !mouse.button eq 2 then begin
    hold = min((xcl-x)^2+(ycl-y)^2, ind)
    plots, xin[ind], yin[ind], ps = 8, symsize = 2, color = 0
    okay = where(indarr ne ind)
    indarr = indarr[okay]
  endif
endwhile

if n_elements(indarr) eq 1 then return, -1
  for i = 1, n_elements(indarr)-1 do begin 
    plots, xin[indarr[i]], yin[indarr[i]], ps = 8, symsize = 2, color = 0
  endfor
  indarr = indarr[1:*]
  indarr = indarr[sort(indarr)]

  return, indarr
end
