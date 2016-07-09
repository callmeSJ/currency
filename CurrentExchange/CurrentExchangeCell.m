//
//  CurrentExchangeCell.m
//  CurrentExchange
//
//  Created by SJ on 16/7/4.
//  Copyright © 2016年 SJ. All rights reserved.
//

#import "CurrentExchangeCell.h"
#import "Define.h"
@interface CurrentExchangeCell()


@end
@implementation CurrentExchangeCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self){
        //国家图片
        UIImageView *countryImgView = [[UIImageView alloc]initWithFrame:CGRectMake(16, 16, 48, 48)];
        countryImgView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:countryImgView];
        self.countryImgView = countryImgView;
        
        //货币名字
        UILabel *currentName = [[UILabel alloc]initWithFrame:CGRectMake(80, 16, 60, 48)];
        currentName.font = [UIFont fontWithName:@"Arial" size:20.0f];
        [self.contentView addSubview:currentName];
        self.currentName = currentName;
        
        //货币汇率
        UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(150, 16, kScreenWidth - 160, 35)];
        textField.textAlignment = NSTextAlignmentRight;
        textField.font = [UIFont fontWithName:@"Arial" size:23.0];
        textField.textColor = [UIColor redColor];
        textField.keyboardType = UIKeyboardTypeNumberPad;
        //添加 完成
        textField.inputAccessoryView = [self addToolbar];
        [self.contentView addSubview:textField];
        self.textField =  textField;
        
        UILabel *currentExchange = [[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth - 150, 16, 140, 35)];
        currentExchange.textAlignment = NSTextAlignmentRight;
        currentExchange.font = [UIFont fontWithName:@"Arial" size:23.0f];
        currentExchange.textColor = [UIColor redColor];
        //[self.contentView addSubview:currentExchange];
        self.currentExchange = currentExchange;
        
        //国家名字
        UILabel *countryName = [[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth - 180, 54, 160, 20)];
        countryName.textColor = [UIColor grayColor];
        countryName.font = [UIFont fontWithName:@"Arial" size:15.0f];
        countryName.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:countryName];
        self.countryName = countryName;
        
    }
    return  self;
}
- (UIToolbar *)addToolbar
{
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 35)];
    toolbar.tintColor = [UIColor blueColor];
    toolbar.backgroundColor = [UIColor grayColor];

    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *bar = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(textFieldDone)];
    toolbar.items = @[space, bar];
    return toolbar;
}
-(void)textFieldDone{
    self.textField.textColor = [UIColor redColor];
    [self.textField setUserInteractionEnabled:NO];
    [self.textField resignFirstResponder];
}
/*
-(void)setText:(NSString *)text{
    //任何的重写Set方法，都要先把原来的Set功能给实现才能编写其他功能
    _text = text;
    //因为Cell的复用属性，所以所有的创建最好用懒加载的方式,而且要先把contentView上的视图全部移除，避免重复粘贴
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    if (!_label) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(18, 20, 100, 20)];
    }
    _label.text = _text;
    _label.textColor = [UIColor blackColor];
    
    //自定义的View都要添加在contentView上，不能直接添加在Cell上，不然会影响Cell的编辑状态
    [self.contentView addSubview:_label];
    
     UILabel *lable1 = [[UILabel alloc]initWithFrame:CGRectMake(200, 20, 100, 20)];
     lable1.text = @"11";
     lable1.textColor = [UIColor blackColor];
     [self.contentView addSubview:lable1];
     
     UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(120, 6, 48, 48)];
     imageView.image = [UIImage imageNamed:@"China.png"];
     [self.contentView addSubview:imageView];
     
    
    
}
*/


@end
