
cd "old/v1.2/1981-1989"
unicode analyze *.do
unicode analyze   *.do
unicode encoding set latin1
unicode translate *.do
cd .. 

forvalues y = 1990/2019 {
	cd `y'
	unicode analyze   *.do
	unicode encoding set latin1
	unicode translate *.do
	cd ..
}
