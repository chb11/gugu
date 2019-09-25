//
//  CB_BottomAddressCell.h
//  gugu
//
//  Created by Mike Chen on 2019/6/8.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CB_BottomAddressCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *img_header;
@property (weak, nonatomic) IBOutlet UILabel *lbl_address;
@property (weak, nonatomic) IBOutlet UILabel *lbl_brief;
@property (weak, nonatomic) IBOutlet UILabel *lbl_time;


@end

NS_ASSUME_NONNULL_END
