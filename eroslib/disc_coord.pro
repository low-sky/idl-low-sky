function disc_coord,  ra_in, dec_in, gname, $
  structure = structure, posang = posang, $
  inc = inc, ra_gc = ra_gc, dec_gc = dec_gc, dist = dist, $
  orient = orient, galstr = g, header = header, params = gp
;+
; NAME:
;   DISC_COORD
; PURPOSE:
;   To convert from sky coordinates to coordinates on a galactic disc.
;
; CALLING SEQUENCE:
;   result = DISC_COORD(ra, dec)
;
; INPUTS:
;   ra -- The Right ascensions of points to be converted.
;   dec -- The declinations of points to be converted.
;   gname -- String matching name of galaxy in GALAXIES function
;
; KEYWORD PARAMETERS:
;   STRUCTURE - set this flag to return a structure.
;   POSANG - The position angle of the line of nodes.
;   INC - Inclination of the disk
;   RA_GC - The RA of the galactic center.
;   DEC_GC - The DEC of the galactic center.
;   DIST - The distance to the galaxy.
;   GALSTR - Galaxy information structure.  See GALAXIES.PRO
; 
; NOTES:
;   Program defaults to M33.
;
; OUTPUTS:
;   RESULT: The distance from the center of the galaxy.
;   
;   If the STRUCTURE keyword is set, then the routine returns a
;   structure with tags x and y for the appropriate coordinates. x and
;   y are of the same dimension as passed to the routine.  The
;   structure contains tag r, the radial distance from the center.
;
; MODIFICATION HISTORY:
;
;       Tue Apr 19 13:15:22 2005, <eros@master>
;		Changed to use IDL ASTRO spherical trig as opposed to
;		my own.  
;
;       Tue Nov 25 16:37:49 2003, <eros@master>
;         Added GNAME argument		
;
;       Changed the value of
;       M33 distance to match the Kennicutt values that we like.  Fri
;       Feb 14 16:12:22 2003, Erik Rosolowsky <eros@cosmic>
;       
;       Modified to include galaxy structures.
;       Wed Jun 12 15:21:39 2002, Erik Rosolowsky <eros@cosmic>
;
;       Documented -- 
;       Tue Jan 23 12:28:03 2001, Erik Rosolowsky <eros@cosmic>
;
;-

  if n_params() eq 1 then gname = ra_in
  if n_elements(header) gt 0 then begin
    rdhd, header, s = h, c = c, /full
    ra_in = c.ra
    dec_in = c.dec
  endif

  if n_elements(gname) gt 0 then g = galaxies(gname)
  
  if n_elements(g) eq 0 then g = galaxies('M33')
  if n_elements(g) gt 0 then begin
    posang = g.posang*!dtor
    inc = g.inc*!dtor
    ra_gc = g.ra_gc
    dec_gc = g.dec_gc
    dist = g.dist
  endif

  if n_elements(gp) gt 0 then begin
    posang = gp.posang_deg*!dtor
    inc = gp.incl_deg*!dtor
    ra_gc = gp.ra_deg
    dec_gc = gp.dec_deg
    dist = gp.dist_mpc*1d6
  endif



;  if not keyword_set(posang) then posang = 23*!dtor      
;; Quoted Value by 1989, AJ, 97,97 (Zaritsky et al.)
;  if not keyword_set(inc) then inc = 52*!dtor
;  if not keyword_set(ra_gc) then ra_gc = double([01, 33, 50.8])
;  if not keyword_set(dec_gc) then dec_gc = double([30, 39, 36.7])
;  if not keyword_set(dist) then dist = 850000.

  if n_elements(ra_gc) gt 1 then ra_gc = convang(ra_gc, /ra)
  if n_elements(dec_gc) gt 1 then dec_gc = convang(dec_gc)

  ra_gc = ra_gc*!dtor
  dec_gc = dec_gc*!dtor

  ra = double(ra_in*!dtor)
  dec = double(dec_in*!dtor)

; Calculate great circle distance (theta) between the galactic center
; and the ra and dec given.

  gcirc, 0, ra, dec, ra_gc, dec_gc, theta
  posang, 0, ra_gc, dec_gc, ra, dec, pos
  pos = pos-posang
  index = where(pos lt -!pi, ct)
  if ct gt 0 then pos[index] = pos[index]+2*!pi
  index = where(pos gt !pi, ct)
  if ct gt 0 then pos[index] = pos[index]-2*!pi

; Next transform into the X and Y coordinates on a plane tangent to
; the sky at the galactic center with +X axis along the major axis

  r_plane = dist*tan(theta)
  x_plane = r_plane*cos(pos)
  y_plane = r_plane*sin(pos)

; Now project X_PLANE and Y_PLANE into the plane of the galaxy.
; X_PLANE remains the same, Y_PLANE is expanded by 1/cos(inc)

  x_g = x_plane
  y_g = y_plane/cos(inc)
  r = sqrt(x_g^2+y_g^2)

;   costheta = sin(dec)*sin(dec_gc)+cos(dec)*cos(dec_gc)*cos(ra-ra_gc)
;   sintheta = sqrt(1-costheta^2)

; ; Both roots of sqrt?!
;   parab = (1-costheta^2-sin(ra-ra_gc)^2*cos(dec)^2)
;   ind = where(parab gt -1e-8 and parab lt 0, ct)
;   if ct gt 0 then parab[ind] = 0.0
;   x = (1-2*(dec le dec_gc))*dist*sqrt(parab)
;   y = dist*sin(ra-ra_gc)*cos(dec)
;   x_g = x*cos(posang)+y*sin(posang)
;   y_g = (-sin(posang)*cos(inc)-sin(posang)*sin(inc)*tan(inc))*x+$
;         (cos(posang)*cos(inc)+tan(inc)*sin(inc)*cos(posang))*y
;   ra = ra*!radeg
;   dec = dec*!radeg
;   r = sqrt(x_g^2+y_g^2)

  if keyword_set(structure) then return, {x:x_g, y:y_g, r:r}
  return, r
end



