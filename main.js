//jusitification container
const diagnosticText = document.querySelector("#diagnostic");
//list container
const listContainer = document.querySelector(".list-container");
//list of syntoms
const listText = document.querySelector("#list");
//syntom container
const justificationContainer = document.querySelector(".justification-container");
//btn init
const btnInit = document.querySelector("#init");

// create session
var session = pl.create();

//consult the program 'prolog/prolog_program.pl'
session.consult("prolog/prolog_program.pl", {
  success: function () {
    console.log("all good");
  },
  error: function (err) {
    /* Error parsing goal */ console.log(err);
    document.body.innerHTML = "<p>" + err + "</p>";
  },
});

btnInit.addEventListener("click", () => {
  initProgram();
});

function show() {
  return function (answer) {
    // Valid answer
    if (pl.type.is_substitution(answer)) {
    }
  };
}

function initProgram() {
  listContainer.style.display = "none";
  justificationContainer.style.display = "none";
  //goal
  session.query("consulta.", {
    success: function (goal) {
      /* Goal parsed correctly */ console.log(goal);
    },
    error: function (err) {
      /* Error parsing goal */ console.log(err);
    },
  });

  session.answers(show(), 1000);
}

function showSyntom(syntom) {
  let res = window.prompt(`¿Es verdad que ${syntom}?`);
  res = res === null ? "empty" : res;
  console.log(res);
  return res;
}

function validateInputSyntom() {
  alert("Debes contestar si, no o porque");
}

function wantToJustify() {
  let just = confirm("¿Deseas una justificación del diagnóstico?");
  just = just ? "si" : "no";
  //console.log("respuesta: " + just);
  return just;
}

function wantToKnowWhy(diagnostic, syntom) {
  alert(`Estoy investigando la hipótesis ${diagnostic}.\nPara esto necesito saber si ${syntom}`);
}

function showDiagnostic(diagnostic) {
  justificationContainer.style.display = "block";
  diagnosticText.innerHTML = `El diagn&oacute;stico es ${diagnostic}`;
}

function listSyntom(syntom) {
  listContainer.style.display = "block";
  //normalize string
  syntom = syntom.substring(0, 1).toUpperCase() + syntom.substring(1);
  //create nodes
  let node = document.createElement("LI");
  let textNode = document.createTextNode(syntom);
  //append node to the list
  node.appendChild(textNode);
  listText.appendChild(node);
}

function knowledgeLoss() {
  alert("No hay suficiente conocimiento para elaborar un diagnóstico");
}
