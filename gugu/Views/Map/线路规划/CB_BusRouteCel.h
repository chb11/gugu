//
//  CB_BusRouteCel.h
//  gugu
//
//  Created by Mike Chen on 2019/6/10.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CB_BusRouteCel : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lbl_time;
@property (weak, nonatomic) IBOutlet UILabel *lbl_walkDistance;
@property (weak, nonatomic) IBOutlet UILabel *lbl_segment;
@property (weak, nonatomic) IBOutlet UILabel *lbl_naviinfo;


@end

NS_ASSUME_NONNULL_END
