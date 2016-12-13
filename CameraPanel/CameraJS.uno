using Uno;
using Uno.Collections;
using Fuse;
using Fuse.Scripting;
using Fuse.Reactive;
using Uno.Threading;
using Uno.IO;
using Uno.Permissions;

public class CameraExtended : NativeModule
{

	internal static Dictionary<string, Camera> Cameras = new Dictionary<string, Camera>();

	public CameraExtended()
	{
		AddMember(new NativePromise<PictureResult, Fuse.Scripting.Object>("takePicture", TakePicture, Converter));
		AddMember(new NativePromise<object,object>("requestCameraPermission", (Fuse.Scripting.FutureFactory<object>)RequestCameraPermission));
	}

	Future<object> RequestCameraPermission(object[] args)
	{
		return new PermissionsPromise();
	}

	class PermissionsPromise : Promise<object>
	{
		public PermissionsPromise()
		{
			if defined(Android)
			{
				var future = Permissions.Request(Permissions.Android.CAMERA);
				future.Then(OnResolve, Reject);
			}
			else
			{
				Resolve(null);
			}
		}

		void OnResolve(PlatformPermission permission)
		{
			Resolve(null);
		}
	}

	Future<PictureResult> TakePicture(object[] args)
	{
		if (args.Length > 1)
			throw new Exception("No camera name provided");

		var name = args[0] as string;
		if (name == null)
			throw new Exception("Argument not a string");

		Camera camera = null;
		if (Cameras.TryGetValue(name, out camera))
		{
			return camera.TakePicture();
		}
		else
		{
			throw new Exception("Not cameras named: " + name);
		}
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