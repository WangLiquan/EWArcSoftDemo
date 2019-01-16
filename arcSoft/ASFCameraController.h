#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
/// 获取摄像头数据的回调protocol
@protocol ASFCameraControllerDelegate <NSObject>
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection;
@end

/// AVFoundation调用前摄像头获取影像控制器
@interface ASFCameraController : NSObject

@property (nonatomic, weak)     id <ASFCameraControllerDelegate>   delegate;
@property (nonatomic, strong)     AVCaptureVideoPreviewLayer *previewLayer;

- (BOOL) setupCaptureSession:(AVCaptureVideoOrientation)videoOrientation;
- (void) startCaptureSession;
- (void) stopCaptureSession;

@end




