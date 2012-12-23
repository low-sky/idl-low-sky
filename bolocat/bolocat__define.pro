pro bolocat__define

; Structure definition for catalog entry.  Add tags here for global definition.
  
  s = {BOLOCAT, $
       filename:'', $  ; Original File Name
       name:'', $ ; Name of the source.
       cloudnum:0L, $  ; Running cloud number for this FILE
       npix:0L, $ ; Number of pixels for cloud
       xdata:0d0, $ ; X location in the original data file
       ydata:0d0, $ ; Y location in the original data file
       xdata_err:0d0, $ ; Error in X-location (pixels)
       ydata_err:0d0, $ ; Error in Y-location (pixels)
       xerror_as:0.0, $ ; X-error in arcsec
       yerror_as:0.0, $ ; Y-error in arcsec
       ra:0d0, $ ; Right Ascension (by header astrometry)
       dec:0d0, $ ; Declination (by header astrometry)
       glon:0d0, $ ; Galactic Longitude 
       glat:0d0, $ ; Galactic Latitude
       glon_max:0d0, $ ; Gal .long of max in cloud
       glat_max:0d0, $ ; Gal lat of max in cloud
       flux:0d0, $ ; Total flux in the object. Requires BUNIT, BMAJ and
;       BMIN to be set correctly to work.  
       maxxpix:0.0, $ ; X position of maximum
       maxypix:0.0, $ ; Y position of maximum
       maxra:0d0, $ ; RA of maximum 
       maxdec: 0d0, $ ; DEC of maximum
       momxpix:0.0, $  ; 2nd Moment in the data X-direction
       momypix:0.0, $  ; 2nd Moment in the data Y-direction
       momxpix_err:0.0, $ ; error in 2nd moment, x-direction
       momypix_err:0.0, $ ; error in 2nd moment, y-direction
       mommajpix:0.0, $ ; 2nd Moment along the major axis of the object
       momminpix:0.0, $ ; 2nd moment along the minor axis of the object
       mommaj_as:0.0, $ ; 2nd Moment along the major axis of the object
       mommin_as:0.0, $ ; 2nd moment along the minor axis of the object
       posang:0.0, $ ; Position angle IN THE ORIGINAL DATA!
       rad_pix:0.0, $ ; Radius measured in pixels 
       rad_pix_nodc:0.0, $ ; Radius measured in pixels, no deconvolution
       rad_as:0.0, $  ; Radius in arcseconds
       rad_as_nodc:0.0, $ ; Radius in arcsec, no deconvolution
       concen:0.0, $ ; Concentration parameter
       rms:0.0, $ ; Median error value
       max:0.0, $ ; Maximum data value over all included pixels.
       ppbeam:1.0, $ ; Pixels per beam used in flux calculation
       rms2rad:1.91, $ ; Scale factor from 2nd moment -> Radius
;       grs_spec:fltarr(1000)+!values.f_nan, $ ; GRS spectrum
;       grs_vel:fltarr(1000)+!values.f_nan, $ ; GRS velocity axis
       decomp_alg:'', $ ; Decomposition algorithm used
       threshold:0.0, $ ; Threshold for identifying emission.
       exp_thresh:0.0, $ ; Expanshion threshold for padding out significant regions.
       delta:0.0, $  ; Rejection interval to determine significant peaks.  This is the distance above a saddle point a local max must be to be counted as significant.  
       minpix:0.0, $ ; Minimum number of pixels for siginificant regions.
       pk_s2n:0.0, $ ; Peak S/N value
       mn_s2n:0.0, $ ; Median S/N value
       flux_obj:0.0, $ ; Flux of object determined in an aperture based on its derived size.  
       flux_obj_err:0.0, $
       flux_40:0.0, $           ; Flux in 40" aperture
       eflux_40:0.0, $
       flux_40_nobg:0.0, $           ; Flux in 40" aperture w/no bgs
       eflux_40_nobg:0.0, $
       flux_80:0.0, $           ; Flux in 80" aperture
       eflux_80:0.0, $
       flux_120:0.0, $          ; Flux in 120" aperture
       eflux_120:0.0, $
       gauss_amp:0.0, $  ; Gaussian amplitude
       gauss_maj:0.0, $  ; Gaussian fit major axis
       gauss_min:0.0, $  ; Gaussian fit minor axis
       gauss_xc:0.0, $ ; Gaussian fit x centroid
       gauss_yc:0.0, $ ; Gaussian fit y centroid
       gauss_pa:0.0, $ ; Gaussian fit position angle
       gauss_flux:0.0, $; Gaussian fit integrated flux density
       gauss_chisq:0.0 $ ; Chisq of gaussian fit
         }

         return
end
