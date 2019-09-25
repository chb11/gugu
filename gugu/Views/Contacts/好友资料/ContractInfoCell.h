//
//  ContractInfoCell.h
//  gugu
//
//  Created by Mike Chen on 2019/3/6.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContractInfoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lbl_title;
@property (weak, nonatomic) IBOutlet UIImageView *img_right;

@end

NS_ASSUME_NONNULL_END
