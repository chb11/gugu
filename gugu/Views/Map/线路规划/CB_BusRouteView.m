//
//  CB_BusRouteView.m
//  gugu
//
//  Created by Mike Chen on 2019/6/10.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_BusRouteView.h"
#import "CB_BusRouteCel.h"

static NSString *cellId = @"CB_BusRouteCel";

@interface CB_BusRouteView()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView *_tableview;
@property (nonatomic,strong) UIView *hlds_view_empty;

@end

@implementation CB_BusRouteView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self._tableview];
    }
    return self;
}

-(void)setDataSource:(NSMutableArray *)dataSource{
    _dataSource = dataSource;
    [self._tableview reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CB_BusRouteCel *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    if (!cell) {
        cellId = [[[NSBundle mainBundle] loadNibNamed:cellId owner:self options:nil] lastObject];
    }
    AMapTransit *transit = self.dataSource[indexPath.row];
    
    cell.lbl_time.text = [NSString stringWithFormat:@"%ld分",transit.duration/60];
    if (transit.walkingDistance>1000) {
        cell.lbl_walkDistance.text = [NSString stringWithFormat:@"%.1f公里",transit.walkingDistance*0.001];
    }else{
        cell.lbl_walkDistance.text = [NSString stringWithFormat:@"%ld米",transit.walkingDistance];
    }
    
    NSString *segment = @"";
    NSInteger stateCount = 0;
    NSString *startState = @"";
    for (int i = 0; i<transit.segments.count; i++) {
        AMapSegment *segm = transit.segments[i];
        if (segm.buslines.count>0) {
            AMapBusLine *busLine = segm.buslines[0];
            stateCount += busLine.viaBusStops.count;
            NSString *buslineName = [[busLine.name componentsSeparatedByString:@"("] firstObject];
            if (i == 0) {
                segment =buslineName;
                startState = busLine.departureStop.name;
            }else{
                segment =[segment stringByAppendingString:[NSString stringWithFormat:@">%@",buslineName]];
            }
        }
    }
    cell.lbl_segment.text = segment;
    cell.lbl_naviinfo.text = [NSString stringWithFormat:@"%ld站    %.1f元    %@上车",stateCount,transit.cost,startState];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    AMapTransit *transit = self.dataSource[indexPath.row];
    if (self.block_choosebusLine) {
        self.block_choosebusLine(indexPath.row);
    }
}

-(UITableView *)_tableview{
    if (!__tableview) {
        __tableview = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        [__tableview registerNib:[UINib nibWithNibName:cellId bundle:nil] forCellReuseIdentifier:cellId];
        __tableview.tableFooterView = [[UIView alloc] init];
        __tableview.backgroundColor = [UIColor clearColor];
        __tableview.rowHeight = 80;
        __tableview.delegate = self;
        __tableview.dataSource = self;
        __tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        __tableview.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
//        __tableview.contentInset = UIEdgeInsetsMake(0, 0, BottomPadding, 0);
    }
    return __tableview;
}

-(UIView *)hlds_view_empty{
    if (!_hlds_view_empty) {
        _hlds_view_empty = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 300)];
        _hlds_view_empty.backgroundColor = [UIColor clearColor];
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake((_hlds_view_empty.width-100)/2, (_hlds_view_empty.height-100)/2-20, 100, 100)];
        img.image = [UIImage imageNamed:@"empty.png"];
        img.contentMode = UIViewContentModeScaleAspectFit;
        [_hlds_view_empty addSubview:img];
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake((_hlds_view_empty.width-100)/2, img.mj_y+img.height+10, 100, 30)];
        lbl.textColor = [UIColor colorWithHexString:@"bfbfbf"];
        lbl.text = @"暂无内容";
        lbl.textAlignment = NSTextAlignmentCenter;
        [_hlds_view_empty addSubview:lbl];
    }
    return _hlds_view_empty;
}

@end
