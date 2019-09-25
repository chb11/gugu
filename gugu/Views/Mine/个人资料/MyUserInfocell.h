//
//  MyUserInfocell.h
//  gugu
//
//  Created by Mike Chen on 2019/3/2.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyUserInfocell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lbl_title;
@property (weak, nonatomic) IBOutlet UIImageView *img_header;
@property (weak, nonatomic) IBOutlet UILabel *lbl_subtitle;


@end

NS_ASSUME_NONNULL_END
