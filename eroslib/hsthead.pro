pro hsthead, path, structure = s
;+
; NAME:
;   HSTHEAD
; PURPOSE:
;   To read out header information from directory of HST files into a
;   structure containing information about the files found in the
;   directory.  
;
; CALLING SEQUENCE:
;   HSTHEAD, directory [, structure = structure]
;
; INPUTS:
;   DIRECTORY -- The directory to be searched.  The directory is not
;                searched recursively.  Defaults to the working directory.
;
; KEYWORD PARAMETERS:
;
;
; OUTPUTS:
;  STRUCTURE -- File information is stored in the structure.
;
; MODIFICATION HISTORY:
;
;-
  if n_elements(path) eq 0 then path = '.'
  filenames = findfile(path+'/*.fits', count = ct)
  template = {name:'', path:'', instrument:'', type:'', extensions:0, $
              root:'', object:'', ra:0d1, dec:0d1, l:0d1, b:0d1, $
              date:'', filter:'', fileext:''}
  s = [template]
 for i = 0, ct-1 do begin
    hd = headfits(filenames[i])
    tmp = template
    name = filenames[i]
    posn = strpos(filenames[i], '/', /reverse_search)
    tmp.name = strmid(filenames[i], posn+1, 20)
    tmp.path = strmid(filenames[i], 0, posn+1)
    dotpos = strpos(filenames[i], '.', /reverse_search)
    tmp.fileext = strmid(filenames[i], dotpos-3, 3)
    tmp.instrument = strcompress(sxpar(hd, 'INSTRUME'), /rem)
    tmp.type = strcompress(sxpar(hd, 'FILETYPE'), /rem)
    tmp.extensions = sxpar(hd, 'NEXTEND')
    tmp.root = strcompress(sxpar(hd, 'ROOTNAME'), /rem)
    tmp.object = strcompress(sxpar(hd, 'TARGNAME'), /rem)
    tmp.ra = sxpar(hd, 'RA_TARG')
    tmp.dec = sxpar(hd, 'DEC_TARG')
    tmp.l = sxpar(hd, 'GAL_LONG')
    tmp.b = sxpar(hd, 'GAL_LAT')
    tmp.date = strcompress(sxpar(hd, 'DATE-OBS'), /rem)
    tmp.filter = strcompress(sxpar(hd, 'FILTER'), /rem)
    s = [s, tmp]
  endfor
  s = s[1:*]


  return
end
