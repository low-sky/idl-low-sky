function ewrbase, data, order = order, nomask = nomask, mask = mask

  if n_elements(order) eq 0 then order = 2

  nelts = n_elements(data) 
  if nelts eq 1 then return,0.0

  x = findgen(nelts)/(nelts-1)

  ind = where(finite(data),ct)
  if ct eq 0 then return,0.0
  baseline = svdfit(x[ind], data[ind], order, /legendre, yfit = yf)
  basemod = fltarr(nelts)
  for k = 0, order-1 do basemod = basemod+legendre(x, k)*baseline[k]

  if keyword_set(nomask) then return,basemod

  if n_elements(mask) eq n_elements(data) then ind = where(mask) else begin
     trialdata = data-basemod
     rms = mad(trialdata)
     ind = where((abs(trialdata) lt rms*3.5) and finite(data),ct)
  endelse
  if ct eq 0 then return, 0.0
  baseline = svdfit(x[ind], data[ind], order, /legendre, yfit = yf)
  basemod = fltarr(nelts)
  for k = 0, order-1 do basemod = basemod+legendre(x, k)*baseline[k]


  return,basemod
end
