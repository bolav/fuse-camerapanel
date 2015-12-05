#import <AVFoundation/AVFoundation.h>
#include "-.CaptureWrapper.h"
#include <app/-.ViewFinder.h>
#include <app/Uno.Graphics.Texture2D.h>


@implementation CaptureWrapper
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    // doing copying to currentBuffer
    NSLog(@"Capture2");
    uAutoReleasePool pool;
    app::ViewFinder *view = [self ViewFinderInst];
    opaqueCMSampleBuffer *buf = sampleBuffer;
    // ::app::Uno::Graphics::Texture2D* t2 = view->textureFromSampleBuffer((id)buf);
    int t3 = view->videoTextureFromSampleBuffer((id)buf);
    view->PostVideoTexture(t3);
    int r = [self Runs];
    r++;
    if (r > 100) {
        [[self Session] stopRunning];
    }
    [self setRuns:r];
}

@end
