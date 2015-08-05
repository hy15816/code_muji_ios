//
//  ContactsTableViewCell.m
//  TXBoxNew
//
//  Created by Naron on 15/7/27.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "ContactsTableViewCell.h"

@implementation ContactsTableViewCell

- (void)awakeFromNib {
    // Initialization code
}


#pragma mark-创建上下分割线
- (void)drawRect:(CGRect)rect
{
    
    for (int i =1; i<2; i++) {
        self.imgView = [[UIImageView alloc]initWithFrame:CGRectMake(15, i*kCellHeight+1, self.contentView.frame.size.width-15, .1)];
        //VCLog(@"h:%F",rect.size.height-1);
        //VCLog(@"w:%f",self.contentView.frame.size.width);
        //self.imgView.image = [UIImage imageNamed:@"test.png"];
        self.imgView.backgroundColor = [UIColor greenColor];
    }
    
    
    [self.contentView addSubview:self.imgView];
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
