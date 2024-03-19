%%%% Colonetti Fabio 
%%%% Coldani Andrea 

%%%% -*- Mode: Prolog -*-
%%%% oop.pl

:- dynamic instance/3.
:- dynamic class/3.


% DEF_CLASS/2:
% def_class/2 chiama def_class/3
% con parts uguale alla lista vuota
def_class(ClassName, Parents) :-
    def_class(ClassName, Parents, []).

% DEF_CLASS/3:
% def_class/3 � l'implementazione completa
def_class(ClassName, Parents, Parts) :-
    atomic(ClassName),
    is_list(Parents),
    is_list(Parts),
    \+(is_class(ClassName)),
    % non pu� essere gi� una classe
    \+(member(ClassName, Parents)),
    part_is_correct(Parts),
    has_no_variables(Parents),
    parents_is_class(Parents),
    parents_parts(Parents, ParentsParts),
    flatten(ParentsParts, NewParentsParts),
    concatenate_parts(NewParentsParts, Parts, CompleteParts),
    append(CompleteParts, Parts, FinalParts),
    assert(class(ClassName, Parents, FinalParts)), !.


% HAS_NO_VARIABLES/1:
% controllo che nella lista delle
% superclassi non ci siano variabili
has_no_variables([]).
has_no_variables([X | List]) :-
    atomic(X),
    has_no_variables(List).


% PARENTS_IS_CLASS/1:
% controllo che le superclassi siano anch'esse classi
parents_is_class([]).
parents_is_class([X | Parents]) :-
    class(X, _, _),
    parents_is_class(Parents).


% PARENTS_PARTS/2:
% importo le parts delle superclassi
parents_parts([], []).
parents_parts([X | Parents], [Parts | ParentsParts]) :-
    % controllo errori sulla lista uscente parentsparts
    class(X, _, Parts),
    parents_parts(Parents, ParentsParts).


% CONCATENATE_PARTS/3:
% per comodit� quando definisco la classe
% implemento gi� i metodi delle superclassi
concatenate_parts([], _, []).
concatenate_parts([X | NewParentsParts], Parts,
                  [X | CompleteParts]) :-
    % prendo X vedo se il suo campo age/talk
    % (con arg) esiste: se esiste non faccio nulla
    % e prendo quello di parts (override)
    % se non esiste importo da parents parts e lo
    % aggiungo alla lista finale
    arg(1, X, Term),
    not_part_member(Term, Parts),
    concatenate_parts(NewParentsParts, Parts, CompleteParts).
concatenate_parts([Y | NewParentsParts], Parts, CompleteParts) :-
    check_class_type(Y, Parts),
    concatenate_parts(NewParentsParts, Parts, CompleteParts).


% CHECK_CLASS_TYPE/2:
% controlla che gli attributi delle classi
% siano coerenti tra superclassi e classi
% figlie (un float non pu� essere inserito
% in un intero)

% caso in cui sia un metodo
check_class_type(Y, _) :-
    functor(Y, method, 3).

% caso in cui la superclasse non
% abbia un tipo specificato
check_class_type(Y, _) :-
    functor(Y, field, 2).

% caso in cui i due
% tipi dichiarati siano uguali
check_class_type(Y, [B | _]) :-
    arg(1, Y, C),
    arg(1, B, C),
    functor(Y, field, A),
    functor(B, field, A),
    A == 3,
    arg(3, Y, D),
    arg(3, B, D),
    !.

% caso in cui nella superclasse ci sia
% float e venga dichiarato intero: corretto
check_class_type(Y, [B | _]) :-
    arg(1, Y, C),
    arg(1, B, C),
    functor(Y, field, A),
    functor(B, field, A),
    A == 3,
    arg(3, Y, float),
    arg(3, B, integer).

% caso in cui nella superclasse
% ci sia instance e venga dichiarata
% come istanza: corretto
check_class_type(Y, [B | _]) :-
    arg(1, Y, C),
    arg(1, B, C),
    functor(Y, field, A),
    functor(B, field, A),
    A == 3,
    arg(3, Y, instance),
    arg(3, B, InstanceName),
    instance(InstanceName, _, _).

% caso in cui non trovi il field
% corrispondente: continua a cercarlo
check_class_type(Y, [B | Parts]) :-
    arg(1, Y, _),
    arg(1, B, _),
    check_class_type(Y, Parts).


% NOT_PART_MEMBER/2:
% controllo se part esiste gi� nelle superclassi
not_part_member(_, []).
not_part_member(Term, [Y | Parts]) :-
    arg(1, Y, SecondTerm),
    Term \= SecondTerm,
    not_part_member(Term, Parts).


% PART_IS_CORRECT:
% controlli su parts
part_is_correct([]).
part_is_correct([X | Rest]) :- % field di ariet� 2
    compound(X),
    functor(X, field, 2),
    arg(1, X, FieldName),
    atom(FieldName),
    part_is_correct(Rest).
part_is_correct([X | Rest]) :- % field di ariet� 3
    compound(X),
    functor(X, field, 3),
    arg(1, X, FieldName),
    atom(FieldName),
    % nelle prossime 3 righe controllo che il tipo
    % dichiarato sia effettivamente quello utilizzato
    arg(2, X, A),
    arg(3, X, B),
    check_type(A, B),
    part_is_correct(Rest).
part_is_correct([X | Rest]) :- % method di ariet� 3
    compound(X),
    functor(X, method, 3),
    arg(1, X, MethodName),
    atom(MethodName),
    part_is_correct(Rest).


% SUPERCLASS/2:
% predicato che verifica se una classe
% � superclasse di un'altra
% verifico che sono entrambi classi
% e che la Y abbia come parent X
superclass(X, Y) :-
    is_class(X),
    is_class(Y),
    class(Y, L1, _),
    member(X, L1), !.


% MAKE/2:
make(InstanceName, ClassName) :-
    duplicate_instance_control(InstanceName),
    class(ClassName, _, Parts),
    assert(instance(InstanceName, ClassName, Parts)),
    method_installation(InstanceName, Parts),
    write('Created instance: '),
    write(InstanceName), !.


% MAKE/3:
% caso di debug 2:
make(InstanceName, ClassName, Field) :-
    is_class(ClassName),
    % fa anche il controllo atomic(ClassName)
    atomic(InstanceName),
    is_list(Field),
    instance(InstanceName, ClassName, Field),
    write(InstanceName),
    write(' unifies correctly with: '),
    write(instance(InstanceName, ClassName, Field)), !.


% MAKE/3:
% caso in cui ci InstanceName sia un simbolo
% o una variabile istanziata:
make(InstanceName, ClassName, Field) :-
    is_class(ClassName),
    % fa anche il controllo atomic(ClassName)
    atomic(InstanceName),
    is_list(Field),
    duplicate_instance_control(InstanceName),
    class(ClassName, _, Parts),
    field_is_correct(Parts, Field, NewField),
    flatten(NewField, FlattenNewField),
    add_all_fields(Parts, FlattenNewField, CompleteField),
    append(FlattenNewField, CompleteField, FinalField),
    method_installation(InstanceName, FinalField),
    assert(instance(InstanceName, ClassName, FinalField)),
    write('Created instance: '),
    write(InstanceName), !.


% MAKE/3:
% caso di debug 1, InstanceName � una variabile
% NON istanziata
make(InstanceName, ClassName, Field) :-
    is_class(ClassName),
    % fa anche il controllo atomic(ClassName)
    var(InstanceName), !,
    is_list(Field),
    instance(Name, ClassName, Field),
    InstanceName =.. [instance, Name, ClassName, Field].


% DUPLICATE_INSTANCE_CONTROL/1:
% se un'istanza esiste allora elimino le precedenti
duplicate_instance_control(InstanceName) :-
    retract(instance(InstanceName, _, _)).
duplicate_instance_control(_).


% FIELD_IS_CORRECT/3:
% controllo che il field sia corretto
field_is_correct(_, [], []).
field_is_correct(Parts, [Name = Valore | Field],
                 [NewParts | NewField]) :-
    atomic(Name),
    verifyCorrispondency(Parts, NewParts, Name, Valore),
    NewParts \= [],
    field_is_correct(Parts, Field, NewField).


% CHECK_TYPE/2:
% controlla che il tipo dell'istanza sia coerente
% con quello della classe di appartenenza
check_type(Valore, Tipo) :-
    is_of_type(Tipo, Valore), !.
check_type(Valore, float) :- % caso in cui in un
    % float possa essere messo un intero
    integer(Valore).
check_type(Valore, instance) :-
    instance(Valore, _, _).
check_type(Valore, Tipo) :-
    class(Tipo, _, _),
    instance(Valore, Tipo, _).


% VERIFY_CORRISPONDENCY/4:
% se il field esiste ci sostituisco
% il valore passato con make
verifyCorrispondency([], [], _, _).
verifyCorrispondency([field(Name, _) | Parts],
                     [field(Name, Valore) | NewParts],
                     Name, Valore) :-
    % faccio passare tutta la lista, se Name � presente in
    % parts allora posso sostituirlo
    verifyCorrispondency(Parts, NewParts, Name, Valore).

verifyCorrispondency([field(Name, _, Type) | Parts],
                     [field(Name, Valore, Type) | NewParts],
                     Name, Valore) :-
    % valore deve essere dello stesso tipo del type
    check_type(Valore, Type),
    verifyCorrispondency(Parts, NewParts, Name, Valore).

verifyCorrispondency([_ | Parts],
                     NewParts,
                     Name, Valore) :-
    % se il termine tolto da parts non ha lo stesso nome
    % allora non faccio nulla
    verifyCorrispondency(Parts, NewParts, Name, Valore).


% ADD_ALL_FIELDS/3:
% aggiungo i field che mancano in Complete Fields
add_all_fields([], _, []).
add_all_fields([X | Parts],
               NewField, CompleteField) :-
    arg_NewField(NewField, ListaArg),
    arg(1, X, Nome),
    member(Nome, ListaArg),
    add_all_fields(Parts, NewField, CompleteField).

add_all_fields([X | Parts],
               NewField, [X | CompleteField]) :-
    add_all_fields(Parts, NewField, CompleteField).


% ARG_NEWFIELD/2:
% utilizzato in add_all_fields
arg_NewField([], []).
arg_NewField([X | NewField], [Name | ListaArg]) :-
    arg(1, X, Name),
    arg_NewField(NewField, ListaArg).


% METHOD_INSTALLATION/2:
% costruisco i metodi da asserire
method_installation(InstanceName, Parts) :-
    method_preparation(Parts, String_Method),
    method_division(String_Method, InstanceName).

% seleziono dal parts della
% classe i campi con method
% e li inserisco in String_method
method_preparation([], []).
method_preparation([method(Name, Par, Oth) | Parts_String],
                   [method(Name, Par, Oth) | String_Method]) :-
    method_preparation(Parts_String, String_Method).
method_preparation([_ | Parts_String], String_Method) :-
    method_preparation(Parts_String, String_Method).

% per ogni metodo chiamo method_assertion
method_division([], _).
method_division([Method | Method_String], InstanceName) :-
    method_assertion(Method, InstanceName),
    method_division(Method_String, InstanceName).


% METHOD_ASSERTION/2:
% questo metodo si occupa veramente
% di costruire i metodi per poi asserirli
% nella base dati come predicati
% per semplicit� ci sono i due casi, quelli
% senza parametri e quelli con i parametri
method_assertion(Method, InstanceName) :-
    arg(1, Method, Name),
    % inserisco il nome dell'istanza nel metodo
    string_concat("(", Name, Out),
    string_concat(Out, "(", X),
    string_concat(X, InstanceName, Y),
    arg(2, Method, List_Args),
    List_Args \= [], % sono presenti parametri
    % dato che sono sottoforma di lista li faccio
    % diventare delle stringhe da poter
    % aggiungere all'intestazione del metodo
    term_string(List_Args, String_Args),
    string_length(String_Args, Length),
    Lung is Length - 2,
    sub_string(String_Args, 1, Lung, _, SubString),
    string_concat(Y, ", ", Out2),
    string_concat(Out2, SubString, Out3),
    string_concat(Out3, ")", Method_Def),
    string_concat(Method_Def, ":-", Z),
    arg(3, Method, Body),
    % costruisco il body del metodo
    % prima di tutto lo faccio diventare una lista
    % per poter sostituire facimente tutti i this
    term_string(Body, StringBody),
    string_concat("[", StringBody, StringBody1),
    string_concat(StringBody1, "]", StringBody2),
    term_string(ListBody, StringBody2),
    replace_this(this, InstanceName, ListBody, NewBody),
    % poi lo ricostruisco come stringa facendo le
    % opportune modifiche
    term_string(NewBody, Out4),
    string_length(Out4, L),
    Lu is L - 2,
    sub_string(Out4, 1, Lu, _, SubStringOut4),
    string_concat(SubStringOut4, ")", Out5),
    string_concat(Z, Out5, Final),
    term_string(Metodo, Final),
    % infine lo asserisco come predicato
    assert(Metodo), !.

% molto simile a prima cambia solo che non
% ha parametri
method_assertion(Method, InstanceName) :-
    arg(1, Method, Name),
    string_concat("(", Name, Out),
    string_concat(Out, "(", X),
    string_concat(X, InstanceName, Y),
    arg(2, Method, List_Args),
    List_Args == [], % metodi senza parametri
    string_concat(Y, ")", Method_Def),
    string_concat(Method_Def, ":-", Z),
    arg(3, Method, Body),
    term_string(Body, StringBody),
    string_concat("[", StringBody, StringBody1),
    string_concat(StringBody1, "]", StringBody2),
    term_string(ListBody, StringBody2),
    replace_this(this, InstanceName, ListBody, NewBody),
    term_string(NewBody, Out1),
    string_length(Out1, L),
    Lu is L - 2,
    sub_string(Out1, 1, Lu, _, SubStringOut1),
    string_concat(SubStringOut1, ")", Out2),
    string_concat(Z, Out2, Final),
    term_string(Metodo, Final),
    assert(Metodo).


% REPLACE_THIS/4:
% predicato che rimpiazza this con il nome dell'istanza
replace_this(_, _, [], []).
replace_this(StringToChange, InstanceName,
             [field(StringToChange, Adj, Var) | ListBody],
             [field(InstanceName, Adj, Var) | NewBody]) :-
    replace_this(StringToChange, InstanceName, ListBody, NewBody).

replace_this(StringToChange, InstanceName,
             [X | ListBody], [X | NewBody]) :-
    replace_this(StringToChange, InstanceName, ListBody, NewBody).


% IS_CLASS/1:
% predicato per controllare l'esistenza di una classe
is_class(ClassName) :-
    atomic(ClassName),
    class(ClassName, _, _).


% IS_INSTANCE/1:
% predicato per verificare l'esistenza di un'istanza
is_instance(Value, ClassName) :-
    instance(Value, Class, _),
    superclass(ClassName, Class), !.

is_instance(Value) :-
    instance(Value, _, _).


% INST/2:
% predicato che recupera un'istanza
inst(InstanceName, InstanceName) :-
    instance(InstanceName, _, _).


% RET_INST/2:
% predicato che recupera un'istanza
% e la ritorna formattata
ret_inst(InstanceName, Instance):-
    atomic(InstanceName),
    var(Instance),
    bagof(ClassName: InstanceName - Parts,
          instance(InstanceName, ClassName, Parts),
          Instance), !.


% FIELD/3:
% estrae il valore di un campo da una classe
field(Instance, FieldName, Result) :-
    atomic(Instance),
    atomic(FieldName),
    instance(Instance, _, InstanceField),
    % controllo se l'istanza esiste
    % ed esporto il campo Field
    unify(InstanceField, FieldName, Result).


% UNIFY/3:
% utilizzato in field:
% se trovo il campo cercato lo unifico con result
% altrimenti scorro la lista dei field
unify([], _, _) :- fail.
unify([field(FieldName, FieldAdj) | _], FieldName, FieldAdj) :- !.
unify([field(FieldName, FieldAdj, _) | _], FieldName, FieldAdj) :- !.
unify([_ | InstanceField], FieldName, Result) :-
    unify(InstanceField, FieldName, Result).


% FIELDX/3:
% scorre una lista di attributi e ne estrae il valore dell'ultimo
fieldx(Instance, [X | FieldNames], Result) :-
    instance(Instance, _, _),
    has_no_variables(FieldNames), % controlla anche che sia una lista
    FieldNames \== [], % lista non vuota
    atomic(X),
    field(Instance, X, InstanceName),
    instance(InstanceName, _, _),
    fieldx(InstanceName, FieldNames, Result), !.
fieldx(Instance, [X | FieldNames], Result) :-
    atomic(X),
    has_no_variables(FieldNames), % controlla anche che sia una lista
    field(Instance, X, Result).


%%%% end of file -- oop.pl --


