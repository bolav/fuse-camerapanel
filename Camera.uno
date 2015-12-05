using Uno;
using OpenGL;
using Uno.Graphics;
using Uno.Compiler.ExportTargetInterop;

[TargetSpecificImplementationAttribute]
extern(iOS) class Camera
{
  ObjC.ID _handle;

  public Camera () {
    _handle = CameraImpl.allocateCamera();
  }
  [TargetSpecificImplementation]
  public void Start() {
    CameraImpl.initialize(_handle);
    CameraImpl.start(_handle);
  }
  public void Stop() {

  }
  public int2 Size { get; private set; }
  public event EventHandler FrameAvailable;
  public GLTextureHandle Texture { get; private set; }
  public VideoTexture VideoTexture { get; private set; }
  public void Update() {
    return;
  }
}

[ExportCondition("iOS")]
[TargetSpecificImplementation]
internal class CameraImpl
{
  
  [TargetSpecificImplementation]
  public static extern ObjC.ID allocateCamera();

  [TargetSpecificImplementation]
  public static extern void freeVideoState(Uno.IntPtr videoState);

  [TargetSpecificImplementation]
  public static extern void initialize(ObjC.ID camera);

  [TargetSpecificImplementation]
  public static extern double getDuration(Uno.IntPtr videoState);

  [TargetSpecificImplementation]
  public static extern double getPosition(Uno.IntPtr videoState);

  [TargetSpecificImplementation]
  public static extern void setPosition(Uno.IntPtr videoState, double position);

  [TargetSpecificImplementation]
  public static extern float getVolume(Uno.IntPtr videoState);

  [TargetSpecificImplementation]
  public static extern void setVolume(Uno.IntPtr videoState, float volume);

  [TargetSpecificImplementation]
  public static extern int getWidth(Uno.IntPtr videoState);

  [TargetSpecificImplementation]
  public static extern int getHeight(Uno.IntPtr videoState);

  [TargetSpecificImplementation]
  public static extern void start(ObjC.ID camera);

  [TargetSpecificImplementation]
  public static extern void pause(Uno.IntPtr videoState);

  [TargetSpecificImplementation]
  public static extern GLTextureHandle updateTexture(Uno.IntPtr videoState);

  [TargetSpecificImplementation]
  public static extern void setErrorHandler(Uno.IntPtr videoState, Uno.Action errorHandler);

  
}
