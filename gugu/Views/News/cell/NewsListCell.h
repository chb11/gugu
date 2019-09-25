//
//  NewsListCell.h
//  gugu
//
//  Created by Mike Chen on 2019/4/8.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NewsListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *img_cover;
@property (weak, nonatomic) IBOutlet UILabel *lbl_title;
@property (weak, nonatomic) IBOutlet UILabel *lbl_keywords;
@property (weak, nonatomic) IBOutlet UILabel *lbl_from;
@property (weak, nonatomic) IBOutlet UILabel *lbl_time;


@end

NS_ASSUME_NONNULL_END
