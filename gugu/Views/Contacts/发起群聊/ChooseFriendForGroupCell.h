//
//  ChooseFriendForGroupCell.h
//  gugu
//
//  Created by Mike Chen on 2019/3/9.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChooseFriendForGroupCell : UITableViewCell

@property (nonatomic,strong) CB_FriendModel *friendModel;

@property (weak, nonatomic) IBOutlet UIImageView *img_header;

@property (weak, nonatomic) IBOutlet UILabel *lbl_name;


@end

NS_ASSUME_NONNULL_END
