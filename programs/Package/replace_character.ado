* replace_character: program to replace several characters and accents 
* Version 3.0

program define replace_character

	args var

	replacestrvar `var' , r("ŕ ĂĄ ă ą ąă ĂŁ ăł ł à Á á") w("a") 
	replacestrvar `var' , r("ĂŠ Ă¨ č é è ? ę ê")         w("e") 
	replacestrvar `var' , r("Í í Ą")                     w("i") 
	replacestrvar `var' , r("ń ¤")                       w("n") 
	replacestrvar `var' , r("Ó ó ˘ ö")                   w("o") 
	replacestrvar `var' , r("Ú ú")                       w("u") 
	replacestrvar `var' , r("- ..")                      w(" ") 

end
	
