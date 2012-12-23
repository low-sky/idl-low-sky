pro ps, x = x, ps = ps, _extra = ex, $
        defaults = defaults, toggle = toggle, $
        verbose = verbose, journal = journal, nicefont = nicefont
;+
; NAME:
;   PS
; PURPOSE:
;   Opens and closes the PS device with appropriate flags. 
;
; CALLING SEQUENCE:
;   PS [, ps = ps, x = x, defaults = defaults, toggle = toggle,
;         verbose = verbose, DEVICE KEYWORDS]
;
; INPUTS:
;  NONE
;
; KEYWORD PARAMETERS: 
;  PS -- switch DEVICE to PS
;  X -- switch device to X
;  If both are set, the device will be toggled.
;  If neither, no effect unless called from $MAIN which will message
;  the device name.
;  DEFAULTS -- Use my favorite calls for the PS command.
;  TOGGLE -- Toggles between PS and X
;  VERBOSE -- Forces a message about device name at end of execution.
;  JOURNAL -- Thickens up the lines and characters so that the file
;             will print well.
;
; OUTPUTS:
;  None.
;
; MODIFICATION HISTORY:
;
;       Sat Oct 16 16:28:51 2004, <eros@master>
;		Added /JOURNAL keyword, as inspired by JT Wright.
;
;       Written.
;       Sun Feb 16 14:54:33 2003, Erik Rosolowsky <eros@cosmic>
;-

  if keyword_set(defaults)  then begin
    xsize = 4.25
    ysize = 4.25
    inches = 1b
    color = color
    bits_per_pixel = 8
    yoffset = 1
  endif

  name = !d.name

  if (keyword_set(ps) and keyword_set(x)) or keyword_set(toggle) then begin 
    if stregex(name, 'X', /bool) then begin
      set_plot, 'ps'
      device, _extra = ex, xsize = xsize, ysize = ysize, $
              inches = inches, color = color, $
              bits_per_pixel = bits_per_pixel, $
              yoffset = yoffset
    endif else begin
      if stregex(name, 'PS', /bool) then device, /close
      set_plot, 'x', _extra = ex
    endelse

  endif else begin

    if keyword_set(ps) then begin
      set_plot, 'ps'
      device, _extra = ex, xsize = xsize, ysize = ysize, $
              inches = inches, color = color, bits_per_pixel = bits_per_pixel, $
              yoffset = yoffset
    endif
    if keyword_set(x) then begin
      if stregex(name, 'PS', /bool) then device, /close
      set_plot, 'X', _extra = ex
    endif
  endelse

  help, calls = calls

  if (not keyword_set(ps) and not keyword_set(x)) or $
    keyword_set(verbose) or n_elements(calls) eq 2 then begin
    message, 'Device set to '+!d.name, /con
    if keyword_set(defaults) then message, 'PS Defaults Used', /con
  endif

  if keyword_set(nicefont) and !d.name eq 'PS' then !p.font = 0

  if keyword_set(journal) and !d.name eq 'PS' then begin
    !p.thick = 3
    !p.charthick = 3
    !x.thick = 3
    !y.thick = 3
  endif
  if !d.name eq 'X' then begin
    !p.thick = 1
    !x.thick = 1
    !y.thick = 1
    !p.charthick = 1
    !p.font = -1
  endif



  return
end
