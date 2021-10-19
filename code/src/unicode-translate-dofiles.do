cd "old/v1.2"
cd "1981-1989"
unicode analyze *.do
unicode encoding set windows-1252
unicode translate *.do	
cd .. 

forvalues y = 1990/2019 {
	cd `y'
	unicode analyze   *.do
	unicode encoding set windows-1252
	unicode translate *.do
	cd ..
}
