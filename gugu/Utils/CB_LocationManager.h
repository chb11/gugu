//
//  CB_LocationManager.h
//  gugu
//
//  Created by Mike Chen on 2019/4/8.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CB_LocationManager : NSObject

+(CB_LocationManager *)shareInstance;

-(void)locateWithCompleted:(void(^)(NSString *formattedAddress,CLLocation *location))calculateBlock;

@end

NS_ASSUME_NONNULL_END
