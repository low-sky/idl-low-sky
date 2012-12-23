pro gather_source, dirname
;+
; NAME:
;   GATHER_SOURCE
; PURPOSE:
;   To collect all currently compiled source files into a new
;   directory (i.e. for exporting a library of code to other people).
;   Assumes a UNIX system that the copies MKDIR and CP are appropriate
;   on.  And that '/' is the directory separating character.
;
; CALLING SEQUENCE:
;   GATHER_SOURCE, directory_name
;
; INPUTS:
;   DIRECTORY_NAME -- The name of the directory into which the files
;                     are collected.  If the directory already exists,
;                     the files are simply written into the existing
;                     directory.
;
; KEYWORD PARAMETERS:
;   NONE
;
; OUTPUTS:
;   NONE
;
; MODIFICATION HISTORY:
;
;       Fri Dec 10 09:15:11 2004, Erik Rosolowsky <eros@cosmic>
;		Written.
;
;-
  if n_elements(dirname) eq 0 then dirname = 'source_files'

  help, /source_files, output = output

  ind1 = where(output eq 'Compiled Procedures:')
  ind2 = where(output eq 'Compiled Functions:')
  ind3 = where(stregex(output, '\$MAIN\$', /bool))
  ind4 = where(output eq '')
  goodind = bytarr(n_elements(output))+1b
  goodind[ind1] = 0b
  goodind[ind2] = 0b
  goodind[ind3] = 0b
  goodind[ind4] = 0b
  goodind = where(goodind, ct)


  spawn, 'mkdir '+dirname
  if ct ge 1 then begin 
    for k = 0, ct-1 do begin
      slashpos = strpos(output[goodind[k]], '/')
      filename = strmid(output[goodind[k]], slashpos, $
                         strlen(output[goodind[k]])-slashpos)
      spawn, 'cp '+filename+' '+dirname, /sh
    endfor
  endif

  message, strcompress(string(ct), /rem)+$
           ' files have been gathered to directory '+dirname, /con


   return
end
