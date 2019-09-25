//
//  CB_EditCardController.m
//  gugu
//
//  Created by Mike Chen on 2019/5/26.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_EditCardController.h"
#import "PerMissonManager.h"
#import "PackageGroupOpetationView.h"

@interface CB_EditCardController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *lbl_cardname;
@property (weak, nonatomic) IBOutlet UITextField *lbl_cardnum;

@property (weak, nonatomic) IBOutlet UIButton *btn_gongsi;

@property (weak, nonatomic) IBOutlet UIButton *btn_confirm;
@property (weak, nonatomic) IBOutlet UIImageView *img_gongsi;

@property (nonatomic,strong) NSString *gongsiId;
@property (nonatomic,strong) NSMutableDictionary *para;
@property (nonatomic, weak) UIImagePickerController * imgPicker;

@end

@implementation CB_EditCardController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"编辑卡包";
    
    if (self.dict) {
        self.para = self.dict.mutableCopy;
        self.lbl_cardname.text = [AppGeneral getSafeValueWith:self.dict[@"Name"]];
        self.lbl_cardnum.text = [AppGeneral getSafeValueWith:self.dict[@"CardNum"]];
        NSString *url = self.dict[@"PhotoUrl"];
        if (![url containsString:@"http"]) {
            url = [NSString stringWithFormat:@"%@%@",NET_MAIN_URL,url];
        }
        self.gongsiId = self.dict[@"CompanyId"];
        [[SDWebImageManager sharedManager].imageDownloader downloadImageWithURL:[NSURL URLWithString:url] options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
            self.img_gongsi.image = image;
        }];
        [self.btn_gongsi setTitle:self.dict[@"Company"][@"Name"] forState:UIControlStateNormal];
        [self addItemWithTitle:@"删除" imageName:@"" selector:@selector(action_delete) left:NO];
    }
    [self.btn_confirm addlayerRadius:self.btn_confirm.height/2];
}

- (IBAction)action_chooseGongsi:(id)sender {
    CGFloat o_height = 400+BottomPadding;
    PackageGroupOpetationView *operationView = [[PackageGroupOpetationView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, o_height)];
    __weak typeof(self) weakSelf = self;
    operationView.block_chooseGongsi = ^(NSDictionary * _Nonnull dict) {
        weakSelf.gongsiId = dict[@"Guid"];
        NSString *title = dict[@"Name"];
        [weakSelf.btn_gongsi setTitle:title forState:UIControlStateNormal];
    };
    
    [self.view addSubview:operationView];
    [self.view bringSubviewToFront:operationView];
    [UIView animateWithDuration:0.4 animations:^{
        operationView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, -o_height);
    }];
}

- (IBAction)choosePhoto:(id)sender {
    [self action_choosePhoto];
}

- (IBAction)action_confirm:(id)sender {
    if (self.lbl_cardname.text.length ==0) {
        [AppGeneral showMessage:@"请输入卡片名称" andDealy:1];
        return ;
    }
    if (self.lbl_cardnum.text.length ==0) {
        [AppGeneral showMessage:@"请输入卡片编号" andDealy:1];
        return ;
    }
    if (self.gongsiId.length == 0&&!self.dict) {
        [AppGeneral showMessage:@"请选择公司" andDealy:1];
        return ;
    }
    if (!self.img_gongsi.image && !self.dict) {
        [AppGeneral showMessage:@"请选择图片" andDealy:1];
        return ;
    }
    if (!self.dict) {
        self.para = @{}.mutableCopy;
    }
    NSData  * data = UIImageJPEGRepresentation(self.img_gongsi.image, 1);
    [self.para setValue:self.gongsiId forKey:@"CompanyId"];
    [self.para setValue:self.lbl_cardnum.text forKey:@"CardNum"];
    [self.para setValue:self.lbl_cardname.text forKey:@"Name"];
    
    [[NetWorkConnect manager] postImageWith:data postDataWith:self.para withUrl:COMPANY_EDIT_COMPANY_CARD withFileName:@"Photo" withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
        if (resultCode == 1) {
            [AppGeneral showMessage:@"编辑成功" andDealy:1];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
    
}

-(void)action_delete{
    [AppGeneral action_showAlertWithTitle:@"是否删除？" andConfirmBlock:^{
        [[NetWorkConnect manager] postDataWith:@{@"Guid":self.dict[@"Guid"]} withUrl:COMPANY_DELETE_COMPANY_CARD withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
            if (resultCode == 1) {
                [AppGeneral showMessage:@"删除成功" andDealy:1];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }];
}

-(void)action_choosePhoto{
    __weak typeof(self) weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"使用相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf presentCameraSingle];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"选择图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        [weakSelf presentPhotoPickerViewController];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [self.navigationController presentViewController:alertController
                                            animated:YES
                                          completion:nil];
}

-(void)presentCameraSingle
{
    if ([PerMissonManager isOpenCamera]) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController*  _picker = [[UIImagePickerController alloc] init] ;
            _picker.delegate = self;
            _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            _picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            _picker.allowsEditing = YES ;
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
            self.imgPicker = _picker;
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            {
                __weak typeof(self) weakSelf = self;
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [weakSelf presentViewController:_picker animated:YES completion:^{
                        
                    }];
                }];
                
            }else {
                [self presentViewController:_picker animated:YES completion:^{
                    
                }];
            }
        }
    }
    
}

-(void)presentPhotoPickerViewController
{
    if ([PerMissonManager isOpenAlbum]) {
        
        UIImagePickerController*  _picker = [[UIImagePickerController alloc] init] ;
        _picker.delegate = self;
        _picker.allowsEditing = YES;
        _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            __weak typeof(self) weakSelf = self;
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [weakSelf presentViewController:_picker animated:YES completion:^{
                    
                }];
            }];
        }else {
            [self presentViewController:_picker animated:YES completion:^{
                
            }];
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [picker dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    UIImage *yourImage;
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
        yourImage=[UIImage imageWithData:UIImageJPEGRepresentation(image, 0.4)];
        self.img_gongsi.image = image;
    }
    [picker dismissViewControllerAnimated:YES completion:^{
    }];
}

-(void)action_uploadImage:(UIImage *)image{
    
    
}

@end
