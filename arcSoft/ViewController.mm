//
//  ViewController.m
//  arcSoft
//
//  Created by Ethan.Wang on 2018/12/18.
//  Copyright © 2018 Ethan. All rights reserved.
//

#import "ViewController.h"
#import <ArcSoftFaceEngine/ArcSoftFaceEngine.h>
#import <ArcSoftFaceEngine/ArcSoftFaceEngineDefine.h>
#import <ArcSoftFaceEngine/amcomdef.h>
#import <ArcSoftFaceEngine/merror.h>
#import "VideoCheckViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton *buttonE = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonE setFrame:CGRectMake(50, 120, 200, 100)];
    [buttonE setBackgroundColor:[UIColor grayColor]];
    [buttonE setTitle:@"引擎激活" forState:UIControlStateNormal];
    [buttonE addTarget:self action:@selector(engineActive:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonE];

    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button2 setFrame:CGRectMake(50, 360, 200, 100)];
    [button2 setBackgroundColor:[UIColor grayColor]];
    [button2 setTitle:@"Video模式检测" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(videoCheck:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
}

-(void)engineActive:(UIButton*)sender {
    /// 虹软官网注册的appid
    NSString *appid = @"827JymBcUZD7E5GKisw4jVGL3JvEWAjcJyHkhGzR7iH4";
    NSString *sdkkey = @"CSHHVMxni2LNY9VP8tq9UF2japndSZcXvFjxAStdrV9B";
    ArcSoftFaceEngine *engine = [[ArcSoftFaceEngine alloc] init];
    MRESULT mr = [engine activeWithAppId:appid SDKKey:sdkkey];
    if (mr == ASF_MOK) {
        UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"SDK激活成功" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alertController animated:YES completion:nil];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }]];
    } else if(mr == MERR_ASF_ALREADY_ACTIVATED){
        UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"SDK已激活" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alertController animated:YES completion:nil];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }]];
    } else {
        NSString *result = [NSString stringWithFormat:@"SDK激活失败：%ld", mr];
        UIAlertController* alertController = [UIAlertController alertControllerWithTitle:result message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alertController animated:YES completion:nil];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }]];
    }
}

-(void)videoCheck:(UIButton*)sender {
    VideoCheckViewController *videoC = [[VideoCheckViewController alloc] init];
    [self presentViewController:videoC animated:true completion:nil];
}


@end
