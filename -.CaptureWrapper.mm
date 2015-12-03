#import <AVFoundation/AVFoundation.h>
#include "-.CaptureWrapper.h"
#include <app/-.ViewFinder.h>


@implementation CaptureWrapper
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    // doing copying to currentBuffer
    NSLog(@"Capture2");
    app::ViewFinder *view = [self ViewFinderInst];
    view->textureFromSampleBuffer((id)sampleBuffer);
    // UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
    int r = [self Runs];
    r++;
    if (r > 100) {
        uAutoReleasePool pool;
        [[self Session] stopRunning];
        UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
        NSData *imageData = UIImageJPEGRepresentation(image, 0.7f);
        NSString *encodedString = [imageData base64Encoding];
        NSString *javascript = @"CanvasCamera.capture('data:image/jpeg;base64,";
        javascript = [javascript stringByAppendingString:encodedString];
        javascript = [javascript stringByAppendingString:@"');"];
        view->PostString(javascript);
        // view->showImage((id)image);
    }
    [self setRuns:r];
}

// Create a UIImage from sample buffer data

- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer

{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
   CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);

    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);

    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);

    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
      bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);

    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);

    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];

    // Release the Quartz image
    CGImageRelease(quartzImage);

    return (image);
}

@end
