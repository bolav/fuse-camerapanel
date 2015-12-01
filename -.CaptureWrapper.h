#ifndef __APP___CAPTUREWRAPPER_H__
#define __APP___CAPTUREWRAPPER_H__

#ifdef __OBJC__

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#include <app/-.ViewFinder.h>

@interface CaptureWrapper : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate> {
    CMSampleBufferRef currentBuffer;
}
@property     app::ViewFinder *ViewFinderInst;
@end

#endif

#endif
