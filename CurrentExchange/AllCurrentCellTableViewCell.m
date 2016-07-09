//
//  AllCurrentCellTableViewCell.m
//  CurrentExchange
//
//  Created by SJ on 16/7/5.
//  Copyright © 2016年 SJ. All rights reserved.
//

#import "AllCurrentCellTableViewCell.h"

@implementation AllCurrentCellTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        //国家照片
        UIImageView *countryImgView = [[UIImageView alloc]initWithFrame:CGRectMake(9, 9, 32, 32)];
        [self.contentView addSubview:countryImgView];
        self.countryImgView = countryImgView;
        
        //货币名字
        UILabel *currentName = [[UILabel alloc]initWithFrame:CGRectMake(45, 9, 50, 16)];
        currentName.font = [UIFont fontWithName:@"Arial" size:13.0f];
        [self.contentView addSubview:currentName];
        self.currentName = currentName;
        
        //国家名字
        UILabel *countryName = [[UILabel alloc]initWithFrame:CGRectMake(45, 30, 130, 16)];
        countryName.font = [UIFont fontWithName:@"Arial" size:13.0f];
        [self.contentView addSubview:countryName];
        self.countryName = countryName;
        
    }
    return self;
}

@end
