function labelclusters, height, clusters, decimkern, levelsin, $
  x, y, v, t, szin, $
  all_neighbors = all_neighbors

  sz = szin
  if sz[0] eq 2 then sz[3] = 1
  cubify, x, y, v, t, sz, c = c
  x0 = decimkern mod sz[1]
  y0 = (decimkern mod (sz[1]*sz[2]))/sz[1]
  v0 = decimkern/(sz[1]*sz[2])
  clusterlabel = intarr(sz[1], sz[2], sz[3])+2^15-1
  levels = reverse(levelsin[sort(levelsin)])
; We need an array to tell secondary clusters (not leaves) where to
; find a point within them.  This initializes that array
  usekernels = intarr(max(clusters)+1)+max(clusters)+2

  for k = 0, max(clusters) do begin
   print, k
; Find all parent clusters
    roots = cluster_member(k, clusters)
    print, roots
; Tell every parent cluster to use the smallest index kernel within it
; as a seed point.
    usekernels[roots] = (min(roots))+intarr(n_elements(roots)) $
                        < usekernels[roots]
    mrglevels = height[roots[1]]
; For this cluster, find the lowest level in it that's above a merge
    sup = max(where(levels gt float(mrglevels), ct))
    if ct eq 0 then sup = 0
    above_mrg = levels[sup]
; Contour above this level
    mask = label_region(c ge above_mrg, all_neighbors = all_neighbors, /ulong)
; Reject regions that don't contain the kernel
    mask = mask eq mask[x0[usekernels[k]], y0[usekernels[k]], v0[usekernels[k]]]; Label every point in this with the smallest value present (k or a
; preassigned value)
    clusterlabel[where(mask)] = clusterlabel[where(mask)] < k
  endfor
;  clusterlabel[where(c lt min(height))] = max(clusters)+1
; Send back a vector.
  return, clusterlabel[x, y, v]
end



;  labelcube = intarr(n_elements(t))+(2^15-1)
;; Figure out what we've labelled.  Start a counter.
;  done = [-1]

;  for k = 0, n_elements(decimkern)-1 do begin

;; Find the kernel in the vectors
;    kernel = decimkern[k]
;    x0 = kernel mod sz[1]
;    y0 = (kernel mod (sz[1]*sz[2]))/sz[1]
;    v0 = kernel/(sz[1]*sz[2])

;; Find the cluster roots of this cluster:

;    roots = cluster_member(k, clusters)

;; Find which ones haven't been labelled.
;    still_remaining = notind(done, n_elements(clusters))
;    mrglevels = height[roots]
;    above_mrg = mrglevels
;; Figure out the levels immediately above the merge points.
;    for i = 1, n_elements(roots)-1 do begin 
;      sup = max(where(levels gt mrglevels[i]))
;      if sup gt 0 then above_mrg[i] = levels[sup]
;    endfor

;; Decide where to stop looking for labels in the roots and pare the
;; search levels down accordingly
;    stopper = max(intersection(roots, still_remaining))
;    index = (where(stopper eq roots)+1) < (n_elements(roots)-1)
;    roots = roots[0:index]
;    above_mrg = above_mrg[0:index]
;    mrglevels = mrglevels[0:index]
;; Find the regions above the mrg levels
;    tlevel = contourcloud(x, y, v, t, x0 = x0, $
;                          y0 = y0, v0 = v0, clev = above_mrg)
;    for j = 1, n_elements(above_mrg)-1 do begin
;      index = where(tlevel ge above_mrg[j], ct)
;      if ct eq 0 then continue
;      labelcube[index] = roots[j-1] < labelcube[index]      
;    endfor
;; Grab everything >= the last level
;    tlevel = contourcloud(x, y, v, t, x0 = x0, $
;                          y0 = y0, v0 = v0, clev = mrglevels[j-1])
;    index = where(tlevel ge mrglevels[j-1], ct)
;    if ct gt 0 then labelcube[index] = roots[j-1] < labelcube[index]
;    done = [done, roots]
;    done = done[uniq(done, sort(done))]
;  endfor
;; Patch up last bit of cloud into the final cluster
;  ind = where(labelcube gt n_elements(clusters), ct)
;  if ct gt 0 then labelcube[ind] = n_elements(clusters) 

;  return, labelcube
;end


