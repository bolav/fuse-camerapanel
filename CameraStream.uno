using Fuse.Controls;

public class CameraStream : Panel {
	CameraVisual _visual;
	public CameraVisual Visual 
	{ 
		get 
		{
			return _visual;
		}
		set 
		{
			_visual = value;
			Children.Add(_visual);
		}
	}
}
