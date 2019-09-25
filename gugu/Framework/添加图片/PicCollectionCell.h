//
//  PicCollectionCell.h
//  PPLiaoMei
//
//  Created by Glenn on 2017/12/19.
//  Copyright © 2017年 BingQiLin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PicCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *cellImageView;
@property (weak, nonatomic) IBOutlet UIButton *cellDeleteButton;

@end
