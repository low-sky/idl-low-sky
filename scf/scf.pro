pro scf, data, patch = in_patch, scf_0 = scf_0, scf_s = scf_s, $
         qcorr = qcorr, corrval = corrval, $
         ss_mat = ss_mat, s0_mat = s0_mat, rms = emap, $
         renormalize = renormalize, silent = silent, $
         counts = counts, store = pstore, sstore = spstore, $
         corrcalc = corrcalc, corrmat = corrmat
;+
; NAME:
;   SCF
; PURPOSE:
;   To calculate the SCF on a data cube given a local patch.
;
; CALLING SEQUENCE:
;   SCF, data, patch = patch, scf_0 = scf_0 [, scf_s = scf_s, 
;     qcorr = qcorr, rms = rms, ss_mat = ss_mat, s0_mat = s0_mat,
;     /renormalize]
;
; INPUTS:
;   DATA -- Data cube to be analyzed (velocity on Axis 3)
; KEYWORD PARAMETERS:
;   PATCH -- Weight to be given to the SCF local averaging.  Defaults
;            to a 3 X 3 box with no weight on self correlation. 2D
;            matrix with value of -1 at location of base spectrum.
;            The base spectrum is the spectrum which is T_0 in the SCF
;            literature.  The SCF for the comparison spectra (T_1) are
;            calculated for all positions simultaneously.  
;   RMS -- Map of the RMS in each pixel.  Needed for calculating the
;          Quality correction.
;   RENORMALIZE -- Generate SCF_0 1-[T_1-T_0]^2/(T_1^2+T_0^2) instead
;                  of the literature's 1-sqrt([T_1-T_0]^2/(T_1^2+T_0^2)).
;   SILENT -- Suppress progress text.
;   CORRCALC -- Only calculate the correction value.
;
; OUTPUTS:
;   SCF_0 -- Map of 0th order SCF.
;   SCF_S -- Scaled SCF to maximize the correlation
;   SS_MAT -- Matrix of the SCF_S function on the patch averaged for
;             all the pixels in the map.
;   S0_MAT -- As ss_mat, but for SCF_0
;   QCORR -- Set flag to scale SCF products up by the Quality
;            Correction to account for the presence of noise.
;   CORRVAL -- Set this variable to contain the Median value of the
;              correction that was applied.
;   COUNTS -- Matrix containing the number of spectrum pairs that
;             contribute to the average in each position of the patch. 
;   CORRCALC -- Set this keyword to calculate Quality Correction and exit.
;
; MODIFICATION HISTORY:
;
;       Fri Dec 17 18:30:46 2004, Erik Rosolowsky <eros@cosmic>
;		Added correction flags and some quick exits if all you
;		need is the correction.
;
;       Thu Aug 14 13:22:52 2003, Erik Rosolowsky <eros@cosmic>
;		Added in patch storing at all points and utilized
;		JohnJohn's line counter.
;
;       Added the square root renormalization (a la the literature)
;       and added some commentary.  Tue Dec 17 16:32:51 2002, Erik
;       Rosolowsky <eros@cosmic>
;
;       'ere we go again!
;       Fri Nov 15 13:35:36 2002, Erik Rosolowsky <eros@cosmic>
;-



  sz = size(data)
; Generate a map of the RMS in each pixel and smooth to simulate beam
; smoothing.  Only used if (1) no error map is passed and (2) the
; quality correction is needed.
  if n_elements(emap) eq 0 then begin 
    emap = errmap_rob(data)
    emap = smooth(emap, 5, /edge_trun, /nan)
  endif 


  q = total(data^2, 3)/emap^2/sz[3] 
  corr = q/(q-1)                ; Calculate the quality correction.
  corrmat = corr
  corrval = median(corr)

  if keyword_set(corrcalc) then return


; Set up default nearest-neighbors patch.
  if n_elements(in_patch) eq 0 then begin
    patch = fltarr(3, 3)+1
    patch[1, 1] = -1
  endif else patch = in_patch

; Establish data vectors.
  sz_patch = size(patch)
  patch = float(patch)
  s0_mat = patch
  s0_mat[*] = 0.
  ss_mat = s0_mat

  spec_pos = where(patch eq -1, ct)
  if ct ne 1 then begin
    message, 'Local Patch has invalid base spectrum placement', /con
    return
  endif
  x_base = spec_pos mod sz_patch[1]
  y_base = spec_pos/sz_patch[1]
  patch[spec_pos] = 0.
  scf_0 = fltarr(sz[1], sz[2])
  scf_s = fltarr(sz[1], sz[2])
  cts = ss_mat

  pstore = fltarr(sz[1], sz[2], sz_patch[1], sz_patch[2])
  spstore = pstore
  errcube = fltarr(sz[1], sz[2], sz_patch[1], sz_patch[2])


; Begin looping through the base spectra
  for i = 0, sz[1]-1 do begin
    for j = 0, sz[2]-1 do begin

; Form the two basic cubes from the data, forcing any edge
; effected pixels to have zero weight (hence, all the conditionals).
      cube1 = fltarr(sz_patch[1], sz_patch[2], sz[3])
      cube0 = cube1
      cube1[(0 > (x_base-i)):((sz[1]-1-i+x_base) < (sz_patch[1]-1)), $
            (0 > (y_base-j)):((sz[2]-1-j+y_base) < (sz_patch[2]-1)), *] = $
        data[(0 > (i-x_base)):(sz[1]-1 < (i-x_base+sz_patch[1]-1)), $
             (0 > (j-y_base)):(sz[2]-1 < (j-y_base+sz_patch[2]-1)), *]
      base_sp = transpose(data[i, j, *])
; Flag the locations of good spectra.
      valid = bytarr(sz_patch[1], sz_patch[2])
      valid[(0 > (x_base-i)):((sz[1]-1-i+x_base) < (sz_patch[1]-1)), $
            (0 > (y_base-j)):((sz[2]-1-j+y_base) < (sz_patch[2]-1))] = 1b
; Build the base spectrum cube with a for loop since there isn't a
; generalized outer product function in IDL.
      cube0 = rebin(base_sp, sz[3], sz_patch[1], sz_patch[2])
      cube0 = transpose(cube0, [1, 2, 0])
;      for ii = 0, sz[3]-1 do cube0[*, *, ii] = base_sp[ii]*valid

; Calculate the nominal scaling weight for different amplitudes.
      wt = total(cube0*cube1, 3)/total(cube1^2, 3)
      s = fltarr(sz_patch[1], sz_patch[2], sz[3])

      for ii = 0, sz[3]-1 do s[*, *, ii] = wt

; Calculate the SCF.
      scf0_matrix = 2*total(cube0*cube1, 3)/(total(cube1^2+cube0^2, 3))
      inds = where((scf0_matrix eq scf0_matrix)*(patch ne 0)*$
                   (wt eq wt), ind_ct)
      if ind_ct eq 0 then continue
; Add the SCF values to a running tally in the patch.  This allows for
; maps of the SCF over the patch.
      s0_mat[inds] = scf0_matrix[inds]*patch[inds]+s0_mat[inds]
      scf_0[i, j] = total(patch[inds]*scf0_matrix[inds])/total(patch[inds])
      pstore[i, j, *, *] = scf0_matrix

      scfs_matrix = 2*total(s*cube0*cube1, 3)/$
                    (total(s^2*cube1^2+cube0^2, 3))
      spstore[i, j, *, *] = scfs_matrix
      inds = where(scfs_matrix eq scfs_matrix and patch ne 0, ind_ct)
      if ind_ct eq 0 then continue
      ss_mat[inds] = scfs_matrix[inds]*patch[inds]+ss_mat[inds]
      scf_s[i, j] = total((patch*scfs_matrix)[inds])/total(patch[inds])
; Keep track of what positions in the patch get spectra.  This allows
; the for the maps of the SCF over the patch to have appropriate
; weights in the weighted average.
      cts[inds] = cts[inds]+1
    endfor

    if not keyword_set(silent) then counter, i+1, sz[1], 'Processing Row '
  endfor

  ss_mat = ss_mat/cts/patch     ;Calculate the maps.
  s0_mat = s0_mat/cts/patch
  

  if not keyword_set(renormalize) then begin 
    scf_0 = 1-sqrt(1-scf_0)
    scf_s = 1-sqrt(1-scf_s)
    ss_mat = 1-sqrt(1-ss_mat)
    s0_mat = 1-sqrt(1-s0_mat)
    if keyword_set(qcorr) then begin
      scf_0 = scf_0*corr
      s0_mat = s0_mat*median(corr)
    endif

  endif



  counts = cts
  return
end







