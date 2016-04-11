using Uno;
using Uno.Graphics;
using Uno.Threading;
using Uno.Compiler.ExportTargetInterop;
using OpenGL;
using Android.android.app;

[TargetSpecificImplementationAttribute]
public extern(Android) class Camera
{
  CameraFacing _facing = CameraFacing.Default;
  public CameraFacing Facing { get { return _facing; } set { _facing = value; } }
  public readonly Java.Object Handle;
  readonly GLTextureHandle _textureHandle;

  public Camera()
  {
    Handle = CreateCameraJavaHandle();
    _textureHandle = GL.CreateTexture();
    VideoTexture = new VideoTexture(_textureHandle);
  }

  [Foreign(Language.Java)]
  public Java.Object CreateCameraJavaHandle()
  @{
    return (java.lang.Object)new com.fuse.camerapanel.CameraAndroid();
  @}

  public void Start()
  {
    Activity a = Activity.GetAppActivity();
    StartInternal(a, (int)_textureHandle);
  }

  [Foreign(Language.Java)]
  void StartInternal(Java.Object a, int textureHandle)
  @{
    final com.fuse.camerapanel.CameraAndroid cameraAndroid = (com.fuse.camerapanel.CameraAndroid)@{Camera:Of(_this).Handle:Get()};

    cameraAndroid.setOnFrameAvailableListener(new android.graphics.SurfaceTexture.OnFrameAvailableListener() {
      public void onFrameAvailable(android.graphics.SurfaceTexture surfaceTexture) {
        if(cameraAndroid.HasSurfaceTexture())
        {
          surfaceTexture.updateTexImage();
          @{Camera:Of(_this).OnFrameAvailable():Call()};
        }
      }
    });

    android.app.Activity activity = (android.app.Activity)a;
    cameraAndroid.start(activity.getWindowManager().getDefaultDisplay().getRotation(), textureHandle);
  @}

  public void OnFrameAvailable()
  {
    if(FrameAvailable != null)
      FrameAvailable(this, new EventArgs());
  }

  [Foreign(Language.Java)]
  public void Stop()
  @{
    com.fuse.camerapanel.CameraAndroid cameraAndroid = (com.fuse.camerapanel.CameraAndroid)@{Camera:Of(_this).Handle:Get()};
    cameraAndroid.stop();
  @}

  [Foreign(Language.Java)]
  public int GetWidth()
  @{
    com.fuse.camerapanel.CameraAndroid cameraAndroid = (com.fuse.camerapanel.CameraAndroid)@{Camera:Of(_this).Handle:Get()};
    return cameraAndroid.getWidth();
  @}

  [Foreign(Language.Java)]
  public int GetHeight()
  @{
    com.fuse.camerapanel.CameraAndroid cameraAndroid = (com.fuse.camerapanel.CameraAndroid)@{Camera:Of(_this).Handle:Get()};
    return cameraAndroid.getHeight();
  @}

  public TakePictureTask _mutableTakePictureShit; // TODO: Please find a better way to solve this, I get headache of current solution...
  public Promise<PictureResult> TakePicture()
  {
    var futurePicture = new Promise<PictureResult>();
    _mutableTakePictureShit = new TakePictureTask(futurePicture);
    TakePictureInternal();
    return futurePicture;
  }

  [Foreign(Language.Java)]
  void TakePictureInternal()
  @{
    final com.fuse.camerapanel.CameraAndroid cameraAndroid = (com.fuse.camerapanel.CameraAndroid)@{Camera:Of(_this).Handle:Get()};
    try {
      cameraAndroid.takePictureJpeg(new android.hardware.Camera.PictureCallback() {
        public void onPictureTaken(byte[] data, android.hardware.Camera camera) {
          java.io.FileOutputStream outStream = null;          
          try {
            android.app.Activity activity = @(Activity.Package).@(Activity.Name).GetRootActivity();

            int angleToRotate = cameraAndroid.getRotationAngle(activity, 1);
            // Solve image inverting
            angleToRotate += 180;

            android.graphics.Bitmap originalImg = android.graphics.BitmapFactory.decodeByteArray(data, 0, data.length);
            android.graphics.Bitmap rotatedImg = cameraAndroid.rotate(originalImg, angleToRotate, true);            

            java.io.File storageDir = activity.getExternalFilesDir(null);
            java.io.File destination = java.io.File.createTempFile("JPEG_", ".jpg", storageDir);
            destination.deleteOnExit();
            outStream = new java.io.FileOutputStream(destination);

            rotatedImg.compress(android.graphics.Bitmap.CompressFormat.JPEG, 80, outStream);
            outStream.flush();
            outStream.close();
            originalImg.recycle();
            rotatedImg.recycle();

            @{Camera:Of(_this).OnTakePictureSuccess(string):Call(destination.getAbsolutePath())};
          } catch (Exception e) {
            @{Camera:Of(_this).OnTakePictureFailed(string):Call(e.getMessage())};
          }
        }
      });
    }
    catch (Exception e) {
      @{Camera:Of(_this).OnTakePictureFailed(string):Call(e.getMessage())};
    }
  @}

  public void OnTakePictureFailed(string message)
  {
    _mutableTakePictureShit.OnFailed(message);
  }

  public void OnTakePictureSuccess(string path)
  {
    _mutableTakePictureShit.OnSuccess(path);
  }

  [Foreign(Language.Java)]
  public void RefreshCamera()
  @{
    //Call to start preview of the camera again.
    com.fuse.camerapanel.CameraAndroid cameraAndroid = (com.fuse.camerapanel.CameraAndroid)@{Camera:Of(_this).Handle:Get()};
    cameraAndroid.refreshCamera();
  @}

  public event EventHandler FrameAvailable;

  public int2 Size
  {
    get
    {
      return int2(GetHeight(), GetWidth());
    }
  }

  public VideoTexture VideoTexture
  {
    get;
    private set;
  }

  public int Rotate { get { return 3; } }
}

class PictureResult
{
  public readonly string Path;
  public PictureResult(string path)
  {
    Path = path; 
  }
}

class TakePictureTask
{
  readonly Promise<PictureResult> FuturePicture;
  public TakePictureTask(Promise<PictureResult> futurePicture)
  {
    FuturePicture = futurePicture;
  }

  public void OnSuccess(string path)
  {
    FuturePicture.Resolve(new PictureResult(path));
  }

  public void OnFailed(string message)
  {
    FuturePicture.Reject(new Exception(message));    
  }
}