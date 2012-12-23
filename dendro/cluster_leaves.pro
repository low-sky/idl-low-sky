function cluster_leaves, label, clusters

; Given a cluster label, this routine finds all subclusters that are
; its children.

  sz = size(clusters)
  nleaves = (sz[2]+1)

; Work array to make sure we get to the leaves
  children = label
; Output array containing all the subclusters
  outchildren = children
  while (total(children gt nleaves-1) gt 0) do begin
; Find first cluster label that's out of bounds
    ind = min(where(children gt nleaves-1))
; Find the children of that cluster
    new_kids = clusters[*, children[ind]-nleaves]
    if n_elements(children) eq 1 then children = new_kids else begin
      ni = notind(ind, n_elements(children)) 
      children = [children[ni], new_kids]
    endelse
    outchildren = [outchildren, new_kids]
  endwhile


  return, outchildren
end
