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
	public event EventHandler FrameAvailable;
	public int2 Size { get { return int2(0,0); } }
	public VideoTexture VideoTexture { get { return null; } }
	public CameraFacing Facing { get; set;}
	public int Rotate { get { return 0; } }

}

[Require("Source.Include", "AVFoundation/AVFoundation.h")]
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

	public Promise<PictureResult> TakePicture() {

		var p = new TakePicturePromise();
		TakePicture(CameraImpl.getStillImageOutputHandle(_handle), p.Sucess, p.Error);
		return p;
	}

	class TakePicturePromise : Promise<PictureResult>
	{
		public void Sucess(string filePath)
		{
			Resolve(new PictureResult(filePath));
		}

		public void Error(string msg)
		{
			Reject(new Exception(msg));
		}
	}

	[Foreign(Language.ObjC)]
	static void TakePicture(IntPtr stillImageOutputHandle, Action<string> callback, Action<string> errorCallback)
	@{

		auto stillImageOutput = (AVCaptureStillImageOutput*)stillImageOutputHandle;

	    AVCaptureConnection *videoConnection = nil;
	    for (AVCaptureConnection *connection in stillImageOutput.connections) {
	        for (AVCaptureInputPort *port in [connection inputPorts]) {
	            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
	                videoConnection = connection;
	                break;
	            }
	        }
	        if (videoConnection) { break; }
	    }

	    NSLog(@"about to request a capture from: %@", stillImageOutput);
	    
	    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {

	    	if (error != nil)
	    	{
	    		errorCallback(error.localizedDescription);
	    		return;
	    	}

	        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
			UIImage* sourceImage = [UIImage imageWithData:imageData];

			CGFloat degrees = -90.0f;
			CGFloat radians = degrees * (M_PI / 180.f);
			CGImageRef imageRef = [sourceImage CGImage];
			CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
			auto targetWidth = sourceImage.size.width;
			auto targetHeight = sourceImage.size.height;
			CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
			CGContextRef bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
			CGContextRotateCTM (bitmap, radians);
			CGContextTranslateCTM (bitmap, -targetHeight, 0);
			CGContextDrawImage(bitmap, CGRectMake(0, 0, targetHeight, targetWidth), imageRef);
			CGImageRef ref = CGBitmapContextCreateImage(bitmap);
			auto newImage = [UIImage imageWithCGImage:ref];

			NSString *guid = [[NSUUID new] UUIDString];
			NSString *uniqueFileName = [NSString stringWithFormat:@"%@_%@.jpg", @"picture_", guid];
			NSString *filePath = [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), uniqueFileName];

			[UIImageJPEGRepresentation(newImage, 1.0) writeToFile:filePath atomically:false];

			callback(filePath);
	     }];
	@}

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
	public static extern IntPtr getStillImageOutputHandle(ObjC.ID camera);

	[TargetSpecificImplementation]
	public static extern void addUpdateListener(ObjC.ID camera, Uno.Action action);

	[TargetSpecificImplementation]
	public static extern GLTextureHandle updateTexture(ObjC.ID camera);

}
