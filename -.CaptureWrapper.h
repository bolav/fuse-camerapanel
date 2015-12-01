#ifndef __APP___CAPTUREWRAPPER_H__
#define __APP___CAPTUREWRAPPER_H__

#ifdef __OBJC__

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface CaptureWrapper : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate> {
    CMSampleBufferRef currentBuffer;
}
@end

#endif

#endif
