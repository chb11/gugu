//
//  CB_ActivityDriveAnnotation.h
//  gugu
//
//  Created by Mike Chen on 2019/5/28.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <AMapNaviKit/AMapNaviKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CB_ActivityDriveAnnotation : AMapNaviCompositeCustomAnnotation

@property (nonatomic,strong) NSString *Guid;

@property (nonatomic,strong) NSString *userHeadUrl;

@end

NS_ASSUME_NONNULL_END
