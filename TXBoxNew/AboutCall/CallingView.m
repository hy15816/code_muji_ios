//
//  CallingView.m
//  TXBoxNew
//
//  Created by Naron on 15/7/2.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "CallingView.h"

@interface CallingView ()

@property (strong,nonatomic) UIImageView *imgv;
@property (strong,nonatomic) UIView *topView;

@end

@implementation CallingView

-(void)drawRect:(CGRect)rect{
    
    //[self addCallingView];
    [self addTopView];
}

-(void)addTopView{
    
    
}

-(void)addCallingView{
    
    //_imgv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    //_imgv.image = [UIImage imageNamed:@"calling_bg"];
    
    _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 40)];
    _topView.backgroundColor = [UIColor redColor];
    
    UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
    [but setTitle:@"123" forState:UIControlStateNormal];
    [but setBackgroundColor:[UIColor clearColor]];
    but.layer.borderWidth = .5;
    but.layer.cornerRadius = 3;
    but.layer.borderColor = [UIColor whiteColor].CGColor;
    [but setFrame:CGRectMake(DEVICE_WIDTH/4, _topView.frame.size.height-25, DEVICE_WIDTH/2, 25)];
    [but addTarget:self action:@selector(butClick:) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:but];
    
    //[self addGestureRecognizer:tap];
    [self addSubview:_topView];
    [self addSubview:_imgv];
    
    [self changed];
}



-(void)butClick:(UIButton *)button{
    VCLog(@"click");
}

-(void)changed{
    if (self.alpha ==1) {
        [self.delegateCalling tabBarOrginHeight:DEVICE_HEIGHT-40];
    }
    if (self.alpha <1) {
        [self.delegateCalling tabBarOrginHeight:DEVICE_HEIGHT];
    }
}


@end
