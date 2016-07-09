//
//  AllCurrentTableViewController.m
//  CurrentExchange
//
//  Created by SJ on 16/7/5.
//  Copyright © 2016年 SJ. All rights reserved.
//
#import "newViewController.h"
#import "AllCurrentTableViewController.h"
#import "AllCurrentCellTableViewCell.h"
#import "Define.h"

@interface AllCurrentTableViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>

@property(nonatomic,strong)NSMutableArray *allCurrentArray;
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *indexTitleArray;
@property(nonatomic,strong)NSDictionary *indexDic;

@end
static NSString *allCurrentCell = @"AllCurrentCell";

@implementation AllCurrentTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self createView];
}


-(void)createView{
    [self initData];
    [self createTableView];
    //[self createIndex];
}

#pragma mark 创建tableView
-(void)createTableView{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 20, kScreenWidth, kScreenHeight-20) style:UITableViewStyleGrouped];
    [_tableView registerClass:[AllCurrentCellTableViewCell class] forCellReuseIdentifier:allCurrentCell];
    _tableView.delegate  = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.tableFooterView = [UIView new];
    [self.view addSubview:_tableView];
    
}
#pragma mark 创建索引
/*
-(void)createIndex{
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}*/

#pragma mark 初始化数据
-(void)initData{
    NSString *dataPath = [[NSBundle mainBundle]pathForResource:@"test.plist" ofType:nil];
//    _allCurrentArray = [NSMutableArray arrayWithContentsOfFile:dataPath];
//    [_tableView reloadData];
    NSDictionary *d = [[NSDictionary alloc]initWithContentsOfFile:dataPath];
    _indexDic = d;
    //_allCurrentArray = [d objectForKey:@"#"];
    
    
    
    _indexTitleArray = [NSMutableArray array];
//    _indexTitleArray = [d allKeys];
   
    for (NSString *key in d.allKeys){
        [_indexTitleArray addObject:key];
        NSLog(@"%@",key);
    }
    
    
}

#pragma mark 调用API
NSString *httpU = @"http://apis.baidu.com/apistore/currencyservice/currency";
NSString *httpA = @"fromCurrency=CNY&toCurrency=USD&amount=100";

-(void)updateWithFromString:(NSString *)toString{
    NSString *path = [[NSBundle mainBundle]pathForResource:@"current.plist" ofType:nil];
    NSString *path2 = @"/Users/SJ/Desktop/CurrentExchange/CurrentExchange/current.plist";
    
    NSMutableArray *array = [NSMutableArray arrayWithContentsOfFile:path];
    NSString *fromString = [[array objectAtIndex:0] valueForKey:@"currentName"];
    NSString *amount = [[array objectAtIndex:0]valueForKey:@"currentExchange"];
    
    httpA = [NSString stringWithFormat:@"fromCurrency=%@&toCurrency=%@&amount=%@",fromString,toString,amount];
    [self request:httpU withHttpArg:httpA];
    
}

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
                                   
                                   
                                   //添加到plist
                                   NSString *path2 = @"/Users/SJ/Desktop/CurrentExchange/CurrentExchange/current.plist";
                                   NSString *path = [[NSBundle mainBundle]pathForResource:@"current.plist" ofType:nil];
                                   NSMutableArray *array = [NSMutableArray arrayWithContentsOfFile:path];
                                   
                                   NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                                   NSDictionary *data = [dic objectForKey:@"retData"];
                                   NSString *toName = [data objectForKey:@"toCurrency"];
                                   NSString *currency = [data objectForKey:@"convertedamount"];
                                   float currencyFloat = [currency floatValue];
                                   NSString *currencyString = [NSString stringWithFormat:@"%.2f",currencyFloat];
                                   
                                   for(int i = 0 ; i < array.count ; i ++){
                                       NSDictionary *d = [array objectAtIndex:i];
                                       NSString *plistCurrentName = [d objectForKey:@"currentName"];
                                       if([plistCurrentName isEqualToString:toName]){
                                           [[array objectAtIndex:i] setValue:currencyString forKey:@"currentExchange"];
                                       }
                                       
                                   }
                                   [array writeToFile:path atomically:YES];
                                   [array writeToFile:path2 atomically:YES];
                                   [self backMainView];
                                   
                               }
                               

                           }];
}


#pragma mark 实现scrollerView代理
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if(scrollView ==_tableView){
        NSLog(@"%f",scrollView.contentOffset.y);
        
        NSLog(@"%f",scrollView.frame.size.height);
        
        NSLog(@"%f",scrollView.contentSize.height);
        if(scrollView.contentOffset.y < - 120){
            [self backMainView];
        }
    }
}

#pragma mark 上拉跳转至主页面
-(void)backMainView{
    newViewController *firV = [[newViewController alloc]init];
    firV.view.backgroundColor = [UIColor whiteColor];
    [self presentViewController:firV animated:YES completion:^{
        NSLog(@"完成");
    }];
    
}

#pragma mark 实现tableView代理
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return  _indexTitleArray.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSString *key = [_indexTitleArray objectAtIndex:section];
    return  [[_indexDic objectForKey:key] count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AllCurrentCellTableViewCell  *cell = [tableView dequeueReusableCellWithIdentifier:allCurrentCell];
    if(cell == nil){
        cell = [[AllCurrentCellTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:allCurrentCell];
    }
    NSUInteger section = indexPath.section;
    NSString *key = [_indexTitleArray objectAtIndex:section];
    NSMutableArray *country = [_indexDic objectForKey:key];
    
    
    
    NSDictionary *item = [country objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.countryImgView setImage:[UIImage imageNamed:[item objectForKey:@"countryImg"]]];
    [cell.currentName setText:[item objectForKey:@"currentName"]];
    [cell.countryName setText:[item objectForKey:@"countryName"]];
    return  cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger section = indexPath.section;
    NSString *key = [_indexTitleArray objectAtIndex:section];
    NSMutableArray *country = [_indexDic objectForKey:key];
    NSDictionary *item = [country objectAtIndex:indexPath.row];
    
    NSString *path2 = @"/Users/SJ/Desktop/CurrentExchange/CurrentExchange/current.plist";
    NSString *path = [[NSBundle mainBundle]pathForResource:@"current.plist" ofType:nil];
    NSMutableArray *array = [NSMutableArray arrayWithContentsOfFile:path];
    NSLog(@"array:%@",array);
    
    int count = 0;
    NSString *itemName = [item objectForKey:@"currentName"];
    NSLog(@"itemName:%@",itemName);
    for(int i = 0 ; i < array.count ; i ++){
        NSDictionary *dic = [array objectAtIndex:i];
        NSString *dicName = [dic objectForKey:@"currentName"];
        NSLog(@"dicName:%@",dicName);
        if([itemName isEqualToString:dicName]){
            count++;
        }
    }
    NSLog(@"count:%d",count);
    if(count !=0){
        
        NSLog(@"存在");
        [self backMainView];
    
    }else{
        [array addObject:item];

        [array writeToFile:path atomically:YES];
        [array writeToFile:path2 atomically:YES];
        [self updateWithFromString:[item objectForKey:@"currentName"]];


       
//        [self backMainView];
    }
    
    
    NSLog(@"选择了%@",item);
   
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger section = indexPath.section;
    NSString *key = [_indexTitleArray objectAtIndex:section];
    NSMutableArray *country = [_indexDic objectForKey:key];
    NSDictionary *item = [country objectAtIndex:indexPath.row];
    NSLog(@"取消选择了%@",item);
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return _indexTitleArray[section];
}
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

//索引
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{

    return _indexTitleArray;
}
//点击右侧索引的时候调用
-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{

    
    return index;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
