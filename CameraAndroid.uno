using Uno;
using Uno.Graphics;
using Uno.Compiler.ExportTargetInterop;
using OpenGL;

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
    StartForeign((int)_textureHandle);
  }

  [Foreign(Language.Java)]
  public void StartForeign(int textureHandle)
  @{
    final com.fuse.camerapanel.CameraAndroid cameraAndroid = (com.fuse.camerapanel.CameraAndroid)@{Camera:Of(_this).Handle:Get()};

    cameraAndroid.setOnFrameAvailableListener(new android.graphics.SurfaceTexture.OnFrameAvailableListener() {
      public void onFrameAvailable(android.graphics.SurfaceTexture surfaceTexture) {
        cameraAndroid.updateTexImage();
        @{Camera:Of(_this).OnFrameAvailable():Call()};
      }
    });

    cameraAndroid.start(textureHandle);
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

  public event EventHandler FrameAvailable;

  public int2 Size { get { return int2(352, 288); } }

  public VideoTexture VideoTexture
  {
    get;
    private set;
  }

  public int Rotate { get { return 0; } }
}
