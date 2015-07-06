//
//  CallingView.m
//  TXBoxNew
//
//  Created by Naron on 15/7/2.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "CallingView.h"

@interface CallingView ()


@end

@implementation CallingView

-(void)drawRect:(CGRect)rect{
    
    [self addTopView];
    [self addCallingView];
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"calling_bg"]];
}

-(void)addTopView{
    _topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 40)];
    _topView.userInteractionEnabled = YES;
    _topView.image = [UIImage imageNamed:@"calling_bg"];
    _topView.backgroundColor = [UIColor greenColor];
    
    UIButton *showTimesBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [showTimesBut setTitle:@"轻按此处返回 00:00" forState:UIControlStateNormal];
    showTimesBut.titleLabel.font = [UIFont systemFontOfSize:12];
    [showTimesBut setBackgroundColor:[UIColor clearColor]];
    [showTimesBut setFrame:CGRectMake(0, _topView.frame.size.height-16, DEVICE_WIDTH, 15)];
    [showTimesBut addTarget:self action:@selector(showTimesButClick:) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:showTimesBut];

    [self addSubview:_topView];
    
}

-(void)addCallingView{
    
    _imgv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    _imgv.backgroundColor = [UIColor greenColor];
    _imgv.image = [UIImage imageNamed:@"calling_bg"];
    _imgv.userInteractionEnabled = YES;
    
    UISwipeGestureRecognizer *sswipe =[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(sswipes:)];
    sswipe.direction = UISwipeGestureRecognizerDirectionUp;
    
    
    UIButton *cutbut = [UIButton buttonWithType:UIButtonTypeCustom];
    [cutbut setTitle:@"cut" forState:UIControlStateNormal];
    [cutbut setBackgroundColor:[UIColor clearColor]];
    cutbut.layer.borderWidth = .5;
    cutbut.layer.cornerRadius = 3;
    cutbut.layer.borderColor = [UIColor whiteColor].CGColor;
    [cutbut setFrame:CGRectMake(DEVICE_WIDTH/4, _imgv.frame.size.height-125, DEVICE_WIDTH/2, 35)];
    [cutbut addTarget:self action:@selector(cutButClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    
    
    UIButton *packUpbut = [UIButton buttonWithType:UIButtonTypeCustom];
    [packUpbut setTitle:@"packup" forState:UIControlStateNormal];
    [packUpbut setBackgroundColor:[UIColor clearColor]];
    packUpbut.layer.borderWidth = .5;
    packUpbut.layer.cornerRadius = 3;
    packUpbut.layer.borderColor = [UIColor whiteColor].CGColor;
    [packUpbut setFrame:CGRectMake(DEVICE_WIDTH/4, _imgv.frame.size.height-35, DEVICE_WIDTH/2, 35)];
    [packUpbut addTarget:self action:@selector(packUpButClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    
    
    
    [_imgv addGestureRecognizer:sswipe];
    [_imgv addSubview:cutbut];
    [_imgv addSubview:packUpbut];
    
    
    
    [self addSubview:_imgv];
    
    //[self changed];
}
-(void)sswipes:(UISwipeGestureRecognizer *)sp{
    
    [self.delegateCalling showTimesbuttonClick:nil];
    
}

-(void)showTimesButClick:(UIButton *)button{
    VCLog(@"height:%f",self.frame.size.height);
    if (self.frame.size.height>40) {
        [self.delegateCalling showTimesbuttonClick:button];
        [self.delegateCalling tabBarOrginHeight:DEVICE_HEIGHT-10];
    }else{
        [self.delegateCalling tabBarOrginHeight:DEVICE_HEIGHT];
    }
    
}

-(void)cutButClick:(UIButton *)button{
    
    [self.delegateCalling disMissCallingView];
    
    
}
-(void)packUpButClick:(UIButton *)button{

    [self.delegateCalling showTimesbuttonClick:button];
}

@end
