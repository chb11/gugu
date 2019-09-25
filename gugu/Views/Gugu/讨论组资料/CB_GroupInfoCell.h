//
//  CB_GroupInfoCell.h
//  gugu
//
//  Created by Mike Chen on 2019/5/4.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CB_GroupInfoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lbl_title;
@property (weak, nonatomic) IBOutlet UILabel *lbl_right;
@property (weak, nonatomic) IBOutlet UISwitch *view_switch;
@property (weak, nonatomic) IBOutlet UIImageView *img_erweima;
@property (nonatomic,copy) void(^block_switch)(BOOL isOpen);


@end

NS_ASSUME_NONNULL_END
