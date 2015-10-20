function binavg, x_in, y_in, _ref_extra = ex, stdev = stdev_y, $
                 counts = counts, binsize = binsize, centers = bincenters, $
                 xavg = xavg, xstdev = stdev_x, median = median, $
                 reject = reject, finite = finite, binmin = binmin, $
                 binmax = binmax, rank = rank
;+
; NAME:
;   BINAVG
;
; PURPOSE:
;   To perform a binned average of a set of data.
;
; CALLING SEQUENCE:
;   avg = BINAVG(x, y, [stdev = stdev, counts = counts])
;
; INPUTS:
;   X -- The values to be binned.
;   Y -- The values to be averaged.
;
; KEYWORD PARAMETERS:
;   All extra keywords passed to HISTOGRAM function and named
;   variables are passed back (e.g. OMIN and such)
;   STDEV -- Name of variable to accept the standard deviation around
;            the mean.
;   COUNTS -- Vector returning the number of data in each bin.;
;   CENTER -- The X values of the bin centers.
;   XAVG -- The average value of X in each bin.
;   XSTDEV -- The standard deviation around each bin center.
;   MEDIAN -- Use median instead of the mean.
;   REJECT -- Reject values greater than this many sigma 
;             from mean and recompute. If used in conjunction with
;             MEDIAN, this is the fraction of points at the wings to reject.
;   BINMIN, BINMAX -- Minimum and maximum values in each bin 
;                     (after rejection!)
;   RANK -- Instead of returning the mean / median, fill the resulting
;           vector with this rank of point (between 0 and 1).  0.5 is
;           equivalent to the /MEDIAN keyword.
; OUTPUTS:
;   AVG -- The average in each bin.
;
; MODIFICATION HISTORY:
;
;       Tue Oct 20 11:46:56 2015, <erosolo@noise.siglab.ok.ubc.ca>
;
;		Small fixes to make rejection work. Thanks to Adam
;		McLean for pointing out the errors."
;
;       Wed Aug 11 09:44:33 2004, <eros@master>
;		Added RANK keyword.
;
;       Tue Dec 9 15:49:40 2003, <eros@master>
;		Added BINMIN and BINMAX values.
;
;       Tue Nov 25 16:58:30 2003, <eros@master>
;		Added FINITE keyword.
;
;       Thu May 22 13:31:51 2003, <eros@master>
;		Written.
;
;-

  if n_elements(x) ne n_elements(y) then begin
    message, 'X and Y vectors must have same size!', /info
    return, !values.f_nan
  end

  if keyword_set(finite) then begin
    goodind = where(finite(x_in) and (x_in eq x_in) and (y_in eq y_in) $
                    and finite(y_in), ct)
    if ct eq 0 then return, !values.f_nan
    x = x_in[goodind]
    y = y_in[goodind]
  endif else begin
    x = x_in
    y = y_in
  endelse

  counts = histogram(x, _extra = ex, reverse = ri, $
                     binsize = binsize, omin = omin)
  bincenters = findgen(n_elements(counts))*binsize+binsize/2.0+omin

  yavg = make_array(n_elements(counts), type = size(y, /type))
  xavg = make_array(n_elements(counts), type = size(x, /type))
  stdev_y = yavg
  stdev_x = xavg
  binmin = yavg
  binmax = yavg
  for i = 0, n_elements(counts)-1 do begin
    case ri[i+1]-ri[i] of
      0: begin
        yavg[i] = !values.f_nan
        stdev_y[i] = !values.f_nan
        xavg[i] = !values.f_nan
        stdev_x[i] = !values.f_nan
        binmin[i] = !values.f_nan
        binmax[i] = !values.f_nan
      end
      1: begin
        xavg[i] = x[ri[ri[i]]]
        yavg[i] = y[ri[ri[i]]]
        stdev_y[i] = !values.f_nan
        stdev_x[i] = !values.f_nan
        binmin[i] = y[ri[ri[i]]]
        binmax[i] = binmin[i]
      end
      else: begin
        index = ri[ri[i]:ri[i+1]-1] 
        moment_y = (moment(y[index], sdev = sdy, /nan))[0]
        moment_x = (moment(x[index], sdev = sdx, /nan))[0]
        binmin[i] = min(y[index], /nan)
        binmax[i] = max(y[index], /nan)

        if keyword_set(reject) then begin
          yvals = y[index]
;          djs_iterstat, yvals, sigrej = reject, mean = mean, sigma = sdy
          ind = where(yvals ge moment_y-reject*sdy and $
                      yvals le moment_y+reject*sdy, ct)
          if ct gt 2 then moment_y = moment(yvals[ind],  sdev = sdy, /nan) 
          binmin[i] = min(yvals[ind], /nan)
          binmax[i] = max(yvals[ind], /nan)

        endif
        yavg[i] = moment_y[0]
        stdev_y[i] = sdy
        xavg[i] = moment_x[0]
        stdev_x[i] = sdx
        if n_elements(rank) gt 0 then begin
          stdev_y[i] = !values.f_nan
          stdev_x[i] = !values.f_nan
          vec = y[index]
          xvec = x[index]
          sindex = sort(vec)
          vec = vec[sindex]
          xvec = xvec[sindex]
          yavg[i] = vec[0 > (rank*(counts[i]-1) < (counts[i]-1))]
          xavg[i] = xvec[0 > (rank*(counts[i]-1) < (counts[i]-1))]
        endif        
        if keyword_set(median) then begin
          yavg[i] = median(y[index])
          xavg[i] = median(x[index])
          stdev_x[i] = mad(x[index])
          stdev_y[i] = mad(y[index])
        endif
        if keyword_set(median) and keyword_set(reject) then begin
          yvals = y[index]
          xvals = x[index]
          nelts = ri[i+1]-ri[i]
          nkill = reject*nelts/2
          if nkill ge 1 then begin
            goodind = (sort(yvals))[nkill:(nelts-nkill-1)]
            yavg[i] = median(yvals[goodind])
            xavg[i] = median(xvals[goodind])
            stdev_x[i] = mad(xvals[goodind])
            stdev_y[i] = mad(yvals[goodind])
            binmin[i] = min(yvals[goodind], /nan)
            binmax[i] = max(yvals[goodind], /nan)
          endif
        endif 
      endelse
    endcase
  endfor
  return, yavg
end
