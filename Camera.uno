using Uno;
using OpenGL;
using Uno.Graphics;

extern(iOS) class Camera
{
  void Start() {

  }
  void Stop() {

  }
  int2 Size { get; private set; }
  event EventHandler FrameAvailable;
  GLTextureHandle Texture { get; private set; }
  Texture2D VideoTexture { get; private set; }
  void Update() {
    return;
  }
}
