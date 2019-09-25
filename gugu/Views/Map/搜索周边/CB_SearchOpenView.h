//
//  CB_SearchOpenView.h
//  gugu
//
//  Created by Mike Chen on 2019/3/31.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CB_SearchOpenView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UILabel *lbl_title;
@property (weak, nonatomic) IBOutlet UIButton *btn_open;
@property (nonatomic,assign) BOOL isOpen;
@property (nonatomic,copy) void(^block_open)(BOOL isopen);

@end

NS_ASSUME_NONNULL_END
