using Uno;
using OpenGL;
using Uno.Graphics;
using Uno.Compiler.ExportTargetInterop;

[TargetSpecificImplementationAttribute]
extern(iOS) class Camera
{
  public void Start() {

  }
  public void Stop() {

  }
  public int2 Size { get; private set; }
  public event EventHandler FrameAvailable;
  public GLTextureHandle Texture { get; private set; }
  public VideoTexture VideoTexture { get; private set; }
  public void Update() {
    return;
  }
}
