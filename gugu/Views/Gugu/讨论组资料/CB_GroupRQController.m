//
//  CB_GroupRQController.m
//  gugu
//
//  Created by Mike Chen on 2019/5/4.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_GroupRQController.h"

@interface CB_GroupRQController ()

@property (weak, nonatomic) IBOutlet UIImageView *img_group;
@property (strong, nonatomic) IBOutlet UILabel *lbl_group;

@property (weak, nonatomic) IBOutlet UIView *view_qr;
@property (weak, nonatomic) IBOutlet UIImageView *img_qr;

@end

@implementation CB_GroupRQController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"群二维码名片";
    NSString *photoUrl = self.groupDict[@"PhotoUrl"];
    if (![photoUrl containsString:@"http"]) {
        photoUrl = [NSString stringWithFormat:@"%@%@",NET_MAIN_URL,photoUrl];
    }
    [self.img_group sd_setImageWithURL:[NSURL URLWithString:photoUrl]];
    self.lbl_group.text = [AppGeneral getSafeValueWith:self.groupDict[@"Name"]];
    
    
    NSDictionary *dict = @{@"qrType":@(2),@"groupId":self.groupDict[@"Guid"]};
    
    self.img_qr.image = [WSLNativeScanTool createQRCodeImageWithString:[dict modelToJSONString] andSize:CGSizeMake(200, 200) andBackColor:[UIColor whiteColor] andFrontColor:[UIColor blackColor] andCenterImage:nil];
    
}


@end
