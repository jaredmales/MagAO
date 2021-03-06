;+
;   NAME:
;    INIT_RTR_M2C
;
;   PURPOSE:
;       Restore the modes to commands matrix(matrix_M2C)
;
;   USAGE:
;    err = init_rtr_m2c(M2C_FILENAME=M2C_filename, STRUCT=struct, NOFILL=nofill)
;
;   INPUT:
;       None.
;   OUTPUT:
;    Error code.
;
;   KEYWORD:
;
;    M2C_FILENAME : path of file where is saved the M2C_matrix
;    STRUCT      : structure creates in the file in which the m2c data are saved.
;    NOFIL       : If it is set, the rtr reconstructor fields are filled up.
;
;  COMMON BLOCKS:
;   RTR               : secondary adaptive base common block. A part of it will be filled.
;
;  PACKAGE:
;   LBT Adsec Libraries.
;
;  HISTORY
;   Created on 7 Feb 2005 by Daniela Zanotti (DZ).
;   07 Oct 2005, MX
;     RTR matrices now managed by pointers.
;   January 2006, DZ
;     Added a writefits if no M2C matrix exists.
;     Added keyword nowrite.  
;   03 April 2007, MX
;     Bug in the size of M2C matrix [n_modes2correct,n_acts].      
;   NOTE:
;    None.
;-

function init_rtr_m2c, M2C_FILENAME=m2c_filename, STRUCT=struct, NOFILL=nofill, $
                        NO_WRITE=no_write

@adsec_common

; Restoring the feedforward matrix
;
n_acts = adsec.n_actuators
no_write = 1

if (keyword_set(m2c_filename)) then begin
    
    check = file_search(m2c_filename)

    if check[0] eq ""  then begin
        message, 'The file '+m2c_filename+ $
        " containing the modes to commands matrix(M2C) doesn't exist", /INFO
        print, 'A zero matrix will be used as M2C matrix'
        meas_m2c_used = 0B
        m2c_matrix = fltarr(rtr.n_modes2correct,n_acts)
        if ~keyword_set(no_write) then writefits, adsec_path.data+'m2c_matrix.fits', m2c_matrix

    endif else begin
        m2c_matrix = 0 
        m2c_matrix = readfits(m2c_filename)
        meas_m2c_used = 1B
   endelse                                                                                                                          
endif else begin
    message, "No file containing m2c_matrix was selected ", /INFO
        print, 'A zero matrix will be used as modes to commands matrix'
        meas_m2c_used = 0B
        m2c_matrix = fltarr(rtr.n_modes2correct,n_acts)
        if ~keyword_set(no_write) then writefits, adsec_path.data+'m2c_matrix.fits', m2c_matrix
endelse
;
; End of: Restoring the modes to commands  matrix
;
;===================================================================================================
;
if test_type(m2c_matrix, /REAL, DIM=dim) then $
   message, "The M2C matrix must be real"
      if dim[0] ne 2 then $
         message, "The M2C matrix must be a 2-D matrix"
         if total(dim eq [2, rtr.n_modes2correct, n_acts]) ne 3 then $
            message, "The M2C matrix must be a " $
                   +strtrim(rtr.n_modes2correct,2)+"x"+strtrim(n_acts,2)+" matrix."


struct = $
  { $
    meas_m2c_used : meas_m2c_used ,$  ; 1B: a m2c_matrix stored in data dir has been used (0B: eitherwise)
    m2c_matrix : ptr_new(/alloc) $ ; M2C matrix: n_act X n_act 
 }
*struct.m2c_matrix = m2c_matrix
;
;==================================================================================================
;
if not(keyword_set(nofill)) then begin
    rtr.meas_m2c_used = meas_m2c_used ; 1B: a k matrix stored in data dir has been used (0B: eitherwise)
    ptr_free, rtr.m2c_matrix
    rtr.m2c_matrix = ptr_new(m2c_matrix) ; m2c matrix: n_act X n_act
endif


return, adsec_error.ok
end
