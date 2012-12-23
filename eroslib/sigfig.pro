function sigfig, inarr, nfigs
;+
; NAME:
;  SIGFIG
; PURPOSE:
;	SIGFIG is a function which returns an input value (INFIG) as
;	a string rounded to the appropriate number of significant
;	figures (NFIGS), as taught by Bonnie Kelly, my high school 
; 	physics teacher.  
;
;
; CALLING SEQUENCE:
;   result = SIGFIG(input, n_figures)
;
; INPUTS:
;   INPUT -- Vector of floats or whatever (they become floats)
;   N_FIGURES -- Number of figures to round to.
; KEYWORD PARAMETERS:
;   None.
;
; OUTPUTS:
;   RESULT -- A well rounded string array.
;
; MODIFICATION HISTORY:
;
;       Thu Dec 16 17:28:30 2004, <eros@master>
;		Trapped zero being passed to it.
;
;       Tue Nov 9 14:56:54 2004, Erik Rosolowsky <eros@cosmic>
;		Streamlined.  Preserved Array Type.  Fixed bug
;		pointed out by JohnJohn.
;      Documented.  Wed Nov 21 12:25:29 2001, Erik Rosolowsky
;      <eros@cosmic>
;
;		
;
;-

  outarr = string(inarr)

  sgn = inarr lt 0
  numbers = double(inarr)

  for ii = 0, n_elements(inarr)-1 do begin 
    if numbers[ii] eq 0 then begin
      firstfig = 0
      round = 0
    endif else begin
      firstfig = floor(alog10(abs(numbers[ii])))
      round = round(numbers[ii]*1d1^(nfigs-firstfig-1), /l64)*$
            1d1^(firstfig-nfigs+1)
    endelse
    i = (firstfig-nfigs) ge 0 ? 'I' : 'F'
    ndec = strcompress((-(firstfig-nfigs)-1 > 0), /rem)
    fstr = '('+i+'40.'+ndec+')'
    string = strcompress(string(round, format = fstr), /rem)
    outarr[ii] = string
  endfor

  return, outarr
end


