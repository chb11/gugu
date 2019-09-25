//
//  CB_SearchAroundResultCell.h
//  gugu
//
//  Created by Mike Chen on 2019/4/2.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CB_SearchAroundResultCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *img;
@property (weak, nonatomic) IBOutlet UILabel *lbl_title;
@property (weak, nonatomic) IBOutlet UILabel *lbl_address;

@property (weak, nonatomic) IBOutlet UILabel *lbl_phone;
@property (weak, nonatomic) IBOutlet UILabel *lbl_rect;
@property (weak, nonatomic) IBOutlet UILabel *lbl_point;
@property (weak, nonatomic) IBOutlet UILabel *lbl_distance;

@end

NS_ASSUME_NONNULL_END
