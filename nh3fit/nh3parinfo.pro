function nh3parinfo

  parinfo = replicate({limits:fltarr(2), limited:fltarr(2), $
                       fixed:0b, value:0d0, name:'',units:''},7)                

; Temperatures and optical depts are positive!
  parinfo[0].limited[0] = 1b                    
  parinfo[0].limits[0] = 2.73                   
  parinfo[0].name = 'Tkin'
  parinfo[0].units = 'K'
  parinfo[0].value = 15.0


  parinfo[1].limited[0] = 1b                    
  parinfo[1].limits[0] = 0.0                    
  parinfo[1].name = 'log10(N_NH3)'
  parinfo[1].units = 'log(N/cm^-2)'
  parinfo[1].value = 14.0


  parinfo[2].limited[0] = 1b
  parinfo[2].limits[0] = 0.08   ; Channel width
  parinfo[2].name = 'Sigma_v'
  parinfo[2].units = 'km/s'
  parinfo[2].value = 0.2


  parinfo[3].limited = [1b, 1b]
  parinfo[3].limits = [-250,250] ; Limit the VLSR range
  parinfo[3].name = 'VLSR-RAD'
  parinfo[3].units = 'km/s'
  parinfo[3].value = 50.0

  parinfo[4].limited = [1b,1b]
  parinfo[4].limits = [0.0,1.0]; Limit the VLSR range
  parinfo[4].name = 'Tex/Tkin'
  parinfo[4].units = 'K'
  parinfo[4].value = 0.7

  parinfo[5].limited = [1b,1b]
  parinfo[5].limits = [0,1]
  parinfo[5].fixed = 1b
  parinfo[5].name = 'f_ortho'
  parinfo[5].units = 'unitless'
  parinfo[5].value = 0.5

  parinfo[6].limited=[1b,0b]
  parinfo[6].limits=[0.00,0.00]
  parinfo[6].name = 'Tau*(Tex-Tbg)'
  parinfo[6].units = 'K'
  parinfo[6].value = 0.5


  return, parinfo
end
