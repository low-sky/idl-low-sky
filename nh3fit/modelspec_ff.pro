function modelspec_ff, xin, p, tau11 = tau11,tau22 = tau22, tau33 = tau33, tau44 = tau44

; Spectral model for BOLOCAM NH3 survey.

  sfac = 4

; p = [Tkin,log(Ntot),sigv,vlsr,Tex,fortho]

  tkin = p[0]
  tex = tkin
  Ntot = 1d1^p[1]
  width = p[2]
  voff = p[3]
  fortho = p[5]
  fillfrac = p[4]


  ckms = 2.99792458d5
  c = ckms*1d5
  g1 = 1                
  g2 = 1                
  h = 6.6260693d-27     
  kb = 1.3806505d-16     
  mu0 = 1.476d-18               ; Dipole Moment in cgs (1.476 Debeye)

  nu11 = 23.694506d9
  nu22 = 23.722633335d9
  nu33 = 23.8701296d9
  nu44 = 24.1394169d9

  a11 = 1.712d-7  ;64*!pi^4/(3*h*c^3)*nu11^3*mu0^2*(1/2.)
  a22 = 2.291d-7  ;64*!pi^4/(3*h*c^3)*nu22^3*mu0^2*(2/3.)
  a33 = 2.625d-7  ;64*!pi^4/(3*h*c^3)*nu33^3*mu0^2*(3/4.)
  a44 = 3.167d-7  ;64*!pi^4/(3*h*c^3)*nu44^3*mu0^2*(4/5.)

; Generate Partition Functions  
  nlevs = 51
  jv=findgen(nlevs)
  ortho=where((jv mod 3) eq 0,comp=para)
  jpara = jv[para]
  jortho = jv[ortho]
  Brot = 298117.06d6
  Crot = 186726.36d6
  Zpara = (2*Jpara+1)*exp(-h*(Brot*Jpara*(Jpara+1)+$
                              (Crot-Brot)*Jpara^2)/(kb*tkin))
  Zortho = 2*(2*Jortho+1)*exp(-h*(Brot*Jortho*(Jortho+1)+$
                                 (Crot-Brot)*Jortho^2)/(kb*tkin))
  

  tau11 = Ntot * (1-fortho) * Zpara[0]/total(Zpara) / $
          (1+exp(-h*nu11/(kb*tkin))) * c^2/(8*!pi*nu11^2)*a11*$
          (1-exp(-h*nu11/(kb*tex)))/(width/ckms*nu11*sqrt(2*!pi))

  tau22 = Ntot * (1-fortho) * Zpara[1]/total(Zpara) / $
          (1+exp(-h*nu22/(kb*tkin))) * c^2/(8*!pi*nu22^2)*a22*$
          (1-exp(-h*nu22/(kb*tex)))/(width/ckms*nu22*sqrt(2*!pi))

  tau44 = Ntot * (1-fortho) * Zpara[2]/total(Zpara) / $
          (1+exp(-h*nu44/(kb*tkin))) * c^2/(8*!pi*nu44^2)*a44*$
          (1-exp(-h*nu44/(kb*tex)))/(width/ckms*nu44*sqrt(2*!pi))

  tau33 = Ntot * (fortho) * Zortho[1]/total(Zortho) / $
          (1+exp(-h*nu33/(kb*tkin))) * c^2/(8*!pi*nu33^2)*a33*$
          (1-exp(-h*nu33/(kb*tex)))/(width/ckms*nu33*sqrt(2*!pi))

  goodind = where(xin gt 0,ct)
  if ct eq 0 then return,!values.f_nan
  x = xin[goodind]
  runspec = dblarr(n_elements(x))


; Do the (1,1) From CLASS data
  voff_lines = [19.8513, $
                19.3159, $
                7.88669, $
                7.46967, $
                7.35132, $
                0.460409, $
                0.322042, $
                -0.0751680, $
                -0.213003, $
                0.311034, $
                0.192266, $
                -0.132382, $
                -0.250923, $
                -7.23349, $
                -7.37280, $
                -7.81526, $
                -19.4117, $
                -19.5500]

  tau_wts = [0.0740740, $
             0.148148, $
             0.0925930, $
             0.166667, $
             0.0185190, $
             0.0370370, $
             0.0185190, $
             0.0185190, $
             0.0925930, $
             0.0333330, $
             0.300000, $
             0.466667, $
             0.0333330, $
             0.0925930, $
             0.0185190, $
             0.166667, $
             0.0740740, $
             0.148148]

  lines = (1-voff_lines/ckms)*23.6944955d0
  tau_wts = tau_wts / total(tau_wts)
  nuwidth = width/ckms*lines*(-1)
  nuoff = voff/ckms*lines*(-1)

  tauprof = dblarr(n_elements(x))
  for k = 0, n_elements(nuoff)-1 do begin 
    tauprof = tauprof+tau11*tau_wts[k]*$
              exp(-(x-nuoff[k]-lines[k])^2/(2*nuwidth[k]^2))
  endfor

; Next, add in the (2,2)!

  voff_lines = [26.5263, $
                26.0111, $
                25.9505, $
                16.3917, $
                16.3793, $
                15.8642, $
                0.562503, $
                0.528408, $
                0.523745, $
                0.0132820, $
                -0.00379100, $
                -0.0132820, $
                -0.501831, $
                -0.531340, $
                -0.589080, $
                -15.8547, $
                -16.3698, $
                -16.3822, $
                -25.9505, $
                -26.0111, $
                -26.5263]
  tau_wts = [0.00418600, $
             0.0376740, $
             0.0209300, $
             0.0372090, $
             0.0260470, $
             0.00186000, $
             0.0209300, $
             0.0116280, $
             0.0106310, $
             0.267442, $
             0.499668, $
             0.146512, $
             0.0116280, $
             0.0106310, $
             0.0209300, $
             0.00186000, $
             0.0260470, $
             0.0372090, $
             0.0209300, $
             0.0376740, $
             0.00418600]
  
  tau_wts = tau_wts/total(tau_wts)

  lines = (1-(voff_lines/ckms))*23.722633335d0
  ckms = 2.99792458d5
  nuwidth = width/ckms*lines*(-1)
  nuoff = voff/ckms*lines*(-1)

  for k = 0, n_elements(nuoff)-1 do begin 
    tauprof = tauprof+tau22*tau_wts[k]*$
              exp(-(x-nuoff[k]-lines[k])^2/(2*nuwidth[k]^2))
  endfor

; Do NH3 (3,3)

  voff_lines = [29.195098, $
                29.044147, $
                28.941877, $
                28.911408, $
                21.234827, $
                21.214619, $
                21.136387, $
                21.087456, $
                1.005122, $
                0.806082, $
                0.778062, $
                0.628569, $
                0.016754, $
                -0.005589, $
                -0.013401, $
                -0.639734, $
                -0.744554, $
                -1.031924, $
                -21.125222, $
                -21.203441, $
                -21.223649, $
                -21.076291, $
                -28.908067, $
                -28.938523, $
                -29.040794, $
                -29.191744]

  tau_wts = [0.012263, $
             0.008409, $
             0.003434, $
             0.005494, $
             0.006652, $
             0.008852, $
             0.004967, $
             0.011589, $
             0.019228, $
             0.010387, $
             0.010820, $
             0.009482, $
             0.293302, $
             0.459109, $
             0.177372, $
             0.009482, $
             0.010820, $
             0.019228, $
             0.004967, $
             0.008852, $
             0.006652, $
             0.011589, $
             0.005494, $
             0.003434, $
             0.008409, $
             0.012263]

  tau_wts = tau_wts/total(tau_wts)

  lines = (1-(voff_lines/ckms))*23.8701296d0
  nuwidth = width/ckms*lines*(-1)
  nuoff = voff/ckms*lines*(-1)

  for k = 0, n_elements(nuoff)-1 do begin 
    tauprof = tauprof+tau33*tau_wts[k]*$
              exp(-(x-nuoff[k]-lines[k])^2/(2*nuwidth[k]^2))
  endfor


; NH3 (4,4) from Keto?
  nuoff_lines =  [0.0000, $
            -2.4540, $
            2.4540, $     
            0.0000, $        
            1.9520, $        
            -1.9520, $        
            0.0000]/1d3

  tau_wts = [0.2431, $
             0.0162, $
             0.0162, $
             0.3008, $
             0.0163, $
             0.0163, $
             0.3911]
  lines = nuoff_lines+24.1394169d0
  nuoff = voff/ckms*lines*(-1)

  tau_wts = tau_wts/total(tau_wts)
  ckms = 2.99792458d5
  nuwidth = width/ckms*24.1394169d0
  for k = 0, n_elements(nuoff)-1 do begin 
    tauprof = tauprof+tau44*tau_wts[k]*$
              exp(-(x-nuoff[k]-lines[k])^2/(2*nuwidth^2))
  endfor

  T0 = (6.626d-27*x*1d9/1.38d-16)
  runspec = (T0/(exp(T0/tex)-1)-T0/(exp(T0/2.73)-1))*(1-exp(-tauprof))+runspec

;; FREQUENCY SWITCH
  defsysv,'!NH3',exists = exists
  if exists then begin
     if (!nh3.freqswthrow gt 0) then begin
        runspec = runspec-0.5*(interpol(runspec, x, x-!nh3.freqswthrow/1d3))-$
                  0.5*(interpol(runspec, x, x+!nh3.freqswthrow/1d3))
     endif
  endif

;; CONVOLUTION HERE
;;   range = 16	
;;   offsets = findgen(sfac*range+1)/sfac-range/2
;;   kernel = sin(offsets*!pi)/offsets/!pi
;;   kernel[sfac*range/2] = 1.0
;;   kernel = kernel/total(kernel)
;;   conspec = convol(runspec, kernel, /edge_trun)
;;   outspec = rebin(conspec, n_elements(xin)) 

  outspec = dblarr(n_elements(xin)) 
  outspec[goodind] = runspec
  
; Do a proper interpolation onto the exp(-x2) fcn here XXX

;  eta = 1.32*0.71*exp(-(4*!pi*390d-9*x*1d9/ckms)^2)
;  outspec = outspec*eta*fillfrac
  return, outspec
end
