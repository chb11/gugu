//
//  CB_MyCardCell.h
//  gugu
//
//  Created by Mike Chen on 2019/5/26.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CB_MyCardCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *img_gongsiHeader;
@property (weak, nonatomic) IBOutlet UILabel *lbl_gongsiname;
@property (weak, nonatomic) IBOutlet UIImageView *img;

@property (weak, nonatomic) IBOutlet UIView *view_conten;

@end

NS_ASSUME_NONNULL_END
