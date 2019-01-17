#import "ASFCameraController.h"
#import <AVFoundation/AVFoundation.h>

@interface ASFCameraController ()<AVCaptureVideoDataOutputSampleBufferDelegate>
{
    /// AVCaptureSession是AVFoundation的核心类,用于捕捉视频和音频,协调视频和音频的输入和输出流.
    AVCaptureSession    *captureSession;
    /// 捕捉连接——AVCaptureConnection,捕捉连接负责将捕捉会话接收的媒体类型和输出连接起来
    AVCaptureConnection *videoConnection;
}
@end

@implementation ASFCameraController

#pragma mark capture
/// 输出流回调,开启相机后实时调用
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if (connection == videoConnection) {
        /// 使用protocol将其回调到VideoCheckViewController
        if (self.delegate && [self.delegate respondsToSelector:@selector(captureOutput:didOutputSampleBuffer:fromConnection:)]) {
            [self.delegate captureOutput:captureOutput didOutputSampleBuffer:sampleBuffer fromConnection:connection];
        }
    }
}

#pragma mark - Setup Video Session
/// 设置数据源摄像头
- (AVCaptureDevice *)videoDeviceWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
        if ([device position] == position)
            return device;
    return nil;
}

- (BOOL) setupCaptureSession:(AVCaptureVideoOrientation)videoOrientation
{
    captureSession = [[AVCaptureSession alloc] init];
    /// beginConfiguration和commitConfiguration方法中的修改将在commit时同时提交
    [captureSession beginConfiguration];
    /// 设置摄像头为前置摄像头
    AVCaptureDevice *videoDevice = [self videoDeviceWithPosition:AVCaptureDevicePositionFront];
    AVCaptureDeviceInput *videoIn = [[AVCaptureDeviceInput alloc] initWithDevice:videoDevice error:nil];
    if ([captureSession canAddInput:videoIn])
        [captureSession addInput:videoIn];
    /// 设置输出流
    AVCaptureVideoDataOutput *videoOut = [[AVCaptureVideoDataOutput alloc] init];
    [videoOut setAlwaysDiscardsLateVideoFrames:YES];

    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    /// 指定像素格式
    NSDictionary *dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    [videoOut setVideoSettings:dic];
    /// 开新线程进行输出流代理方法调用
    dispatch_queue_t videoCaptureQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0);
    [videoOut setSampleBufferDelegate:self queue:videoCaptureQueue];
    /// 将输出流加入session
    if ([captureSession canAddOutput:videoOut])
        [captureSession addOutput:videoOut];
    videoConnection = [videoOut connectionWithMediaType:AVMediaTypeVideo];
    /// 设置镜像展示,不设置或赋值为false则获取图片是延垂直线相反
    if (videoConnection.supportsVideoMirroring) {
        [videoConnection setVideoMirrored:true];
    }
    /// 设置摄像头位置
    if ([videoConnection isVideoOrientationSupported]) {
        [videoConnection setVideoOrientation:videoOrientation];
    }
    if ([captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        [captureSession setSessionPreset:AVCaptureSessionPreset1280x720];
    }
    
    [captureSession commitConfiguration];
    
    return YES;
}

- (void) startCaptureSession
{
    if ( !captureSession )
        return;
    
    if (!captureSession.isRunning )
        [captureSession startRunning];
}

- (void) stopCaptureSession
{
    [captureSession stopRunning];
}

@end
