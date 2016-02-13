using Uno;
using Fuse;
using Fuse.Scripting;
using Fuse.Reactive;
using Uno.Threading;
using Uno.IO;

public class CameraExtended : NativeModule
{
  public CameraVisual Camera { get; set; }
  public CameraExtended()
  {
    AddMember(new NativePromise<PictureResult, Fuse.Scripting.Object>("takePicture", TakePicture, Converter));
  }

  Future<PictureResult> TakePicture(object[] args)
  {
    debug_log "Came here";
    return Camera.TakePicture();
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