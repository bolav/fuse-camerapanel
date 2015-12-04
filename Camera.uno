extern(iOS) class Camera
{
  void Start();
  void Stop();
  int2 Size { get; }
  event EventHandler FrameAvailable;
  GLTextureHandle Texture { get; }
  void Update();
}
