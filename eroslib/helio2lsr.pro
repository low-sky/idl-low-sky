pro helio2lsr, vhelio, vlsr, ra = ra, dec = dec, g = g, reverse = reverse, $
               dynamical = dynamical,  kinematic = kinematic
;+
; NAME:
;   HELIO2LSR
; PURPOSE:
;   Converts between heliocentric and LSR velocities
;
; CALLING SEQUENCE:
;   HELIO2LSR, v_helio, v_lsr,ra = ra, dec = dec, g = g
;
; INPUTS:
;   V_HELIO -- Heliocentric velocity in km/s
;
; KEYWORD PARAMETERS:
;   RA, DEC -- The RA and DEC of the object out for conversion in
;              decimal degrees.
;   G -- Galaxy structure or any structure with tags RA and DEC
;   REVERSE -- Perform V_LSR -> V_HELIO
;   KINEMATIC -- Set to use with the the Kinematic definition of the
;                LSR (Default)
;   DYNAMICAL -- Set to use with the Dynamical definition of the LSR.
;   (see http://www.gb.nrao.edu/~fghigo/gbtdoc/doppler.html)
; OUTPUTS:
;   V_LSR -- The other one is returned, unless REVERSE is set.
;
; MODIFICATION HISTORY:
;
;	Wed Apr 26 10:17:57 2006, Erik Rosolowsky (erosolow@cfa)
;               Seriously debugged with Dave Wilner's help.  Added
;               /KINEMATIC and /DYNAMICAL flags.  Caught sign error.  
;
;       Mon Jan 26 14:10:02 2004, Erik Rosolowsky <eros@cosmic>
;		Written
;
;-

  if n_elements(g) gt 0 then begin
    ra = g.ra
    dec = g.dec
  endif

  if n_elements(ra) eq 0 or n_elements(dec) eq 0 then begin
    message, 'RA and DEC are needed to specify the conversion.', /con
    message, 'Use J2000 coordinates!', /con
    return
  endif

; From http://www.gb.nrao.edu/~fghigo/gbtdoc/doppler.html

  if (not keyword_set(dynamical)) or (keyword_set(kinematic)) then begin
    solarmotion_ra = ((18+03/6d1+50.29/3.6d3)*15)*!dtor
    solarmotion_dec = (30+0/6d1+16.8/3.6d3)*!dtor
    solarmotion_mag = 20.0
  endif else begin
    solarmotion_ra = ((17+49/6d1+58.667/3.6d3)*15)*!dtor
    solarmotion_dec = (28+7/6d1+3.96/3.6d3)*!dtor
    solarmotion_mag = 16.55294
  endelse

  racalc = ra*!dtor
  deccalc = dec*!dtor
  gcirc, 0, solarmotion_ra, solarmotion_dec, racalc, deccalc, theta


; Do V_HEL -> V_LSR
  if not keyword_set(reverse) then begin
    vlsr = vhelio+solarmotion_mag*cos(theta)
    return
  endif
; Do V_LSR -> V_HEL
  vhelio = vlsr-solarmotion_mag*cos(theta)

  return
end
