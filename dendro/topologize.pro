pro topologize, data, mask, friends = friends, specfriends = specfriends, $
                resolvetop = resolvetop, minpix = minpix, levels = levels, $
                all_neighbors = all_neighbors, kernels = kernels, $
                delta = delta, pointer = pointer, structure = structure, $
                nlevels = nlevels, ecube = ecube, error = error
;+
; NAME:
;    TOPOLOGIZE
; PURPOSE:
;    Topologize evaulates the evolving connectivity of a 2 or 3 dimensional
;    data set as it is contoured on a range of levels.  It is used to
;    evaluate the heirarchical structure in an image / data cube.
;
; CALLING SEQUENCE:
;    TOPOLOGIZE, data, mask
; INPUTS:
;    DATA -- a 2 or 3 dimensional image.
;    MASK -- A binary mask array of the same dimensions as DATA that
;            indicates where the data should be studied (1=include,
;            0=exclude). 
;
; KEYWORD PARAMETERS:
;    FRIENDS, SPECFRIENDS -- Used to establish the local maxima in the
;                            data cube if not specified.  See
;                            ALLLOCMAX.pro for details.
;    LEVELS -- Input/output keyword.  Sepecified the contouring levels
;              at which to evaluate the data.
;    RESOLVETOP -- Set this keyword to force a full resolution of the
;                  behavior of the data at high levels.  By default,
;                  the routine focuses its attention at the lower
;                  intensity levels where mergers are more common.
;    MINPIX -- Used in culling local maxima (see DECIMATE_KERNELS.pro)
;              for details.
;    DETLA --  Used in culling local maxima (see DECIMATE_KERNELS.pro)
;              for details.
;    NLEVELS -- The number of contour levels to use.
;
; OUTPUTS: Keyword controlled.  IF YOU WANT ANY OUTPUT, you must set a
; keyword.  You may set either:
;    STRUCTURE -- A structure containing information about the
;                 topology of the data.  Used by all other routines.
;    POINTER -- Named pointer to a heap variable containing all the
;               information that is in structure.  This is the
;               preferred method of dealing with data since it
;               accommodates multiple clouds in the data.
;
; SIDE EFFECTS:  HEAP VARIABLE LEAKAGE IF USED IMPROPERLY!
;
; MODIFICATION HISTORY:
;
;	Fri Oct 20 18:52:58 2006, Erik 
;
;-

  compile_opt idl2
  szdata = size(data)

  if n_elements(friends) eq 0 then friends = 3
  if n_elements(specfriends) eq 0 then specfriends = 3
  if szdata[0] eq 2 then specfriends = 0
  if not(keyword_set(all_neighbors)) then  all_neighbors = 0b
  if n_elements(minpix) eq 0 then minpix = 4
  

; Always find the largest cloud in the mask and do the analysis.  If
; you want a particular cloud, pre-process the mask for it.
;  l = label_region(mask, all_neighbors = all_neighbors, /ulong)
;  h = histogram(l)
;  nreg = max(h[1:*], ind)
;  mask = (l eq ind+1)  


; Begin with data file and mask and reduce to minimum working size.
  vectorify, data, mask = mask, x = x, y = y, v = v, t = t, $
             ind = cubeindex

  if n_elements(ecube) eq 0 then begin
    if n_elements(error) eq 0 then $ 
      err = replicate(mad(data), n_elements(t)) else $
        err = replicate(error, n_elements(t)) 
  endif else err = ecube[cubeindex]

  if n_elements(delta) eq 0 then delta = 3*median(err)


; Trim to minimum size  
  cubify, x, y, v, t, cube = minicube, pad = (friends > specfriends), $
          twod = (szdata[0] eq 2), indvec = cubeindex, indcube = indcube
;; Generate a string to label
;  clusterlabel = intarr(n_elements(cubeindex))-1

  if n_elements(kernels) gt 0 then begin
    newkern = kernels*0
    for i = 0, n_elements(kernels)-1 do newkern[i] = where(indcube eq kernels[i])
  endif 

; Establish Contouring levels if unset
  if n_elements(levels) eq 0 then begin
    if n_elements(nlevels) eq 0 then  nlevels = (n_elements(x)/50 > 250) < 500
    levels = (max(t)-min(t))/(nlevels)*(findgen(nlevels))+min(t)
    levels = [0.0, levels]
;    levels = contour_values(t, nlevels = nlevels, /uniform)
;    if keyword_set(resolvetop) and max(levels) ne max(t) then begin
;      levels = [levels, t[where(t gt max(levels))]]
;      levels = reverse(levels[sort(levels)])
;    endif
  endif


; Establish local maxima if unset
  if n_elements(newkern) eq 0 then begin 
    lmax = alllocmax(minicube, friends = friends, specfriends = specfriends)
    kernels = decimate_kernels(lmax, minicube, $
                               all_neighbors = all_neighbors $
                               , delta = delta, sigma = 1.0 $
                               , minpix = minpix);, levels = levels)
  endif else kernels = newkern
  message, 'Kernels used in decomposition: '+$
           string(n_elements(kernels)), /con
; Calculated toplogy of the data cube
    merger = mergefind(minicube, kernels, levels = levels, $
                       all_neighbors = all_neighbors)
    disconnected = where(merger ne merger, discct)
    if discct gt 0 then merger[disconnected] = 0.0

; Turn into sparse values again.
    vectorify, minicube, x = x, y = y, v = v, t = t, $
               mask = (minicube eq minicube)

; Use this chunk of code to make a distance metric that measures how
; close two kernels are to each other.  The "distance" is larger for
; kernels that merge at lower contour levels.
    sz = size(merger)
    vals = merger[indgen(sz[1]), indgen(sz[1])]
    v1 = vals#replicate(1, sz[1])
    v2 = transpose(v1)
    d = max(merger)-merger
    d[indgen(sz[1]), indgen(sz[1])] = 0

; Find clusters using the RSI program.
    clusters = cluster_tree(d, linkdistance)

; Calculate the linkages between all the clusters.  This is a modified
; version that returns the X location and height of clusters that are
; plotted in the final visualization.

    DENDROGRAM_MOD, clusters, linkdistance, outverts, outconn, $
                    LEAFNODES = leafnodes, xlocation = xlocation, $
                    height = height

  
; This turns the height output from dendrogram_mod into the actual
; brightness temperature associated with each cluster.
    dvals = merger[indgen(sqrt(n_elements(merger))), $
                   indgen(sqrt(n_elements(merger)))] 
    leafy = where(outverts[1, *] eq 0)
    outverts[1, *] = max(dvals)-outverts[1, *]
    outverts[1, leafy] = dvals[leafnodes[outverts[0, leafy]]]
    
; This does the same thing for the height vector.
    height = max(merger)-height
    height[findgen(n_elements(leafnodes))] = merger[$
      findgen(n_elements(leafnodes)), $
      findgen(n_elements(leafnodes))]
; Patch up roundoff error.
    mld=abs(median(levels-shift(levels,-1)))
    matchtol=1e-2*mld
    for jj = 0, n_elements(height)-1 do begin
      diffs = min(abs(height[jj]-levels), ind)
      if diffs lt matchtol then height[jj] = levels[ind]      
    endfor

; This reorders the merger matrix so that it corresponds to the order
; that the nodes are plotted in the dendrogram.

    newmerger = merger
    newmerger[*] = 0
    for k = 0, n_elements(leafnodes)-1 do begin
      for j = 0, k do begin
        newmerger[k, j] = merger[leafnodes[k], leafnodes[j]]
      endfor
    endfor
    newmerger = newmerger > transpose(newmerger)
    order = leafnodes
    sz = size(minicube)    
    cluster_label = labelclusters(height, clusters, $
                                  kernels, levels, x, y, v, t, sz)

; Create a topology structure to contain all the information about the
; cloud's analysis

    structure = {merger:merger, cluster_label:cluster_label, $
                 levels:levels, clusters:clusters, height:height, $
                 kernels:kernels, order:order, $
                 newmerger:newmerger, x:x, y:y, v:v, t:t, sz:sz, $
                 cubeindex:cubeindex, szdata:szdata, $
                 all_neighbors:all_neighbors, err:err, xlocation:xlocation}

    pointer = ptr_new(structure)

  return
end
