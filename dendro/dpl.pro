pro dpl, input, _extra = ex, annotate = annotate, labels = labels, $
         mask = mask, overplot = overplot, hcolor = hcolor, hthick = hthick, $
         hline = hline, block = block
;+
; NAME:
;    DPL
; PURPOSE:
;    To generate a dendroplot for a merger matrix.  
; CALLING SEQUENCE:
;    DPL, merger_matrix [plot keywords]
;      or 
;    DPL, topology_pointer [plot keywords]
; INPUTS:
;    MERGER_MATRIX -- A standard merger matrix
;    TOPOLOGY_POINTER -- A pointer to a heap variable structure containing the
;                        topology information for a given data set.
; OPTIONAL INPUTS:
;    Accepts most plot keywords.  And dollar bills.
; MODIFICATION HISTORY:
;
;	Thu Oct 26 15:58:51 2006, Erik
;
;-

  type = size(input, /type)
  if type eq 10 then begin
    leafnodes = (*input).order
    xlocation = (*input).xlocation
    height = (*input).height
    clusters = (*input).clusters
    levels = (*input).levels
    merger = (*input).merger
    newmerger = (*input).newmerger
  endif else newmerger = input
  
  if n_elements(hcolor) eq 0 then hcolor = 128b 
  if n_elements(hthick) eq 0 then hthick = 4*!p.thick
  if n_elements(hline) eq 0 then hline = 0

  if n_elements(labels) eq 0 then begin 
    labels = string(sqrt(n_elements(newmerger)))+' '
    annotation = decimals(leafnodes, 0)
  endif else begin
    annotation = labels
  endelse



  if not keyword_set(overplot) then begin  
    sz = size(merger)
    vals = merger[indgen(sz[1]), indgen(sz[1])]
    v1 = vals#replicate(1, sz[1])
    v2 = transpose(v1)
    d = max(merger)-merger
    d[indgen(sz[1]), indgen(sz[1])] = 0
;  d = (v1-newmerger) < (v2-newmerger)

    cl = cluster_tree(d, ld)
    cldendro, cl, ld, merger, _extra = ex, label_names = string(sqrt(n_elements(newmerger)))+' '
    
    if keyword_set(annotate) then begin
      xyouts, indgen(n_elements(leafnodes)), $
              newmerger[indgen(n_elements(leafnodes)), $
                        indgen(n_elements(leafnodes))]*1.02, $          
              orientation = 90, align = 0, annotation, $
              charsize = 1.5, _extra = ex
    endif
  endif
    if keyword_set(mask) then begin
      for i = 0, n_elements(leafnodes)-1 do begin
        
; For a given LEAFNODE trace its path from leaf to root:
        roots = cluster_member(leafnodes[i], clusters)
; Find the plotted positions of these points.
        xpos = xlocation[roots]
        ypos = height[roots]
;    oplot, xpos, ypos, ps = 4, color = !blue
; Select which levels to highlight based on the virial parameter.  
;        highlight = mask[i, *] lt 2 and mask[i, *] gt 0
        highlight = mask[i, *]
; Identify chunks in the virial parameter space
        label = label_region(reform(highlight))
        for chunk = 1, max(label) do begin
          subind = where(label eq chunk, ct)
          if ct eq 1 or keyword_set(block) then begin
            yvals = levels[subind]
            xvals = fltarr(ct)
            for j = 0, ct-1 do xvals[j] = xpos[max(where(yvals[j] le ypos))]
            usersym, [-0.5, 0.5, 0.5, -0.5, -0.5], $
              [-0.1, -0.1, 0.1, 0.1, -0.1], /fill
            plots, xvals, yvals, ps = 8, color = hcolor, $
              symsize = 1, /con

          endif else begin
            yvals = levels[subind]
            corners = intersection(yvals, ypos, corner_ct, $
                                   /index_tag, b_ind = bind, a_ind = aind)
            xvals = fltarr(ct)
            for j = 0, ct-1 do xvals[j] = xpos[max(where(yvals[j] le ypos))]
; Stick in corners!
            if corner_ct gt 0 then begin
              for k = 0, corner_ct-1 do begin
                if aind[k]+k+1 ge n_elements(yvals) then continue
                yvals = [yvals[0:(aind[k]+k)], $
                         yvals[aind[k]+k], $
                         yvals[((aind[k])+k+1):*]]
                xvals = [xvals[0:(aind[k]+k)], $
                         xvals[aind[k]+k+1], $
                         xvals[(aind[k]+k+1):*]]
              endfor
            endif
            oplot, xvals, yvals, color = hcolor, thick = hthick, line = hline
          endelse
        endfor
      endfor
    endif


  return
end
