pro colprint, v1, v2, v3, v4, v5, v6, v7, v8, $
              decimals = decimals, sigfig = sigfig, $
              delimiter = delimiter, endstr = endstr, $
              latex = latex, file = file, begstr = begstr, lun = lun
;+
; NAME:
;   COLPRINT
; PURPOSE:
;   Print out input variables in a column.  Do some simple string
;   processing.  Even dumps LaTeX if you like.  
;
; CALLING SEQUENCE:
;   COLPRINT,V1,...,V8 [,decimals=decimals,sigfig=sigfig
;            DELIMITER = string, ENDSTR = str, /LATEX]
;
; INPUTS:
;   V1,... V8, -- Up to 8 named variables.
;
; KEYWORD PARAMETERS:
;   Decimals -- Round figures to this many decimal places
;   Sigfig -- Output this many significant figures.  SIGFIG beats decimals.
;   DELIMITER -- The text delimiter to place between columns
;   ENDSTR -- The end delimiter of the line
;   BEGSTR -- The beginning delimiter of the line.
;   /LATEX -- Set this flag to dump LaTeX style table formatting.
;   LUN -- The LUN to dump output to (exclusive from the use of FILE)
; OUTPUTS:
;   Screen output
;
; MODIFICATION HISTORY:
;
;       Tue Apr 20 09:09:33 2004, Erik Rosolowsky <eros@cosmic>
;		Added LaTeX dump capacity.
;
;       Sat Feb 21 19:14:31 2004, <eros@master>
;		'Bout damned time!
;
;-

;nvar = n_params()
  forward_function sigfig, decimals
  if n_elements(file) gt 0 then openw, lun, file, /get_lun
  nelts = n_elements(v1) 
  ncols = 8
  if keyword_set(latex) then begin
    endstr = ' \\'
    delimiter = ' & '
  endif
  if n_elements(endstr) eq 0 then endstr = ''
  if n_elements(begstr) eq 0 then begstr = ''

  if n_elements(v8) eq 0 then begin 
    v8 = strarr(nelts)
    ncols = ncols-1
  endif
  if n_elements(v7) eq 0 then begin 
    v7 = strarr(nelts)
    ncols = ncols-1
  endif
  if n_elements(v6) eq 0 then begin 
    v6 = strarr(nelts)
    ncols = ncols-1
  endif
  if n_elements(v5) eq 0 then begin 
    v5 = strarr(nelts)
    ncols = ncols-1
  endif
  if n_elements(v4) eq 0 then begin 
    v4 = strarr(nelts)
    ncols = ncols-1
  endif
  if n_elements(v3) eq 0 then begin 
    v3 = strarr(nelts)
    ncols = ncols-1
  endif
  if n_elements(v2) eq 0 then begin 
    v2 = strarr(nelts)
    ncols = ncols-1
  endif

  if n_elements(sigfig) gt 0 then begin
    type = size(v1, /tname)
    if type ne 'STRING' then v1 = sigfig(v1, sigfig)
    type = size(v2, /tname)
    if type ne 'STRING' then v2 = sigfig(v2, sigfig)
    type = size(v3, /tname)
    if type ne 'STRING' then v3 = sigfig(v3, sigfig)
    type = size(v4, /tname)
    if type ne 'STRING' then v4 = sigfig(v4, sigfig)
    type = size(v5, /tname)
    if type ne 'STRING' then v5 = sigfig(v5, sigfig)
    type = size(v6, /tname)
    if type ne 'STRING' then v6 = sigfig(v6, sigfig)
    type = size(v7, /tname)
    if type ne 'STRING' then v7 = sigfig(v7, sigfig)
    type = size(v8, /tname)
    if type ne 'STRING' then v8 = sigfig(v8, sigfig)
  endif else begin
    if n_elements(decimals) gt 0 then begin
      type = size(v1, /tname)
      if type ne 'STRING' then v1 = decimals(v1, decimals)
      type = size(v2, /tname)
      if type ne 'STRING' then v2 = decimals(v2, decimals)
      type = size(v3, /tname)
      if type ne 'STRING' then v3 = decimals(v3, decimals)
      type = size(v4, /tname)
      if type ne 'STRING' then v4 = decimals(v4, decimals)
      type = size(v5, /tname)
      if type ne 'STRING' then v5 = decimals(v5, decimals)
      type = size(v6, /tname)
      if type ne 'STRING' then v6 = decimals(v6, decimals)
      type = size(v7, /tname)
      if type ne 'STRING' then v7 = decimals(v7, decimals)
      type = size(v8, /tname)
      if type ne 'STRING' then v8 = decimals(v8, decimals)
    endif
  endelse 
  if n_elements(decimals) eq 0 and n_elements(sigfig) eq 0 then begin
    type = size(v1, /tname)
    if type ne 'STRING' then v1 = string(v1)
    type = size(v2, /tname)
    if type ne 'STRING' then v2 = string(v2)
    type = size(v3, /tname)
    if type ne 'STRING' then v3 = string(v3)
    type = size(v4, /tname)
    if type ne 'STRING' then v4 = string(v4)
    type = size(v5, /tname)
    if type ne 'STRING' then v5 = string(v5)
    type = size(v6, /tname)
    if type ne 'STRING' then v6 = string(v6)
    type = size(v7, /tname)
    if type ne 'STRING' then v7 = string(v7)
    type = size(v8, /tname)
    if type ne 'STRING' then v8 = string(v8)
  endif
  for k = 0, nelts-1 do begin
    if n_elements(delimiter) eq 0 then delimiter = ' '
    
    strout = v1[k]+delimiter+v2[k]+delimiter+v3[k]+delimiter+$
             v4[k]+delimiter+v5[k]+delimiter+v6[k]+delimiter+$
             v7[k]+delimiter+v8[k]+delimiter
; Trim to last delimiter...

    for ctr = 0, 8-ncols do begin
      strout = strmid(strout, 0, strpos(strout, delimiter, $
                                        /reverse_search))
    endfor
    strout = begstr+strout+endstr
;    if not keyword_set(latex) then begin
;      strout = strcompress(strjoin(strsplit(strout, delimiter, /extract), $
;                                   delimiter))+endstr
;    endif else begin
;      strout = strout+endstr
;    endelse
    if n_elements(file) gt 0 or n_elements(lun) gt 0 $
    then printf, lun, strout else print, strout
  endfor 
  if n_elements(file) gt 0  then begin
    close, lun
    free_lun, lun
  endif

  return
end
