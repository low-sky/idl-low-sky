
function f,x
; Put the function here!  The function should return the value given
; and input of the dependent variable x.

fx = 5*x-2
  return, fx
end

function transcend,xmin,xmax
; Numerically solves a transcedental equation using The Stupid
; Method. Namely, the routine searched for the x value where the
; function is closest to zero and 'zooms in' on that value, hopefully
; returning the zero of the function.
; Syntax: print,transcend(xmin,xmax)
;    xmin -- lower bound on which to begin searching for the zero.
;    xmax -- upper bound on which to begin searching for the zero.

dx=(float(xmax)-float(xmin))/100.

for i=1,10 do begin
	x=findgen(100)*dx+xmin
	mini=min(abs(f(x)),ind)
	print,i,x(ind),mini
	dx=dx/50.
	xmin=x(ind)-50*dx	
endfor

return,x(ind)
end
