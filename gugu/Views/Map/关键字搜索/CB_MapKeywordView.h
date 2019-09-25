//
//  CB_MapKeywordView.h
//  gugu
//
//  Created by Mike Chen on 2019/3/27.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CB_MapKeywordView : UIView

@property (weak, nonatomic) IBOutlet UITextField *txt_keyword;
@property (weak, nonatomic) IBOutlet UIButton *btn_clear;

@property (nonatomic,strong) NSString *keywordStr;

@property (nonatomic,copy) void(^block_searchKeywords)(void);
@property (nonatomic,copy) void(^block_clearKeywords)(void);

@end

NS_ASSUME_NONNULL_END
