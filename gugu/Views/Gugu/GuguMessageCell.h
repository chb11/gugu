//
//  GuguMessageCell.h
//  gugu
//
//  Created by Mike Chen on 2019/3/9.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GuguMessageCell : UITableViewCell

@property (nonatomic,strong) CB_MessageModel *model;

@property (weak, nonatomic) IBOutlet UILabel *lbl_isread;
@property (weak, nonatomic) IBOutlet UIImageView *img_header;
@property (weak, nonatomic) IBOutlet UILabel *lbl_title;
@property (weak, nonatomic) IBOutlet UILabel *lbl_brief;
@property (weak, nonatomic) IBOutlet UILabel *lbl_time;
@property (weak, nonatomic) IBOutlet UIView *view_count;


@end

NS_ASSUME_NONNULL_END
