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
import android.graphics.Matrix;
import android.graphics.Bitmap;

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
			camera = Camera.open(1);
		} catch (RuntimeException e) {
			// check for exceptions
			System.err.println(e);
			return;
		}
		Camera.Parameters param;
		param = camera.getParameters();

    Camera.Size largestSupportedSize = param.getSupportedPreviewSizes().get(0);
    size = largestSupportedSize;
    param.setPictureSize(largestSupportedSize.width, largestSupportedSize.height);
		param.setPreviewSize(largestSupportedSize.width, largestSupportedSize.height);
    param.setJpegQuality(50);
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

  public static int getRotationAngle(Activity mContext, int cameraId) {
      android.hardware.Camera.CameraInfo info = new android.hardware.Camera.CameraInfo();
      android.hardware.Camera.getCameraInfo(cameraId, info);
      int rotation = mContext.getWindowManager().getDefaultDisplay().getRotation();
      int degrees = 0;
      switch (rotation) {
      case Surface.ROTATION_0:
          degrees = 0;
          break;
      case Surface.ROTATION_90:
          degrees = 90;
          break;
      case Surface.ROTATION_180:
          degrees = 180;
          break;
      case Surface.ROTATION_270:
          degrees = 270;
          break;
      }
      int result;
      if (info.facing == Camera.CameraInfo.CAMERA_FACING_FRONT) {
          result = (info.orientation + degrees) % 360;
          result = (360 - result) % 360; // compensate the mirror
      } else { // back-facing
          result = (info.orientation - degrees + 360) % 360;
      }
      return result;
  }

  public static Bitmap rotate(Bitmap bitmap, int degree, boolean cameraFacingFront) {
    int w = bitmap.getWidth();
    int h = bitmap.getHeight();

    Matrix mtx = new Matrix();
    mtx.postRotate(degree);

    if(cameraFacingFront)
    {
      Matrix flipHorizontal = new Matrix();
      flipHorizontal.setScale(1,-1);
      flipHorizontal.postTranslate(0, bitmap.getHeight());
      mtx.setConcat(mtx, flipHorizontal);
    }

    return Bitmap.createBitmap(bitmap, 0, 0, w, h, mtx, true);
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
