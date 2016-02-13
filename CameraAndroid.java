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
import android.view.Surface;
import android.view.View;
import android.view.Display;
import android.widget.TextView;
import android.widget.Toast;
import android.graphics.SurfaceTexture;
import android.graphics.SurfaceTexture.OnFrameAvailableListener;

public class CameraAndroid {
	Camera camera;
  SurfaceTexture surfaceTexture;
  OnFrameAvailableListener listener;
  Camera.Size size;

	public void takePictureJpeg(PictureCallback jpegCallback) throws IOException {
		//take the picture
		camera.takePicture(null, null, jpegCallback);
	}

  public void refreshCamera() {    
    camera.startPreview();
  }

  public void start(int rotation, int textureHandle)
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

    Camera.Size largestSupportedSize = param.getSupportedPreviewSizes().get(0);
    size = largestSupportedSize;
		param.setPreviewSize(largestSupportedSize.width, largestSupportedSize.height);
		camera.setParameters(param);
    //setCameraDisplayOrientation(rotation, 0, camera);
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

  public static void setCameraDisplayOrientation(int rotation, int cameraId, android.hardware.Camera camera)
  {
    android.hardware.Camera.CameraInfo info = new android.hardware.Camera.CameraInfo();
    android.hardware.Camera.getCameraInfo(cameraId, info);
    int degrees = 0;
    switch (rotation) {
        case Surface.ROTATION_0: degrees = 0; break;
        case Surface.ROTATION_90: degrees = 90; break;
        case Surface.ROTATION_180: degrees = 180; break;
        case Surface.ROTATION_270: degrees = 270; break;
    }

    int result;
    if (info.facing == Camera.CameraInfo.CAMERA_FACING_FRONT) {
        result = (info.orientation + degrees) % 360;
        result = (360 - result) % 360;  // compensate the mirror
    } else {  // back-facing
        result = (info.orientation - degrees + 360) % 360;
    }
    camera.setDisplayOrientation(90);
  }

  public void setOnFrameAvailableListener(OnFrameAvailableListener onFrameAvailableListener)
  {
    listener = onFrameAvailableListener;
  }

  public int getWidth()
  {
    return size.width;
  }

  public int getHeight()
  {
    return size.height;
  }

  public void stop() 
  {
    if(camera != null)
    {
      // stop preview and release camera
      camera.stopPreview();
      camera.release();
      camera = null;
    }    

    if(surfaceTexture != null)
    {
      surfaceTexture.release();
      surfaceTexture = null;    
    }
  }

  public boolean HasSurfaceTexture()
  {
    return surfaceTexture != null;
  }
}
