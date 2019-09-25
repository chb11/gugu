//
//  CB_ActivityUserAnnotation.h
//  gugu
//
//  Created by Mike Chen on 2019/5/25.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CB_ActivityUserAnnotation : MAPointAnnotation<MAAnnotation>

@property (nonatomic,strong) NSString *Guid;

@property (nonatomic,strong) NSString *userHeadUrl;

@end

NS_ASSUME_NONNULL_END
