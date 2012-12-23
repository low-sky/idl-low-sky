pro strip, gridfile, pval, cluster = cluster
;+
; NAME:
;    STRIP
; PURPOSE:
;    Writes MIRIAD files for indiviudal source extraction from a
;    mosaiced observations.
;
; CALLING SEQUENCE:
;    STRIP, gridfile, pval
;
; INPUTS:
;    GRIDFILE -- The MIRIAD gridfile used in the observations
;    PVAL -- The starting number for the data cubes.
;    /CLUSTER -- Prepend a PBS header for the job.
; REQUIRES: 
;    PARSEGRID.pro   
;
; OUTPUTS:
;   Two files are written to the current directory.  stripscr.csh
;   strips the mosaic into its individual data sets.  blockinv.csh
;   reduces each data cube separately.
;
; MODIFICATION HISTORY:
;       Documented --
;       Mon Mar 19 16:09:56 2001, Erik Rosolowsky <eros@cosmic>
;-


  if n_params() lt 2 then begin
    message, 'Insufficient arguments', /con
    message, 'Usage: STRIP,gridfile,file_number', /con
    return
  endif

  parsegrid, gridfile, ra, dec
  ra = ra*60
  dec = dec*60
  openw, lun, 'stripscr.csh', /get_lun
  printf, lun, '#!/bin/csh -f'
  openw, lun2, 'blockinv.csh', /get_lun
  printf, lun2, '#!/bin/csh -f'
  if keyword_set(cluster)  then begin
    printf, lun, '#PBS -N Block'
    printf, lun, '#PBS -k eo'
    printf, lun, '#PBS -m a'
    printf, lun, '#PBS -M eros@astro.berkeley.edu'
    printf, lun, '#PBS -l nodes=1:ppn=1:ral'
    printf, lun, 'source ~/cshrc.MIRIAD'
    printf, lun, ' '
  endif


  cd, current = path

  for i = 0, n_elements(ra)-1 do begin 
    filename = strcompress(string(i+pval)+'.gcal', /remove)
    ura = strtrim(string(ra[i]+1), 2)
    lra = strtrim(string(ra[i]-1), 2)
    udec = strtrim(string(dec[i]+1), 2)
    ldec = strtrim(string(dec[i]-1), 2)
    printf, lun, 'uvcat vis=m33.gcal out='+filename+' select=dra\('+lra+','+ura+$
            '\),ddec\('+ldec+','+udec+'\)'
    shortname = strcompress(string(i+pval), /remove)
    printf, lun, 'mkdir '+strcompress(string(i+pval), /remove)
    printf, lun, 'mv '+filename+' '+strcompress(string(i+pval), /remove)+'/.'
    printf, lun2, 'cd '+path+'/'+shortname
    printf, lun2, 'set source = '+shortname
    printf, lun2, 'rm -rf $source.bm $source.mp'
    printf, lun2, 'invert vis=$source.gcal map=$source.mp beam=$source.bm\'
    printf, lun2, ' line=velocity,200,-400,2,2 robust=0.5 options=double,systemp,mosaic cell=1.5 imsize=80,80'
    printf, lun2, 'rm -rf $source.cl $source.cm'
    printf, lun2, 'clean map=$source.mp beam=$source.bm out=$source.cl, \'
    printf, lun2, 'niters=200'
    printf, lun2, 'restor map=$source.mp beam=$source.bm model=$source.cl\'
    printf, lun2, 'out=$source.cm mode=clean'
    printf, lun2, 'rm -rf $source.fits'
    printf, lun2, 'fits in=$source.cm out=$source.fits op=xyout'
    printf, lun2, 'fits in=$source.bm out=$source.bm.fits op=xyout'
    printf, lun2, 'cp $source.bm.fits ~/clouds/DATA/fitsdir_beam'
  endfor


  close, lun
  free_lun, lun
  close, lun2
  free_lun, lun2
  spawn, 'chmod 744 stripscr.csh'
  spawn, 'chmod 744 blockinv.csh'
  return
end
