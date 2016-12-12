#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <AVFoundation/AVFoundation.h>

@interface FuseCameraImpl : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>
 	- (int) textureHeight;
 	- (int) textureWidth;
 	- (int) getRotation;
 	- (void*)getStillImageOutputHandle;
 	- (void)startCam:(int)device;
 	- (void)stopCam;
 	- (void)addUpdateListener:(uDelegate *)callback;
 	@property int Texture;
@end
