pro subcubes, sz, x0 = x0, y0 = y0, x1 = x1, y1 = y1, size = size,$
              stagger = stagger, structure = structure
;+
; NAME:
;   SUBCUBES
; PURPOSE:
;   When dealing with large cubes, it's easier to just extract
;   subcubes and process them individually.  This routine generates a
;   structure with tags corresponding to the corners of the subcubes
;   or 4 vectors of the corrdinates.
;
; CALLING SEQUENCE:
;   SUBCUBES, size_vector [, x0 = x0, y0 = y0, x1 = x1, y1 = y1, 
;   size = size, stagger = stagger, structure = structure 
;              
; INPUTS:
;   SIZE -- The size vector, the output from the SIZE function or a
;           vector such that SIZE[1] is the X size, SIZE[2] is the Y
;           size and SIZE[3] is the Z size.
;
; KEYWORD PARAMETERS:
;   X0,X1,Y0,Y1 -- Names of vectors to store the start X, finish X,
;                  start Y and Finish Y indices respectively for each cube.
;   STRUCTURE -- Name of a structure to store the indices of the cube
;                corners.  The tage names are X0, X1, Y0, Y1,
;                corresponding to the vectors detailed above.
;   SIZE -- The length of each subcube size (only does square cubes
;           right now.  Defaults to 100
;   STAGGER -- The stagger of each center relative to the next.
;              Defaults to SIZE
; OUTPUTS:
;   See Keywords.
;
; MODIFICATION HISTORY:
;      Documented.
;       Wed Nov 21 12:34:47 2001, Erik Rosolowsky <eros@cosmic>
;-


if not keyword_set(size) then size = 100
if not keyword_set(stagger) then stagger = size

nx = (sz[1]-size)/stagger+1
rx = (sz[1]-size) mod stagger
if rx ne 0 then nx = nx+1
ny = (sz[2]-size)/stagger+1
ry = (sz[2]-size) mod stagger
if ry ne 0 then ny = ny+1
x0 = indgen(nx)*stagger
x1 = x0+size-1
x1[nx-1] = sz[1]-1
y0 = indgen(ny)*stagger
y1 = y0+size-1
y1[ny-1] = sz[2]-1

structure = {x0:x0, y0:y0, x1:x1, y1:y1}


  return
end
