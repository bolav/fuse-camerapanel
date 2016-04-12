using Uno;
using OpenGL;
using Uno.Graphics;
using Uno.Threading;
using Uno.Compiler.ExportTargetInterop;

public enum CameraFacing
{
    Default = 0,
    Back = 1,
    Front = 2
}

public extern (!iOS && !Android) class Camera
{
  public Promise<PictureResult> TakePicture() {
    return new Promise<PictureResult>();
  }
  public void Start() {}
  public void Stop() {}
  public void RefreshCamera() {}
  public event EventHandler FrameAvailable;
  public int2 Size { get { return int2(0,0); } }
  public VideoTexture VideoTexture { get { return null; } }
  public CameraFacing Facing { get; set;}
  public int Rotate { get { return 0; } }

}

[TargetSpecificImplementationAttribute]
public extern(iOS) class Camera
{
  ObjC.ID _handle;
  public CameraFacing _facing = CameraFacing.Default;
  public CameraFacing Facing { get { return _facing; } set { _facing = value; } }

  public void Start() {
    debug_log("Start");
    CameraImpl.initialize(_handle);
    CameraImpl.start(_handle, (int)Facing);
  }

  public void Stop() {
    debug_log("Stop");
    CameraImpl.stop(_handle);
  }

  public void RefreshCamera() {}

  public Promise<PictureResult> TakePicture() {
    var p = new Promise<PictureResult>();
    p.Resolve(new PictureResult("test.jpeg"));
    return p;
  }

  public int2 Size {
    get {
      var o = Rotate;
      if (o == 1) {
        return int2(CameraImpl.getHeight(_handle), CameraImpl.getWidth(_handle));
      }
      return int2(CameraImpl.getWidth(_handle), CameraImpl.getHeight(_handle));
    }
  }

  public int Rotate {
    get { return CameraImpl.getRotation(_handle); }
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
  public static extern int getRotation(ObjC.ID camera);

  [TargetSpecificImplementation]
  public static extern void start(ObjC.ID camera, int devicetype);

  [TargetSpecificImplementation]
  public static extern void stop(ObjC.ID camera);

  [TargetSpecificImplementation]
  public static extern void addUpdateListener(ObjC.ID camera, Uno.Action action);

  [TargetSpecificImplementation]
  public static extern GLTextureHandle updateTexture(ObjC.ID camera);

}
