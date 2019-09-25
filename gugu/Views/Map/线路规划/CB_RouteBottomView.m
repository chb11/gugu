//
//  CB_RouteBottomView.m
//  gugu
//
//  Created by Mike Chen on 2019/4/6.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_RouteBottomView.h"
#import "CB_RouteBottomCell.h"

static NSString *CellId = @"CB_RouteBottomCell";

@interface CB_RouteBottomView ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *view_content;
@property (nonatomic,strong) UICollectionView *_collection;
@property (weak, nonatomic) IBOutlet UIButton *btn_pianhao;
@property (weak, nonatomic) IBOutlet UIButton *btn_go;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrain_toRight;

@end

@implementation CB_RouteBottomView

-(void)awakeFromNib{
    [super awakeFromNib];
    self.backgroundColor = [UIColor whiteColor];
    [self.btn_pianhao addborderColor:[UIColor lightGrayColor] borderWith:0.5 layerRadius:self.btn_pianhao.height/2];
    [self.btn_go addlayerRadius:self.btn_go.height/2];
    [self.btn_go az_setGradientBackgroundWithColors:@[COLOR_MAIN_LEFT,COLOR_MAIN_RIGHT] locations:nil startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 0)];
    [self.view_content addSubview:self._collection];
    
}

- (IBAction)action_pianhao:(id)sender {
    if (self.block_click_pianhao) {
        self.block_click_pianhao();
    }
}

- (IBAction)action_go:(UIButton *)sender {
    if (self.block_click_go) {
        self.block_click_go();
    }
}

-(void)action_showPianHao:(BOOL)isShow{
    if (isShow) {
        self.btn_pianhao.hidden = NO;
        self.constrain_toRight.constant = 120;
    }else{
        self.btn_pianhao.hidden = YES;
        self.constrain_toRight.constant = 20;
    }
    
}

-(void)setCurrIndex:(NSInteger)currIndex{
    _currIndex = currIndex;
    
    [self._collection reloadData];
}

-(void)setRoutes:(NSArray *)routes{
    _routes = routes;
    [self._collection reloadData];
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    self._collection.frame = CGRectMake(0, 0, SCREEN_WIDTH, 90);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.routes.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CB_RouteBottomCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellId forIndexPath:indexPath];
    
    AMapNaviRoute *path = self.routes[indexPath.row];
    cell.lbl_way.text = path.routeLabels[0].content;
    cell.lbl_time.text = [AppGeneral hourStringWithSeconds:path.routeTime];
    if (path.routeLength>=1000) {
        cell.lbl_distance.text = [NSString stringWithFormat:@"%.2f公里",@(path.routeLength*0.001).floatValue];
    }else{
        cell.lbl_distance.text = [NSString stringWithFormat:@"%ld米",path.routeLength];
    }
    
    if (self.currIndex == indexPath.row) {
        cell.lbl_way.textColor = [UIColor colorWithHexString:@"1782D2"];
        cell.lbl_time.textColor = [UIColor colorWithHexString:@"1782D2"];
        cell.lbl_distance.textColor = [UIColor colorWithHexString:@"1782D2"];
    }else{
        cell.lbl_way.textColor = [UIColor colorWithHexString:@"363636"];
        cell.lbl_time.textColor = [UIColor colorWithHexString:@"363636"];
        cell.lbl_distance.textColor = [UIColor colorWithHexString:@"363636"];
    }
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    self.currIndex = indexPath.row;
    [self._collection reloadData];
    if (self.block_changeRoute) {
        self.block_changeRoute(self.currIndex);
    }
}

#pragma mark  定义每个UICollectionView的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat tiemWidth = (SCREEN_WIDTH-20-(self.routes.count-1)*10)/self.routes.count;
    return  CGSizeMake(tiemWidth,self._collection.height);
}


#pragma mark  定义整个CollectionViewCell与整个View的间距
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 10, 0, 10);//（上、左、下、右）
}

#pragma mark  定义每个UICollectionView的横向间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

#pragma mark  定义每个UICollectionView的纵向间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}


-(UICollectionView *)_collection{
    if (!__collection) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        //设置CollectionView的属性
        __collection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 90) collectionViewLayout:flowLayout];
        __collection.backgroundColor = [UIColor clearColor];
        __collection.delegate = self;
        __collection.dataSource = self;
        
        [__collection registerNib:[UINib nibWithNibName:CellId bundle:nil] forCellWithReuseIdentifier:CellId];
        __collection.showsHorizontalScrollIndicator = NO;
        __collection.allowsSelection = YES;
    }
    return __collection;
}

@end
