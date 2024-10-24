import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_2/etudiants.dart';
import 'package:camera/camera.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:record/record.dart';
import 'package:voice_message_package/voice_message_package.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

String randomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Université de Yaoundé 1',
      home: Accueil(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Accueil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accueil'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bienvenue à l\'Université de Yaoundé 1',
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PageGestionEtudiant()),
                );
              },
              child: Text('Gestion des étudiants (CRUD)'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CameraManagementPage()),
                );
              },
              child: Text('Gestion de la camera'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SoundManagementPage()),
                );
              },
              child: Text('Gestion du Son'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatManagementPage()),
                );
              },
              child: Text('Chat'),
            )
          ],
        ),
      ),
    );
  }
}

class PageGestionEtudiant extends StatefulWidget {
  @override
  State<PageGestionEtudiant> createState() => _PageGestionEtudiantState();
}

class _PageGestionEtudiantState extends State<PageGestionEtudiant> {
  List<Etudiant> etudiants = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    GestionEtudiant.initdb().then((r) {
      print('database initialised');
      GestionEtudiant.fetchEtudiants().then((r) {
        setState(() {
          etudiants = [...GestionEtudiant.etudiants];
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des Étudiants'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'Liste des Étudiants',
            style: TextStyle(fontSize: 24),
          ),
          // Affichage de la liste des étudiants
          etudiants.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: etudiants.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                          etudiants[index].nom + " " + etudiants[index].prenom),
                      subtitle: Text(etudiants[index].matricule +
                          " | " +
                          etudiants[index].filiere +
                          " | " +
                          etudiants[index].niveau +
                          " | " +
                          etudiants[index].email),
                      //add edit and delete button
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PageModifierEtudiant(
                                          etudiant: etudiants[index],
                                          modifierEtudiant: ((etudiant) async {
                                            await GestionEtudiant
                                                .modifierEtudiant(etudiant);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Étudiant modifié avec succès')),
                                            );
                                            setState(() {
                                              etudiants = [
                                                ...GestionEtudiant.etudiants
                                              ];
                                            });
                                          }),
                                        )),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Confirmation'),
                                    content: Text(
                                        'Voulez-vous vraiment supprimer cet étudiant?'),
                                    actions: [
                                      TextButton(
                                        child: Text('Annuler'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: Text('Supprimer'),
                                        onPressed: () async {
                                          await GestionEtudiant
                                              .supprimerEtudiant(
                                                  etudiants[index].id);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Étudiant supprimé avec succès')),
                                          );
                                          setState(() {
                                            etudiants = [
                                              ...GestionEtudiant.etudiants
                                            ];
                                          });
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                )
              : Center(child: Text("Pas d'étudiants ")),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //aller à la page de création d'un étudiant
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    PageCreerEtudiant(ajouterEtudiant: (etudiant) async {
                      await GestionEtudiant.ajouterEtudiant(etudiant);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Étudiant ajouté avec succès')),
                      );
                      setState(() {
                        etudiants = [...GestionEtudiant.etudiants];
                      });
                    })),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class PageCreerEtudiant extends StatefulWidget {
  Function(Etudiant etudiant) ajouterEtudiant;

  PageCreerEtudiant({required this.ajouterEtudiant});

  @override
  State<PageCreerEtudiant> createState() => _PageCreerEtudiantState();
}

class _PageCreerEtudiantState extends State<PageCreerEtudiant> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _matriculeController = TextEditingController();
  final _filiereController = TextEditingController();
  final _niveauController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter un étudiant'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _nomController,
                  decoration: InputDecoration(labelText: 'Nom'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un nom';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _prenomController,
                  decoration: InputDecoration(labelText: 'Prénom'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un prénom';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _matriculeController,
                  decoration: InputDecoration(labelText: 'Matricule'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un matricule';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _filiereController,
                  decoration: InputDecoration(labelText: 'Filière'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une filière';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _niveauController,
                  decoration: InputDecoration(labelText: 'Niveau'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un niveau';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      //Firebase.initializeApp();
                      //CollectionReference collRef = FirebaseFirestore.instance.collection('etudiant');
                      final etudiant = Etudiant(
                        0,
                        _nomController.text,
                        _prenomController.text,
                        _matriculeController.text,
                        _filiereController.text,
                        _niveauController.text,
                        _emailController.text,
                      );

                      widget.ajouterEtudiant(etudiant);
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Ajouter'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _matriculeController.dispose();
    _filiereController.dispose();
    _niveauController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}

//Edit Etudiant Page
class PageModifierEtudiant extends StatefulWidget {
  final Etudiant etudiant;
  final Function(Etudiant etudiant) modifierEtudiant;

  PageModifierEtudiant(
      {required this.etudiant, required this.modifierEtudiant});

  @override
  State<PageModifierEtudiant> createState() => _PageModifierEtudiantState();
}

class _PageModifierEtudiantState extends State<PageModifierEtudiant> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _matriculeController = TextEditingController();
  final _filiereController = TextEditingController();
  final _niveauController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    //initialisation des champs avec les valeurs de l'étudiant
    _nomController.text = widget.etudiant.nom;
    _prenomController.text = widget.etudiant.prenom;
    _matriculeController.text = widget.etudiant.matricule;
    _filiereController.text = widget.etudiant.filiere;
    _niveauController.text = widget.etudiant.niveau;
    _emailController.text = widget.etudiant.email;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier un étudiant'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _nomController,
                  decoration: InputDecoration(labelText: 'Nom'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un nom';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _prenomController,
                  decoration: InputDecoration(labelText: 'Prénom'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un prénom';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _matriculeController,
                  decoration: InputDecoration(labelText: 'Matricule'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un matricule';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _filiereController,
                  decoration: InputDecoration(labelText: 'Filière'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une filière';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _niveauController,
                  decoration: InputDecoration(labelText: 'Niveau'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un niveau';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final etudiant = Etudiant(
                        widget.etudiant.id,
                        _nomController.text,
                        _prenomController.text,
                        _matriculeController.text,
                        _filiereController.text,
                        _niveauController.text,
                        _emailController.text,
                      );
                      etudiant.id = widget.etudiant.id;

                      widget.modifierEtudiant(etudiant);
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Modifier'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _matriculeController.dispose();
    _filiereController.dispose();
    _niveauController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}

class CameraManagementPage extends StatefulWidget {
  @override
  _CameraManagementPageState createState() => _CameraManagementPageState();
}

class _CameraManagementPageState extends State<CameraManagementPage> {
  //late List<CameraDescription> _cameras;
  CameraController? _controller;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    availableCameras().then((cameras) {
      List<CameraDescription> _cameras = cameras;
      if (_cameras.length > 0) {
        _controller = CameraController(_cameras[0], ResolutionPreset.medium);
        _controller!.initialize().then((_) {
          setState(() {});
        });
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (!_controller!.value.isInitialized) {
      return null;
    }
    //final directory = await getApplicationDocumentsDirectory();
    //final imagePath = join(directory.path, '${DateTime.now()}.jpg');
    XFile file = await _controller!.takePicture();
    String path = file.path;

    setState(() {
      _imagePath = path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gestion de la Caméra')),
      body: Column(
        children: [
          Expanded(
            child: CameraPreview(_controller!),
          ),
          if (_imagePath != null) Image.file(File(_imagePath!)),
          ElevatedButton(
            onPressed: _takePicture,
            child: Text('Prendre une photo'),
          ),
        ],
      ),
    );
  }
}

class SoundManagementPage extends StatefulWidget {
  @override
  _SoundManagementPage createState() => _SoundManagementPage();
}

class _SoundManagementPage extends State<SoundManagementPage> {
  final AudioRecorder audioRecorder = AudioRecorder();
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isRecording = false;
  bool isPlaying = false;
  String? recordingPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gestion du son')),
      floatingActionButton: _recordingButton(),
      body: _lireAudio(),
    );
  }

  Widget _lireAudio() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (recordingPath != null)
            MaterialButton(
              onPressed: () async {
                if (audioPlayer.playing) {
                  audioPlayer.stop();
                  setState(() {
                    isPlaying = false;
                  });
                } else {
                  await audioPlayer.setFilePath(recordingPath!);
                  audioPlayer.play();
                  setState(() {
                    isPlaying = true;
                  });
                }
              },
              color: Theme.of(context).colorScheme.primary,
              child: Icon(
                isPlaying ? Icons.stop : Icons.play_arrow,
              ),
            ),
          if (recordingPath == null) const Text("Pas d enregistrement trouvé "),
        ],
      ),
    );
  }

  Widget _recordingButton() {
    return FloatingActionButton(
      onPressed: () async {
        if (isRecording) {
          String? filePath = await audioRecorder.stop();
          if (filePath != null) {
            setState(() {
              isRecording = false;
              recordingPath = filePath;
            });
          }
        } else {
          if (await audioRecorder.hasPermission()) {
            final Directory appDocumentsDir =
                await getApplicationDocumentsDirectory();

            final String filePath =
                p.join(appDocumentsDir.path, "recording.wav");
            await audioRecorder.start(const RecordConfig(), path: filePath);

            setState(() {
              isRecording = true;
              recordingPath = null;
            });
          }
        }
      },
      child: Icon(
        isRecording ? Icons.stop : Icons.mic,
      ),
    );
  }
}

class ChatManagementPage extends StatefulWidget {
  @override
  _ChatManagementPage createState() => _ChatManagementPage();
}

@override
class _ChatManagementPage extends State<ChatManagementPage> {
  final List<types.Message> _messages = [];
  final _user = const types.User(id: '82091008-a484-4a89-ae75-a22bf8d6f3ac');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Chat(
        messages: _messages,
        onSendPressed: _handleSendPressed,
        user: _user,
        onAttachmentPressed: _handleImageSelection,
        theme: const DefaultChatTheme(
          inputBackgroundColor: Colors.blue,
        ),
      ),
    );
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);
      final message = types.ImageMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        height: image.height.toDouble(),
        id: randomString(),
        name: result.name,
        size: bytes.length,
        uri: result.path,
        width: image.width.toDouble(),
      );
      _addMessage(message);
    }
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: message.text,
    );
    _addMessage(textMessage);
  }
}
