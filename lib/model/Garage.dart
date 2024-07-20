class Garage {
  String id;
  String nom;
  String description;
  String email;
  String telephone1;
  String telephone2;
  String photo;
  String ville;
  String pays;
  double longitude;
  double latitude;
  double rating;
  double distance;
  String type;


  Garage({
    this.id = "",
    this.nom = "",
    this.description = "",
    this.email = "",
    this.telephone1 = "",
    this.telephone2 = "",
    this.photo = "",
    this.ville = "",
    this.pays = "",
    this.longitude = 0.0,
    this.latitude = 0.0,
    this.rating = 0.0,
    this.distance = 0.0,
    this.type = "",
  });

  factory Garage.fromJson(Map<String, dynamic> json) {
    return Garage(
      id : json["id"],
      nom : json["nom"],
      description : json["description"],
      email : json["email"],
      telephone1 : json["telephone1"],
      telephone2 : json["telephone2"],
      photo : json["photo"],
      ville : json["ville"],
      pays : json["pays"],
      longitude : json["longitude"],
      latitude : json["latitude"],
      rating : json["rating"],
      distance : json["distance"],
      type : json["type"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id' :id,
      'nom' :nom,
      'description' :description,
      'email' :email,
      'telephone1' :telephone1,
      'telephone2' :telephone2,
      'photo' :photo,
      'ville' :ville,
      'pays' :pays,
      'longitude' :longitude,
      'latitude' :latitude,
      'type' :type,
    };
  }
}
