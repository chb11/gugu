//
//  CB_NAviTypeChooseView.h
//  gugu
//
//  Created by Mike Chen on 2019/6/8.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CB_NAviTypeChooseView : UIView

@property (weak, nonatomic) IBOutlet UILabel *lbl_addressName;
@property (weak, nonatomic) IBOutlet UILabel *lbl_brief;
@property (weak, nonatomic) IBOutlet UIButton *btn_guihua;
@property (weak, nonatomic) IBOutlet UIButton *btn_navi;
@property (weak, nonatomic) IBOutlet UIImageView *img_navi;
@property (weak, nonatomic) IBOutlet UIView *view_content;

@property (nonatomic,strong) CB_MessageModel *model;

@property (nonatomic,copy) void(^block_guihua)(CB_MessageModel *model);
@property (nonatomic,copy) void(^block_zudui)(CB_MessageModel *model);

@end

NS_ASSUME_NONNULL_END
