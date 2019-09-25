//
//  CB_SearchKeywordController.h
//  gugu
//
//  Created by Mike Chen on 2019/3/27.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface CB_SearchKeywordController : BaseViewController

@property (nonatomic,copy) void(^block_select)(AMapPOI *mapPoi);

@end

NS_ASSUME_NONNULL_END
