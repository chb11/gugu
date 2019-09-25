//
//  CB_SearchHistoryView.m
//  gugu
//
//  Created by Mike Chen on 2019/3/30.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_SearchHistoryView.h"


@implementation CB_SearchHistoryView



- (IBAction)aciton_delete:(UIButton *)sender {
    if (self.block_delete) {
        self.block_delete();
    }
}



@end
