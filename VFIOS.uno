using Uno;
using Uno.Collections;
using Fuse;
public extern(iOS) class VFIOS: iOS.AVFoundation.IAVCaptureAudioDataOutputSampleBufferDelegate
{

	public VFIOS() {
		var a = new iOS.AVFoundation.AVCaptureOutput();
		var b = new iOS.CoreMedia.CMSampleBufferRef();
		var c = new iOS.AVFoundation.AVCaptureConnection();
		captureOutputDidOutputSampleBufferFromConnection(a,b,c);
	}

	public iOS.AVFoundation.AVCaptureSession Session 
	{
		get; set;
	}

	public ObjC.ID SessionID
	{
		get; set;
	}



	public void captureOutputDidOutputSampleBufferFromConnection(iOS.AVFoundation.AVCaptureOutput captureOutput, iOS.CoreMedia.CMSampleBufferRef sampleBuffer, iOS.AVFoundation.AVCaptureConnection connection) {
	  // debug_log("CAPTURE");
	}

}

public extern(!iOS) class VFIOS
{
	public VFIOS() {

	}
	
}