function transcend2, xmin, xmax, fname = fname, _extra = ex
; Numerically solves a transcedental equation using The Stupid
; Method. Namely, the routine searched for the x value where the
; function is closest to zero and 'zooms in' on that value, hopefully
; returning the zero of the function.
; Syntax: print,transcend(xmin,xmax)
;    xmin -- lower bound on which to begin searching for the zero.
;    xmax -- upper bound on which to begin searching for the zero.

if not keyword_set(fname) then begin
  message, 'Set funtion name with keyword FNAME', /con
  return, 0
endif

dx=(double(xmax)-double(xmin))/100.

for i=1,10 do begin
        x=findgen(100)*dx+xmin
        if keyword_set(ex) then f = call_function(fname, x, _extra = ex)$
        else  f = call_function(fname, x)

        mini=min(abs(f),ind, /nan)
;        print,i,x(ind),mini
        dx=dx/50.
        xmin=x(ind)-50*dx
endfor

return,x(ind)
end
