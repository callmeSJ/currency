//
//  AllCurrentView.m
//  CurrentExchange
//
//  Created by SJ on 16/7/5.
//  Copyright © 2016年 SJ. All rights reserved.
//

#import "AllCurrentView.h"
#import "AllCurrentCellTableViewCell.h"
#import "Define.h"

@interface AllCurrentView()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)NSMutableArray *allCurrentArray;
@property(nonatomic,strong)UITableView *tableView;

@end
static NSString *allCurrentCell = @"AllCurrentCell";
@implementation AllCurrentView


-(void)createView{
    [self initData];
    [self createTableView];
}

#pragma mark 创建tableView
-(void)createTableView{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 20, kScreenWidth, kScreenHeight-20) style:UITableViewStylePlain];
    [_tableView registerClass:[AllCurrentCellTableViewCell class] forCellReuseIdentifier:allCurrentCell];
    _tableView.delegate  = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.tableFooterView = [UIView new];
    [self addSubview:_tableView];
    
}
#pragma mark 初始化数据
-(void)initData{
    NSString *dataPath = [[NSBundle mainBundle]pathForResource:@"AllCurrent.plist" ofType:nil];
    _allCurrentArray = [NSMutableArray arrayWithContentsOfFile:dataPath];
    [_tableView reloadData];
    
}

#pragma mark 实现tableView代理
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return  1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  _allCurrentArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AllCurrentCellTableViewCell  *cell = [tableView dequeueReusableCellWithIdentifier:allCurrentCell];
    if(cell == nil){
        cell = [[AllCurrentCellTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:allCurrentCell];
    }
    NSDictionary *item = [_allCurrentArray objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.countryImgView setImage:[UIImage imageNamed:[item objectForKey:@"countryImg"]]];
    [cell.currentName setText:[item objectForKey:@"currentName"]];
    [cell.countryName setText:[item objectForKey:@"countryName"]];
    return  cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"选择了%@",_allCurrentArray[indexPath.row]);
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"取消选择了%@",_allCurrentArray[indexPath.row]);
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
