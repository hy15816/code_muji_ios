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
    
    
    
    
    /*
    cellView = [[Cellview alloc] initWithFrame:CGRectMake(0, 40, self.contentView.frame.size.width, 40)];
    cellView.backgroundColor = [UIColor blackColor];
    [self.contentView addSubview:cellView];
    
    self.callBtns.hidden = YES;
    self.msgsBtn.hidden = YES;
    self.editBtn.hidden = YES;
     */
}


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //
        self.clipsToBounds = YES;
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 170, 20)];
        UIWindow *w = [[UIApplication sharedApplication].windows objectAtIndex:0];
        CGFloat f = w.frame.size.width;
        self.numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(f-150-20, 10, 150, 20)];
        self.numberLabel.textAlignment = NSTextAlignmentRight;
        self.numberLabel.font = [UIFont systemFontOfSize:16];
        //[self.numberLabel sizeToFit];
        
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.numberLabel];
            }
    
    
    
    return self;
}

#pragma mark-创建上下分割线
- (void)drawRect:(CGRect)rect
{
    for (int i =0; i<2; i++) {
        self.imgView = [[UIImageView alloc]initWithFrame:CGRectMake(10, -0.5+i*rect.size.height, self.contentView.frame.size.width, .5)];
        self.imgView.image = [UIImage imageNamed:@"grayBG"];
    }
    
    [self.contentView addSubview:self.imgView];
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
