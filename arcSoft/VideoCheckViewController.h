//
//  VideoCheckViewController.h
//  arcSoft
//
//  Created by Ethan.Wang on 2018/12/19.
//  Copyright © 2018 Ethan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoCheckViewController : UIViewController

@property(nonatomic,strong)CMMotionManager *motionManager;

@end

NS_ASSUME_NONNULL_END
