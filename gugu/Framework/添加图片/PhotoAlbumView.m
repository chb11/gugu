//
//  PhotoAlbumView.m
//  PPLiaoMei
//
//  Created by 岩 陈 on 2018/4/25.
//  Copyright © 2018年 岩 陈. All rights reserved.
//
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
#import "TZImagePickerController.h"
#import "TZImageManager.h"
#import "PhotoAlbumView.h"
#import "AlbumImages.h"
#import "PerMissonManager.h"
#import "PicCollectionCell.h"
#import "UIImage+FX.h"
#import "DDNavBrowserViewController.h"
#import "BaseViewController.h"
#import "AlbumImages.h"
#import "ImgModel.h"
#import "CyActionSheet.h"
#import "AlbumImages.h"
#define cellIdentifier @"PicCollectionCell"
#import "DDNavBrowserViewController.h"
#import "UIViewController+HUD.h"
@interface PhotoAlbumView ()<UICollectionViewDataSource,UICollectionViewDelegate,TZImagePickerControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate>
{
    UIAlertView * _alert;
}
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) NSMutableArray *imagesArray;
@property (nonatomic, strong) NSMutableArray *assetsArray;
@property (nonatomic, strong) BaseViewController *weakVC;
@property (nonatomic, copy) AppendClickedBlock clicked;
@property (nonatomic, copy) AppendVideoBlock videoFinish;
@property (nonatomic, strong) NSMutableDictionary *imageDataDic;
@property (nonatomic, strong) NSMutableDictionary *imagePathDic;
@end

@implementation PhotoAlbumView

- (id)initBaseArray:(NSArray *)array WeakCtrl:(BaseViewController *)weakCtrl CompleteBlock:(AppendClickedBlock)clicked
{
    self = [super initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    if (self) {
        
        self.imageDataDic = [NSMutableDictionary dictionary];
        self.imagePathDic = [NSMutableDictionary dictionary];
        self.clicked = clicked;
        [self setUpCollectionView];
        [self setUpDataArray:array];
        self.weakVC = weakCtrl;
        self.backgroundColor = [UIColor whiteColor];
        self.limitCount = 8;
        _alert = [[UIAlertView alloc]initWithTitle:nil message:@"已达到最大上传个数，无法继续添加" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles: nil];
        self.addIcon = IMAGE_ADD;
    }
    return self;
}

-(void)setUpDataArray:(NSArray *)array
{
    [self.imagesArray removeAllObjects];
    self.imagesArray = [NSMutableArray arrayWithArray:array];
    self.assetsArray = [NSMutableArray arrayWithArray:array];
    [self.collectionView reloadData];
   
   
}

-(BOOL)haveImage
{
    return self.imagesArray.count>0;
}

-(void)setImageArray:(NSArray *)imgArray andAssetArray:(NSArray *)array
{
    self.imagesArray = [NSMutableArray arrayWithArray:imgArray];
    self.assetsArray = [NSMutableArray arrayWithArray:array];
    [self.collectionView reloadData];
    if (self.resetFraCallBack) {
        [self resetFrame];
        self.resetFraCallBack();
    }

}

- (void)setUpCollectionView {
    
    CGFloat count = 4.0f;
    CGFloat padding = 11.0f;
    CGFloat width = (SCREEN_WIDTH-(count+1)*padding)/count;
    _flowLayout = [[UICollectionViewFlowLayout alloc] init];
    _flowLayout.itemSize = CGSizeMake(width, width);
    _flowLayout.minimumLineSpacing = padding;
    _flowLayout.minimumInteritemSpacing = padding;
    _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _flowLayout.sectionInset = UIEdgeInsetsMake(padding, padding, padding, padding);
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_flowLayout];
    UINib *nib = [UINib nibWithNibName:cellIdentifier
                                bundle: [NSBundle mainBundle]];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:cellIdentifier];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.allowsSelection = YES;
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.showsVerticalScrollIndicator = NO;
    //此处给其增加长按手势，用此手势触发cell移动效果
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlelongGesture:)];
    longGesture.minimumPressDuration = 0.5f;//触发长按事件时间为：秒
    [_collectionView addGestureRecognizer:longGesture];
    [self addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
}

-(void)resetFrame
{
    NSInteger count = 4;
    CGFloat padding = 11.0f;
    CGFloat width = (SCREEN_WIDTH-(count+1)*padding)/count;
    NSInteger sumCount =self.imagesArray.count+1;
    NSInteger lineCount = (sumCount)%4==0?sumCount/count:sumCount/count+1;
    CGFloat height = (lineCount+1)*padding+lineCount*width;
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;

}

-(void)setAddIcon:(UIImage *)addIcon
{
    _addIcon = addIcon;
    [self.collectionView reloadData];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.imagesArray count]+1;
}

#pragma mark 定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

#pragma mark 每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PicCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.cellImageView.image = self.addIcon;
    cell.cellDeleteButton.hidden = YES;
    //最后一项显示为添加照片
    if (indexPath.row<self.imagesArray.count) {
        cell.cellDeleteButton.tag = indexPath.row;
        cell.cellDeleteButton.hidden = NO;
        [cell.cellDeleteButton addTarget:self action:@selector(btnDeleteClicked:) forControlEvents:UIControlEventTouchUpInside];
        id obj = self.imagesArray[indexPath.row];
        if ([obj isKindOfClass:[UIImage class]]) {
            cell.cellImageView.image = obj;
        }else if ([obj isKindOfClass:[AlbumImages class]]) {
            AlbumImages * data = obj;
            [cell.cellImageView sd_setImageWithURL:[NSURL URLWithString:data.imageDetailPath] placeholderImage:[UIImage imageNamed:DEFAULT_BG_IMAGE]];
        }
    }else{
        cell.cellDeleteButton.tag = indexPath.row;
        cell.cellDeleteButton.hidden = YES;
    }
    return cell;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==self.imagesArray.count) {
        [self showAddImageItem];
    }else {
        [DDNavBrowserViewController showBrowserView:_weakVC PhotoView:self arrayImg:self.imagesArray currentPage:indexPath.row];
    }
}


-(void)showAddImageItem
{
    WeakSelf(self);
    if (self.limitCount-self.imagesArray.count) {
        if (_isDazzing) {
            CyActionSheet * actionSheet = [[CyActionSheet alloc]initCamera];
            [actionSheet showActionSheet:^(id obj) {
                [selfWeak toDetailOption:obj];
            }];
        }else {
            UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                          initWithTitle:nil
                                          delegate:self
                                          cancelButtonTitle:@"取消"
                                          destructiveButtonTitle:nil
                                          otherButtonTitles:@"使用照相", @"选择图片",nil];
            [actionSheet showInView:self];
        }
        
    }else {
        
        NSString *str = [NSString stringWithFormat:@"最多可以添加%ld张图片",(long)self.limitCount];
        [SVProgressHUD showInfoWithStatus:str];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return _flowLayout.headerReferenceSize;
    }else {
        return CGSizeMake(0, 0);
    }
}

-(void)btnDeleteClicked:(UIButton *)btn
{
    if (btn.tag<self.imagesArray.count) {
        [self removeObjWithIndex:btn.tag];
    }
}

#pragma mark 监听手势，并设置其允许移动cell和交换资源
- (void)handlelongGesture:(UILongPressGestureRecognizer *)longGesture {
    if (IOS_VERSION < 9.0) {
        //iOS9之前
        [self action:longGesture];
    }else{
        //iOS9及其以上版本
        [self iOS9_Action:longGesture];
    }
}

#pragma mark item拖动 iOS9后才有
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row>=self.imagesArray.count) {
        return NO;
    }
    //返回YES允许其item移动
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath {
    
    if (destinationIndexPath.row>=self.imagesArray.count) {
        NSIndexSet *set = [[NSIndexSet alloc] initWithIndex:0];
        [self.collectionView reloadSections:set];
        return;
    }
    [self refreashDataWithIndexPath:sourceIndexPath.item toIndexPath:destinationIndexPath.item];
}

-(void)refreashDataWithIndexPath:(NSInteger )sourceIndex toIndexPath:(NSInteger)destinationIndex
{
    [self.imagesArray exchangeObjectAtIndex:sourceIndex withObjectAtIndex:destinationIndex];
    [self.assetsArray exchangeObjectAtIndex:sourceIndex withObjectAtIndex:destinationIndex];
    [self.collectionView reloadData];
}

- (void)iOS9_Action:(UILongPressGestureRecognizer *)longGesture{
    switch (longGesture.state) {
        case UIGestureRecognizerStateBegan:{//手势开始
            //判断手势落点位置是否在Item上
            NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[longGesture locationInView:self.collectionView]];
            if (indexPath == nil||(indexPath.row>=self.imagesArray.count)) {
                break;
            }
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
            [self.collectionView bringSubviewToFront:cell];
            //在Item上则开始移动该Item的cell
            [self.collectionView beginInteractiveMovementForItemAtIndexPath:indexPath];
        }
            break;
        case UIGestureRecognizerStateChanged:{//手势改变
            //移动过程当中随时更新cell位置
            [self.collectionView updateInteractiveMovementTargetPosition:[longGesture locationInView:self.collectionView]];
        }
            break;
        case UIGestureRecognizerStateEnded:{//手势结束
            //移动结束后关闭cell移动
            [self.collectionView endInteractiveMovement];
        }
            break;
        default://手势其他状态
            [self.collectionView cancelInteractiveMovement];
            break;
    }
}

//========================================
#pragma mark item拖动 iOS9之前，需要截图等操作
static UIView *snapedView;              //截图快照
static NSIndexPath *currentIndexPath;   //当前路径
static NSIndexPath *oldIndexPath;       //旧路径

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)sourceIndexPath willMoveToIndexPath:(NSIndexPath *)destinationIndexPath
{
    if (destinationIndexPath.row>=self.imagesArray.count) {
        NSIndexSet *set = [[NSIndexSet alloc] initWithIndex:0];
        [self.collectionView reloadSections:set];
        return;
    }
    [self refreashDataWithIndexPath:sourceIndexPath.item toIndexPath:destinationIndexPath.item];
    
}

- (void)action:(UILongPressGestureRecognizer *)longGesture{
    switch (longGesture.state) {
        case UIGestureRecognizerStateBegan:{//手势开始
            //判断手势落点位置是否在Item上
            oldIndexPath = [self.collectionView indexPathForItemAtPoint:[longGesture locationInView:self.collectionView]];
            if (oldIndexPath == nil) {
                break;
            }
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:oldIndexPath];
            //使用系统截图功能，得到cell的截图视图
            snapedView = [cell snapshotViewAfterScreenUpdates:NO];
            snapedView.frame = cell.frame;
            [self.collectionView addSubview:snapedView];
            
            //截图后隐藏当前cell
            cell.hidden = YES;
            CGPoint currentPoint = [longGesture locationInView:self.collectionView];
            [UIView animateWithDuration:0.25 animations:^{
                snapedView.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
                snapedView.center = CGPointMake(currentPoint.x, currentPoint.y);
            }];
        }
            break;
        case UIGestureRecognizerStateChanged:{//手势改变
            //当前手指位置 - 截图视图位置移动
            CGPoint currentPoint = [longGesture locationInView:self.collectionView];
            snapedView.center = CGPointMake(currentPoint.x, currentPoint.y);
            
            //计算截图视图和哪个cell相交
            for (UICollectionViewCell *cell in [self.collectionView visibleCells]) {
                //当前隐藏的cell就不需要交换了，直接continue
                if ([self.collectionView indexPathForCell:cell] == oldIndexPath) {
                    continue;
                }
                //计算中心距
                CGFloat space = sqrtf(pow(snapedView.center.x - cell.center.x, 2) + powf(snapedView.center.y - cell.center.y, 2));
                //如果相交一半就移动
                if (space <= snapedView.bounds.size.width / 2) {
                    currentIndexPath = [self.collectionView indexPathForCell:cell];
                    //移动 会调用willMoveToIndexPath方法更新数据源
                    [self.collectionView moveItemAtIndexPath:oldIndexPath toIndexPath:currentIndexPath];
                    //设置移动后的起始indexPath
                    oldIndexPath = currentIndexPath;
                    break;
                }
            }
        }
            break;
        default:{//手势结束和其他状态
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:oldIndexPath];
            //结束动画过程中停止交互，防止出问题
            self.collectionView.userInteractionEnabled = NO;
            //给截图视图一个动画移动到隐藏cell的新位置
            [UIView animateWithDuration:0.25 animations:^{
                snapedView.center = cell.center;
                snapedView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
            } completion:^(BOOL finished) {
                //移除截图视图、显示隐藏的cell并开启交互
                [snapedView removeFromSuperview];
                cell.hidden = NO;
                self.collectionView.userInteractionEnabled = YES;
            }];
        }
            break;
    }
}

//========================================

#pragma mark -
#pragma mark 高亮点击动画放大缩小效果
- (BOOL)collectionView:(UICollectionView *)collectionView  shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row>=self.imagesArray.count) {
        [self showAddImageItem];
        return NO;
    }
    
    if (IOS_VERSION >= 9 ) {
        return YES;
    }else{
        return NO;
    }
}

static UIView *view;
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *selectedCell = [collectionView cellForItemAtIndexPath:indexPath];
    [collectionView bringSubviewToFront:selectedCell];
    [UIView animateWithDuration:0.28 animations:^{
        selectedCell.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
    }];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *selectedCell = [collectionView cellForItemAtIndexPath:indexPath];
    [UIView animateWithDuration:0.28 animations:^{
        selectedCell.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    }];
}

-(void)openAlbum
{
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:self.limitCount-self.imagesArray.count columnNumber:4 delegate:self pushPhotoPickerVc:YES];
    imagePickerVc.isSelectOriginalPhoto = YES;
    imagePickerVc.sortAscendingByModificationDate = YES;
    imagePickerVc.showSelectBtn = NO;
    imagePickerVc.isStatusBarDefault = YES;
    imagePickerVc.allowTakePicture = NO;
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.naviTitleColor = [UIColor blackColor];
    imagePickerVc.naviBgColor =[UIColor whiteColor];
    imagePickerVc.barItemTextColor = COLOR_APP_MAIN;
    [imagePickerVc setNavLeftBarButtonSettingBlock:^(UIButton *leftButton){
        [leftButton setImage:[UIImage imageNamed:NAV_RETURN_BACK] forState:UIControlStateNormal];
        [leftButton setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 20)];
    }];
    
    __weak typeof(self) weakSelf = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [weakSelf.weakVC presentViewController:imagePickerVc animated:YES completion:NULL];
    }];
//    [self.weakVC presentViewController:imagePickerVc animated:YES completion:nil];
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    [self.imagesArray addObjectsFromArray:photos];
    [self.assetsArray addObjectsFromArray:assets];
    [self.collectionView reloadData];
    if (self.resetFraCallBack) {
        [self resetFrame];
        self.resetFraCallBack();
    }
}

-(void)toDetailOption:(id)title
{
    WeakSelf(self);
    if ([title rangeOfString:@"拍摄"].location!=NSNotFound) {
        [selfWeak presentCameraSingle];
    }else{
        [selfWeak openAlbum];
    }
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self presentCameraSingle];
    }else if (buttonIndex == 1) {
        [self openAlbum];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        [self setUpSeletImage:image];
    }
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}


-(void)presentCameraSingle
{
    if ([PerMissonManager isOpenCamera]) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            if (_isDazzing) {
               
                
            }else {
                UIImagePickerController*  _picker = [[UIImagePickerController alloc] init] ;
                _picker.delegate = self;
                _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                _picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                _picker.allowsEditing = NO;
                
                [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
                __weak typeof(self) weakSelf = self;
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [weakSelf.weakVC presentViewController:_picker animated:YES completion:NULL];
                }];
            }
        }
    }
}

-(void)setUpSeletImage:(UIImage  *)image
{
    UIImage *yourImage=image;
    image = [image fixOrientation];
    yourImage=[UIImage imageWithData:UIImageJPEGRepresentation(image, 0.6)];
    [self.assetsArray addObject:yourImage];
    [self.imagesArray addObject:yourImage];
    [self.collectionView reloadData];
  
}

-(void)setUpVideo:(NSURL *)videoUrl dicResult:(NSDictionary *)dicResult
{
    if (_videoFinish) {
        _videoFinish (videoUrl,dicResult);
    }
  
}

-(void)appendVideFinish:(AppendVideoBlock)finish
{
    _videoFinish = finish;
}

-(void)removeObjWithIndex:(NSInteger)index
{
    if (index<self.imagesArray.count) {
        [self.imagesArray removeObjectAtIndex:index];
        [self.assetsArray removeObjectAtIndex:index];
        [self.collectionView reloadData];
        if (self.resetFraCallBack) {
            [self resetFrame];
            self.resetFraCallBack();
        }
    }
}
-(NSString *)getSafeValueWith:(id)value{
    if (value == nil || value == [NSNull null]){
        return @"";
    }else if ([value isKindOfClass:[NSNumber class]]){
        return  [value stringValue];
    }
    return [NSString stringWithFormat:@"%@",value];
}

//拉取图片信息
-(void)getAllImage
{
    //获取并发队列
    [self.imageDataDic removeAllObjects];
    [self.imagePathDic removeAllObjects];
    if (_assetsArray.count) {
        [self.weakVC showHint:@"正在获取图片信息"];
        __weak typeof(self) weakSelf = self;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_async(group, queue, ^{
            dispatch_apply(_assetsArray.count, queue, ^(size_t index) {
                id obj = self.assetsArray[index];
                if ([obj isKindOfClass:[PHAsset class]]) {
                    dispatch_group_enter(group);
                    PHAsset *asset = obj;
                    PHImageRequestOptions* options = [[PHImageRequestOptions alloc] init];
                    options.synchronous = YES;
                    options.version = PHImageRequestOptionsVersionOriginal;
                    options.networkAccessAllowed = YES;
                    NSLog(@"获取----%ld",index);
                    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                        dispatch_group_leave(group);
                        if (imageData == nil) {
                            NSLog(@"失败了----%ld",index);
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.weakVC hideHud];
                                [SVProgressHUD showWithStatus:@"检测到您所选图片中有未能识别的图片，请检查后重新上传"];
                                [SVProgressHUD dismissWithDelay:1];
                            });
                            return ;
                        }
                        NSLog(@"获取成功----%ld",index);
                        UIImage *yourImage=[UIImage imageWithData:imageData];
                        yourImage = [yourImage fixOrientation];
                        [weakSelf.imageDataDic setValue:UIImageJPEGRepresentation(yourImage,1) forKey:[self getSafeValueWith:@(index)]];
                    }];
                }else if ([obj isKindOfClass:[UIImage class]]) {
                    [weakSelf.imageDataDic setValue:UIImageJPEGRepresentation(obj, 0.6) forKey:[self getSafeValueWith:@(index)]];
                }else if ([obj isKindOfClass:[AlbumImages class]]) {
                    AlbumImages * data = obj;
                    [weakSelf.imagePathDic setValue:data.imageValue forKey:[self getSafeValueWith:@(index)]];
                }
            });
        });
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            NSLog(@"开始上传——————————————————————————————————————————");
            [weakSelf uploadAllImage];
        });
    }else {
        [AppGeneral showMessage:@"请选择图片" andDealy:0.5];
    }
    
}


//上传图片
-(void)uploadAllImage{
    if (self.imageDataDic.allKeys.count) {
        [self.weakVC showHint:@"正在获取图片信息"];
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        __weak typeof(self) weakSelf = self;
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_async(group, queue, ^{
            dispatch_apply(_assetsArray.count, queue, ^(size_t index) {
                id data = [self.imageDataDic valueForKey:[self getSafeValueWith:@(index) ]];
                //nsdata 类型 图片
                if ([data isKindOfClass:[NSData class]]) {
                    NSLog(@"上传图片----%ld",index);
                    NSData *imageData = data;
                    UIImage *oriImg = [UIImage imageWithData:imageData];
                    UIImage *img = [UIImage imageWithData:UIImageJPEGRepresentation(oriImg, 0.8)];
                    UIImage *yourImage = [UIImage imageWithData:UIImageJPEGRepresentation(img, 0.6)];
                    NSData *imgData = UIImageJPEGRepresentation(yourImage, 0.26);
                    dispatch_group_enter(group);
                    NSMutableDictionary * dicImgType = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"2",@"image_type", nil];
                    if (_imgType.length) {
                        [dicImgType setObject:_imgType forKey:@"image_type"];
                    }
                    [[NetWorkConnect manager] postImageWith:imgData postDataWith:dicImgType withUrl:@"uploadreportimage" withFileName:@"file" withResult:^(NSInteger returnCode, id responseObject, NSError *error) {
                        NSDictionary * resultDic = responseObject;
                        ImgModel * model = [ImgModel modelObjectWithDictionary:responseObject];
                        if ( model.result == 1) {
                            NSString *value = resultDic[@"value"];
                            if(value){
                                NSLog(@"上传图片结果----%ld",index);
                                [self.imagePathDic setObject:value forKey:[self getSafeValueWith:@(index)]];
                            }
                        }else{
                            //访问失败
                            NSLog(@"上传图片结果失败----%ld",index);
                            NSString *msg = resultDic[@"msg"];
                            [AppGeneral showMessage:msg andDealy:1];
                        }
                        dispatch_group_leave(group);
                    }];
                }
            });
            dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                NSLog(@"处理结果——————————————————————————————————————————");

                [weakSelf detailUploadResult];
            });
        });
    }else {
        [self.weakVC hideHud];
        [self detailUploadResult];
    }
}

-(void)detailUploadResult
{
    NSString *  strImglist = @"";
    for (int i=0; i<self.assetsArray.count; i++) {
        NSString * path = self.imagePathDic[[self getSafeValueWith:@(i)]];
        if (path&&path.length) {
            strImglist = [NSString stringWithFormat:@"%@%@|",strImglist,path];
        }
    }
    if ([strImglist hasSuffix:@"|"]) {
        strImglist = [strImglist substringToIndex:strImglist.length-1];
    }
    if (self.clicked) {
        self.clicked(strImglist);
    }
}


@end
