using Uno;


using Uno.Collections;
using Fuse;
using Fuse.Scripting;
using Fuse.Reactive;
using Fuse.Controls;
using Uno.Compiler.ExportTargetInterop;
using Uno.Graphics;

[TargetSpecificImplementation]
public class ViewFinder : Panel
{
  internal Fuse.Controls.Image Photo;

  BundleFile _ConfigFile;

  public ViewFinder () {
    Photo = new Fuse.Controls.Image();
    ImageSource = new Fuse.Resources.TextureImageSource();
    Photo.Source = ImageSource;
    this.Children.Add(Photo);
    // Texture = import Texture2D( "Assets/tower1.png" );
    // Texture2 = import Texture2D( "Assets/tower2.png" );
    ImageSource.Texture = Texture;

  }
  protected override void OnRooted()
  {
    base.OnRooted();

    if defined(iOS) {
      textureFromSampleBuffer(null); // striping hack
      PostTexture(null);            // striping hack
      showImage(null);            // striping hack
      var view = iOS.UIKit.UIApplication._sharedApplication().KeyWindow.RootViewController.View;             // striping hack
    	SetupCaptureSessionImpl();
      	// SetupCaptureSession();
    }
  }

  Fuse.Resources.TextureImageSource ImageSource {
    get; set;
  }

  Uno.Graphics.Texture2D Texture {
    get; set;
  }
  Uno.Graphics.Texture2D Texture2 {
    get; set;
  }

  int one = 0;

  
  protected override void OnUnrooted()
  {
    base.OnUnrooted();
  }

  [TargetSpecificImplementation]
  extern(iOS)
  public void SetupCaptureSessionImpl();

  [TargetSpecificImplementation]
  extern(iOS)
  public void SetSampleBuffer(iOS.AVFoundation.AVCaptureVideoDataOutput output);

  [TargetSpecificImplementation]
  extern(iOS)
  public ObjC.ID GetAVCaptureVideoDataOutput();

  [TargetSpecificImplementation]
  extern(iOS)
  public void StartSession(iOS.AVFoundation.AVCaptureSession sess);

  [TargetSpecificImplementation]
  extern(iOS)
  public Uno.Graphics.Texture2D textureFromSampleBuffer(ObjC.ID buffer);

  [TargetSpecificImplementation]
  extern(iOS)
  public void showImage(ObjC.ID image);


  class TextureEnclosure {
    public TextureEnclosure (ViewFinder vf, Uno.Graphics.Texture2D texture) {
      Texture = texture;
      MyViewFinder = vf;
    }

    ViewFinder MyViewFinder {
      get; set;
    }

    Uno.Graphics.Texture2D Texture {
      get; set;
    }

    public void Invoke () {
      MyViewFinder.SetTexture(Texture);
    }
  }

  public void SetTexture2 (Uno.Graphics.Texture2D texture) {
    // var imageSource = new Fuse.Resources.TextureImageSource();
  }
  public void SetTexture (Uno.Graphics.Texture2D texture) {
    // Experimental.TextureLoader.TextureLoader.PngByteArrayToTexture2D(new Buffer(data), SetTexture2);
    ImageSource.Texture = texture;
    InvalidateVisual();
  }

  public void PostTexture (Uno.Graphics.Texture2D texture) {
    if (texture == null) return;
    UpdateManager.PostAction(new TextureEnclosure(this, texture).Invoke);
  }

  public void SetupCaptureSession() {
    var AVMediaTypeVideo = "vide"; // AVMediaTypeVideo
    var _session = new iOS.AVFoundation.AVCaptureSession();
    _session.init();
    _session.SessionPreset = "AVCaptureSessionPresetMedium";
    var device = iOS.AVFoundation.AVCaptureDevice._defaultDeviceWithMediaType(AVMediaTypeVideo);
    var error = new iOS.Foundation.NSError();
    error.init();
    var input = iOS.AVFoundation.AVCaptureDeviceInput._deviceInputWithDeviceError(device, out error);
    if (error.Code < 0) {
    	debug_log error.Code + ": " + error.Domain + " " + error.LocalizedDescription + ", " + error.LocalizedFailureReason;
    	return;
    }
    if (input == null) return;
    var avinput = new iOS.AVFoundation.AVCaptureDeviceInput(input);
    _session.addInput(avinput);
    var output_id = GetAVCaptureVideoDataOutput();
    var output = new iOS.AVFoundation.AVCaptureVideoDataOutput(output_id);

    _session.addOutput(output);
    SetSampleBuffer(output);

    // var v = iOS.Foundation.NSDictionary._dictionaryWithObjectForKey();
    /*
    output.videoSettings =
                [NSDictionary dictionaryWithObject:
                    [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                    forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    */


    // output.setMinFrameDuration(iOS.CoreMedia.Functions.CMTimeMake(1, 15));
    StartSession(_session);
    // _session.startRunning();

  }

}