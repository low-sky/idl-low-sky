function minimergefind, minicube, primary_kernel, kernels $
               , all_neighbors = all_neighbors $
               , npixels = npixels, tolerance = tolerance, _extra = ex

;+
; NAME:
;    MINIMERGEFIND
; PURPOSE:
;    Finds the highest level at which a local maximum shares a contour
;    with any other max
; CALLING SEQUENCE:
;    level = MINIMERGEFIND( data, primary_kernel, kernels [/all_neighbors,
;    npixels = npixels, tol = tol])
;
; INPUTS:
;    DATA -- A 2D or 3D data set
;    PRIMARY_KERNEL -- The 1D index of the kernel in question
;    KERNELS -- A full list of all kernels in the data set
; KEYWORD PARAMETERS:
;    /ALL_NEIGHBORS -- Passed to LABEL_REGIONS (IDL native)
;    TOL -- tolerance for splitting merge levels
;    NPIXELS -- Number of pixels within contour above LEVEL
; OUTPUTS:
;    LEVEL -- Level at which region containing PRIMARY_KERNEL merges
;             with other regions.
;
; MODIFICATION HISTORY:
;
;       Fri Dec 18 02:45:59 2009, Erik <eros@orthanc.local>
;
;		Docd.
;
;-


  if n_elements(tolerance) eq 0 then tolerance = 1e-5


; Determine intial clouds.  
  clouds = label_region(minicube eq minicube, all_neighbors = all_neighbors, /ulong)
  primary_asgn = clouds[primary_kernel]
  asgns = clouds[kernels]

  maxvalue = minicube[primary_kernel]
  minvalue =  min(minicube[where(clouds eq primary_asgn, ct)], /nan)
  mld = (maxvalue-minvalue)
  samecloud = kernels[where(asgns eq primary_asgn, ct)]

  cloudmask = (clouds eq primary_asgn)
; If there's only 1 kernel in the cloud return the minimum value in
; the cloud -- Do we want to do this?

  if ct eq 1 then begin
    npixels = total(cloudmask)
    return, minvalue
  endif
; Begin refinement

  blankedcube = minicube*cloudmask
  repeat begin
    testvalue = sqrt(minvalue*maxvalue)
    if minvalue lt 0 then testvalue = (minvalue+maxvalue)*0.5
    l = label_region(blankedcube ge testvalue, all_neighbors = all_neighbors, /ulong)
    primary_asgn = l[primary_kernel]
    asgns = l[samecloud]
    sameclump = where(asgns eq primary_asgn, ct)
    if ct eq 1 then begin
      maxvalue = testvalue 
      lastsolo = testvalue
    endif else minvalue = testvalue

  endrep until abs(maxvalue-minvalue) lt (tolerance*mld) > 1e-6
; This finds a value not necessarily in the data cube.  We need to
; find the lowest contour _IN THE CLUMP_ that lassos only the clump.  Alas

  l = label_region(blankedcube ge lastsolo, all_neighbors = all_neighbors, /ulong)
  value = min(blankedcube[where(l eq l[primary_kernel], npixels)],/nan)
  return, value
;  return, !values.f_nan
end



