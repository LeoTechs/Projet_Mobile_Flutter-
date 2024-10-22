class Etudiant {
  static int count = 0;

  int id = count;
  String nom;
  String prenom;
  String matricule;
  String filiere;
  String niveau;
  String email;

  Etudiant(this.nom, this.prenom, this.matricule, this.filiere, this.niveau, this.email) {
    count++;
  }
  
 // 
}

class GestionEtudiant{
  static List<Etudiant> etudiants = [
    Etudiant('Tchoupe', 'Aurelien', '18A1234', 'Informatique', 'L3','aurelien@gmail.com') ];

  static void ajouterEtudiant(Etudiant etudiant){
    etudiants.add(etudiant);
  }

  static void modifierEtudiant(Etudiant etudiant){
    etudiants[etudiants.indexWhere((element) => element.id == etudiant.id)] = etudiant;
  }

  static void supprimerEtudiant(int id){
    etudiants.removeWhere((element) => element.id == id);
  }
}