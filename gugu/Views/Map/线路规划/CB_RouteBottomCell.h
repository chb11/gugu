//
//  CB_RouteBottomCell.h
//  gugu
//
//  Created by Mike Chen on 2019/4/6.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <UIKit/UIKit.h>



NS_ASSUME_NONNULL_BEGIN

@interface CB_RouteBottomCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *lbl_way;
@property (weak, nonatomic) IBOutlet UILabel *lbl_time;
@property (weak, nonatomic) IBOutlet UILabel *lbl_distance;

@end

NS_ASSUME_NONNULL_END
