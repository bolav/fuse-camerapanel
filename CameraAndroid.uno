using Uno;
using Uno.Graphics;
using Uno.Compiler.ExportTargetInterop;
using OpenGL;
using Android.android.app;

[TargetSpecificImplementationAttribute]
extern(Android) class Camera
{
  public CameraFacing Facing { get; set;}
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
    StartForeign(a, (int)_textureHandle);
  }

  [Foreign(Language.Java)]
  public void StartForeign(Java.Object a, int textureHandle)
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

  public int Rotate { get { return 1; } }
}
