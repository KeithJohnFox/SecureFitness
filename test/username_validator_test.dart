import 'package:flutter_test/flutter_test.dart';
import 'package:fluttershare/pages/create_account.dart';

void main(){

 test('empty username returns error string', () {
   var result = UsernameFieldValidator.validate('');
   expect(result, "Username needs 6 or more characters");
 });

  test('username is too long', () {
   var result = UsernameFieldValidator.validate('myNameIsTooLongForThisTestToWork');
   expect(result, "Username can't be over 20 characters");
 });

 test('username can only be alphanumeric', () {
   var result = UsernameFieldValidator.validate('myuser*(name<}{');
   expect(result, "Username must only contain Characters and Numbers");
 });
}