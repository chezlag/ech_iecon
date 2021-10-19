

compare ht11 bc_ht11_sss_corr if bc_nper==1

/*
                                        ---------- difference ----------
                            count       minimum      average     maximum
------------------------------------------------------------------------
ht11<bc_ht11~r               1045     -57146.32    -1640.198   -7.28e-12
ht11=bc_ht11~r              10378
ht11>bc_ht11~r              38974      1.82e-12     2934.186      252374
                       ----------
jointly defined             50397     -57146.32     2235.113      252374
                       ----------
total                       50397

. 
end of do-file
*/
