pro jstring, name, ra, dec

  ra = dblarr(n_elements(name))
  dec = dblarr(n_elements(name)) 

  hr = strmid(name, 1, 2)
  min = strmid(name, 3, 2)
  sec = strmid(name, 5, 4)
  ra = (double(hr)+double(min)/60+double(sec)/3600.)*15
  
  deg = double(strmid(name, 9, 3))
  min = double(strmid(name, 12, 2))
  sec = double(strmid(name, 14, 2))

  dec = deg+min/60.+sec/3600.
  return
end
