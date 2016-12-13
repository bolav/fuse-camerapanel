using Fuse.Controls.Graphics;
using Fuse;
using Uno.Graphics;
using Uno;
using Fuse.Elements;
using Uno.Threading;


public class CameraVisual : ControlVisual<CameraStream>
{
	Camera _camera = null;
	public Camera Camera {
		get
		{
			if (_camera == null)
			{
				_camera = new Camera();
			}
			return _camera;
		}
		set { _camera = value; } }
		
	readonly SizingContainer _sizing = new SizingContainer();

	public CameraFacing Facing {
		get {
			return Camera.Facing;
		}
		set {
			Camera.Facing = value;
		}
	}

	protected override void Attach()
	{
		debug_log "Attach";
		Camera.Start();
		Camera.FrameAvailable += OnFrameAvailable;
		
		if (Name != null)
			CameraExtended.Cameras.Add(Name, Camera);
	}

	protected override void Detach()
	{
		if (Name != null)
			CameraExtended.Cameras.Remove(Name);
		debug_log "Detach";
		Camera.FrameAvailable -= OnFrameAvailable;
		Camera.Stop();
	}

	public override float2 GetMarginSize(LayoutParams layoutParams)
	{
		_sizing.snapToPixels = Control.SnapToPixels;
		_sizing.absoluteZoom = Control.AbsoluteZoom;
		return _sizing.ExpandFillSize(GetSize(), layoutParams);
	}

	public Promise<PictureResult> TakePicture()
	{
		return Camera.TakePicture();
	}

	int2 _sizeCache = int2(0,0);
	void OnFrameAvailable(object sender, EventArgs args)
	{
		if (Camera.Size != _sizeCache)
		{
			_sizeCache = Camera.Size;
			InvalidateLayout();
		}
		InvalidateVisual();
	}


	float2 GetSize()
	{
		return (float2)Camera.Size;
	}

	float2 _origin;
	float2 _scale;
	float2 _drawOrigin;
	float2 _drawSize;
	float4 _uvClip;
	protected override float2 OnArrangeMarginBox(float2 position, LayoutParams lp)
	{
		var size = base.OnArrangeMarginBox(position, lp);

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


		public override void Draw(DrawContext dc)
		{
			var texture = Camera.VideoTexture;
			if (texture == null)
			return;
			VideoDrawElement.Impl.Draw(dc, this, _drawOrigin, _drawSize, _uvClip.XY, _uvClip.ZW - _uvClip.XY, texture, Camera.Rotate);
		}

 
	class VideoDrawElement
	{
		static public VideoDrawElement Impl = new VideoDrawElement();

		//public static void SetState(Node n, bool loaded)
		//public static void SetState(Visual v, bool loading)
		//element

		public void Draw(DrawContext dc, Fuse.Visual element, float2 offset, float2 size, 
			float2 uvPosition, float2 uvSize, VideoTexture tex, int rotate)
		{
			draw
			{
				apply Fuse.Drawing.Planar.Rectangle;

				DrawContext: dc;
				Visual: element;
				Size: size;
				Position: offset;

				TexCoord: VertexData * uvSize + uvPosition;

				// rotate == 0, no rotation
				// rotate == 1, 
				// rotate == 2, 
				// rotate == 3, flip x and y 

				TexCoord: (rotate == 0) 
					? float2(prev.X, prev.Y) 
					: (rotate == 1) // was 1
					? float2(prev.Y, 1.0f - prev.X) 
					: (rotate == 2) 
					? float2(1.0f - prev.X, 1.0f - prev.Y) 
					: float2(1.0f - prev.Y, 1.0f - prev.X);

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

	class SizingContainer
	{
		public StretchMode stretchMode = StretchMode.UniformToFill;
		public StretchDirection stretchDirection = StretchDirection.Both;
		public Alignment align = Alignment.Center;
		public StretchSizing stretchSizing = StretchSizing.Natural;

		public bool SetStretchMode( StretchMode mode )
		{
			if (mode == stretchMode)
				return false;
			stretchMode = mode;
			return true;
		}

		public bool SetStretchDirection( StretchDirection dir )
		{
			if (dir == stretchDirection)
				return false;
			stretchDirection = dir;
			return true;
		}

		public bool SetAlignment( Alignment a )
		{
			if (a == align)
				return false;
			align = a;
			return true;
		}

		public bool SetStretchSizing( StretchSizing ss )
		{
			if (ss == stretchSizing)
				return false;
			stretchSizing = ss;
			return true;
		}

		//set prior to calling CalcSize
		public float4 padding;
		public float absoluteZoom = 1;
		public bool snapToPixels;

		float PaddingWidth { get { return padding[0] + padding[2]; } }
		float PaddingHeight { get { return padding[1] + padding[3]; } }

		public float2 CalcScale( float2 availableSize, float2 desiredSize )
		{
			return CalcScale( availableSize, desiredSize, false, false );
		}

		public float2 CalcContentSize( float2 size, int2 pixelSize )
		{
			switch (stretchMode)
			{
				case StretchMode.PixelPrecise:
				{
					if (pixelSize.X == 0 || pixelSize.Y == 0)
						return float2(0);
					return float2(pixelSize.X,pixelSize.Y) / absoluteZoom;
				}

				case StretchMode.PointPrefer:
				{
					if (pixelSize.X == 0 || pixelSize.Y == 0)
						return float2(0);

					var exact = float2(pixelSize.X,pixelSize.Y) / absoluteZoom;
					var scale = size / exact;
					if (scale.X  > 0.75 && scale.X < 1.5)
						return exact;

					/* em: I don't see value in this unless you turned off interpolation on drawing as well
					//try an integer multiple
					var iScale = (int)(Math.Round(scale.X));
					var near = float2(pixelSize.X,pixelSize.Y) * iScale / absoluteZoom;
					scale = size/exact - iScale;
					if ( scale.X  > -0.25f && scale.X < 0.5f)
						return near;
					*/
					break;
				}

				default:
					break;
			}

			if (!snapToPixels)
				return size;
			return SnapSize(size);
		}

		float2 SnapSize( float2 sz )
		{
			return Math.Round(sz* absoluteZoom) / absoluteZoom;
		}

		float2 CalcScale( float2 availableSize, float2 desiredSize,
			bool autoWidth, bool autoHeight )
		{
			var d = availableSize;
			d.X -= PaddingWidth;
			d.Y -= PaddingHeight;

			var scale = float2(1);

			if (autoWidth && autoHeight && !(stretchMode == StretchMode.PointPrecise ||
				stretchMode == StretchMode.PixelPrecise ||
				stretchMode == StretchMode.PointPrefer) )
			{
				if (stretchSizing == StretchSizing.Zero)
					scale = float2(0);
				else
					scale = float2(1);
			}
			else
			{
				float2 s = float2(
					desiredSize.X < float.ZeroTolerance ? 0f : d.X / desiredSize.X,
					desiredSize.Y < float.ZeroTolerance ? 0f : d.Y / desiredSize.Y
					);
				switch( stretchMode )
				{
					case StretchMode.PointPrecise:
					case StretchMode.PixelPrecise:
					case StretchMode.PointPrefer:
						scale = float2(1);
						break;

					case StretchMode.Scale9:
					case StretchMode.Fill:
					{
						scale = autoWidth ? float2(s.Y) :
							autoHeight ? float2(s.X) :
							s;
						break;
					}

					case StretchMode.Uniform:
					{
						var sm = autoWidth ? s.Y :
							autoHeight ? s.X :
							Math.Min( s.X, s.Y );
						scale = float2(sm);
						break;
					}

					case StretchMode.UniformToFill:
					{
						var sm = autoWidth ? s.Y :
							autoHeight ? s.X :
							Math.Max( s.X, s.Y );
						scale = float2(sm);
						break;
					}
				}
			}

			//limit direction of stretching
			//TODO: if the stretching mode is uniform then both should be limited the same
			switch( stretchDirection )
			{
				case StretchDirection.Both:
					break;

				case StretchDirection.DownOnly:
					scale.X = Math.Min( scale.X, 1 );
					scale.Y = Math.Min( scale.Y, 1 );
					break;

				case StretchDirection.UpOnly:
					scale.X = Math.Max( 1, scale.X );
					scale.Y = Math.Max( 1, scale.Y );
					break;
			}

			if (snapToPixels && desiredSize.X > float.ZeroTolerance && desiredSize.Y > float.ZeroTolerance)
				scale = SnapSize( scale * desiredSize ) / desiredSize;
			return scale;
		}

		public float2 CalcOrigin( float2 availableSize, float2 contentActualSize )
		{
			var origin = float2(0);
			switch ( AlignmentHelpers.GetHorizontalAlign(align) )
			{
				case Alignment.Default: //may be set for clarity if used with Fill modes
				case Alignment.Left:
					origin.X = padding[0];
					break;

				case Alignment.HorizontalCenter:
					origin.X = (availableSize.X - padding[0] - padding[2]) / 2
						- contentActualSize.X/2 + padding[0];
					break;

				case Alignment.Right:
					origin.X = availableSize.X - padding[2] - contentActualSize.X;
					break;
			}

			switch( AlignmentHelpers.GetVerticalAlign(align) )
			{
				case Alignment.Default:
				case Alignment.Top:
					origin.Y = padding[1];
					break;

				case Alignment.VerticalCenter:
					origin.Y = (availableSize.Y - padding[1] - padding[3]) / 2
						- contentActualSize.Y/2 + padding[1];
					break;

				case Alignment.Bottom:
					origin.Y = availableSize.Y - padding[3] - contentActualSize.Y;
					break;
			}

			if (snapToPixels)
				origin = SnapSize(origin);
			return origin;
		}

		public float4 CalcClip( float2 availableSize, ref float2 origin, ref float2 contentActualSize )
		{
			//cases where everything is outside clip region
			if (origin.X > availableSize.X ||
				origin.X + contentActualSize.X < 0 ||
				origin.Y > availableSize.Y ||
				origin.Y + contentActualSize.Y < 0)
			{
				origin = float2(0,0);
				contentActualSize = float2(0);
				return float4(0,0,1,1);
			}

			float2 tl = Math.Max( float2(0), (padding.XY-origin) / contentActualSize );
			float2 br = Math.Min( float2(1), (availableSize - origin - padding.ZW) / contentActualSize );

			var dx = padding.X - origin.X;
			if (dx > 0)
			{
				contentActualSize.X -= dx;
				origin.X = padding.X;
			}

			dx = origin.X + contentActualSize.X - availableSize.X + padding.Z;
			if (dx > 0)
			{
				contentActualSize.X -= dx;
			}

			var dy = padding.Y - origin.Y;
			if (dy > 0)
			{
				contentActualSize.Y -= dy;
				origin.Y = padding.Y;
			}

			dy = origin.Y + contentActualSize.Y - availableSize.Y + padding.W;
			if (dy > 0)
			{
				contentActualSize.Y -= dy;
			}

			return float4( tl.X, tl.Y, br.X, br.Y );
		}

		public float2 ExpandFillSize( float2 size, LayoutParams layoutParams )
		{
			bool autoWidth = !layoutParams.HasX;
			bool autoHeight = !layoutParams.HasY;
			var scale = CalcScale( layoutParams.Size, size, autoWidth, autoHeight );
			return scale * size;
		}
	}
