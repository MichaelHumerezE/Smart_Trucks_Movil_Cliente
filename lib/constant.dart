import 'package:flutter/material.dart';

// ----- STRINGS ------
const baseURL = 'https://www.basurero-inteligente.site/api';
const loginURL = baseURL + '/loginC';
const registerURL = baseURL + '/registerC';
const logoutURL = baseURL + '/logout';
const getUserURL = baseURL + '/getUser';
const createAlarmaURL = baseURL + '/createAlarma';
const getAlarmaURL = baseURL + '/getAlarmas';
const getLastAlarmaURL = baseURL + '/getLastAlarma';
const getRutasURL = baseURL + '/getRutas';
const getRutaURL = baseURL + '/getRuta';

// ----- Errors -----
const serverError = 'Server error';
const unauthorized = 'Unauthorized';
const somethingWentWrong = 'Something went wrong, try again!';

// --- input decoration
InputDecoration kInputDecoration(String label) {
  return InputDecoration(
      labelText: label,
      contentPadding: EdgeInsets.all(10),
      border: OutlineInputBorder(borderSide: BorderSide(width: 1, color: Colors.black))
    );
}


// button

TextButton kTextButton(String label, Function onPressed){
  return TextButton(
    child: Text(label, style: TextStyle(color: Colors.white),),
    style: ButtonStyle(
      backgroundColor: MaterialStateColor.resolveWith((states) => Colors.blue),
      padding: MaterialStateProperty.resolveWith((states) => EdgeInsets.symmetric(vertical: 10))
    ),
    onPressed: () => onPressed(),
  );
}

// loginRegisterHint
Row kLoginRegisterHint(String text, String label, Function onTap) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(text),
      GestureDetector(
        child: Text(label, style:TextStyle(color: Colors.blue)),
        onTap: () => onTap()
      )
    ],
  );
}