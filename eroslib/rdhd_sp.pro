pro rdhd_sp, hd, structure = structure, ms = ms
;+
; NAME:
;   RDHD_SP
; PURPOSE:
;   Header processing for 1-dimensional spectra with velocity as 1st
;   axis (e.g. those extracted from the UASO 12-m).
;
; CALLING SEQUENCE:
;   rdhd_sp, hd [, structure = structure]
;
; INPUTS:
;   HD -- A string array FITS header for a single spectrum.
;
; KEYWORD PARAMETERS:
;   MS -- Spectral information is given in meters/sec.
;
; OUTPUTS:
;   STRUCTURE -- Structure containing header information
;
; MODIFICATION HISTORY:
;       Written as a subroutine for rdhd.pro
;       Fri Feb 22 11:16:32 2002, Erik Rosolowsky <eros@cosmic>
;-

dim = sxpar(hd, 'NAXIS')
naxis1 = sxpar(hd, 'NAXIS1')
ra = sxpar(hd, 'CRVAL2')
dec = sxpar(hd, 'CRVAL3')
freq = sxpar(hd, 'RESTFREQ')
date = sxpar(hd, 'DATE-OBS')
if date[0] eq 0 then date = sxpar(hd, 'DATE')

bunit = sxpar(hd, 'BUNIT')
freq = sxpar(hd, 'RESTFREQ')
extast, hd, astrom

vel = (dindgen(naxis1)+1-astrom.crpix[0])*astrom.cdelt[0]+astrom.crval[0]

if keyword_set(ms) then vel = vel/1000

if bunit eq 0 then bunit = 'KELVIN'
structure = {naxis1:naxis1, ra:ra, dec:dec, v:vel, $
             ctype:astrom.ctype, $
             crpix:astrom.crpix, $
             crval:astrom.crval, $
             cdelt:astrom.cdelt, $
             freq:freq, $
             date:date}


  return
end

