#import <AVFoundation/AVFoundation.h>
#include "-.CaptureWrapper.h"
#include <app/-.ViewFinder.h>


@implementation CaptureWrapper
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    // doing copying to currentBuffer
    NSLog(@"Capture2");
    app::ViewFinder *view = [self ViewFinderInst];
    view->textureFromSampleBuffer((id)sampleBuffer);
    [[self Session] stopRunning];
    int r = [self Runs];
    r++;
    if (r > 100) {
        [[self Session] stopRunning];
    }
    [self setRuns:r];
}

@end
