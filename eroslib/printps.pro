pro printps, file = file, nopreview = nopreview, printer = printer, $
             duplex = duplex
;+
; NAME:
;   PRINTPS
; PURPOSE:
;   Prints a PostScript file using lp and GS.  
;   To be used with the PS.pro routine.
;
; CALLING SEQUENCE:
;   PRINTPS [file = file, preview = preview]
;
; INPUTS:
;   None.
;
; KEYWORD PARAMETERS:
;   FILE -- File name of Postscript file to be printed.
;   NOPREVIEW -- Supresses a preview of the file.
;   PRINTER -- name of printer.  Passed to lp with a -d flag.
;   DUPLEX -- Passes a '-oduplex' flag.  
; OUTPUTS:
;   None
;
; MODIFICATION HISTORY:
;       Written --
;       Sun Feb 16 15:22:30 2003, Erik Rosolowsky <eros@cosmic>
;
;-

  duplex_flag = '-oduplex '
  destination_flag = '-d'

  if not keyword_set(file) then file = 'idl.ps'
  if n_elements(printer) gt 0 then $
    printer_str = destination_flag+printer else printer = ''
  if keyword_set(duplex) then options = duplex_flag else $
    options = ''
  if keyword_set(nopreview) then begin
    spawn, 'lp '+printer+' '+options+' '+file
  endif else begin
    spawn, 'gs -dBATCH '+file
    message, 'Print file [Y/n]:', /con
    char = get_kbrd(1)
    if char eq 'N' or char eq 'n' then $
      message, 'Printing Aborted', /con else $
      spawn, 'lp '+printer+' '+options+' '+file
  endelse

  return
end
