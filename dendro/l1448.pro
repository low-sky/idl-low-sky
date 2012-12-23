pro l1448

; Read in the data
  data = readfits('L1448.13co.un.fits', hd)

  eff = 1.0 ; Beam efficiency 1.0 for MB scale.
  data = data/eff

; Masking routine -- 2 level masking, start at 5-sigma clip, expand to
;                    2-sigma).  
  m = gmask(data, 5, 2)

; Measures the noise level in the data cube
;  err = mad(data)

;  Does hierarchical analysis
  topologize, $
     data, $ ; This is the data variable
     m, $ ; This masks to the region you care about (1 cloud)
     delta = 1.2, $ ; Local Maximum rejection criterion (1.2 is in K/main beam)
     pointer = ptr, $ ; Output pointer 
     nlevels = 500, $ ; Number of contour levels used in the analysis
     friends = 5, $ ; Noise suppression box size in spatial dimension in pixels, half the total dimension (for 5, this screens over a box 2*5+1)
     specfriends = 5 ; Noise suppression box size in velocity

; LAbels the cube and dumps out a numbered tree
; String is the "root" file name, data file name - '.fits'
; Also dumps Mike's root.cluster.xml file
; dumps cluster labeled cube into root.cll.fits
; dumps number tree into root.clusters.ps
  labelcube, ptr, 'L1448.13co.un', /ps
  
; Measurement of cloud properties under the three paradigms
  levelprops, ptr, $ ; input pointer
              hd = hd, $ ; fits string header 
              dist = 260, $ ; distance to object
              /extrap ; How to calculate properties (/extrap = extrapolation)
; save data file
  save, file = 'l1448.extrap.dat', ptr
; Default to bijection
  levelprops, ptr, hd = hd, dist = 260
  save, file = 'l1448.noex.dat', ptr

; /clip = clipping.
  levelprops, ptr, hd = hd, dist = 260, /clip
  save, file = 'l1448.clip.dat', ptr

  return
end
