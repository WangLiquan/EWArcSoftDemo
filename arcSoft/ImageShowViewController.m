//
//  ImageShowViewController.m
//  ArcSoftFaceEngineDemo
//
//  Created by Ethan.Wang on 2018/12/18.
//  Copyright © 2018 ArcSoft. All rights reserved.
//

#import "ImageShowViewController.h"

@interface ImageShowViewController ()

@end

@implementation ImageShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 500)];
    imageView.image = _image;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:imageView];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
