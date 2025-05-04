class UserModel {
  
  final String id;
  final String name;
  final String email;
  final String password;

const UserModel({
  required this.id,
  required this.name,
  required this.email,
  required this.password,
});

toJson(){
  return {
    'id': id,
    'name': name,
    'email': email,
    'password': password,
  };
}

}






