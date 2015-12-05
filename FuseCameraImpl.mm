/*
     File: FuseCameraImpl.m
 Abstract: Fuse Glue.
  Version: 1.0
 
 Copyright (C) 2015 Bjørn-Olav Strand All Rights Reserved.
 
 */

#import <CoreVideo/CVOpenGLESTextureCache.h>
#import "FuseCameraImpl.h"
#import <OpenGLES/ES2/glext.h>

// Uniform index.
enum
{
    UNIFORM_Y,
    UNIFORM_UV,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_TEXCOORD,
    NUM_ATTRIBUTES
};

@interface FuseCameraImpl () {
    GLuint _program;
    
    GLuint _positionVBO;
    GLuint _texcoordVBO;
    GLuint _indexVBO;
    
    CGFloat _screenWidth;
    CGFloat _screenHeight;
    size_t _textureWidth;
    size_t _textureHeight;
    unsigned int _meshFactor;
    
    EAGLContext *_context;
    
    CVOpenGLESTextureRef _textureHandle;
    
    NSString *_sessionPreset;
    
    AVCaptureSession *_session;
    CVOpenGLESTextureCacheRef _videoTextureCache;

    uDelegate *_callback;
}

@end

@implementation FuseCameraImpl

- (int)textureHeight
{
    return _textureHeight;
}

- (int)textureWidth
{
    return _textureWidth;
}


- (void)start
{
    NSLog(@"mm start");

    _screenWidth = 640;
    _screenHeight = 480;

    _meshFactor = 4;
    _sessionPreset = AVCaptureSessionPreset640x480;        

    [self setupAVCapture];    
}

- (void)stop
{    
    NSLog(@"mm stop");
    [_session stopRunning];
    [self tearDownAVCapture];
}

- (void)addUpdateListener:(uDelegate *)callback
{
    _callback = callback;
}


- (void)captureOutput:(AVCaptureOutput *)captureOutput 
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer 
       fromConnection:(AVCaptureConnection *)connection
{
    NSLog(@"captureOutput");
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

    NSLog(@"CVOpenGLESTextureCacheCreateTextureFromImage done");
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
    
    CVBufferRelease(pixelBuffer);
    // Set Texture of Camera
    // Call callbackhandler
    if(_callback != NULL)
    {
        // TODO: How should we do this? Why don't this work?
        // @{Uno.Action:Of(_callback):Call()};
    }
}

- (int)getVideoTexture {
    return CVOpenGLESTextureGetName(_textureHandle);
}

- (void)setupAVCapture
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
    AVCaptureDevice * videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
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
