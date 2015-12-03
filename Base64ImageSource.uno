using Uno;
using Uno.Graphics;
using Uno.UX;
using Fuse.Resources;
using Experimental.TextureLoader;

public class Base64ImageSource : TextureImageSource
{
  void SetTexture(texture2D texture)
  {
    Texture = texture;
  }

  string _base64image;

  [UXContent]
  public string Base64
  {
    get { return _base64image; }
    set
    {
      if (_base64image != value)
      {
        _base64image = value;
        var stripped = _base64image.Replace("data:image/png;base64,", "").Replace("data:image/jpeg;base64,", "");
        var data = Uno.Text.Base64.GetBytes(stripped);

        try 
        {
          if (_base64image.StartsWith("data:image/png"))
            TextureLoader.PngByteArrayToTexture2D(new Buffer(data), SetTexture);
          else if(_base64image.StartsWith("data:image/jpeg"))
            TextureLoader.JpegByteArrayToTexture2D(new Buffer(data), SetTexture);
        }
        catch(Exception e)
        {
          debug_log e.Message;
        }
      }
    }
  }
}