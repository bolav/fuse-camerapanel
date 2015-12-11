using Fuse.Controls.Graphics;
using Fuse;
using Uno.Graphics;
using Uno;
using Fuse.Elements;


public extern (iOS) class iOSCameraVisual : ControlVisual<CameraStream>
{

  readonly Camera _camera = new Camera();
  readonly SizingContainer _sizing = new SizingContainer();

  protected override void Attach()
  {
    debug_log "Attach";
    _camera.Start();
    _camera.FrameAvailable += OnFrameAvailable;
  }

  protected override void Detach()
  {
    debug_log "Detach";
    _camera.Stop();
    _camera.FrameAvailable -= OnFrameAvailable;
  }

  public sealed override float2 GetMarginSize( float2 fillSize, SizeFlags fillSet)
  {
    _sizing.snapToPixels = Control.SnapToPixels;
    _sizing.absoluteZoom = Control.AbsoluteZoom;
    return _sizing.ExpandFillSize(GetSize(), fillSize, fillSet);
  }

  int2 _sizeCache = int2(0,0);
  void OnFrameAvailable(object sender, EventArgs args)
  {
    if (_camera.Size != _sizeCache)
    {
      _sizeCache = _camera.Size;
      InvalidateLayout();
    }
    InvalidateVisual();
  }


  float2 GetSize()
  {
    return (float2)_camera.Size;
  }

  float2 _origin;
  float2 _scale;
  float2 _drawOrigin;
  float2 _drawSize;
  float4 _uvClip;
  protected sealed override float2 OnArrangeMarginBox(float2 position, float2 availableSize, SizeFlags fillSet)
  {
    var size = base.OnArrangeMarginBox(position, availableSize, fillSet);

    _sizing.snapToPixels = Control.SnapToPixels;
    _sizing.absoluteZoom = Control.AbsoluteZoom;

    var contentDesiredSize = GetSize();

    _scale = _sizing.CalcScale( size, contentDesiredSize );
    _origin = _sizing.CalcOrigin( size, contentDesiredSize * _scale );

    _drawOrigin = _origin;
    _drawSize = contentDesiredSize * _scale;
    _uvClip = _sizing.CalcClip( size, ref _drawOrigin, ref _drawSize );

    return size;
  }

  protected sealed override void OnDraw(DrawContext dc)
  {
    var texture = _camera.VideoTexture;
    if (texture == null)
      return;
/*
    if (Control.StretchMode == StretchMode.Scale9)
      {
        // Not implemented
      }

    else */
      VideoDrawElement.Impl.
        Draw(dc, this, _drawOrigin, _drawSize, _uvClip.XY, _uvClip.ZW - _uvClip.XY, texture, _camera.Orientation);
  }

  class VideoDrawElement
  {
    static public VideoDrawElement Impl = new VideoDrawElement();

    public void Draw(DrawContext dc, Node element, float2 offset, float2 size,
      float2 uvPosition, float2 uvSize, VideoTexture tex, int rotate)
    {
      draw
      {
        apply Fuse.Drawing.Planar.Rectangle;

        DrawContext: dc;
        Node: element;
        Size: size;
        Position: offset;

        TexCoord: VertexData * uvSize + uvPosition;
        TexCoord: (rotate == 1) ? float2(prev.Y, 1.0f - prev.X) : (rotate == 3) ? float2(prev.X, prev.Y) : float2(1.0f - prev.X, 1.0f - prev.Y);
        // This is for landscape left - 4
        // TexCoord: flip ? float2(prev.X, 1.0f - prev.Y) : float2(prev.X, prev.Y);

        // AVCaptureVideoOrientationLandscapeRight - landscaperight - 3
        // TexCoord: float2(prev.X, prev.Y);

        PixelColor: float4(sample(tex, TexCoord).XYZ, 1.0f);
      };
    }
  }

  protected override void OnHitTest(HitTestContext htc)
  {
    //must be in the actual video part shown
    var lp = htc.LocalPoint;
    if (lp.X >= _drawOrigin.X && lp.X <= (_drawOrigin.X + _drawSize.X) &&
      lp.Y >= _drawOrigin.Y && lp.Y <= (_drawOrigin.Y + _drawSize.Y) )
      htc.Hit(this);

    base.OnHitTest(htc);
  }
}


// dummy class 
extern(!iOS) public class iOSCameraVisual : ControlVisual<CameraStream> { 

  protected override void Attach() {
    debug_log "ATTACH!!!";
  }
  protected override void Detach() {}
  protected sealed override void OnDraw(DrawContext dc) {}
}
