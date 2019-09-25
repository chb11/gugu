//
//  CB_SearchKeywordCell.h
//  gugu
//
//  Created by Mike Chen on 2019/3/31.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CB_SearchKeywordCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbl_title;
@property (weak, nonatomic) IBOutlet UILabel *lbl_discribe;
@property (weak, nonatomic) IBOutlet UILabel *lbl_distance;

@end

NS_ASSUME_NONNULL_END
