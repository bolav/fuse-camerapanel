package com.fuse.camerapanel;

import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

import android.app.Activity;
import android.hardware.Camera;
import android.hardware.Camera.PictureCallback;
import android.hardware.Camera.ShutterCallback;
import android.os.Bundle;
import android.util.Log;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;
import android.graphics.SurfaceTexture;
import android.graphics.SurfaceTexture.OnFrameAvailableListener;

public class CameraAndroid {
	Camera camera;
  SurfaceTexture surfaceTexture;
  OnFrameAvailableListener listener;

	public void captureImage(View v) throws IOException {
		//take the picture
		//camera.takePicture(null, null, jpegCallback);
	}

  public void start(int textureHandle)
  {
    try {
			// open the camera
			camera = Camera.open();
		} catch (RuntimeException e) {
			// check for exceptions
			System.err.println(e);
			return;
		}
		Camera.Parameters param;
		param = camera.getParameters();

		param.setPreviewSize(352, 288);
		camera.setParameters(param);
		try {
      surfaceTexture = new SurfaceTexture(textureHandle);

      if(listener != null)
        surfaceTexture.setOnFrameAvailableListener(listener);

      camera.setPreviewTexture(surfaceTexture);
			camera.startPreview();
		} catch (Exception e) {
			// check for exceptions
			System.err.println(e);
			return;
		}
  }

  public void setOnFrameAvailableListener(OnFrameAvailableListener onFrameAvailableListener)
  {
    listener = onFrameAvailableListener;
  }

  public void updateTexImage()
  {
    surfaceTexture.updateTexImage();
  }

  public void stop() {
    // stop preview and release camera
    camera.stopPreview();
    camera.release();
    surfaceTexture.release();
    surfaceTexture = null;
    camera = null;
  }
}
