import 'package:sqflite/sqflite.dart';

class Etudiant {


  int id ;
  String nom;
  String prenom;
  String matricule;
  String filiere;
  String niveau;
  String email;

  Etudiant(this.id , this.nom, this.prenom, this.matricule, this.filiere, this.niveau, this.email) {

  }
  
 //
static Etudiant fromMap(Map elt ) {
     return Etudiant(elt['id'],elt['nom'],elt['prenom'],elt['matricule'],elt['filiere'],elt['niveau'],elt['email']);
  }
}

class GestionEtudiant{
    static late Database db;
    static String path ='my_db.db';
    static List<Etudiant> etudiants = [];
  static Future<void> ajouterEtudiant(Etudiant etudiant) async{
    int id = await insertdb(etudiant);
    Etudiant? created = await getEtudiantWithId(id);
    if(created != null) {

      etudiants.add(created);
    }

  }

  static Future <void> modifierEtudiant(Etudiant etudiant) async{
    int et = await updateEtudiant(etudiant);
    if(et>0){
      etudiants[etudiants.indexWhere((element) => element.id == etudiant.id)] = etudiant;
    }

  }

  static Future <void> supprimerEtudiant(int id) async{
    int result = await db.delete('Etudiant', where: 'id=?', whereArgs: [id]);
    if(result>0){
      etudiants.removeWhere((element) => element.id == id);
    }

  }

  static Future<void> fetchEtudiants() async{
    etudiants.clear();
    List <Map> result  = await db.rawQuery('SELECT * FROM "Etudiant"');
    print(result);
    for (Map elt in result){
      Etudiant etudiant = Etudiant.fromMap(elt);
      etudiants.add(etudiant);
    }

  }
  static Future <Etudiant?> getEtudiantWithId( int id) async{
    List <Map> res = await db.query('Etudiant', where:'id=?', whereArgs:[id]);
    if(res.isNotEmpty){
      Map elt = res[0];
    return Etudiant.fromMap(elt);
    }
  }
static Future <int> insertdb(Etudiant etudiant ) async{
    return await  db.insert('Etudiant', {
      'nom':etudiant.nom,
      'prenom':etudiant.prenom,
      'matricule':etudiant.matricule,
      'filiere':etudiant.filiere,
      'niveau':etudiant.niveau,
      'email':etudiant.email
    });
}
static Future <int> deleteEtudiant(Etudiant etudiant) async{
    return await db.delete('Etudiant', where: 'id=?', whereArgs: [etudiant.id]);
}

static Future <int> updateEtudiant(Etudiant etudiant ) async{
    return await db.update('Etudiant', {
      'nom':etudiant.nom,
      'prenom':etudiant.prenom,
      'matricule':etudiant.matricule,
      'filiere':etudiant.filiere,
      'niveau':etudiant.niveau,
      'email':etudiant.email
    } , where: 'id=?', whereArgs:[etudiant.id],);
}


  static Future<void> initdb() async{
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          // When creating the db, create the table
          await db.execute(
              'CREATE TABLE Etudiant (id INTEGER PRIMARY KEY AUTOINCREMENT, nom TEXT, prenom TEXT, matricule TEXT, filiere TEXT, niveau TEXT, email TEXT)');
        });
    return Future.value();
  }
}