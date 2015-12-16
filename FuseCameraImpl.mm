/*
     File: FuseCameraImpl.m
 Abstract: Fuse Glue.
  Version: 1.0
 
 Copyright (C) 2015 Bjørn-Olav Strand All Rights Reserved.
 
 */

#import <CoreVideo/CVOpenGLESTextureCache.h>
#import "FuseCameraImpl.h"
#import <OpenGLES/ES2/glext.h>

@interface FuseCameraImpl () {
    size_t _textureWidth;
    size_t _textureHeight;
    
    CVOpenGLESTextureRef _textureHandle;
    int _textureOrientation;
    
    NSString *_sessionPreset;
    
    AVCaptureSession *_session;
    CVOpenGLESTextureCacheRef _videoTextureCache;

    uDelegate *_callback;
}

@end

@implementation FuseCameraImpl

- (int)textureHeight
{
    return (int)_textureHeight;
}

- (int)textureWidth
{
    return (int)_textureWidth;
}

- (int)getOrientation
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    return orientation;
    /*
    if(orientation == 0) //Default orientation 
        //UI is in Default (Portrait) -- this is really a just a failsafe. 
    else if(orientation == UIInterfaceOrientationPortrait)
        //Do something if the orientation is in Portrait
    else if(orientation == UIInterfaceOrientationLandscapeLeft)
        // Do something if Left
    else if(orientation == UIInterfaceOrientationLandscapeRight)
    */
}

- (int)getRotation
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    int i_orientation = (int)orientation;
    if (i_orientation == _textureOrientation) {
        return 0;
    }
    else if (i_orientation == 1) {
        return 1;
    }
    else {
        return 2;
    }
}

- (void)startCam:(int)device
{
    NSLog(@"mm start");

    _sessionPreset = AVCaptureSessionPreset640x480;        

    [self setupAVCapture:device];
}

- (void)stopCam
{    
    NSLog(@"mm stop");
    [_session stopRunning];
    [self tearDownAVCapture];
}

- (void)addUpdateListener:(uDelegate *)callback
{
    _callback = callback;
    uRetain(_callback);
}


- (void)captureOutput:(AVCaptureOutput *)captureOutput 
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer 
       fromConnection:(AVCaptureConnection *)connection
{
    if (_textureHandle)
        CFRelease(_textureHandle);
        
     if (_videoTextureCache)
        CVOpenGLESTextureCacheFlush(_videoTextureCache, 0);
    
    uAutoReleasePool pool; // Do we need this???
	CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    _textureWidth = CVPixelBufferGetWidth(pixelBuffer);
    _textureHeight = CVPixelBufferGetHeight(pixelBuffer);
    
    if (!_videoTextureCache)
    {
        NSLog(@"No video texture cache");
        return;
    }

    glActiveTexture(GL_TEXTURE0);
    CVReturn err = CVOpenGLESTextureCacheCreateTextureFromImage(
        kCFAllocatorDefault,
        _videoTextureCache,
        pixelBuffer,
        NULL,
        GL_TEXTURE_2D,
        GL_RGBA,
        (GLsizei)_textureWidth,
        (GLsizei)_textureHeight,
        GL_BGRA_EXT,
        GL_UNSIGNED_BYTE,
        0,
        &_textureHandle);

    // Check orientation of device
    // Check orientation of frame
    _textureOrientation = connection.videoOrientation;
    // NSLog(@"%d", connection.videoOrientation);

    // Rotate frame


    if (err)
    {
        NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
        //if (vs->ErrorHandler)
        //{
        //    @{Uno.Action:Of(vs->ErrorHandler):Call()};
        //}
    }

    glBindTexture(CVOpenGLESTextureGetTarget(_textureHandle), CVOpenGLESTextureGetName(_textureHandle));
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    // CVBufferRelease(pixelBuffer);
    // Set Texture of Camera
    int _th = CVOpenGLESTextureGetName(_textureHandle);
    [self setTexture:_th];
    // Call callbackhandler
    if(_callback != NULL)
    {
        @{Uno.Action:Of(_callback):Call()};
    }
}

- (void)setupAVCapture:(int)devicetype
{
    NSLog(@"mm setupAVCapture");

    //-- Create CVOpenGLESTextureCacheRef for optimal CVImageBufferRef to GLES texture conversion.
    #if COREVIDEO_USE_EAGLCONTEXT_CLASS_IN_API
    CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, [EAGLContext currentContext], NULL, &(_videoTextureCache));
    #else
    CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, (__bridge void *)[EAGLContext currentContext], NULL, &(_videoTextureCache));
    #endif

    if (err)
    {
        NSLog(@"Error at CVOpenGLESTextureCacheCreate %d", err);
        return;
    }

    //-- Setup Capture Session.
    _session = [[AVCaptureSession alloc] init];
    [_session beginConfiguration];
    
    //-- Set preset session size.
    [_session setSessionPreset:_sessionPreset];
    
    //-- Creata a video device and input from that Device.  Add the input to the capture session.
    AVCaptureDevice * videoDevice = nil;
    if (devicetype == 2) {
        NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        for (AVCaptureDevice *device in videoDevices) {
            if (device.position == AVCaptureDevicePositionFront) {
                videoDevice = device;
                break;
            }
        }
    }
    if ( ! videoDevice) {
        videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }

    if(videoDevice == nil)
        assert(0);
    
    //-- Add the device to the session.
    NSError *error;        
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    if(error)
        assert(0);
    
    [_session addInput:input];
    
    //-- Create the output for the capture session.
    AVCaptureVideoDataOutput * dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [dataOutput setAlwaysDiscardsLateVideoFrames:YES]; // Probably want to set this to NO when recording
    
    //-- Set to YUV420.
    [dataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] 
                                                             forKey:(id)kCVPixelBufferPixelFormatTypeKey]]; // Necessary for manual preview
    
    // Set dispatch to be on the main thread so OpenGL can do things with the data
    [dataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];        
    
    [_session addOutput:dataOutput];
    [_session commitConfiguration];
    
    [_session startRunning];
}

- (void)tearDownAVCapture
{
    [self cleanUpTextures];
    
    CFRelease(_videoTextureCache);
}

@end
