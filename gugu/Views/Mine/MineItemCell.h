//
//  MineItemCell.h
//  gugu
//
//  Created by Mike Chen on 2019/3/2.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MineItemCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *img_left;
@property (weak, nonatomic) IBOutlet UILabel *lbl_title;
@property (weak, nonatomic) IBOutlet UISwitch *v_switch;
@property (weak, nonatomic) IBOutlet UILabel *lbl_subtitle;

@property (nonatomic,copy) void(^block_switch)(void);

@end

NS_ASSUME_NONNULL_END
