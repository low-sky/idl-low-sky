function fracshift, vector, shift
;+
; NAME:
;    FRACSHIFT
; PURPOSE:
;    To shift a vector by a fraction of a pixel.
;
; CALLING SEQUENCE:
;    result = FRACSHIFT(V, DV)
;
; INPUTS:
;    V -- A vector
;    DV -- Arbitrary real shift in pixel units
; KEYWORD PARAMETERS:
;    None.  Yet.
;
; OUTPUTS:
;    RESULT -- The shifted vector.
;
; RESTRICTIONS:
;    Beware of edges!
; MODIFICATION HISTORY:
;
;       Sun Oct 19 13:07:32 2003, <eros@master>
;		Written.  For the good of the Universe.
;
;-

  smshift = floor(shift)
  lgshift = ceil(shift)
  delta = shift-smshift

  wt_sm = (1-delta)
  wt_lg = (delta)


  interp = wt_sm*shift(vector, smshift)+wt_lg*shift(vector, lgshift)

  return, interp
end
