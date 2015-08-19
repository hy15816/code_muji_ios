//
//  CallInView.m
//  TXBoxNew
//
//  Created by Naron on 15/8/19.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "CallInView.h"

@interface CallInView ()
{
    CGFloat width;
    CGFloat height;
    UIImageView *imgv;  //图片
    UILabel *name;      //名字
    UILabel *numberAndHome;//号码&归属地
    UIButton *listen;   //接听
    UIButton *hangUp;   //挂断
    
}
@end

@implementation CallInView
@synthesize hisHome,hisName,hisNumber;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)init{
    self = [super init];
    if (self) {
        //
        //width = self.frame.size.width;
        //height = self.frame.size.height;
        
    }
    return self;
}

-(void)drawRect:(CGRect)rect{
    
    //self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"calling_bg"]];
}

-(void)initViews{
    width = self.frame.size.width;
    height = self.frame.size.height;
    [self addLabel];
    [self addbutton];
    [self addImage];
    
    self.userInteractionEnabled  =YES;
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
    swipe.direction = UISwipeGestureRecognizerDirectionUp;// | UISwipeGestureRecognizerDirectionDown;
    [self addGestureRecognizer:swipe];
    
}

-(void)swipeAction:(UISwipeGestureRecognizer *)swipe{
    if ([self.delegate respondsToSelector:@selector(changedHeight)]) {
        [self.delegate changedHeight];
    }
    
}
//中间图片
-(void)addImage{
    
    imgv = [[UIImageView alloc] initWithFrame:CGRectMake(width/4, height/5, width/2, height/5)];
    imgv.image = [UIImage imageNamed:@"board"];
    [self addSubview:imgv];
}

//姓名，号码+归属地
-(void)addLabel{
    name = [[UILabel alloc] initWithFrame:CGRectMake(0, height/2+20, width, 20)];
    name.text = hisName;
    name.userInteractionEnabled = YES;
    name.textAlignment = NSTextAlignmentCenter;
    name.textColor = [UIColor whiteColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    tap.numberOfTapsRequired = 1;
    [name addGestureRecognizer:tap];
    
    numberAndHome = [[UILabel alloc] initWithFrame:CGRectMake(0, name.frame.origin.y+30, width, 20)];
    numberAndHome.text = [NSString stringWithFormat:@"%@%@",hisNumber,hisHome];
    numberAndHome.textAlignment = NSTextAlignmentCenter;
    numberAndHome.textColor = [UIColor whiteColor];
    [self addSubview:name];
    [self addSubview:numberAndHome];
}

-(void)tapAction:(UITapGestureRecognizer *)tap{
    if ([self.delegate respondsToSelector:@selector(changedHeight)]) {
        [self.delegate changedHeight];
    }
    
}

//接听 & 挂断
-(void)addbutton{
    
    listen = [UIButton buttonWithType:UIButtonTypeCustom];
    [listen setImage:[UIImage imageNamed:@"icon_voip_free_call"] forState:UIControlStateNormal];
    listen.frame = CGRectMake(50, height-150, width/5, width/5);
    listen.tag =1;
    [listen addTarget:self action:@selector(listenThisCall:) forControlEvents:UIControlEventTouchUpInside];
    
    hangUp = [UIButton buttonWithType:UIButtonTypeCustom];
    [hangUp setImage:[UIImage imageNamed:@"icon_voip_reject"] forState:UIControlStateNormal];
    hangUp.frame = CGRectMake(width-50-width/5, height-150, width/5, width/5);
    [hangUp addTarget:self action:@selector(hangUpThisCall:) forControlEvents:UIControlEventTouchUpInside];
    hangUp.tag = 2;
    
    [self addSubview:listen];
    [self addSubview:hangUp];
}
-(void)listenThisCall:(UIButton*)btn{
    if ([self.delegate respondsToSelector:@selector(answerOrHangUp:)]) {
        [self.delegate answerOrHangUp:btn];
    }
    
}
-(void)hangUpThisCall:(UIButton*)btn{
    if ([self.delegate respondsToSelector:@selector(answerOrHangUp:)]) {
        [self.delegate answerOrHangUp:btn];
    }
    
}

//hide listen
-(void)hideAnswer{
    [UIView animateWithDuration:.5 animations:^{
        listen.frame = CGRectMake(width/2-width/5/2, height-150, width/5, width/5);
        listen.transform = CGAffineTransformMakeRotation((120.0f * M_PI) / 180.0f);//顺时针旋转角度120
        //listen.transform = CGAffineTransformIdentity;//回到旋转之前的角度
        listen.alpha = 0;
        hangUp.frame = CGRectMake(width/2-width/5/2, height-150, width/5, width/5);
        
    }];
    
    
}

//change name origin
-(void)packUpView{
    
    [UIView animateWithDuration:.5 animations:^{
        if (self.frame.size.height== DEVICE_HEIGHT) {
            name.frame = CGRectMake(0, height/2+20, width, 20);
            
        }else{
            name.frame = CGRectMake(0, self.frame.size.height-10-20, width, 20);
            
        }
    }];
    
}



@end
