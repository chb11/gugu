//
//  PerMissonManager.m
//  PPLiaoMei
//
//  Created by BeRich2019 on 2017/5/17.
//  Copyright © 2017年 BingQiLin. All rights reserved.
//

#import "PerMissonManager.h"
#import "ALAssetsLibrary+WJ.h"
#import <CoreLocation/CoreLocation.h>
static PerMissonManager * Manager = nil;
@interface PerMissonManager ()<UIAlertViewDelegate>
{
    UIAlertView *_alertView;
}
@property (nonatomic, weak)UIViewController * weakVC;

@end
@implementation PerMissonManager

+ (PerMissonManager*)sharedInstance
{
    //    CoinManager = [[super allocWithZone:NULL] init];
    //    return CoinManager;
    @synchronized (self)
    {
        if (Manager == nil)
        {
            Manager = [[self alloc]init];
        }
    }
    return Manager;
}

+(BOOL)isOpenCamera
{
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        NSString *tips = [NSString stringWithFormat:@"请在iPhone的”设置-隐私-相机“选项中，允许%@访问相机",APP_NAME];
        PerMissonManager * data = [PerMissonManager sharedInstance];
        [data showAlertWithMsg:tips];
        return NO;
    }
    return YES;
}

+(BOOL)isOpenAlbum
{
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
  if (author == kCLAuthorizationStatusRestricted || author ==kCLAuthorizationStatusDenied){
      NSString *tips = [NSString stringWithFormat:@"请在iPhone的”设置-隐私-照片“选项中，允许%@访问照片",APP_NAME];
        PerMissonManager * data = [PerMissonManager sharedInstance];
        [data showAlertWithMsg:tips];
        return NO;
    }
    return YES;
}

+(BOOL)PhotoAlbumPermissions
{
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == kCLAuthorizationStatusRestricted || author ==kCLAuthorizationStatusDenied){
        return NO;
    }
    return YES;
}


+(BOOL)isOpenMicroPhone
{
    __block BOOL bCanRecord = YES;
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {//麦克风权限
        bCanRecord = granted;
        
    }];
    if (bCanRecord==NO) {
        NSString *tips = [NSString stringWithFormat:@"请在iPhone的”设置-隐私-麦克风“选项中，允许%@访问麦克风",APP_NAME];
        PerMissonManager * data = [PerMissonManager sharedInstance];
        [data showAlertWithMsg:tips];
    }
    return bCanRecord;
}

-(void)showAlertWithMsg:(NSString *)msg
{
    [_alertView removeFromSuperview];
    _alertView = nil;
    _alertView = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去开启", nil];
    [_alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString * title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"去开启"]) {
        NSURL*url=[NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
    }
}

@end
