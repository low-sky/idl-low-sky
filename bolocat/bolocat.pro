pro bolocat, filein, props = props, zero2nan = zero2nan, obj = obj, $
             watershed = watershed, delta = delta, $
             all_neighbors = all_neighbors, thresh = thresh, $
             expand = expand, minpix = minpix, clip = clip, grs_run = grs, $
             absthresh = absthresh, absdelta = absdelta, $
             absexpand = absexpand, grs_dir = grs_dir, errgen = errgen, $
             error = error, minbeam = minbeam, $
             residual = residual, round = round, corect = corect, $
             sp_minpix = sp_minpix, id_minpix = id_minpix, $
             idmap = idmap, smoothmap = smoothmap, beamuc = beamuc
;+
; NAME:
;    BOLOCAT
; PURPOSE:
;    Generate a catalog from a BOLOCAM image.
; CALLING SEQUENCE:
;    
;    BOLOCAT, filename, props = props [, /zero2nan, obj = obj, 
;             /watershed, /clip, delta = delta, /all_neighbors
;             thresh = thresh, expand = expand, minpix
;             = minpix, /GRS_RUN, grs_dir = grs_dir, /ERRGEN, error =
;             error, minbeam = minbeam, residual = residual, round =
;             round, corect = corect, sp_minpix = sp_minpix, id_minpix
;             = id_minpix, idmap = idmap, smoothmap = smoothmap,
;             beamuc = beamuc]
;
; INPUTS:
;    FILENAME -- Name of the file to process.
;
; KEYWORD PARAMETERS:
;    /ZERO2NAN -- Replace values of zero with NaNs assuming that a
;                 zero represents bad data.  This keyword should
;                 (MUST) be set if zero is the blanking value.
;    /WATERSHED -- Use a seeded watershed decomposition on regions to
;                  determine objects
;    /CLIP -- Identify objects by clipping with no decomposition.
;    DELTA -- Saddle point criterion parameter: Set this parameter to
;             the difference (IN UNITS OF THE LOCAL RMS) a local
;             maximum must be above a saddle-point to represent a
;             unique object.  Default: 2
;    /ALL_NEIGHBORS -- Swith that controls the number of neighbors a
;                      pixel has.  Default is 4 neighbors; set the
;                      switch if a pixel should have 8 neighbors.
;    THRESH -- Initial thresholding value for determining significant
;              emission in units of the local RMS.  Default: 3
;    ID_MINPIX -- Significant regions with fewer pixels than MINPIX are
;              rejected.  Default: 10.  
;    MINBEAM -- As ID_MINPIX, but in numbers of beams.
;    EXPAND -- After rejecting small regions, the remaining regions
;              are expanded to include all connected emission down to
;              this threshold (in units of the local RMS).  Default: 2.
;    ABSDELTA, ABSEXPAND, ABSTHRESH -- Function as the DELTA, EXPAND,
;                                      and THRESH keywords excep
;    GRS_RUN -- Calculate the GRS spectrum along the line of sight of
;               each core.
;    GRS_DIR -- Location of the GRS data cubes.
;    RESIDUAL -- An array the same size as the data containing an
;                estimate of signal-free noise.
;    ERROR -- An array the same size as the data image containing an
;             estimate of the standard deviation at every point.
;    ROUND -- Size of rounding element (radius).  Set to zero for no rounding.
;    BEAMUC -- FRACTIONAL beam size uncertainty.
;    IDMAP -- Auxillary map used for object identification with
;             primary map used for property determination.
;    SMOOTHMAP -- Smoothed map used for property determination
;                 (i.e. for finding a stable maximum)
; OUTPUTS:
;   PROPS -- An array of structures with each element corresponding to
;            a signficant object in the BOLOCAM image.
;
; OPTIONAL OUTPUTS:
;   OBJ -- An object mask of the same dimensions as the input image
;          with the pixels corresponding to the kth element of props
;          labeled with the value k.
;   CORECT -- Set to a named variable containing number of ID objects.
; MODIFICATION HISTORY:
;
;       Tue May 29 12:22:12 2007, Erik <eros@yggdrasil.local>
;		Documented and tidied up.
;
;-

  corect = 0
  if not file_test(filein, /regular) then begin
    message, 'Error: File not found!', /con
    return
  endif
  

; Set default to do Seeded watershed  
  if n_elements(watershed) eq 0 and n_elements(clip) eq 0 then $
     watershed = 1b

; Assume no uncertainty in the beam size
  if n_elements(beamuc) eq 0 then beamuc = 0.0

  data = mrdfits(filein, 0, hd)

; If blanked data are set to 0 move them to NaNs
  if keyword_set(zero2nan) then begin 
    badind = where(data eq 0, ct)
    if ct gt 0 then data[badind] = !values.f_nan
  endif
  
  
  
  if n_elements(error) ne n_elements(data) then begin  
    if strcompress(string(sxpar(hd, 'XTEN1')), /rem) eq 'MapError' and (not keyword_set(errgen)) then begin
      err = mrdfits(filein, 1, ehd)
      if n_elements(err) gt 1 then begin 
        message, 'Using Error Extension for Noise Variance Estimate!', /con
        err = median(err, 5)
      endif else begin
        err = bolocam_emap(datA)
        err = median(err, 11)
      endelse
    endif
    if n_elements(residual) eq n_elements(data) then err = bolocam_emap2(residual, box = 2) 
    if n_elements(err) eq n_elements(data) then error = err else begin
      error = bolocam_emap(data)
      error = median(error, 11)
    endelse
  endif
; Swap in SFL for GLS in headers
    if stregex(sxpar(hd, 'CTYPE1'), 'GLS', /bool) then begin
      ct1 = sxpar(hd, 'CTYPE1')
    ct2 = sxpar(hd, 'CTYPE2')
    pos = stregex(sxpar(hd, 'CTYPE1'), 'GLS')
    sxaddpar, hd, 'CTYPE2', strmid(ct2, 0, pos)+'SFL'
    sxaddpar, hd, 'CTYPE1', strmid(ct1, 0, pos)+'SFL'
  endif
    

    if sxpar(hd, 'PPBEAM') eq 0 then begin
      sxaddpar, hd, 'BMAJ', 33.0/3600.
      sxaddpar, hd, 'BMIN', 33.0/3600.
      sxaddpar, hd, 'BPA', 0.0
      getrot, hd, rot, cdv
      ppbeam = abs((33.0/3600.)^2/(cdv[0]*cdv[1])*$
                   2*!pi/(8*alog(2)))      
      sxaddpar, hd, 'PPBEAM', ppbeam
    endif


  if n_elements(minpix) eq 0 then begin
    if n_elements(minbeam) gt 0 then begin
      minpix = minbeam*sxpar(hd, 'PPBEAM')
    endif else begin
      minpix = 2*sxpar(hd, 'PPBEAM')
    endelse
  endif 

; Call object identification /segementation routine
  if n_elements(idmap) eq n_elements(data) then map = idmap else map = data
  obj = objectid(map, error = error, watershed = watershed, delta = delta, $
                 all_neighbors = all_neighbors, thresh = thresh, $
                 expand = expand, minpix = minpix, absdelta = absdelta, $
                 absthresh = absthresh, absexpand = absexpand, $
                 round = round, sp_minpix = sp_minpix, $
                 id_minpix = id_minpix, original = data)
  if n_elements(obj) ne n_elements(data) then return
  if max(obj) gt 0 then begin
; Call catalog routine
    props = propgen(data, hd, obj, error, smoothmap = smoothmap)
    corect = n_elements(props) 
; Do photometry in annuli (apertures are in diameters)
    props.flux_40 = object_photometry(data, hd, error, props, 40.0, $
                                      fluxerr = fe40, /nobg)
    props.eflux_40 = sqrt((fe40)^2+4*beamuc^2*(props.flux_40)^2)
    
    props.flux_40_nobg = object_photometry(data, hd, error, props, 40.0, $
                                           fluxerr = fe40, /nobg)
    props.eflux_40_nobg = sqrt((fe40)^2+4*beamuc^2*(props.flux_40_nobg)^2)
    
    props.flux_80 = object_photometry(data, hd, error, props, 80.0, $
                                      fluxerr = fe80, /nobg)
    props.eflux_80 = sqrt((fe80)^2+4*beamuc^2*(props.flux_80)^2)
    props.flux_120 = object_photometry(data, hd, error, props, 120.0, $
                                       fluxerr = fe120, /nobg)
    props.eflux_120 = sqrt((fe120)^2+4*beamuc^2*(props.flux_120)^2)
    
    props.flux_obj = object_photometry(data, hd, error, props, props.rad_as_nodc*2, fluxerr = feobj)
    props.flux_obj_err = feobj
; Fill in basic properties that were used in the analysis
; Array compatibility?
    props.exp_thresh = expand[0]
    props.delta = delta[0]
    props.threshold = thresh[0]
    props.minpix = minpix[0]
    props.decomp_alg = (keyword_set(watershed)) ? 'WATERSHED' : 'CLIP'
    props.filename = filein
    
  endif else corect = 0

  if keyword_set(grs) then begin
; Tag each core with a GRS spectrum if available and desired
    grslookup, props, hd, obj = obj, data = data, grs_dir = grs_dir
  endif

  return
end
