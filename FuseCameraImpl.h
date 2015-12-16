/*
     File: FuseCameraImpl.h
 Abstract: Fuse Glue.
  Version: 1.0
 
 Copyright (C) 2015 Bjørn-Olav Strand All Rights Reserved.
 
 */

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <AVFoundation/AVFoundation.h>

@interface FuseCameraImpl : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>
 	- (int) textureHeight;
 	- (int) textureWidth;
 	- (int) getRotation;
 	- (void)startCam:(int)device;
 	- (void)stopCam;
 	- (void)addUpdateListener:(uDelegate *)callback;
 	@property int Texture;
@end
