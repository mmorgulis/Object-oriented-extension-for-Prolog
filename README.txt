COMPONENTI DEL GRUPPO:

- Colonetti Fabio
- Coldani Andrea


***_____________________________PROGETTO PROLOG_____________________________***



UTILIZZO DEI PREDICATI: 

- def_class:

	arietà:  2 con (nome della classe, lista delle superclassi)
	         3 con (nome della classe, lista delle superclassi, 
			attributi e metodi)

	utilizzo:  aggiunge alla base di conoscenza una classe dati il nome 
		   della classe stessa, la lista delle sue eventuali 
		   superclassi ed eventualmente (nel caso di def_class/3) la 
		   lista di metodi ed attributi.
		   N.B.: Alle classi definite con def_class/2 non manca la 
			 lista degli attributi e dei metodi, ma essa esiste 
			 comunque ed è VUOTA.
		   Sono state implementate tutte le regole di ereditarietà e 
		   di overloading tra classi e superclassi con i relativi 
		   controlli di tipo dei field: Se una classe ha un 
		   field dove NON è specificato il tipo, una sua eventuale 
		   sottoclasse può inserire in tale field un valore diverso 
		   di qualsiasi tipo. Altrimenti, qualora fosse specificato, 
		   la sottoclasse, che vuole inserire un nuovo valore in tale 
		   field, viene creata con successo solo se si ha lo stesso 
		   tipo oppure un sottotipo (esempio: in un "float" può 
		   andare un "integer" ed in un "instance" può andare 
		   un'istanza già esistente).

	esempio:     	
			?- def_class(person, [], [field(name, 'Eve'), 
				     field(age, 21, integer)]).

		   	true.
			
		     	?- def_class(student, [person], 
			   	     [field(name, 'Eva Lu Ator'), 
				      field(university, 'Berkeley'), 
				      method(talk, [], (write('My name is '),
				      field(this, name, N), writeln(N), 
				      write('My age is '), 
				      field(this, age, A), writeln(A)))]).

			true.
		

- make:

	arietà:  2 con (nome dell'istanza, nome classe di appartenenza)
		 3 con (nome dell'istanza, nome classe di appartenenza, lista 
			degli attributi)

	utilizzo:  aggiunge alla base di conoscenza un'istanza dati il nome 
		   dell'istanza stessa, il nome della sua classe di 
		   appartenenza ed eventualmente (nel caso di make/3) la 
		   lista degli attributi dell'istanza.
		   Il make ha due casi di debug possibili (di arietà 3): 
		     - Nel primo caso di debug inserisce nella variabile 
		       passatagli come primo argomento 
		       ,al posto del nome dell'istanza (il resto rimane 
		       invariato a seconda dell'istanza che vogliamo cercare), 
		       l'istanza appena creata. Attenzione, il campo field va 
		       inserito come lista di predicati.
		       es: make(Var, person, [field(name, 'Eve'), 
				field(age, 21)]).
		     - Nel secondo caso di debug, viene visualizzato il 
		       messaggio di corretta unificazione di un'istanza 
		       già esistente con il nome dell'istanza, la sua classe 
		       di appartenenza e il campo field passati. Attenzione, 
		       il campo field va inserito come lista di predicati.
		       es: make(eve, person, [field(name, 'Eve'), 
				field(age, 21)]).
		   N.B.: Alle istanze definite con make/2 non manca la lista 
			 degli attributi, ma essa esiste comunque ed è VUOTA.
		   Sono stati implementati tutti i meccanismi di ereditarietà 
		   degli attributi dalla classe alla quale appartiene 
		   l'istanza con i relativi controlli di tipo delle variabili 
		   eventualmente cambiate nella funzione make rispetto a 
		   quelli ereditati dalla classe (solo se nella classe è 
		   specificata una prescrizione di tipo). Qualora si provasse 
		   ad istanziare un'istanza con un nome corrispondente ad 
		   un'istanza già esistente, quella già esistente verrà 
		   sovrascritta con la nuova classe di appartenenza ed i nuovi 
		   eventuali attributi.
	
	esempio:
			?- make(eve, person).
			Created instance: eve
			true.
			?- make(s1, student, [name = 'Eduardo De Filippo'].
			Created instance: s1
			true.		


- is_class:
	
	arietà:  1 con (nome della classe)

	utilizzo:  controlla se l'atomo passatogli corrisponde con il nome di 
		   una classe presente nella base di conoscenza e in tal caso 
		   restituisce true.
	
	esempio:
			?- is_class(person).
			true.


- is_instance:

	arietà:  1 con (nome dell'istanza da verificare)
		 2 con (nome dell'istanza daverificare, nome superclasse)

	utilizzo:  verifica se il nome dell'istanza passatagli corrisponde 
		   con il nome di una istanza presente nella base di 
		   conoscenza. Il predicato, inoltre, ha successo anche se 
		   il nome dell'istanza passatagli è un'istanza di una 
		   classe che ha la classe passatagli come superclasse.

	esempio:
			?- is_instance(eve).
			true.


- inst:

	arietà:  2 con (nome dell'istanza, variabile)

	utilizzo:  recupera l'istanza dalla base di conoscenza con lo 
		   stesso nome passatogli e la unifica alla variabile 
		   passatagli. Il format dell'output è: [classe di 
		   appartenenza:nome istanza-[...attributi...]].
	
	esempio:
			?- inst(eve, X).
			X = [person:eve-[field(name, 'Eve'), 
			     field(age, 21, integer)]].


- field:

	arietà:  3 con (istanza di una classe, nome dell'attributo, 
			variabile)

	utilizzo:  estrae il valore richiesto di un attributo, attraverso il 
		   suo nome,  dall'istanza indicata e lo unifica alla 
		   variabile passatagli.
	
	esempio: 
			?- field(eve, name, X).
			X = 'Eve'.
			?- field(s1, name, X).
			X = 'Eduardo De Filippo.


- fieldx:

	arietà:  3 con (nome dell'istanza, lista di attributi, variabile)

	utilizzo:  percorre elemento per elemento la lista degli attributi 
		   cercando il primo nell'istanza passatagli.
		   Se nell'attributo trova un'altra istanza esistente 
		   rieffettua la ricerca su tale istanza con il secondo 
		   elemento della lista degli attributi e così via.
		   Il predicato unifica qualora il valore dell'attributo 
		   cercato non corrisponda ad un'istanza ed unifica la 
		   variabile passatagli con tale valore.
	
	esempio: 	
			Sia: c1 un'istanza con un field "other = c2",
			     c2 un'istanza con un field "other = c3",
			     c3 un'istanza con un field "name = 'custom name'.

			?- fieldx(c1, [other, other, name], R).
			R = 'custom name'.



***_______________________________END OF FILE_______________________________***
