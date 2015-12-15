using Uno;
public extern(Android) class AndroidFrameListener : Android.java.lang.Object, Android.android.graphics.SurfaceTextureDLROnFrameAvailableListener
{
	public AndroidFrameListener () {
	}
    public void onFrameAvailable(Android.android.graphics.SurfaceTexture arg0) 
    {
    	debug_log "onFrameAvailable";
    }
}
