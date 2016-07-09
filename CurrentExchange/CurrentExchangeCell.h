//
//  CurrentExchangeCell.h
//  CurrentExchange
//
//  Created by SJ on 16/7/4.
//  Copyright © 2016年 SJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CurrentExchangeCell : UITableViewCell
@property(nonatomic,strong)NSString *text;

//货币名字
@property(nonatomic,weak)UILabel *currentName;
//国家图片
@property(nonatomic,weak)UIImageView *countryImgView;
//货币汇率
@property(nonatomic,weak)UILabel *currentExchange;

@property(nonatomic,weak)UITextField *textField;
//国家名字
@property(nonatomic,weak)UILabel *countryName;

@property(nonatomic,strong)UILabel *label;

@end
