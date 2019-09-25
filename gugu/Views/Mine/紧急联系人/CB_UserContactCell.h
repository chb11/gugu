//
//  CB_UserContactCell.h
//  gugu
//
//  Created by Mike Chen on 2019/3/4.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CB_UserContactCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *img_header;

@property (weak, nonatomic) IBOutlet UILabel *lbl_name;
@property (weak, nonatomic) IBOutlet UILabel *lbl_brief;

@property (nonatomic,strong) CB_ContactModel *model;

@end

NS_ASSUME_NONNULL_END
