* replace_character: program to replace several characters and accents 
* Version 2.0

program define replace_character
		
	cleanchars , in("ĂŠ Ă¨ č é è")   out("e") vval values
	cleanchars , in("ă ŕ ĂĄ ĂŁ à á") out("a") vval values
	cleanchars , in("ń")             out("n") vval values
	cleanchars , in("í")             out("i") vval values
	cleanchars , in("ó")             out("o") vval values
	cleanchars , in("ú")             out("u") vval values
	cleanchars , in("-")             out(" ") vval values

end
	
