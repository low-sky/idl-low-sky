function cluster_member, leafnode, clusters

; find the number all clusters that LEAFNODE belongs to.

  roots = [leafnode]
  sz = size(clusters)
  node = leafnode
  repeat begin
    ind = where(clusters eq node)
    clnum = (ind/2)+sz[2]+1
    roots = [roots, clnum]
    node = clnum[0]
  endrep until (clnum eq 2*sz[2])
  


  return, roots
end
