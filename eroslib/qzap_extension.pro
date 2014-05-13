pro qzap_extension,filename,fileout=fileout,zap=zap,_extra=ex

; This file qzaps the zeros extension of an XIDL long_reduce image
; stack.
; Extra keywords passed to qzap

if n_elements(zap) eq 0 then zap = 0  
if n_elements(fileout) eq 0 then fileout = 'qzapped.fits'

rdfits_struct,filename,str

qzap,str.im0,newim,_extra=ex

struct = mrdfits(filename,5,hdr_struct)
mwrfits,newim,fileout,str.hdr0,/create
mwrfits,str.im1,fileout,str.hdr1 
mwrfits,str.im2,fileout,str.hdr2 
mwrfits,str.im3,fileout,str.hdr3 
mwrfits,str.im4,fileout,str.hdr4 
mwrfits,struct,fileout,hdr_struct

  return
end
