//
//  NewsDetailController.h
//  gugu
//
//  Created by Mike Chen on 2019/4/8.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "BaseViewController.h"
#import "NewsListModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NewsDetailController : BaseViewController

@property (nonatomic,strong) NewsListModel *model;

@end

NS_ASSUME_NONNULL_END
