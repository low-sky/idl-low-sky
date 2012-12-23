pro nameregen, bgps

; Helper utility to santize names in galactic coordinates.


  for i = 0, n_elements(bgps)-1 do begin
    glon_max = bgps[i].glon_max
    glat_max = bgps[i].glat_max
    if glon_max lt 0 then glon_str = decimals(360-glon_max, 3) else $
       glon_str = decimals(glon_max, 3)
    if glon_max lt 10 then glon_str = '0'+glon_str
    if glon_max lt 100 then glon_str = '0'+glon_str
    glat_str = decimals(abs(glat_max), 3)
    if abs(glat_max) lt 10 then glat_str = '0'+glat_str
    if glat_max ge 0 then glat_str = '+'+glat_str else glat_str = '-'+glat_str
    bgps[i].name = 'G'+glon_str+glat_str
  endfor 

  return
end
