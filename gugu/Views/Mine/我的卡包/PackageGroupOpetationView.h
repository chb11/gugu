//
//  PackageGroupOpetationView.h
//  VoicePackage
//
//  Created by douyinbao on 2018/10/12.
//  Copyright © 2018年 douyinbao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PackageGroupOpetationView : UIView

@property (nonatomic,strong) NSArray *dataSource;

@property (nonatomic,copy) void(^block_chooseGongsi)(NSDictionary *dict);

@end

NS_ASSUME_NONNULL_END
