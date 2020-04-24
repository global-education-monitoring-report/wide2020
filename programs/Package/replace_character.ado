* replace_character: program to replace several characters and accents 
* Version 3.0

program define replace_character

	args var

	replacestrvar `var' , r("ĂŠ Ă¨ č é è")     w("e") 
	replacestrvar `var' , r("ŕ ĂĄ ă ą ąă ĂŁ ăł ł à á") w("a") 
	replacestrvar `var' , r("ń")               w("n") 
	replacestrvar `var' , r("í")               w("i") 
	replacestrvar `var' , r("ó")               w("o") 
	replacestrvar `var' , r("ú")               w("u") 
	replacestrvar `var' , r("-")               w(" ") 
	

end
	
