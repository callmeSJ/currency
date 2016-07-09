//
//  ViewController.m
//  CurrentExchange
//
//  Created by SJ on 16/7/4.
//  Copyright © 2016年 SJ. All rights reserved.
//

#import "ViewController.h"
#import "Define.h"
#import "CurrentExchangeCell.h"
#import "AllCurrentCellTableViewCell.h"
#import "AllCurrentView.h"
static NSString *CurrentCell = @"CurrentCell";

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>
//数据数组
@property(nonatomic,strong)NSMutableArray *dataArray;
//tableview
@property(nonatomic,strong)UITableView *tableView;
//刷新控件
@property(nonatomic,strong)UIRefreshControl *refresh;
//Json数据
@property(nonatomic,strong)NSData *JsonData;
//新的plist数组
@property(nonatomic,strong)NSMutableDictionary *PlistDic;
//current Plist的
@property(nonatomic,strong)NSMutableDictionary *currentPlistDic;

//是否选择
@property(nonatomic,strong)NSMutableDictionary *selectedIndexes;
//修改之前的值
@property(nonatomic,strong)NSString *previousValue;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initData];
    [self createView];
    [self createGesture];
    [self dragFresh];
    
    //[self request:httpUrl withHttpArg:httpArg];
    
}

#pragma mark 初始化data
-(void)initData{
    //fake data
    _dataArray = [NSMutableArray array];
    /* _dataArray = @[@[@"CNY",@"China",@"100",@"人民币"],
     @[@"GBP",@"2",@"11.29",@"英镑"],
     @[@"USD",@"3",@"15.02",@"美元"],
     @[@"EUR",@"4",@"13.48",@"欧元"],
     @[@"CAD",@"5",@"19.36",@"加拿大币"]];*/
    
    
    //    _dataArray = [NSMutableArray array];
    //    for (int i = 0 ; i<5; i++) {
    //        [_dataArray addObject:[NSString stringWithFormat:@"table%d",i]];
    //    }
    //    //数据填充以后刷新tableView
    //    [_tableView reloadData];
    
    NSString *dataPath = [[NSBundle mainBundle]pathForResource:@"current.plist" ofType:nil];
    _dataArray = [NSMutableArray arrayWithContentsOfFile:dataPath];
    NSLog(@"datapath = %@",dataPath);
    
    
    [_tableView reloadData];
}

-(void)createView{
    //创建主视图
    [self createTableView];
    
    //全部国家的tableView
    //    AllCurrentView *allCurrentView = [[AllCurrentView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    //    [allCurrentView createView];
    //    [self.view addSubview:allCurrentView];
}



#pragma mark 创建视图
//创建tableview视图
-(void)createTableView{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 20, kScreenWidth,kScreenHeight-20) style:UITableViewStylePlain];
    [_tableView registerClass:[CurrentExchangeCell class] forCellReuseIdentifier:CurrentCell];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.tableFooterView = [UIView new];
    [self.view addSubview:_tableView];
}



#pragma mark 下拉刷新
-(void)dragFresh{
    _refresh = [[UIRefreshControl alloc]init];
    NSAttributedString *string = [[NSAttributedString alloc]initWithString:@"刷新"];
    _refresh.attributedTitle = string;
    [_refresh addTarget:self action:@selector(update) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refresh];
    
    
    
}
-(void)update{
    NSAttributedString *string = [[NSAttributedString alloc]initWithString:@"刷新中··"];
    self.refresh.attributedTitle = string;
    [self performSelector:@selector(addData) withObject:nil afterDelay:1];
    _PlistDic = [[NSMutableDictionary alloc]init];
    
    //解析json数据
    NSDictionary *s = [_dataArray objectAtIndex:0];
    NSString *amountString1 = [s objectForKey:@"currentExchange"];
    NSString *fromCurrency = [s objectForKey:@"currentName"];
    for(int i = 0 ; i < _dataArray.count; i ++){
        NSDictionary *item = [_dataArray objectAtIndex:i];
        NSString *toCurrency = [item objectForKey:@"currentName"];
        httpArg = [NSString stringWithFormat:@"fromCurrency=%@&toCurrency=%@&amount=%f",fromCurrency,toCurrency,[amountString1 doubleValue]];
        [self request:httpUrl withHttpArg:httpArg];
        
//        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:_JsonData options:NSJSONReadingMutableContainers error:nil];
//        NSString *amount = [dic objectForKey:@"convertedamount"];
//        float amountFloat = [amount floatValue];
//        NSString *amountString2 = [NSString stringWithFormat:@"%.2f",amountFloat];
//        [_newPlistArray addObject:amountString2];
//        
//        NSLog(@"");
    }
    
    
    //更改plist
   

}
-(void)addData{
    [self.refresh endRefreshing];
    NSAttributedString *string = [[NSAttributedString alloc]initWithString:@"下拉刷新"];
    _refresh.attributedTitle = string;
    NSLog(@"添加新数据");
    [_tableView reloadData];
}

#pragma mark 调用API
NSString *httpUrl = @"http://apis.baidu.com/apistore/currencyservice/currency";
NSString *httpArg = @"fromCurrency=CNY&toCurrency=USD&amount=100";

-(void)request: (NSString*)httpUrl withHttpArg: (NSString*)HttpArg  {
    NSString *urlStr = [[NSString alloc]initWithFormat: @"%@?%@", httpUrl, HttpArg];
    NSURL *url = [NSURL URLWithString: urlStr];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 10];
    [request setHTTPMethod: @"GET"];
    [request addValue: @"ed705983f9f07063552e8251c938425e" forHTTPHeaderField: @"apikey"];
    [NSURLConnection sendAsynchronousRequest: request
                                       queue: [NSOperationQueue mainQueue]
                           completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error){
                               if (error) {
                                   NSLog(@"Httperror: %@%ld", error.localizedDescription, error.code);
                               } else {
                                                                      NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
                                   NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   NSLog(@"HttpResponseCode:%ld", responseCode);
                                   NSLog(@"HttpResponseBody %@",responseString);
                                   
                                   
                                   //添加数据到plistDic
                                   NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                                   NSDictionary *dic1 = [dic objectForKey:@"retData"];
                                   NSString *name = [dic1 objectForKey:@"toCurrency"];
                                   NSString *amount = [dic1 objectForKey:@"convertedamount"];
                                   float amountFloat = [amount floatValue];
                                   NSString *amountString2 = [NSString stringWithFormat:@"%.2f",amountFloat];
                                   [_PlistDic setObject:amountString2 forKey:name];
                                   //plistDic是存放转换后钱
                                   if(_PlistDic.count == _dataArray.count){
                                       NSLog(@"执行");
                                       //修改test.plist,使用沙盒的话之前还需要创建plist
                                      /*
                                       NSArray *sandboxPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                                       NSString *filePath = [[sandboxPath objectAtIndex:0]stringByAppendingPathComponent:@"current.plist"];
                                       */
                                       NSString *filePath2 = @"/Users/SJ/Desktop/CurrentExchange/CurrentExchange/current.plist";
                                       
                                       NSString *filePath = [[NSBundle mainBundle]pathForResource:@"current.plist" ofType:nil];
                                       
                                       NSLog(@"path = %@",filePath);
                                       NSLog(@"%@",_PlistDic);
                                       NSArray *array = [_PlistDic allKeys];
                                       for(int i = 0 ; i < _PlistDic.count ; i++){
                                           NSString *name = array[i];
                                           NSLog(@"name:%@",name);
                                           NSString *value = [_PlistDic objectForKey:name];
                                           NSLog(@"%@",value);
                                           
                                           for(int j = 0 ; j < _dataArray.count ; j++){
                                               _currentPlistDic = [_dataArray objectAtIndex:j];
                                               NSString *currentName = [_currentPlistDic objectForKey:@"currentName"];
                                               NSLog(@"currentName:%@",currentName);
                                               
                                               if([currentName isEqualToString:name]){
                                                   [[_dataArray objectAtIndex:j]setObject:value forKey:@"currentExchange" ];
                                                   NSLog(@"filearray修改成功");
                                               }
                                           }
                                           [_dataArray writeToFile:filePath atomically:YES];
                                           [_dataArray writeToFile:filePath2 atomically:YES];
                                           NSLog(@"写进文件");
                                       }
                                       NSLog(@"%@",_dataArray);
                                       [_tableView reloadData];
                                   }
                               }
                           }];
}
#pragma mark 添加长按手势
-(void)createGesture{
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [self.tableView addGestureRecognizer:longPress];
}
//手势方法
-(void)longPressGestureRecognized:(id)sender{
    UILongPressGestureRecognizer*longPress = (UILongPressGestureRecognizer *)sender;
    UIGestureRecognizerState state = longPress.state;
    
    CGPoint location = [longPress locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    static UIView *snapshot = nil;
    static NSIndexPath *sourceIndexPath = nil;
    
    switch (state) {
        case UIGestureRecognizerStateBegan:{
            if(indexPath){
                sourceIndexPath = indexPath;
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                snapshot = [self customSnapshotFromView:cell];
                
                __block CGPoint center = cell.center;
                snapshot.center = center;
                snapshot.alpha = 0;
                [self.tableView addSubview:snapshot];
                [UIView animateWithDuration:0.25 animations:^{
                    center.y = location.y;
                    snapshot.center = center;
                    snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                    snapshot.alpha = 0.98;
                    cell.backgroundColor = [UIColor whiteColor];
                } completion:nil];
           
            }
            break;
        }
        case UIGestureRecognizerStateChanged:{
            CGPoint center = snapshot.center;
            center.y = location.y;
            snapshot.center = center;
            
            if(indexPath && ![indexPath isEqual:sourceIndexPath]){
                [self.dataArray exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                [self.tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
                sourceIndexPath = indexPath;
            }
            break;
        }
        default:{
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:sourceIndexPath];
            [UIView animateWithDuration:0.25 animations:^{
                snapshot.center = cell.center;
                snapshot.transform = CGAffineTransformIdentity;
                snapshot.alpha = 0;
                cell.backgroundColor = [UIColor whiteColor];
            } completion:^(BOOL finished){
                [snapshot removeFromSuperview];
                snapshot = nil;
            }];
            sourceIndexPath = nil;
            break;
        }
    }
}

-(UIView *)customSnapshotFromView:(UIView *)inputView{
    UIView *snapshot = [inputView snapshotViewAfterScreenUpdates:YES];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    return  snapshot;
}



#pragma mark 实现tableView代理方法
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  80;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CurrentExchangeCell *cell = [tableView dequeueReusableCellWithIdentifier:CurrentCell];
    //cell.text = _dataArray[indexPath.row];
    
    if(cell == nil){
        cell = [[CurrentExchangeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CurrentCell];
        
    }
    
    NSDictionary *item = [_dataArray objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.textField setText:[item objectForKey:@"currentExchange"]];
    [cell.countryName setText:[item objectForKey:@"countryName"]];
    [cell.countryImgView setImage:[UIImage imageNamed:[item objectForKey:@"countryImg"]]];
    [cell.currentName setText:[item objectForKey:@"currentName"]];
    [cell.textField setUserInteractionEnabled:NO];
    
    
    /*
    cell.currentExchange.text = _dataArray[indexPath.row];
    cell.countryName.text = _dataArray[indexPath.row];
    cell.countryImgView.image = [UIImage imageNamed:@"China.png"];
    cell.currentName.text = _dataArray[indexPath.row];*/
    return cell;

}
//判断是否选择
- (BOOL)cellIsSelected:(NSIndexPath *)indexPath {
    // Return whether the cell at the specified index path is selected or not
    NSNumber *selectedIndex = [_selectedIndexes objectForKey:indexPath];
    return selectedIndex == nil ? FALSE : [selectedIndex boolValue];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"选择了%@",_dataArray[indexPath.row]);
    CurrentExchangeCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell.textField setUserInteractionEnabled:YES];
    //点击textField以外的cell，焦点在textfield上
    [cell.textField setNeedsFocusUpdate];
    _previousValue = cell.textField.text;
    cell.textField.textColor = [UIColor cyanColor];
    NSString *currentName = cell.currentName.text;
    [cell.textField becomeFirstResponder];
    
    
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"取消选择了%@",_dataArray[indexPath.row]);
    CurrentExchangeCell *cell = [tableView cellForRowAtIndexPath:indexPath];
if(cell == nil){
        cell = [[CurrentExchangeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CurrentCell];
        
    }
    if(![cell.textField.text isEqualToString:_previousValue]){
        NSLog(@"%@",cell.textField.text);
    }
    [cell.textField setUserInteractionEnabled:NO];
    cell.textField.textColor = [UIColor redColor];
    NSDictionary *item = [_dataArray objectAtIndex:indexPath.row];
    NSString *currentName = [item objectForKey:@"currentName"];
    [cell.textField resignFirstResponder];

}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    [_dataArray removeObjectAtIndex:indexPath.row];
    
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return  YES;
}
-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    NSInteger fromRow = [sourceIndexPath row];
    NSInteger toRow = [destinationIndexPath row];
    id obj = [_dataArray objectAtIndex:fromRow];
    [_dataArray removeObjectAtIndex:fromRow];
    [_dataArray insertObject:obj atIndex:toRow];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
