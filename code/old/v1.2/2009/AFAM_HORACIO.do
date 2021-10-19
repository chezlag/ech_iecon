gen afam_total=0
	replace afam_total=1 if afam_pe_hog==1
	replace afam_total=1 if afam_cont_hog==1
