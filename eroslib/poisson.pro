function poisson, number, meannum, logarithmic = log
;+
; NAME:
;   POISSON
; PURPOSE:
;   Calculates the probability of a number of events based on the mean
;   number of events occuring.
;
; CALLING SEQUENCE:
;   prob = POISSON(number, mean_number [, /logarithmic]
;
; INPUTS:
;   NUMBER -- Number of events.
;   MEAN_NUM -- Probability * number of indpendent trials.
; KEYWORD PARAMETERS:
;   LOGARITHMIC -- Use logarithmic approximation.
;
; OUTPUTS:
;   PROB -- Probability of NUMBER of events occuring.
;
; MODIFICATION HISTORY:
;       Written -- 
;       Thu Oct 25 13:33:04 2001, Erik Rosolowsky <eros@cosmic>
;-

logprob = fltarr(n_elements(number)) 




;ind1 = where(number le 10)
;if total(ind1) gt -1 then $
;logprob[ind1] = $
;  alog(meannum^number[ind1]/factorial(number[ind1])*exp(-meannum))

if keyword_set(log) then $
  logprob = number*alog(meannum)-$
  (0.5*alog(2*!pi*number)+number*$
   alog(number)-number+alog(1+1/(12*number)))-$
  meannum else return, $
    meannum^number/factorial(number)*exp(-meannum)


; Trap log of zero special case
ind = where(number eq 0)
if total(ind) gt -1 then logprob[ind] = -meannum

if keyword_set(log) then return, logprob
  return, exp(double(logprob))
end




