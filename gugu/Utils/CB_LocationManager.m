//
//  CB_LocationManager.m
//  gugu
//
//  Created by Mike Chen on 2019/4/8.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_LocationManager.h"

static CB_LocationManager *_instance;

@interface CB_LocationManager ()<AMapLocationManagerDelegate>

@property (nonatomic,strong) AMapLocationManager *locationManager;

@end

@implementation CB_LocationManager

+(CB_LocationManager *)shareInstance
{
    static dispatch_once_t oneToken;
    
    dispatch_once(&oneToken, ^{
        
        _instance = [[CB_LocationManager alloc]init];
        [_instance initLocationManage];
    });
    
    return _instance;
}

-(void)initLocationManage{
    self.locationManager = [[AMapLocationManager alloc] init];
    self.locationManager.delegate = self;
    // 带逆地理信息的一次定位（返回坐标和地址信息）
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    //   定位超时时间，最低2s，此处设置为2s
    self.locationManager.locationTimeout =2;
    //   逆地理请求超时时间，最低2s，此处设置为2s
    self.locationManager.reGeocodeTimeout = 2;
    
}

-(void)locateWithCompleted:(void(^)(NSString *formattedAddress,CLLocation *location))calculateBlock{
    
    // 带逆地理（返回坐标和地址信息）。将下面代码中的 YES 改成 NO ，则不会返回地址信息。
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        
        if (error)
        {
            NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
            
            if (error.code == AMapLocationErrorLocateFailed)
            {
                return;
            }
        }
        
        NSLog(@"location:%@", location);
        
        if (regeocode)
        {
            NSLog(@"reGeocode:%@", regeocode);
        }
        
        if (calculateBlock) {
            calculateBlock(regeocode.formattedAddress,location);
        }
        
    }];
    
}


@end
