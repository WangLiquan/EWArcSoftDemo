//
//  VideoCheckViewController.m
//  arcSoft
//
//  Created by Ethan.Wang on 2018/12/19.
//  Copyright © 2018 Ethan. All rights reserved.
//

#import "VideoCheckViewController.h"
#import "ASFCameraController.h"
#import "Utility.h"
#import "ASFVideoProcessor.h"
#import "ImageShowViewController.h"
#import <ArcSoftFaceEngine/ArcSoftFaceEngine.h>
#import "RippleAnimationView.h"


#define IMAGE_WIDTH     720
#define IMAGE_HEIGHT    1280

@interface VideoCheckViewController ()<ASFCameraControllerDelegate,ASFVideoProcessorDelegate>{
    BOOL takePhoto;
    UIImageView *showImageView;
    UIView *imageBackView;
    UIImageView *scanningImageView;
}
@property (nonatomic, strong) ASFCameraController* cameraController;
@property (nonatomic, strong) ASFVideoProcessor* videoProcessor;
@property (nonatomic, strong) NSMutableArray* arrayAllFaceRectView;

@end

@implementation VideoCheckViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self getManager];

    takePhoto = true;
    UIInterfaceOrientation uiOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    AVCaptureVideoOrientation videoOrientation = (AVCaptureVideoOrientation)uiOrientation;
    self.arrayAllFaceRectView = [NSMutableArray arrayWithCapacity:0];

    self.videoProcessor = [[ASFVideoProcessor alloc] init];
    self.videoProcessor.delegate = self;
    [self.videoProcessor initProcessor];

    self.cameraController = [[ASFCameraController alloc]init];
    self.cameraController.delegate = self;
    [self.cameraController setupCaptureSession:videoOrientation];

    [self.view.layer addSublayer:self.cameraController.previewLayer];
    self.cameraController.previewLayer.frame = self.view.layer.frame;

    scanningImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scanning"]];
    scanningImageView.frame = CGRectMake((UIScreen.mainScreen.bounds.size.width - 230)/2, 231, 230, 230);
    [self.view addSubview:scanningImageView];


    imageBackView = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    imageBackView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.7];
    imageBackView.hidden = true;
    [self.view addSubview:imageBackView];

    showImageView = [[UIImageView alloc] initWithFrame: CGRectMake((UIScreen.mainScreen.bounds.size.width - 230)/2, 231, 230, 230)];
    showImageView.layer.cornerRadius = 115;
    showImageView.layer.masksToBounds = YES;
    showImageView.contentMode = UIViewContentModeCenter;
//    showImageView.hidden = false;
    [imageBackView addSubview:showImageView];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.cameraController startCaptureSession];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.cameraController stopCaptureSession];
}
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (takePhoto == true){

        CVImageBufferRef cameraFrame = CMSampleBufferGetImageBuffer(sampleBuffer);
        ASF_CAMERA_DATA* cameraData = [Utility  getCameraDataFromSampleBuffer:sampleBuffer];
        NSArray *arrayFaceInfo = [self.videoProcessor process:cameraData];
        __weak __typeof__(self) weakself = self;
        dispatch_sync(dispatch_get_main_queue(), ^{
            if(weakself.arrayAllFaceRectView.count >= arrayFaceInfo.count)
            {
                for (NSUInteger face=arrayFaceInfo.count; face<weakself.arrayAllFaceRectView.count; face++) {
                    UIView *faceRectView = [weakself.arrayAllFaceRectView objectAtIndex:face];
                    faceRectView.hidden = YES;
                }
            }
            else
            {
                for (NSUInteger face=weakself.arrayAllFaceRectView.count; face<arrayFaceInfo.count; face++) {
                    UIView *view = [[UIView alloc] init];
                    [weakself.view addSubview:view];
                    [weakself.arrayAllFaceRectView addObject:view];
                }
            }
                        for (NSUInteger face = 0; face < arrayFaceInfo.count; face++) {
                UIView *faceRectView = [weakself.arrayAllFaceRectView objectAtIndex:face];
                ASFVideoFaceInfo *faceInfo = [arrayFaceInfo objectAtIndex:face];
                faceRectView.hidden = NO;
                faceRectView.frame = [weakself dataFaceRect2ViewFaceRect:faceInfo.faceRect];

                if(faceInfo.face3DAngle.status == 0) {
                    if (faceInfo.face3DAngle.rollAngle <= 10 && faceInfo.face3DAngle.rollAngle >= -10 && faceInfo.face3DAngle.yawAngle <= 10 && faceInfo.face3DAngle.yawAngle >= -10 && faceInfo.face3DAngle.pitchAngle <= 10 && faceInfo.face3DAngle.pitchAngle >= -10){
                        if (CGRectContainsRect(CGRectMake(30, 150, (UIScreen.mainScreen.bounds.size.width - 60), (UIScreen.mainScreen.bounds.size.height - 300)), faceRectView.frame)){
                            CMGyroData *newestAccel = self.motionManager.gyroData;
                            if (newestAccel.rotationRate.x < 0.005 && newestAccel.rotationRate.y < 0.005 && newestAccel.rotationRate.z < 0.005 ){
                                self->takePhoto = false;
                                CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer: cameraFrame];
                                CIContext *context = [[CIContext alloc] init];
                                CGRect imageRect= CGRectMake(0, 0, CVPixelBufferGetWidth(cameraFrame), CVPixelBufferGetHeight(cameraFrame));

                                struct CGImage *image = [context createCGImage:ciImage fromRect:imageRect];
                                UIImage *resultImage = [[UIImage alloc] initWithCGImage:image scale:UIScreen.mainScreen.scale orientation:UIImageOrientationUp];

                                self->imageBackView.hidden = NO;

                                self->showImageView.image = resultImage;

                                [UIView animateWithDuration:1.3 animations:^{
                                    self->showImageView.transform =CGAffineTransformMakeScale(0.7, 0.7);

                                } completion:^(BOOL finished) {
                                    RippleAnimationView *viewA = [[RippleAnimationView alloc] initWithFrame:CGRectMake(0, 0, self->showImageView.frame.size.width, self->showImageView.frame.size.height) animationType:AnimationTypeWithBackground];
                                    viewA.center = self->showImageView.center;
                                    [self->imageBackView addSubview:viewA];
                                    [self->imageBackView bringSubviewToFront:self->showImageView];
                                }];
                            }
                        }
                    }
                }
            }
        });
        /// 释放内存
        [Utility freeCameraData:cameraData];

        }

}

- (void) getManager {
    //初始化全局管理对象
    CMMotionManager *manager = [[CMMotionManager alloc] init];
    self.motionManager = manager;

    if (manager.gyroAvailable) {
        [manager startGyroUpdates];
    }

}

#pragma mark - AFVideoProcessorDelegate
- (void)processRecognized:(NSString *)personName
{

}

- (CGRect)dataFaceRect2ViewFaceRect:(MRECT)faceRect
{
    CGRect frameFaceRect = {0};
    CGRect frameGLView = self.view.frame;
    frameFaceRect.size.width = CGRectGetWidth(frameGLView)*(faceRect.right-faceRect.left)/IMAGE_WIDTH;
    frameFaceRect.size.height = CGRectGetHeight(frameGLView)*(faceRect.bottom-faceRect.top)/IMAGE_HEIGHT;
    frameFaceRect.origin.x = CGRectGetWidth(frameGLView)*faceRect.left/IMAGE_WIDTH;
    frameFaceRect.origin.y = CGRectGetHeight(frameGLView)*faceRect.top/IMAGE_HEIGHT;

    return frameFaceRect;
}
@end
