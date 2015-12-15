using Uno;
public extern(Android) class AndroidPreviewCallback : Android.java.lang.Object, Android.android.hardware.CameraDLRPreviewCallback
{
	public AndroidPreviewCallback () {
	}
    public void onPreviewFrame(Android.Runtime.ByteArray arg0, Android.android.hardware.Camera arg1) 
    {
    	debug_log "onPreviewFrame";
    }
}
