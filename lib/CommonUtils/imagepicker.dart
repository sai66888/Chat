import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:upaychat/CommonUtils/common_utils.dart';

import 'imagepickerdialog.dart';

class ImagePickerHandler {
  ImagePickerDialog? imagePicker;
  AnimationController? _controller;
  ImagePickerListener? _listener;
  bool isCrop = true;
   ImagePickerHandler(this._listener, this._controller);
  compressedImage(String path) async {
    return File(path);
  }

  openCamera(BuildContext context) async {
    if (imagePicker != null) imagePicker!.dismissDialog();
    var image = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 25);
    if (image != null && _listener != null)
    //   _listener!.userImage(await compressedImage(image.path));
      if(this.isCrop)
        cropImage(context, await compressedImage(image.path));
      else
        _listener!.userImage(await compressedImage(image.path));
  }
  openNoCropCamera(BuildContext context) async {
    if (imagePicker != null) imagePicker!.dismissDialog();
    var image = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 25);
    if (image != null && _listener != null)
      //   _listener!.userImage(await compressedImage(image.path));
        _listener!.userImage(await compressedImage(image.path));
  }

  openGallery(BuildContext context) async {
    if (imagePicker != null) imagePicker!.dismissDialog();
    var image = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 25);
    if (image != null && _listener != null)
    if(this.isCrop)
      cropImage(context,await compressedImage(image.path));
    else
      _listener!.userImage(await compressedImage(image.path));
  }
  openNoCropGallery(BuildContext context) async {
    if (imagePicker != null) imagePicker!.dismissDialog();
    var image = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 25);
    if (image != null && _listener != null)
        _listener!.userImage(await compressedImage(image.path));
  }

  void init() {
    imagePicker = new ImagePickerDialog(this, _controller!);
    imagePicker!.initState();
  }

  Future cropImage(BuildContext context, File image) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      maxWidth: 300,
      maxHeight: 300,
        aspectRatio: CropAspectRatio(ratioX: 1,ratioY: 1)
    );
    // _listener!.userImage(croppedFile);
    if(croppedFile != null)
    _listener!.userImage(File(croppedFile.path));
  }

  showDialog(BuildContext context) {
    imagePicker!.getImage(context);

  }

  showDialogNoCrop(BuildContext context) {
    this.isCrop = false;
    imagePicker!.getImage(context);
  }
}

abstract class ImagePickerListener {
  userImage(File _image);
}
