pro levelprops, p, extrapolate = extrapolate, deltav = deltav, $
                psize = psize, xfac = xfac, hd = hd, dist = dist, $
                forcelin = forcelin, clip = clip

; Pointer variable in, add information.  Calculate the properties of
; the emission as a function of level.  Return RMAT, VMAT, LMAT  

if n_elements(extrapolate) eq 0 then noextrap = 1b else noextrap = 0b
if n_elements(psize) eq 0 then psize = 1
if n_elements(deltav) eq 0 then deltav = 1
if n_elements(xfac) eq 0 then xfac = 1

if n_elements(hd) gt 0 and n_elements(dist) eq 1 then begin
    rdhd, hd, s = h
; DEG -> PC
    psize = abs(h.cdelt[1])*!dtor*dist
; M/S -> KM/S
    if n_elements(h.cdelt) eq 3 then $  
      deltav = abs(h.cdelt[2]/1e3) else $
      deltav = 1.0
endif 


; Dereference out of the heap.  

leafnodes = (*p).order
levels = (*p).levels
decimkern = (*p).kernels
sz = (*p).sz
x = (*p).x
y = (*p).y
v = (*p).v
t = (*p).t
err = (*p).err
order = (*p).order
newmerger = (*p).newmerger

; Initialize the matrix of virial parameters: N_local_max by N_levels

rmat = fltarr(n_elements(leafnodes), n_elements(levels))+!values.f_nan 
vmat = rmat
lmat = rmat
nmat = rmat
xmat = rmat
ymat = rmat
vvmat = rmat
rmat_err = rmat
vmat_err = vmat
lmat_err = lmat
majmat = rmat
minmat = rmat
pamat = rmat 
for i = 0, n_elements(leafnodes)-1 do begin
; Pick a kernel.
    kernel = decimkern[order[i]]
; Find its positions
    x0 = kernel mod sz[1]
    y0 = (kernel mod (sz[1]*sz[2]))/sz[1]
    v0 = kernel/(sz[1]*sz[2])
; Find its location in the vector data
    ind = (where(x eq x0 and y eq y0 and v eq v0))[0]
; Determine all new points that we have to calcuate properties at.
    calc_levels = where(levels le t[ind] and $
                        rmat[i, *] ne rmat[i, *], calc_ct)
; If the matrix is all filled in for this cloud, then no worries!
    
    if calc_ct eq 0 then continue
; Calculate properties

;;     str = contour_prop(x, y, v, t, ind[0], $
;;                        levels = levels[calc_levels], $
;;                        noextrap = noextrap, $
;;                        all_neighbors = all_neighbors, /rotate, $
;;                        forcelin = forcelin, remove_min = clip, err = err)

    str = contour_prop(float(x), float(y), float(v), float(t), ind[0], $
                       levels = levels[calc_levels], $
                       noextrap = 1, $
                       all_neighbors = all_neighbors, $
                       forcelin = forcelin, remove_min = clip, err = err)

    strrot = contour_prop(float(x), float(y), float(v), float(t), ind[0], $
                          levels = levels[calc_levels], $
                          noextrap = 1, $
                          all_neighbors = all_neighbors, /rotate, $
                          forcelin = forcelin, remove_min = clip, err = err, $
                          pavec = pavec)



; Fill in the property matrices for this kernel.
    rmat[i, calc_levels] = (1.91*sqrt(strrot.rmsx*strrot.rmsy))*psize
    vmat[i, calc_levels] = sqrt((str.rmsv)^2)*deltav
    lmat[i, calc_levels] = str.flux*psize^2*deltav
    nmat[i, calc_levels] = str.number
    xmat[i, calc_levels] = str.xcen
    ymat[i, calc_levels] = str.ycen
    vvmat[i, calc_levels] = str.vcen
    lmat_err[i, calc_levels] = str.eflux*psize^2*deltav
    rmat_err[i, calc_levels] = 1.91*psize/(2*sqrt(strrot.rmsx*strrot.rmsy))*$
      sqrt(strrot.rmsy^2*strrot.ermsx^2+strrot.rmsx^2*strrot.ermsy^2)
    vmat_err[i, calc_levels] = str.ermsv*deltav
    pamat[i, calc_levels] = pavec+!pi/2*(strrot.rmsy gt strrot.rmsx)
    minmat[i, calc_levels] = (strrot.rmsy < strrot.rmsx)
    majmat[i,calc_levels] = (strrot.rmsx > strrot.rmsy)
    if keyword_set(extrapolate) then begin
        message,'Warning!  Extrapolation currently disabled!  You are not getting extrapolated properties!',/con
        vmat[i, calc_levels] = sqrt((str.rmsv)^2)*deltav
    endif

; Fill in any common values that we can determine based on our
; calculations
    for j = i+1, n_elements(order)-1 do begin
        repeat_ind = where(levels lt newmerger[i, j], ct)
        if ct gt 0 then begin
            lmat[j, repeat_ind] = lmat[i, repeat_ind]
            rmat[j, repeat_ind] = rmat[i, repeat_ind]
            vmat[j, repeat_ind] = vmat[i, repeat_ind]
            nmat[j, repeat_ind] = nmat[i, repeat_ind]
            xmat[j, repeat_ind] = xmat[i, repeat_ind]
            ymat[j, repeat_ind] = ymat[i, repeat_ind]
            vmat[j, repeat_ind] = vmat[i, repeat_ind]
            lmat_err[j, repeat_ind] = lmat_err[i, repeat_ind]
            rmat_err[j, repeat_ind] = rmat_err[i, repeat_ind]
            vmat_err[j, repeat_ind] = vmat_err[i, repeat_ind]
            minmat[j, repeat_ind] = minmat[i, repeat_ind]
            majmat[j, repeat_ind] = majmat[i, repeat_ind]
            pamat[j, repeat_ind] = pamat[i, repeat_ind]

        endif
    endfor
endfor

labelmat = fix(lmat)*0-1
clusters = (*p).clusters
sz = size(clusters)
height = (*p).height
for i = 0, n_elements(height)-1 do begin
    roots = cluster_leaves(i, clusters)
    ind = where(roots le (n_elements(leafnodes)-1), ct)
    goodlvls = where(levels le height[i])
    for j = 0, ct-1 do begin
        null = where(roots[ind[j]] eq leafnodes)
        labelmat[null[0], goodlvls] = $
          labelmat[null[0], goodlvls] > i
    endfor
endfor 

ind=where(pamat gt !pi,ct)
if ct gt 0 then pamat[ind]=pamat[ind]-!pi

; Dump new data into the heap.  
tn = tag_names(*p)
if total(tn eq 'LMAT') gt 0 then begin
    (*p).lmat = lmat
    (*p).rmat = rmat
    (*p).vmat = vmat
    (*p).nmat = nmat
    (*p).xmat = xmat
    (*p).ymat = ymat
    (*p).vvmat = vvmat
    (*p).labelmat = labelmat
    (*p).hd = hd
    (*p).lmat_err = lmat_err
    (*p).rmat_err = rmat_err
    (*p).vmat_err = vmat_err
    (*p).majmat = majmat
    (*p).minmat = minmat
    (*p).pamat = pamat

endif else begin
    (*p) = create_struct((*p), 'lmat', lmat, 'rmat', rmat, $
                         'vmat', vmat, 'nmat', nmat, 'xmat', xmat, $
                         'ymat', ymat, 'vvmat', vvmat, 'labelmat', labelmat, $
                         'hd', hd, 'lmat_err', lmat_err, $
                         'rmat_err', rmat_err, $
                         'vmat_err', vmat_err, 'majmat',majmat,$
                         'minmat',minmat, 'pamat',pamat)
endelse     


return
end
