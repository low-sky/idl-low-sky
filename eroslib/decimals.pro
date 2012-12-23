function decimals, inval, dp
;+
; NAME:
;   DECIMALS
; PURPOSE:
;   To convert a value into a string containing the specified number of
;   decimal places.
;
; CALLING SEQUENCE:
;   string = DECIMALS (float, places)
;
; INPUTS:
;   FLOAT -- Value to be converted
;   PLACES -- Number of places to include
; KEYWORD PARAMETERS:
;   NONE
;
; OUTPUTS:
;   STRING 
;
; MODIFICATION HISTORY:
;
;       Tue Dec 16 18:17:51 2003, <eros@master>
;	Added compatibility for up to 2^63 (~ 10^18)
;	
;       Written Wed Jun 19
;       12:06:59 2002, Erik Rosolowsky <eros@cosmic>
;
;		
;
;-
  sz = size(inval)
  output = string(inval)
  j = 0
  for i = 0, n_elements(output)-1 do begin 
    if n_elements(dp) eq n_elements(inval) then j = i 
    value = double(round(inval[i]*1d1^(dp[j]), /l64))*1d1^(-dp[j])
    string = string(double(value), format = '(f30.15)')
    start = strpos(string, ' ', /reverse_search)
    dpos = strpos(string, '.')
    string = strmid(string, start, dpos-start+1+dp[j]-1*(dp[j] eq 0))
    output[i] = string
  endfor 
  return, strcompress(output, /rem)
end
