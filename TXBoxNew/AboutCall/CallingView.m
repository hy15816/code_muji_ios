//
//  CallingView.m
//  TXBoxNew
//
//  Created by Naron on 15/7/2.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "CallingView.h"
#import <ImageIO/ImageIO.h>
#import "TXCallAction.h"
#import "TXSqliteOperate.h"
#import "NSString+helper.h"

@interface CallingView ()
{
    NSString *showTopViewTimes;
    UIButton *showTimesBut;
    
    UIButton *button;
    
    CGImageSourceRef gif; // 保存gif动画
    NSDictionary *gifProperties; // 保存gif动画属性
    size_t index; // gif动画播放开始的帧序号
    size_t count; // gif动画的总帧数
    NSTimer *gifTimer; // 播放gif动画所使用的timer
    
    NSTimer *timeLengthTimer;
    int timesCount;
    BOOL isLighter;
    
    TXCallAction *callAction;
    
}
@property (strong, nonatomic) UIView *gifView;
@property (strong,nonatomic) NSString *hisHome;     //归属地
@property (strong,nonatomic) NSString *isCall;      //正在拨号
@end

@implementation CallingView
@synthesize hisNames,hisNumbers;

-(void)drawRect:(CGRect)rect{
    
    [self addTopView];
    [self addCallingView:rect];
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"calling_bg"]];
    
    showTopViewTimes = @"";
    _hisHome = @"";
    _isCall = @"正在拨号...";
    timesCount = 0;
    callAction = [[TXCallAction alloc] init];
}

-(void)addTopView{
    _topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 45)];
    _topView.userInteractionEnabled = YES;
    _topView.image = [UIImage imageNamed:@"calling_bg"];
    //_topView.backgroundColor = [UIColor greenColor];
    
    showTimesBut = [UIButton buttonWithType:UIButtonTypeCustom];
    showTimesBut.titleLabel.font = [UIFont systemFontOfSize:12];
    [showTimesBut setBackgroundColor:[UIColor clearColor]];
    [showTimesBut setFrame:CGRectMake(0, _topView.frame.size.height-16, self.frame.size.width, 15)];
    [showTimesBut addTarget:self action:@selector(showTimesButClick:) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:showTimesBut];

    [self addSubview:_topView];
    
}

-(void)addCallingView:(CGRect)rect{
    
    _imgv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    //_imgv.backgroundColor = [UIColor greenColor];
    _imgv.image = [UIImage imageNamed:@"calling_bg"];
    _imgv.userInteractionEnabled = YES;
    
    UISwipeGestureRecognizer *sswipe =[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(sswipes:)];
    sswipe.direction = UISwipeGestureRecognizerDirectionUp;
    //姓名，号码。。。
    for (int i=0; i<3; i++) {
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        button.tag = 3000+i;
        if (i == 0) {
            [button setTitle:hisNames forState:UIControlStateNormal];
        }
        if (i == 1) {
            //获取归属地
            TXSqliteOperate *txsqlite = [[TXSqliteOperate alloc] init];
            if (hisNumbers.length >=7) {
                _hisHome = [txsqlite searchAreaWithHisNumber:[[hisNumbers purifyString] substringToIndex:7]];
            }else{_hisHome = @"";}
            
            [button setTitle:[NSString stringWithFormat:@"%@ %@",hisNumbers,_hisHome] forState:UIControlStateNormal];

        }
        if (i == 2) {
            [button setTitle:@"正在拨号..." forState:UIControlStateNormal];
        }
        [button setBackgroundColor:[UIColor clearColor]];
        [button setFrame:CGRectMake(0, _imgv.frame.size.height/2+i*35, rect.size.width, 35)];
        [_imgv addSubview:button];
    }
    
    //挂断
    UIButton *cutbut = [UIButton buttonWithType:UIButtonTypeCustom];
    [cutbut setImage:[UIImage imageNamed:@"icon_voip_reject"] forState:UIControlStateNormal];
    [cutbut setBackgroundColor:[UIColor clearColor]];
    [cutbut setFrame:CGRectMake(DEVICE_WIDTH/2-45/2, _imgv.frame.size.height-125, 45, 45)];
    [cutbut addTarget:self action:@selector(cutButClick:) forControlEvents:UIControlEventTouchUpInside];
    
    //收起
    UIButton *packUpbut = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [packUpbut setBackgroundColor:[UIColor clearColor]];
    [packUpbut setFrame:CGRectMake(DEVICE_WIDTH-35, _imgv.frame.size.height-35, 20, 20)];
    [packUpbut addTarget:self action:@selector(packUpButClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [_imgv addGestureRecognizer:sswipe];
    [_imgv addSubview:cutbut];
    [_imgv addSubview:packUpbut];
    
    //加载gif
    self.gifView =[[UIView alloc] initWithFrame:CGRectMake(rect.size.width/2-120/2-15, rect.size.height/2-130, 176, 120)];
    [self initWithGifFrame:CGRectMake(0, 0, 0, 0) filePath:[[NSBundle mainBundle] pathForResource:@"board" ofType:@"gif"]];
    
    [_imgv addSubview:self.gifView];
    [self addSubview:_imgv];
    
}

#pragma mark --time length
-(void)startTimeLengthTimer{
    timeLengthTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timesChangedCount:) userInfo:nil repeats:YES];
    [timeLengthTimer fire];
    
    //==接通电话
    //我的号码
    NSString *myPhoneNumber = [NSString stringWithFormat:@"%@",@"my phone number"];
    [callAction callOutFromNumber:myPhoneNumber HisNumber:hisNumbers];
    
    
}
-(void)timesChangedCount:(NSTimer *)timer{
    timesCount ++;
    
    NSString *second;
    NSString *min;
    NSString *hours;
    
    //小于10秒
    //00:0s
    hours = @"";
    if (timesCount <10) {
        min = [NSString stringWithFormat:@"00"];
    }
    
    if (10<=timesCount && timesCount<60) {
        
        min = [NSString stringWithFormat:@"0%d",timesCount/60];
        
    }
    // 1min <= times < 1hours
    if (60<=timesCount && timesCount<3600) {
        
        if (timesCount/60<10) {
            min = [NSString stringWithFormat:@"0%d",timesCount/60];
        }else
        {
            min = [NSString stringWithFormat:@"%d",timesCount/60];
        }
        
        
    }
    // 1hours <=times < 10 hours
    if (timesCount>=3600 && timesCount<36000) {
        hours = [NSString stringWithFormat:@"0%d:",timesCount/3600];
        if ((timesCount/60)%60<10) {
            min = [NSString stringWithFormat:@"0%d",(timesCount/60)%60];
        }else
        {
            min = [NSString stringWithFormat:@"%d",(timesCount/60)%60];
        }
        
        
        
    }
    
    // times >= 10 hours
    if (timesCount >=36000) {
        hours = [NSString stringWithFormat:@"%d:",timesCount/3600];
        if ((timesCount/60)%60<10) {
            min = [NSString stringWithFormat:@"0%d",(timesCount/60)%60];
        }else
        {
            min = [NSString stringWithFormat:@"%d",(timesCount/60)%60];
        }
        
        
    }
    
    if (timesCount%60 <10) {
        second = [NSString stringWithFormat:@"0%d",timesCount%60];
    }else
    {
        second = [NSString stringWithFormat:@"%d",timesCount%60];
    }
    
    _isCall = [NSString stringWithFormat:@"%@%@:%@",hours,min,second];
    [userDefaults setValue:_isCall forKey:@"timeLength"];
    if (button.tag == 3002) {
        [button setTitle:_isCall forState:UIControlStateNormal];
    }
    showTopViewTimes =[NSString stringWithFormat:@"轻按此处返回 %@%@:%@",hours,min,second];
    [showTimesBut setTitle:showTopViewTimes forState:UIControlStateNormal];
    
    //使文字闪烁
    if (isLighter) {
        [UIView animateWithDuration:0.5f animations:^{
            showTimesBut.alpha = .3;
            isLighter = NO;
        }];
    }else{
        [UIView animateWithDuration:0.5f animations:^{
            showTimesBut.alpha = 1;
            isLighter = YES;
        }];
    }
    
    
    //VCLog(@"timeLength :%@",self.isCall);
    //VCLog(@"%d",[_isCall intValue]);
}
#pragma mark -- 加载gif
- (void)initWithGifFrame:(CGRect)frame filePath:(NSString *)filePath
{
    NSDictionary *gifLoopCount = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:(NSString *)kCGImagePropertyGIFLoopCount];
    gifProperties = [NSDictionary dictionaryWithObject:gifLoopCount forKey:(NSString *)kCGImagePropertyGIFDictionary] ;
    gif = CGImageSourceCreateWithURL((CFURLRef)[NSURL fileURLWithPath:filePath], (CFDictionaryRef)gifProperties);
    count =CGImageSourceGetCount(gif);
    gifTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(playGif) userInfo:nil repeats:YES];
    [gifTimer fire];
    
}
/**
 *  开始播放动画
 */
-(void)playGif
{
    index ++;
    index = index%count;
    CGImageRef ref = CGImageSourceCreateImageAtIndex(gif, index, (CFDictionaryRef)gifProperties);
    self.gifView.layer.contents = (__bridge id)ref;
    CFRelease(ref);
}

-(void)stopTimer{
    [gifTimer invalidate];
    gifTimer = nil;
    
    [timeLengthTimer invalidate];
    timeLengthTimer = nil;
}
#pragma mark -swipe
/**
 *  手势，上滑收起
 *  @param sp swipe
 */
-(void)sswipes:(UISwipeGestureRecognizer *)sp{
    
    [self.delegateCalling packUpCallingView];
    
}

#pragma mark -- btn action

/**
 *  calling 收起状态，点击展开
 *  @param button btn
 */
-(void)showTimesButClick:(UIButton *)button{
    //VCLog(@"height:%f",self.frame.size.height);
    if (self.frame.size.height>40) {
        [self.delegateCalling packUpCallingView];
        [self.delegateCalling changeWindowfram];
    }else{
        [self.delegateCalling changeWindowfram];
    }
    
}
/**
 *  挂断
 *  @param button btn
 */
-(void)cutButClick:(UIButton *)button{
    
    _isCall = @"通话结束";
    [self stopTimer];
    [self.delegateCalling disMissCallingView];
    
    
    //保存通话记录
    NSString *st = [NSString stringWithFormat:@"%@",[userDefaults objectForKey:@"timeLength"]];
    if (st.length>0) {
        [callAction callEndByMeWithState:1 hisNumber:hisNumbers hisName:hisNames timeLength:st];
    }else
    {
        st = @"00:00";
        [callAction callEndByMeWithState:1 hisNumber:hisNumbers hisName:hisNames timeLength:st];
    }
    
    //刷新表格
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kCallViewReloadData object:self ]];
}
/**
 *  calling 展开状态，点击收起
 *  @param button btn
 */
-(void)packUpButClick:(UIButton *)button{

    [self.delegateCalling packUpCallingView];
}

@end
