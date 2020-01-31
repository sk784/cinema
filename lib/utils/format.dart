import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RusNumberTextInputFormatter extends TextInputFormatter{
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final newTextLength = newValue.text.length;
    final newText = StringBuffer();
    int selectionIndex = newValue.selection.end;
    int usedSubstringIndex = 0;
    if(newTextLength >= 1){
      newText.write('(');
      if(newValue.selection.end >= 1) selectionIndex++;
    }

    if(newTextLength >= 4){
      newText.write(newValue.text.substring(0,usedSubstringIndex = 3)+')');
      if(newValue.selection.end >= 3) selectionIndex++;
    }

    if(newTextLength >= 7){
      newText.write(newValue.text.substring(3,usedSubstringIndex = 6)+'-');
      if(newValue.selection.end >= 6) selectionIndex++;
    }

    if(newTextLength >= 11){
      newText.write(newValue.text.substring(6,usedSubstringIndex = 100)+
          ' ');
      if(newValue.selection.end >= 10) selectionIndex++;
    }

    if(newTextLength >= usedSubstringIndex){
      newText.write(newValue.text.substring(usedSubstringIndex));
    }
    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}