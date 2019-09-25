//
//  CB_MapBottomView.m
//  gugu
//
//  Created by Mike Chen on 2019/3/25.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_MapBottomView.h"

@interface CB_MapBottomView ()

@property (weak, nonatomic) IBOutlet UIButton *btn_searchAround;
@property (weak, nonatomic) IBOutlet UIButton *btn_goThere;


@end

@implementation CB_MapBottomView

-(void)awakeFromNib{
    [super awakeFromNib];
    
    [self.btn_goThere addlayerRadius:self.btn_goThere.height/2];
    [self.btn_searchAround addlayerRadius:self.btn_searchAround.height/2];
    
}

-(void)action_show{
    
        self.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, -self.height);
    
}

-(void)action_hide{
    
        self.transform = CGAffineTransformIdentity;
    
}

- (IBAction)action_searchAround:(id)sender {
    if (self.block_searchAround) {
        self.block_searchAround();
    }
}

- (IBAction)action_goThere:(id)sender {
    if (self.block_goToThere) {
        self.block_goToThere();
    }
}

- (IBAction)action_showResultList:(UIButton *)sender {
    if (self.block_showResultList) {
        self.block_showResultList();
    }
}


@end
