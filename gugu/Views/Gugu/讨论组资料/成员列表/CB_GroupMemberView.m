//
//  CB_GroupMemberView.m
//  gugu
//
//  Created by Mike Chen on 2019/5/4.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_GroupMemberView.h"
#import "CB_DidiHeaderUserCell.h"

//#define imageItemWidth 70
//#define imageItemHeight 100
#define lineitemCount 5
static NSString *CellId = @"CB_DidiHeaderUserCell";

@interface CB_GroupMemberView ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong) UICollectionView *_collection;

@end

@implementation CB_GroupMemberView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self._collection];
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
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        //设置CollectionView的属性
        __collection = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
        __collection.backgroundColor = [UIColor clearColor];
        __collection.delegate = self;
        __collection.dataSource = self;
        
        [__collection registerNib:[UINib nibWithNibName:CellId bundle:nil] forCellWithReuseIdentifier:CellId];
        __collection.showsHorizontalScrollIndicator = NO;
        __collection.showsVerticalScrollIndicator = NO;
        __collection.scrollEnabled = NO;
        __collection.allowsSelection = YES;
    }
    return __collection;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self._dataSource.count+1;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CB_DidiHeaderUserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellId forIndexPath:indexPath];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:CellId owner:self options:nil] lastObject];
    }
    
    if (indexPath.row==self._dataSource.count) {
        cell.img_header.image = [UIImage imageNamed:@"people_add"];
    }else{
        CB_GroupModel *model = self._dataSource[indexPath.row];
        [cell.img_header sd_setImageWithURL:[NSURL URLWithString:model.HeadPhotoURL]];
        cell.lbl_name.text = model.UserName;
    }
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==self._dataSource.count) {
        if (self.block_invite) {
            self.block_invite();
        }
    }else{
        CB_GroupModel *model = self._dataSource[indexPath.row];
        if (self.block_clickUser) {
            self.block_clickUser(model);
        }
    }
}

-(void)getImageFromDict:(NSDictionary *)dict{
    
}

#pragma mark  定义每个UICollectionView的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat imageItemWidth =(SCREEN_WIDTH-20-(lineitemCount-1)*10)/lineitemCount;
    CGFloat imageItemHeight = imageItemWidth/7*10;
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


+(CGFloat)heightOfMemberCount:(NSInteger)totalCount{
    totalCount +=1;
    CGFloat height = 20;
    NSInteger lineCount = totalCount/lineitemCount;
    if (totalCount % lineitemCount !=0) {
        lineCount +=1;
    }
    
    CGFloat imageItemWidth =(SCREEN_WIDTH-20-(lineitemCount-1)*10)/lineitemCount;
    CGFloat imageItemHeight = imageItemWidth/7*10;
    
    return height +(lineCount-1)*10+lineCount *imageItemHeight;
}

@end
