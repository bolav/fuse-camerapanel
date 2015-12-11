using Uno;
using OpenGL;
using Uno.Graphics;
using Uno.Compiler.ExportTargetInterop;
using Android.Fallbacks;

extern (!iOS && !Android) class Camera
{
  public void Start() {}
  public void Stop() {}
  public event EventHandler FrameAvailable;
  public int2 Size { get { return int2(0,0); } }
  public VideoTexture VideoTexture { get { return null; } }
  public int Orientation { get { return 0; } }
}
[TargetSpecificImplementationAttribute]
extern(Android) class Camera 
{
  public void Start() {
    var f = new Android_android_hardware_CameraDLRPreviewCallback(null,new Uno.Type(),false,false);
  }
}
[TargetSpecificImplementationAttribute]
extern(iOS) class Camera
{
  ObjC.ID _handle;

  public void Start() {
    debug_log("Start");
    CameraImpl.initialize(_handle);
    CameraImpl.start(_handle);
  }

  public void Stop() {
    debug_log("Stop");
    CameraImpl.stop(_handle);
  }

  public int2 Size {
    get { 
      var o = Orientation;
      if (o == 1) {
        return int2(CameraImpl.getHeight(_handle), CameraImpl.getWidth(_handle));
      }
      return int2(CameraImpl.getWidth(_handle), CameraImpl.getHeight(_handle)); 
    }
  }

  public int Orientation {
    get { return CameraImpl.getOrientation(_handle); }
  }

  public GLTextureHandle UpdateTexture() {
    return CameraImpl.updateTexture(_handle);
  }

  void OnFrameAvailable() {
    var handler = FrameAvailable;
    var args = new EventArgs();
    if (handler != null) handler(this, args);
  }

  public Camera () {
    debug_log "Camera.ctor";
    _handle = CameraImpl.allocateCamera();
    CameraImpl.addUpdateListener(_handle, OnFrameAvailable);
  }


  public event EventHandler FrameAvailable;
  public GLTextureHandle Texture { get {
    return CameraImpl.updateTexture(_handle);
  } }
  public VideoTexture VideoTexture { get {
    return new VideoTexture(Texture);
  } }

 }

[ExportCondition("iOS")]
[TargetSpecificImplementation]
internal class CameraImpl
{
  
  [TargetSpecificImplementation]
  public static extern ObjC.ID allocateCamera();

  [TargetSpecificImplementation]
  public static extern void initialize(ObjC.ID camera);

  [TargetSpecificImplementation]
  public static extern int getWidth(ObjC.ID camera);

  [TargetSpecificImplementation]
  public static extern int getHeight(ObjC.ID camera);

  [TargetSpecificImplementation]
  public static extern int getOrientation(ObjC.ID camera);

  [TargetSpecificImplementation]
  public static extern void start(ObjC.ID camera);

  [TargetSpecificImplementation]
  public static extern void stop(ObjC.ID camera);

  [TargetSpecificImplementation]
  public static extern void addUpdateListener(ObjC.ID camera, Uno.Action action);

  [TargetSpecificImplementation]
  public static extern GLTextureHandle updateTexture(ObjC.ID camera);
  
}
