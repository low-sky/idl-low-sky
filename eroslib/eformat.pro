function eformat, value, error, outerr = outerr, latex = latex, $
                  maxerror = maxerror, truncate = truncate, $
                  parenthetical = paren, pad = padin, sigfig = sig

  if n_elements(sig) eq 0 then sig = 1

  if n_elements(maxerror) eq 0 then maxerror = 2

  output = strarr(n_elements(value)) 
  outerr = output
  for i = 0, n_elements(value)-1 do begin
    position = floor(alog10(abs(error[i])))-(sig-1)
    if error[i] eq 0 then begin 
      output[i] = string(value[i])
      outerr[i] = '0'
    endif else begin
      if keyword_set(paren) then begin
        outerr[i] = strcompress(string(round(1e1^(-position)*error[i])), /rem)
        logv = floor(alog10(abs(value[i])))
        nsigfig = (logv-position+1)
        if outerr[i] eq '10' then begin
          outerr[i] = '1'
          nsigfig = nsigfig-1
        endif
        if logv lt position  then begin
          if position lt 0 then begin
            vals = round(value[i]*1d1^(-position))*1d1^(position) 
            output[i] = decimals(vals, (-position))
          endif
          if position ge 0 then begin
            vals = round(value[i]*1d1^(-position))*1d1^(position)
            output[i] = sigfig(vals, sig)
            outerr[i] = sigfig(string(1e1^(position)*round(1e1^(-position)*error[i])), sig)
          endif
         endif else begin
           if nsigfig le -1*maxerror then output[i] = '0' else $
              output[i] = sigfig(value[i], nsigfig > sig)
         endelse
      endif else begin
        outerr[i] = sigfig(round(1e1^(-position)*error[i], $
                                 /l64)/1d1^(-position), sig)
        position = floor(alog10(abs(float(outerr[i]))))-(sig-1)
        logv = floor(alog10(abs(value[i])))
        nsigfig = (logv-position+1)
        if keyword_set(truncate) then nsigfig = nsigfig-1 > 1
        if nsigfig le -1*maxerror then output[i] = '0' else $
          output[i] = sigfig(value[i], nsigfig > sig)
        if output[i] eq '0' and position lt 0 then begin
          output[i] = output[i]+'.'+strjoin(strarr(-position)+'0')
        endif
        if strpos(outerr[i], '.')+1 eq strlen(outerr[i]) then $
           outerr[i] = strmid(outerr[i], 0, strlen(outerr[i])-1)
        if strpos(output[i], '.')+1 eq strlen(output[i]) then $
           output[i] = strmid(output[i], 0, strlen(output[i])-1)
      endelse
    endelse
  endfor 

  if keyword_set(latex) then begin
    realout = strarr(n_elements(output)) 
    if keyword_set(padin) then pad = max(strlen(output)) > max(strlen(outerr))
    ndecs = total(stregex(output, '\.', /bool))
    ndecerr = total(stregex(outerr, '\.', /bool))
 
    for k = 0, n_elements(output)-1 do begin 
      if n_elements(pad) gt 0 then begin
        frontlen = strlen(output[k])
        backlen = strlen(outerr[k])
        if 1b-stregex(output[k], '\.', /bool) and ndecs gt 0 then begin 
          frpad = '\phantom{.}' 
          frontlen = frontlen+1
        endif else frpad = ''
        if 1b-stregex(outerr[k], '\.', /bool) and ndecerr gt 0 then begin
          backpad = '\phantom{.}' 
          backlen = backlen+1
        endif else backpad = ''
        if pad-frontlen gt 0 then $
           frpad = frpad+strjoin(replicate('\phn', pad-frontlen)) else $
              frpad = frpad+''
        if pad-backlen gt 0 then $
           backpad = backpad+strjoin(replicate('\phn', pad-backlen)) else $
              backpad = backpad+''
        if float(output[k]) lt 0 then backpad = backpad+'\phantom{-}'
       realout[k] = '$'+frpad+output[k]+' \pm '+outerr[k]+backpad+'$ '
      endif else begin
        realout[k] = '$'+output[k]+' \pm '+outerr[k]+'$ '
      endelse

    endfor
    output = realout
  endif

  if keyword_set(paren) then output = output+'('+outerr+')'

  return, output
end
