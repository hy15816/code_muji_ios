//
//  Cellview.m
//  TXBoxNew
//
//  Created by Naron on 15/8/27.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "Cellview.h"

@implementation Cellview

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    //
    if (self) {
        
        for (int i=0; i<3; i++) {
            UIButton *btn = [[UIButton alloc] init];
            btn.frame = CGRectMake((frame.size.width/3)*i, 0,(frame.size.width/3), 40);
            btn.tag = i;
            [btn setImage:[UIImage imageNamed:@"icon_edit"] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(buttonClickAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
        }
        
        
    }
    
    
    return self;
}

-(void)buttonClickAction:(UIButton *)btn{
    
    [self.delegate cellviewActions:btn];
    
}

@end
