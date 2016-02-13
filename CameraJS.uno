using Uno;
using Fuse;
using Fuse.Scripting;
using Fuse.Reactive;
using Uno.Threading;
using Uno.IO;

public class CameraExtended : NativeModule
{
  public Camera Camera { get; set; }
  public CameraExtended()
  {
    AddMember(new NativePromise<PictureResult, Fuse.Scripting.Object>("takePicture", TakePicture, Converter));
    AddMember(new NativeFunction("refreshCamera", (NativeCallback)this.RefreshCamera));
  }

  Future<PictureResult> TakePicture(object[] args)
  {
    return Camera.TakePicture();
  }

  object RefreshCamera(Context c, object[] args)
  {
    Camera.RefreshCamera();
    return null;
  }

  Fuse.Scripting.Object Converter(Context context, PictureResult result)
  {
    var func = (Fuse.Scripting.Function)context.GlobalObject["File"];
    var file = (Fuse.Scripting.Object)func.Construct();
    file["path"] = result.Path;
    file["name"] = Path.GetFileName(result.Path);
    return file;
  }
}