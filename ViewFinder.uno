using Uno;
using Uno.Collections;
using Fuse;
using Fuse.Scripting;
using Fuse.Reactive;
using Fuse.Controls;
using Uno.Compiler.ExportTargetInterop;
using Uno.Graphics;
using OpenGL;

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
  }
  protected override void OnRooted()
  {
    base.OnRooted();

    if defined(iOS) {
      textureFromSampleBuffer(null); // striping hack
      PostTexture(null);            // striping hack
      PostVideoTexture(0);        // striping hack
      videoTextureFromSampleBuffer(null); // striping hack
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
  public Uno.Graphics.Texture2D textureFromSampleBuffer(ObjC.ID buffer);

  [TargetSpecificImplementation]
  extern(iOS)
  public int videoTextureFromSampleBuffer(ObjC.ID buffer);

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

  public void SetTexture (Uno.Graphics.Texture2D texture) {
    // Experimental.TextureLoader.TextureLoader.PngByteArrayToTexture2D(new Buffer(data), SetTexture2);
    ImageSource.Texture = texture;
    InvalidateVisual();
  }

  public void PostTexture (Uno.Graphics.Texture2D texture) {
    if (texture == null) return;
    UpdateManager.PostAction(new TextureEnclosure(this, texture).Invoke);
  }

  GLTextureHandle texture;
  public void PostVideoTexture (int t) {
    texture = t;
  }

  protected sealed override void OnDraw(DrawContext dc) {
    var texture = _camera.VideoTexture;
    if (texture == null) return;
    VideoDrawElement.Impl.Draw(dc, this, _drawOrigin, _drawSize, _uvClip.XY, _uvClip.ZW - _uvClip.XY, texture);
  }


class VideoDrawElement
{
static public VideoDrawElement Impl = new VideoDrawElement();
public void Draw(DrawContext dc, Node element, float2 offset, float2 size,
float2 uvPosition, float2 uvSize, VideoTexture tex)
{
draw
{
apply Fuse.Drawing.Planar.Rectangle;
DrawContext: dc;
Node: element;
Size: size;
Position: offset;
TexCoord: VertexData * uvSize + uvPosition;
TexCoord: float2(prev.X, prev.Y);
PixelColor: float4(sample(tex, TexCoord).XYZ, 1.0f);
};
}
}
}
