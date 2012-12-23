function wt_moment, data, wt, errors = errors
;+
; NAME:
;   WT_MOMENT 
; PURPOSE:
;   To calculate the weighted zeroth and first moments of an input
;   variable weighted by the appropirate value and errors the values
;   if appropriate.
;
; CALLING SEQUENCE:
;   outstruc = WT_MOMENT(data, weight)
;
; INPUTS:
;   DATA -- The data for moment analysis.
;   WEIGHT -- Vector of the same size as data that contains the 
; KEYWORD PARAMETERS:
;   ERRORS -- Errors in the values of the weights (since these are
;             usually the Antenna temperatures).
;
; OUTPUTS:
;   OUTSTRUCTURE -- Structure with the following tags
;                   .mean -- Mean value with weights.
;                   .stdev -- Standard deviation with weights.
;                   .errmn -- Error in the mean (if errors specified)
;                   .errsd -- Error in the standard deviation (if
;                             errors specified).
; MODIFICATION HISTORY:
;       Written -- 
;       Tue Aug 7 12:20:52 2001, Erik Rosolowsky <eros@cosmic>
;-

if n_elements(data) ne n_elements(wt) then begin
  message, 'WEIGHT vector must have the same number of elements as DATA', /con
  return, 0
end



tot = total(wt)
mean = total(wt*data)/tot
stdev = sqrt(total(wt*(data-mean)^2)/tot)

if n_elements(errors) gt 0 then begin 

mean_err = sqrt(total(((tot*data-total(wt*data))/(tot^2))^2*errors^2))
;x2_err = sqrt(total((((tot*data^2-$
;                       total(wt*data^2))/(tot^2))^2*errors^2)))
;sd_err = 1/(2*stdev)*sqrt((2*mean*mean_err)^2+x2_err^2)

sig2err = sqrt(total(((tot*(data-mean)^2-$
                       total(wt*(data-mean)^2))/tot^2)^2*errors^2)+$
               (2*total(wt*(data-mean))/tot)^2*mean_err^2)

sd_err = 1/(2*stdev)*sig2err
  return, {mean:mean, stdev:stdev, errmn:mean_err, errsd:sd_err}
endif

  return, {mean:mean, stdev:stdev}
end




