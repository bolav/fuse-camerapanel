Fuse CameraPanel [![Build Status](https://travis-ci.org/bolav/fuse-camerapanel.svg?branch=master)](https://travis-ci.org/bolav/fuse-camerapanel) ![Fuse Version](http://fuse-version.herokuapp.com/?repo=https://github.com/bolav/fuse-camerapanel)
================

Library to use the camera as a panel in [Fuse](http://www.fusetools.com/).

Currently supports iOS

Issues, feature request and pull request are welcomed.

## Installation

Using [fusepm](https://github.com/bolav/fusepm)

    $ fusepm install https://github.com/bolav/fuse-camerapanel


## Usage:

### JS/UX Approach

        <CameraExtended ux:Global="CameraAPI" />

        <JavaScript>
            var Observable = require("FuseJS/Observable");
            var FileSystem = require("FuseJS/FileSystem");
            var CameraAPI = require("CameraAPI");

            function take_picture() {
                CameraAPI.takePicture("my_camera")
                    .then(function (result) {
                        console.log("Got a pic!");
                        console.log("Name: " + result.name);
                        console.log("Path: " + result.path);

                        return FileSystem.readBufferFromFile(result.path);
                    })
                    .then(function(contents) {
                        console.log("Got contents: " + JSON.stringify(contents));
                    })
                    .catch(function(err) {
                        console.log("Error: " + JSON.stringify(err));
                    });
            }

            function refresh_camera() {
                CameraAPI.refreshCamera("my_camera");
            }

            var camera_available = Observable(false);

            CameraAPI.requestCameraPermission().then(function () { camera_available.value = true });

            module.exports = {
                take_picture:take_picture,
                camera_available:camera_available,
            }

        </JavaScript>

        <WhileTrue Value="{camera_available}">
            <CameraStream Dock="Fill" >
                <CameraVisual Facing="Back" ux:Name="my_camera" />
            </CameraStream>
        </WhileTrue>
