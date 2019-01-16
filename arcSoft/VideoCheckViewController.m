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
/// 人脸识别页面控制器
@interface VideoCheckViewController ()<ASFCameraControllerDelegate,ASFVideoProcessorDelegate>{
    /// 根据takePhoto状态来决定拍照
    BOOL takePhoto;
    /// 拍照后结果展示圆形ImageView
    UIImageView *showImageView;
    /// 拍照后背景半透明View
    UIView *imageBackView;
    /// 扫描框ImageView
    UIImageView *scanningImageView;
}
/// 获取前摄像头影像
@property (nonatomic, strong) ASFCameraController* cameraController;
/// 虹软进行人脸识别分析的工具
@property (nonatomic, strong) ASFVideoProcessor* videoProcessor;
/// 装载所有人脸信息框的Array
@property (nonatomic, strong) NSMutableArray* arrayAllFaceRectView;

@end

@implementation VideoCheckViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self getManager];

    takePhoto = true;
    /// 将设备方向赋给cameraController
    UIInterfaceOrientation uiOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    AVCaptureVideoOrientation videoOrientation = (AVCaptureVideoOrientation)uiOrientation;
    /// 预存Array内存
    self.arrayAllFaceRectView = [NSMutableArray arrayWithCapacity:0];
    /// 虹软的人脸识别控制器
    self.videoProcessor = [[ASFVideoProcessor alloc] init];
    self.videoProcessor.delegate = self;
    [self.videoProcessor initProcessor];
    /// 开启前置摄像
    self.cameraController = [[ASFCameraController alloc]init];
    self.cameraController.delegate = self;
    [self.cameraController setupCaptureSession:videoOrientation];
    /// 将摄影机layer置于控制器前
    [self.view.layer addSublayer:self.cameraController.previewLayer];
    self.cameraController.previewLayer.frame = self.view.layer.frame;
    /// 扫描框ImageView
    scanningImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scanning"]];
    scanningImageView.frame = CGRectMake((UIScreen.mainScreen.bounds.size.width - 230)/2, 231, 230, 230);
    [self.view addSubview:scanningImageView];
    /// 拍照后背景半透明颜色
    imageBackView = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    imageBackView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.7];
    imageBackView.hidden = true;
    [self.view addSubview:imageBackView];
    /// 拍照后预览图
    showImageView = [[UIImageView alloc] initWithFrame: CGRectMake((UIScreen.mainScreen.bounds.size.width - 230)/2, 231, 230, 230)];
    showImageView.layer.cornerRadius = 115;
    showImageView.layer.masksToBounds = YES;
    showImageView.contentMode = UIViewContentModeCenter;
    [imageBackView addSubview:showImageView];

    RippleAnimationView *viewA = [[RippleAnimationView alloc] initWithFrame:CGRectMake(0, 0, self->showImageView.frame.size.width, self->showImageView.frame.size.height) animationType:AnimationTypeWithBackground];
    viewA.center = self->showImageView.center;
    [self->imageBackView addSubview:viewA];
    [self->imageBackView bringSubviewToFront:self->showImageView];
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
                            if (newestAccel.rotationRate.x < 0.0005 && newestAccel.rotationRate.y < 0.0005 && newestAccel.rotationRate.z < 0.0005 ){
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

                                    ImageShowViewController *vc = [[ImageShowViewController alloc] init];
                                    vc.image = resultImage;
                                    double delayInSeconds = 2.0;
                                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

                                        [weakself presentViewController:vc animated:false completion:nil];
                                    });


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

/**
    开启陀螺仪,判断陀螺仪状态保证手机不在太过晃动情况下拍照,保证照片质量
 */
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
