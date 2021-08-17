import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

class PlantDisease extends StatefulWidget {
  PlantDisease({Key key}) : super(key: key);
  static const routeName = '/pDisease';

  @override
  _PlantDiseaseState createState() => _PlantDiseaseState();
}

class _PlantDiseaseState extends State<PlantDisease> {
  List _outputs;
  File _image;
  bool _loading;
  Future<void> _launched;

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  void initState() {
    super.initState();
    _loading = true;

    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: 'assets/model/model.tflite',
      labels: 'assets/model/labels.txt',
      numThreads: 1,
    );
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 3,
      threshold: 0.4,
      imageMean: 0,
      imageStd: 255.0,
    );
    setState(() {
      _loading = false;

      _outputs = output;
    });
  }

  camImage() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 240, maxWidth: 240);

    if (image == null) return null;
    setState(() {
      _loading = true;

      _image = image;
    });
    classifyImage(_image);
  }

  pickImage() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 240, maxWidth: 240);

    if (image == null) return null;
    setState(() {
      _loading = true;

      _image = image;
    });
    classifyImage(_image);
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          new IconButton(
            icon: Icon(
              Icons.person,
              color: Colors.white,
            ),
            onPressed: () => setState(
              () {
                _launched = _launchInBrowser('https://imcp-3000.web.app/#/');
              },
            ),
          ),
        ],
        title: Text(
          'Plant Disease Detector',
          textAlign: TextAlign.center,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickImage,
        child: Icon(Icons.image),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage(
                  "assets/images/main.jpg",
                ),
              ),
            ),
          ),
          ListView(
            children: <Widget>[
              //Flexible(
              //child:
              Container(
                margin: EdgeInsets.all(20),
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 94.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.deepOrangeAccent,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 8,
                      color: Colors.black26,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: Text(
                  'Welcome to PDD',
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    //Theme.of(context).accentTextTheme.title.color,
                    fontSize: 20,
                    fontFamily: 'Anton',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _loading
                  ? Container(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    )
                  : Container(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _image == null ? Container() : Image.file(_image),
                          SizedBox(
                            height: 20,
                          ),
                          _outputs != null
                              ? Container(
                                  height: 100,
                                  width: deviceSize.width * 0.80,
                                  padding: EdgeInsets.all(5),
                                  margin: EdgeInsets.all(10),
                                  constraints: BoxConstraints(
                                    minHeight: 100,
                                    minWidth: deviceSize.width * 0.80,
                                  ),
                                  child: Column(
                                    children: [
                                      if (((_outputs[0]['confidence']) * 100) >
                                          70)
                                        Card(
                                          elevation: 15,
                                          color: Colors.white70,
                                          margin: EdgeInsets.all(10),
                                          child: Text(
                                            "Disease : ${_outputs[0]['label']}\nAccuracy : ${(_outputs[0]['confidence']) * 100}%",
                                            // "${_outputs[0]['label']}",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16.0,
                                              fontFamily: 'Anton',
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      if (((_outputs[0]['confidence']) * 100) <
                                          70)
                                        Card(
                                          elevation: 15,
                                          color: Colors.white70,
                                          margin: EdgeInsets.all(10),
                                          child: Text(
                                            "Disease not in Database",
                                            // "${_outputs[0]['label']}",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16.0,
                                              fontFamily: 'Anton',
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                )
                              : Text("No Data",
                                  style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
              Container(
                alignment: Alignment.bottomCenter,
                child: RaisedButton.icon(
                  elevation: 5,
                  hoverColor: Colors.red,
                  color: Colors.green,
                  onPressed: camImage,
                  icon: Icon(Icons.camera_alt),
                  label: Text('Open Camera'),
                ),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                child: RaisedButton.icon(
                  elevation: 5,
                  hoverColor: Colors.red,
                  color: Colors.green,
                  onPressed: pickImage,
                  icon: Icon(Icons.image),
                  label: Text('Open Gallery'),
                ),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                child: RaisedButton.icon(
                  elevation: 5,
                  hoverColor: Colors.red,
                  color: Colors.green,
                  onPressed: () => setState(() {
                    _launched = _launchInBrowser(
                        'https://www.google.com/search?sxsrf=ALeKk01lUETL4IsrTYvqaj6lLZbiyXJizw%3A1603531871451&source=hp&ei=X_STX8WEGc6W4-EPwuOnmAE&iflsig=AINFCbYAAAAAX5QCb3xWlzvKoqhpT-S9dcstBZRIhhBY&q=${_outputs[0]['label']}+cause+cure&oq=&gs_lcp=CgZwc3ktYWIQARgAMgcIIxDqAhAnMgcIIxDqAhAnMgcIIxDqAhAnMgcIIxDqAhAnMgcIIxDqAhAnMgcIIxDqAhAnMgcIIxDqAhAnMgcIIxDqAhAnMgcIIxDqAhAnMgcIIxDqAhAnUABYAGDRJWgBcAB4AIABAIgBAJIBAJgBAKoBB2d3cy13aXqwAQo&sclient=psy-ab');
                  }),
                  icon: Icon(Icons.search),
                  label: Text('Details About the Disease'),
                ),
              ),
              SizedBox(
                height: 200,
              ),
              Text(
                'To Know About the developer\nClick Top Right Button',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  backgroundColor: Colors.deepOrangeAccent,
                ),
              ),
              Text(
                'This App is in it\'s Beta Stage.it sometimes shows the wrong Result but we are constantly Upgrading Please read the PlayStore Description to know More',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  backgroundColor: Colors.deepOrangeAccent,
                ),
              ),
              SizedBox(
                height: 30,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
