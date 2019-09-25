//
//  CB_TopUserListView.m
//  gugu
//
//  Created by Mike Chen on 2019/6/9.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_TopUserListView.h"

#import "CB_TopUserListCell.h"

#define imageItemWidth 50
#define imageItemHeight 50

static NSString *CellId = @"CB_TopUserListCell";

@interface CB_TopUserListView ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong) UICollectionView *_collection;

@property (nonatomic,strong) NSString *userId;

@end

@implementation CB_TopUserListView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self._collection];
        self.userId = [UserModel shareInstance].Guid;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(void)set_dataSource:(NSMutableArray *)_dataSource{
    __dataSource = _dataSource;
    
    [self._collection reloadData];
}

-(UICollectionView *)_collection{
    if (!__collection) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        //设置CollectionView的属性
        __collection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 10, SCREEN_WIDTH, imageItemHeight) collectionViewLayout:flowLayout];
        __collection.backgroundColor = [UIColor clearColor];
        __collection.delegate = self;
        __collection.dataSource = self;
        
        [__collection registerNib:[UINib nibWithNibName:CellId bundle:nil] forCellWithReuseIdentifier:CellId];
        __collection.showsHorizontalScrollIndicator = NO;
        __collection.allowsSelection = YES;
    }
    return __collection;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self._dataSource.count+1;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CB_TopUserListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellId forIndexPath:indexPath];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:CellId owner:self options:nil] lastObject];
    }
    
    if (indexPath.row == 0) {
        [cell.img_header sd_setImageWithURL:[NSURL URLWithString:[UserModel shareInstance].HeadPhotoURL]];
        if ([self.userId isEqualToString:[UserModel shareInstance].Guid]) {
            [cell.img_header addborderColor:COLOR_APP_MAIN borderWith:4 layerRadius:25];
        }else{
            [cell.img_header addborderColor:[UIColor clearColor] borderWith:4 layerRadius:25];
        }
    }else{
        CB_MessageModel *model = self._dataSource[indexPath.row-1];
        [cell.img_header sd_setImageWithURL:[NSURL URLWithString:model.SendPhotoUrlURL]];
        if ([self.userId isEqualToString:model.SendUserId]) {
            [cell.img_header addborderColor:COLOR_APP_MAIN borderWith:4 layerRadius:25];
        }else{
            [cell.img_header addborderColor:[UIColor clearColor] borderWith:4 layerRadius:25];
        }
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        if (self.block_clickuser) {
            self.block_clickuser(nil);
        }
        self.userId = [UserModel shareInstance].Guid;
    }else{
        CB_MessageModel *model = self._dataSource[indexPath.row-1];
        if (self.block_clickuser) {
            self.block_clickuser(model);
        }
        self.userId = model.SendUserId;
    }
    [self._collection reloadData];
}

#pragma mark  定义每个UICollectionView的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return  CGSizeMake(imageItemWidth,imageItemHeight);
}

#pragma mark  定义整个CollectionViewCell与整个View的间距
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);//（上、左、下、右）
}

#pragma mark  定义每个UICollectionView的横向间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

#pragma mark  定义每个UICollectionView的纵向间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}


@end
