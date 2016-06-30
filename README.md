Fuse CameraPanel [![Build Status](https://travis-ci.org/bolav/fuse-camerapanel.svg?branch=master)](https://travis-ci.org/bolav/fuse-camerapanel) ![Fuse Version](http://fuse-version.herokuapp.com/?repo=https://github.com/bolav/fuse-camerapanel)
================

Library to use the camera as a panel in [Fuse](http://www.fusetools.com/).

Currently supports iOS

Issues, feature request and pull request are welcomed.

## Installation

Using [fusepm](https://github.com/bolav/fusepm)

    $ fusepm install https://github.com/bolav/fuse-camerapanel


## Usage:

### UX

    <CameraStream>
      <CameraVisual Facing="Front" />
    </CameraStream>

### JS/UX Approach

    <JavaScript>
    var cameraExt = require('CameraExtended');
    
    function shoot () {
      cameraExt
          .takePicture()
          .then(function (file) {
              debug_log("Filename: " + file.name);
              debug_log("Path: " + file.path);
              
              cameraExt.refreshCamera();
          })
          .catch(function (e) {
              debug_log(e);
          });    
    }
    module.exports.shoot = shoot;
    </JavaScript>
    
    <CameraStream>
        <CameraVisual Camera="cam" Facing="Front"/>
        <Camera ux:Global="cam" />
        <CameraExtended ux:Global="CameraExtended" Camera="cam" />
    </CameraStream>
