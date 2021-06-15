:- dynamic(conocido/1).
:- use_module(library(js)).

/* BaseConocimientos1: diagnosticos y sintomas
   Dominio: diagnostico medico. Trata los sintomas como una lista multi-elementos
*/
conocimiento('sarampion', 
['el paciente esta cubierto de puntos', 'el paciente tiene temperatura alta',
 'el paciente tiene ojos rojos','el paciente tiene tos seca']).

conocimiento('influenza',
['el paciente tiene dolor en las articulaciones', 'el paciente tiene mucho
estornudo','el paciente tiene dolor de cabeza']).

conocimiento('malaria',
['el paciente tiene temperatura alta','el paciente tiene dolor en las
articulaciones', 'el paciente tiembla violentamente', 'el paciente tiene
escalofrios']).

conocimiento('gripe',
['el paciente tiene cuerpo cortado', 'el paciente tiene dolor de cabeza', 'el
paciente tiene temparatura alta']).

conocimiento('tifoidea',
['el paciente tiene temperatura alta', 'el paciente tiene dolor de cabeza',
'el paciente tiene fatiga', 'el paciente tiene diarrea', 'el
paciente tiene cefalea', 'el paciente tiene nauseas', 'el paciente
tiene dolores abdominales']).

conocimiento('covid',
['el paciente tiene fiebre', 'el paciente tiene tos seca', 'el
paciente tiene cansancio', 'el paciente tiene dolores musculares']).


/*   Sistema Experto: experto.pl
       Trata los sintomas como una lista. La cabeza es el diagnostico y la “cola” son
 los sintomas.
       Utiliza assert/1 para cambiar dinamicamente la base de conocimientos.
       Determina la verdad y falsedad de los sintomas conocidos.
       Puede contestar a las preguntas 'porque' e incluye capacidad de explicacion.
       Elimina dinamicamente las aseveraciones agregadas despues de cada consulta.
*/

consulta:-
      haz_diagnostico(X),
      escribe_diagnostico(X),
      ofrece_explicacion_diagnostico(X),
      clean_scratchpad, halt(0).

consulta:-
      /*se muestra que no hay suficiente conocimiento*/
      prop(knowledgeLoss, KnowledgeLoss), apply(KnowledgeLoss, [], _),  
      clean_scratchpad.

haz_diagnostico(Diagnosis):- 
      obten_hipotesis_y_sintomas(Diagnosis, ListaDeSintomas), 
      prueba_presencia_de(Diagnosis, ListaDeSintomas).

obten_hipotesis_y_sintomas(Diagnosis, ListaDeSintomas):-
      conocimiento(Diagnosis,ListaDeSintomas).

prueba_presencia_de(_Diagnosis, []).

prueba_presencia_de(Diagnosis, [Head | Tail]):- 
      prueba_verdad_de(Diagnosis, Head),
      prueba_presencia_de(Diagnosis, Tail).

prueba_verdad_de(_Diagnosis, Sintoma):- 
      conocido(Sintoma).

prueba_verdad_de(Diagnosis, Sintoma):- 
      not(conocido(is_false(Sintoma))),
      pregunta_sobre(Diagnosis, Sintoma, Reply), 
      Reply = si.

pregunta_sobre(Diagnosis, Sintoma, Reply):- 
        /*se muestra el sintoma en pantalla*/
        prop(showSyntom, ShowSyntom), apply(ShowSyntom, [Sintoma], Respuesta), 
        process(Diagnosis, Sintoma, Respuesta, Reply).

process(_Diagnosis, Sintoma, si, si):- 
      asserta(conocido(Sintoma)).

process(_Diagnosis, Sintoma, no, no):- 
      asserta(conocido(is_false(Sintoma))).

process(_Diagnosis, Sintoma, empty, empty):-
      halt(0).      

process(Diagnosis, Sintoma, porque, Reply):- 
      /*se pregunta por que*/
      prop(wantToKnowWhy, WantToKnowWhy), apply(WantToKnowWhy, [Diagnosis,Sintoma], RespuestaUsuario),
      pregunta_sobre(Diagnosis, Sintoma,Reply).
     

process(Diagnosis, Sintoma, Respuesta, Reply):- 
      Respuesta \== no,
      Respuesta \== si, Respuesta \== porque, Respuesta \== empty, nl,
      /*se valida el input de sintoma*/
      prop(validateInputSyntom, ValidateInputSyntom), apply(ValidateInputSyntom, [], _),
      pregunta_sobre(Diagnosis, Sintoma, Reply).

escribe_diagnostico(Diagnosis):- 
      /*se envia el diagnostico*/
      prop(showDiagnostic, ShowDiagnostic), apply(ShowDiagnostic, [Diagnosis], _).

ofrece_explicacion_diagnostico(Diagnosis):-
      pregunta_si_necesita_explicacion(Respuesta),
      actua_consecuentemente(Diagnosis,Respuesta).

pregunta_si_necesita_explicacion(Respuesta):-
      /*se pregunta si se quiere una justificacion*/
      prop(wantToJustify, WantToJustify), apply(WantToJustify, [], RespuestaUsuario),
      asegura_respuesta_si_o_no(RespuestaUsuario, Respuesta).

asegura_respuesta_si_o_no(si, si).
asegura_respuesta_si_o_no(no, no).

/*asegura_respuesta_si_o_no(_, Respuesta):- 
      write('Debes contestar si o no a que si quieres que se justifique.'),
      pregunta_si_necesita_explicacion(Respuesta).*/

actua_consecuentemente(_Diagnosis, no).

actua_consecuentemente(Diagnosis, si):- 
      conocimiento(Diagnosis, ListaDeSintomas),
      write('Se determino este diagnostico porque se encontraron los siguentes sintomas: '), nl,
      escribe_lista_de_sintomas(ListaDeSintomas).

escribe_lista_de_sintomas([]).

escribe_lista_de_sintomas([Head | Tail]):-
      /*se envia cada item de la lista*/
      prop(listSyntom, ListSyntom), apply(ListSyntom, [Head], _),
      escribe_lista_de_sintomas(Tail).

clean_scratchpad:- 
      retract(conocido(_X)), 
      fail.

clean_scratchpad.

conocido(_):- 
      fail.

not(X):- 
      X,!,fail.
      
not(_).

end:-
  halt(0).
% working_directory(PWD,"/home/ivn/Documents/prolog").