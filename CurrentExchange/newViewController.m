//
//  newViewController.m
//  CurrentExchange
//
//  Created by SJ on 16/7/7.
//  Copyright © 2016年 SJ. All rights reserved.
//

#import "newViewController.h"
#import "Define.h"
#import "CurrentExchangeCell.h"
#import "AllCurrentCellTableViewCell.h"
#import "AllCurrentView.h"
#import "AllCurrentTableViewController.h"
static NSString *CurrentCell = @"CurrentCell";

@interface newViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>
//数据数组
@property(nonatomic,strong)NSMutableArray *dataArray;
//tableview
@property(nonatomic,strong)UITableView *tableView;
//刷新控件
@property(nonatomic,strong)UIRefreshControl *refresh;
//Json数据
//@property(nonatomic,strong)NSData *JsonData;
//新的plist数组
@property(nonatomic,strong)NSMutableDictionary *PlistDic;
//current Plist的
@property(nonatomic,strong)NSMutableDictionary *currentPlistDic;
//api的dic
@property(nonatomic,strong)NSMutableDictionary *APIDic;
//API的数组
@property(nonatomic,strong)NSMutableArray *APIArray;
//是否选择
@property(nonatomic,strong)NSMutableDictionary *selectedIndexes;
//修改之前的值
@property(nonatomic,strong)NSString *previousValue;
//cell的indexPath数组
@property(nonatomic,strong)NSMutableArray *indexPathArray;
@property(nonatomic,strong)NSIndexPath *didPath;
@property(nonatomic,strong)UITableView *didTableView;

//上拉加载，释放增加Lable
@property(nonatomic,strong)UILabel *la;

@end

@implementation newViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initData];
    [self createView];
    [self createGesture];
    [self dragFresh];
    
    //[self request:httpUrl withHttpArg:httpArg];
    
    
    
}
-(void)dealloc{
      [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

#pragma mark 初始化data
-(void)initData{
    //fake data
    _dataArray = [NSMutableArray array];
    _indexPathArray = [NSMutableArray array];
    NSString *dataPath = [[NSBundle mainBundle]pathForResource:@"current.plist" ofType:nil];
    _dataArray = [NSMutableArray arrayWithContentsOfFile:dataPath];
    NSLog(@"datapath = %@",dataPath);
    
    
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
    
    //上拉加载lable
    _la = [[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth/2-50, kScreenHeight - 50, 100, 20)];
    _la.text = @"上拉加载";
    _la.textColor = [UIColor orangeColor];
    _la.font = [UIFont fontWithName:@"Arial" size:20];
    
    _la.hidden = YES;
    [self.view addSubview:_la];
    


    
}



#pragma mark 下拉刷新
-(void)dragFresh{
    _refresh = [[UIRefreshControl alloc]init];
    NSAttributedString *string = [[NSAttributedString alloc]initWithString:@"刷新"];
    _refresh.attributedTitle = string;
    [_refresh addTarget:self action:@selector(update) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refresh];
    
    _APIArray = [NSMutableArray array];
    
}
-(void)update{
    NSAttributedString *string = [[NSAttributedString alloc]initWithString:@"刷新中··"];
    self.refresh.attributedTitle = string;
    _PlistDic = [[NSMutableDictionary alloc]init];
    [self performSelector:@selector(addData) withObject:nil afterDelay:2];
    [self performSelectorOnMainThread:@selector(parseJson) withObject:nil waitUntilDone:YES];
    
    
}
-(void)parseJson{
    for(int k = 0 ; k < _dataArray.count;k++){
        
        NSDictionary *s = [_dataArray objectAtIndex:k];
        
        
        NSString *amountString1 = [s objectForKey:@"currentExchange"];
        NSString *fromCurrency = [s objectForKey:@"currentName"];
        for(int i = 0 ; i < _dataArray.count; i ++){
            NSDictionary *item = [_dataArray objectAtIndex:i];
            NSString *toCurrency = [item objectForKey:@"currentName"];
            httpAr = [NSString stringWithFormat:@"fromCurrency=%@&toCurrency=%@&amount=%f",fromCurrency,toCurrency,[amountString1 doubleValue]];
            [self request:httpUr withHttpArg:httpAr];
            
        }
    }

}
-(void)addData{
    [self.refresh endRefreshing];
    NSAttributedString *string = [[NSAttributedString alloc]initWithString:@"下拉刷新"];
    _refresh.attributedTitle = string;
    NSLog(@"添加新数据");
    [_tableView reloadData];
}

#pragma mark 调用API
NSString *httpUr = @"http://apis.baidu.com/apistore/currencyservice/currency";
NSString *httpAr = @"fromCurrency=CNY&toCurrency=USD&amount=100";

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
                                   
                                   
                                   NSString *filePath2 = @"/Users/SJ/Desktop/CurrentExchange/CurrentExchange/NowCurrent.plist";
                                   
                                   NSString *filePath = [[NSBundle mainBundle]pathForResource:@"NowCurrent.plist" ofType:nil];
                                   NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                                    _APIDic = [dic objectForKey:@"retData"];
                                  // NSLog(@"%@",_APIDic);
                                   [_APIArray addObject:_APIDic];
                                   
                                   if(_APIArray.count == _dataArray.count*_dataArray.count){
                                       int x = 0 ;
                                       for(int i = 0 ; i < _APIArray.count; i++){
                                           if([_APIArray[i] isKindOfClass:[NSDictionary class]])
                                           {
                                               x++;
                                           }
                                       }
                                       NSLog(@"x=%d",x);
                                      // NSLog(@"%@",_APIArray);
                                       if(x == _dataArray.count*_dataArray.count){
                                       [_APIArray writeToFile:filePath atomically:YES];
                                       [_APIArray writeToFile:filePath2 atomically:YES];
                                       NSLog(@"写进文件");
                                       NSLog(@"updata");
//                                           NSLog(@"%@",_indexPathArray);
//                                        [_indexPathArray removeAllObjects];
//                                           //
//                                           NSLog(@"zzz:%@",_indexPathArray);
                                       [self updataTableViewCellData];
                                       }else{
                                           /*
                                           UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"获取数据错误" preferredStyle:UIAlertControllerStyleAlert];
                                           [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                               
                                           }]];
                                           [self presentViewController:alert animated:YES completion:nil];
                                           */
                                           NSLog(@"读取失败");
                                       }
                                       
                                   }

                                       }
                               

                               
     
                           }];
}

#pragma mark 调用API后获取的数据，来更改tableview的数据源
-(void)updataTableViewCellData{
    NSString *path = [[NSBundle mainBundle]pathForResource:@"NowCurrent.plist" ofType:nil];
    NSMutableArray *nowCurrentArray = [NSMutableArray arrayWithContentsOfFile:path];
    
    NSString *filePath2 = @"/Users/SJ/Desktop/CurrentExchange/CurrentExchange/current.plist";
    
    NSString *filePath3 = [[NSBundle mainBundle]pathForResource:@"current.plist" ofType:nil];
    
    for(int i = 0 ; i<nowCurrentArray.count; i++){
        NSDictionary *dic = [nowCurrentArray objectAtIndex:i];
        NSString *name = [dic objectForKey:@"toCurrency"];
        NSString *amount = [dic objectForKey:@"convertedamount"];
        NSString *fromCurrency = [dic objectForKey:@"fromCurrency"];
        
        float amountFloat = [amount floatValue];
        NSString *amountString2 = [NSString stringWithFormat:@"%.2f",amountFloat];
        for (int j = 0; j<_dataArray.count; j++) {
            NSString *toCurrency = [[_dataArray objectAtIndex:j] objectForKey:@"currentName"];
            if([fromCurrency isEqualToString:[[_dataArray objectAtIndex:0] objectForKey:@"currentName" ]] && [toCurrency isEqualToString:name]){
                [[_dataArray objectAtIndex:j] setObject:amountString2 forKey:@"currentExchange"];
                
            }
        }
        
    }
    [_dataArray writeToFile:filePath2 atomically:YES];
    [_dataArray writeToFile:filePath3 atomically:YES];
    [_tableView reloadData];
    
}

#pragma mark 添加长按手势
-(void)createGesture{
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [self.tableView addGestureRecognizer:longPress];
}
//手势方法
-(void)longPressGesture:(UIBarButtonItem *)item{
    [_tableView setEditing:!_tableView.editing animated:YES];
}
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
                
                NSString *path = [[NSBundle mainBundle]pathForResource:@"current.plist" ofType:nil];
                NSString *Path2 = @"/Users/SJ/Desktop/CurrentExchange/CurrentExchange/current.plist";
                [_dataArray writeToFile:path atomically:YES];
                [_dataArray writeToFile:Path2 atomically:YES];
                
                
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
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIView *snapshot = [[UIImageView alloc]initWithImage:image];
//    UIView *snapshot = [inputView snapshotViewAfterScreenUpdates:YES];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    return  snapshot;
}



#pragma mark 修改除了点击的cell之外textfield的值方法
/*-(void)textFieldChanged:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    //取出plist
    NSString *path = [[NSBundle mainBundle]pathForResource:@"NowCurrent.plist" ofType:nil];
    NSMutableArray *array = [NSMutableArray arrayWithContentsOfFile:path];
    
    
    //修改textfield的值
    CurrentExchangeCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellCurrentName = cell.currentName.text;
    
    for (int i = 0 ; i < _indexPathArray.count; i++) {
        NSIndexPath *otherPath = [_indexPathArray objectAtIndex:i];
        
        for(int j = 0 ; j < array.count; j++){
            NSDictionary *dic = [array objectAtIndex:j];
            NSString *fromString = [dic objectForKey:@"fromCurrency"];
            NSString *toString = [dic objectForKey:@"toCurrency"];
            NSString *rate = [dic objectForKey:@"currency"];
        //修改
        if(otherPath != indexPath && [cellCurrentName isEqualToString:fromString]){
            CurrentExchangeCell *otherCell = [tableView cellForRowAtIndexPath:otherPath];
            if([otherCell.currentName.text isEqualToString:toString]){
                float rateFloat = [rate floatValue];
                NSString *value = cell.textField.text;
                float textFloat = [value floatValue];
                float otherFloat = textFloat * rateFloat;
                NSString *otherString = [NSString stringWithFormat:@"%.2f",otherFloat];
                [otherCell.textField setText:otherString];
            }
        }
        
        }
    }
}*/
//修改textfield的值
-(void)textFieldChanged:(id)sender{
    
    //取出plist
    NSString *path2 = [[NSBundle mainBundle]pathForResource:@"current.plist" ofType:nil];
    NSString *Path3 = @"/Users/SJ/Desktop/CurrentExchange/CurrentExchange/current.plist";

    NSString *path = [[NSBundle mainBundle]pathForResource:@"NowCurrent.plist" ofType:nil];
    NSMutableArray *array = [NSMutableArray arrayWithContentsOfFile:path];
    
    NSString *otherString;
    //修改textfield的值
    CurrentExchangeCell *cell = [_didTableView cellForRowAtIndexPath:_didPath];
    NSString *cellCurrentName = cell.currentName.text;
    
    NSLog(@"index:%lu",_indexPathArray.count);
    NSLog(@"array:%lu",_dataArray.count);
    NSLog(@"%@",_indexPathArray);
    NSLog(@"%@",_dataArray);
    for (int i = 0 ; i < _indexPathArray.count; i++) {
        NSIndexPath *otherPath = [_indexPathArray objectAtIndex:i];
        //current.plist的字典
        
        NSDictionary *d = [_dataArray objectAtIndex:i];
        NSString *currentName = [d objectForKey:@"currentName"];
        
        //修改dataArray中点击中该cell对应的currentExchange值
        if(currentName == cellCurrentName){
            [[_dataArray objectAtIndex:i] setValue:cell.textField.text forKey:@"currentExchange"];
        }
        
        
        
        for(int j = 0 ; j < array.count; j++){
            //NowCurrent.plist的字典
            NSDictionary *dic = [array objectAtIndex:j];
            NSString *fromString = [dic objectForKey:@"fromCurrency"];
            NSString *toString = [dic objectForKey:@"toCurrency"];
            NSString *rate = [dic objectForKey:@"currency"];
            //修改
            
            if(otherPath != _didPath && [cellCurrentName isEqualToString:fromString]){
                CurrentExchangeCell *otherCell = [_didTableView cellForRowAtIndexPath:otherPath];
                if([otherCell.currentName.text isEqualToString:toString]){
                    float rateFloat = [rate floatValue];
                    NSString *value = cell.textField.text;
                    float textFloat = [value floatValue];
                    float otherFloat = textFloat * rateFloat;
                    otherString = [NSString stringWithFormat:@"%.2f",otherFloat];
                    [otherCell.textField setText:otherString];
                    
                    //修改current.plist
                    
                    if([currentName isEqualToString:toString]){
                        [[_dataArray objectAtIndex:i] setValue:otherString forKey:@"currentExchange"];
                    
                    }
                
                }
            }
            
        }//for(j)
    }//for(i)
    NSLog(@"asd");
    
   // NSLog(@"dataArray:%@",_dataArray);
    [_dataArray writeToFile:path2 atomically:YES];
    [_dataArray writeToFile:Path3 atomically:YES];
    //[_tableView reloadData];
}

#pragma mark 实现scrollView代理
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(scrollView == _tableView){
        float height = scrollView.contentSize.height > _tableView.frame.size.height ?_tableView.frame.size.height : scrollView.contentSize.height;
        
        
        if ((height - scrollView.contentSize.height + scrollView.contentOffset.y) / height > 0.2) {
            
            // 调用上拉刷新方法
            NSLog(@"释放加载");
            
            
            _la.hidden = NO;
            _la.text = @"释放增加";
            
        }else if
            ((height - scrollView.contentSize.height + scrollView.contentOffset.y) / height > 0.15) {
            
            // 调用上拉刷新方法
            NSLog(@"上拉加载");
            
            
            _la.hidden = NO;
            _la.text = @"上拉加载";
            
        }
               /* if(scrollView.contentOffset.y > 0 && scrollView.contentOffset.y + scrollView.frame.size.height<scrollView.contentSize.height){
            NSLog(@"上拉加载");
            NSLog(@"%f",scrollView.contentOffset.y);
            
            NSLog(@"%f",scrollView.frame.size.height);
            
            NSLog(@"%f",scrollView.contentSize.height);

            _la2.hidden = YES;
            _la.hidden = NO;
        }
        if(scrollView.contentOffset.y > 0 && scrollView.contentOffset.y + scrollView.frame.size.height>scrollView.contentSize.height){
            NSLog(@"释放加载");
            NSLog(@"%f",scrollView.contentOffset.y);
            
            NSLog(@"%f",scrollView.frame.size.height);
            
            NSLog(@"%f",scrollView.contentSize.height);
            _la.hidden = YES;
            _la2.hidden = NO;
        }
        */
        
        
    }
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if(scrollView == _tableView){
        float height = scrollView.contentSize.height > _tableView.frame.size.height ?_tableView.frame.size.height : scrollView.contentSize.height;
        if ((height - scrollView.contentSize.height + scrollView.contentOffset.y) / height > 0.2) {
            
            _la.hidden = YES;
            //[self showsecondViewAnimition];
            [self secondView];
            
        }
        /*
        if (- scrollView.contentOffset.y / _tableView.frame.size.height > 0.2) {
            //[self dragFresh];
            // 调用下拉刷新方法
            
        }*/
    }

}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if(scrollView == _tableView){
        _la.hidden = YES;
        NSLog(@"last");
    }

}
//显示第二个页面的方法
-(void)secondView{
    AllCurrentTableViewController *secV = [[AllCurrentTableViewController alloc]init];
    secV.view.backgroundColor = [UIColor whiteColor];
    [self presentViewController:secV animated:YES completion:^{
        NSLog(@"new");
    }];
    
}
-(void)showsecondViewAnimition{
    NSLog(@"%f",self.tableView.center.x);
    NSLog(@"%f",self.tableView.center.y);
    CGPoint center = CGPointMake(-kScreenWidth/2, -(kScreenHeight-20)/2);
    NSLog(@"%f",center.x);

    NSLog(@"%f",center.y);

    
    [UIView animateWithDuration:2 animations:^{

        self.tableView.center = center;
    }];
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
    
    if([_indexPathArray containsObject:indexPath]){
        NSLog(@"已经存在");
    }else{
        [_indexPathArray addObject:indexPath];
    }
    
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
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:cell.textField];
    
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _didPath = indexPath;
    _didTableView = tableView;
    
    NSLog(@"选择了%@",_dataArray[indexPath.row]);
    CurrentExchangeCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell.textField setUserInteractionEnabled:YES];
    _previousValue = cell.textField.text;
    cell.textField.textColor = [UIColor cyanColor];
    NSString *currentName = cell.currentName.text;
    //点击textField以外的cell，焦点在textfield上
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
    [_indexPathArray removeObject:indexPath];
    NSString *path = [[NSBundle mainBundle]pathForResource:@"current.plist" ofType:nil];
    NSString *Path2 = @"/Users/SJ/Desktop/CurrentExchange/CurrentExchange/current.plist";
    [_dataArray writeToFile:path atomically:YES];
    [_dataArray writeToFile:Path2 atomically:YES];
    
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
    NSLog(@"%@",_dataArray);
    
    

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end