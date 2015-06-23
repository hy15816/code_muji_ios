//
//  CallingController.m
//  TXBoxNew
//
//  Created by Naron on 15/4/21.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "CallingController.h"
#import "TXCallAction.h"
#import <ImageIO/ImageIO.h>
#import <AVFoundation/AVFoundation.h>
#import "BLEmanager.h"

@interface CallingController ()<AVAudioPlayerDelegate,BLEmanagerDelegate>
{
    TXCallAction *callAct;
    int times;
    NSTimer *timer;
    NSUserDefaults *defaults;
    NSTimer *tState;

    CGImageSourceRef gif; // 保存gif动画
    NSDictionary *gifProperties; // 保存gif动画属性
    size_t index; // gif动画播放开始的帧序号
    size_t count; // gif动画的总帧数
    NSTimer *timertimer; // 播放gif动画所使用的timer
    BOOL isLighter;
    BOOL isOrNotConnect;
    AVAudioPlayer *avplay;//播放音频
    BLEmanager *blemanagerc;
}
@property (strong, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) IBOutlet UILabel *topViewLabel;
@property (strong, nonatomic) IBOutlet UIImageView *backImageView;
- (IBAction)packUpClick:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *packUp;
@property (weak, nonatomic) IBOutlet UIView *gifView;
@end

@implementation CallingController
@synthesize nameLabel,numberLabel,timeLength;

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.timeLength.text = @"";
    //创建定时器
    
    //我的号码
    NSString *myPhoneNumber = [NSString stringWithFormat:@"%@",@"my phone number"];
    
    //如果电话接通，开始计时
    if ([callAct callOutAction:0]) {
        
        [callAct callOutFromNumber:myPhoneNumber HisNumber:self.numberLabel.text];
        
    }
    
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    callAct = [[TXCallAction alloc] init];
    defaults = [NSUserDefaults standardUserDefaults];
    blemanagerc = [BLEmanager sharedInstance];
    blemanagerc.managerDelegate = self;
    self.timeLength.text = NSLocalizedString(@"Calling", nil);
    times = 0;
    
    //加载gif
    [self initWithGifFrame:CGRectMake(0, 0, 0, 0) filePath:[[NSBundle mainBundle] pathForResource:@"board" ofType:@"gif"]];
    
    //获取连接状态，是否接通
    if (self.nameLabel.text.length ==0) {
        tState = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(getConnectState) userInfo:nil repeats:YES];
        [tState fire];
    }
    
    self.topView.hidden = YES;
    
}

#pragma mark -- BLEManagerDelegate
-(void)managerConnectedPeripheral:(BOOL)isConnect
{
    isOrNotConnect = isConnect;
    
}

/**
 *  获取连接(打电话)状态
 */
-(void) getConnectState
{
    
    //返回为1，已接通
    if ([callAct callOutAction:1]) {
        
        [defaults setValue:@"1"  forKey:@"isOrNotConnect"];
        [tState invalidate];
        tState = nil;
        
        //开始计时
        timer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(changedCount) userInfo:nil repeats:YES];
        [timer fire];
        //do anything
        [self playMusic];
        
    }else{//未接通
        
        [defaults setValue:@"0" forKey:@"isOrNotConnect"];
    }
}

/**
 *  播放音频
 */
-(void)playMusic{
    
    NSError *error;
    avplay = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"你曾是少年" ofType:@"mp3"]]  error:&error];
    avplay.delegate = self;
    avplay.volume = .5;//音量
    avplay.numberOfLoops = 3;//循环次数
    avplay.currentTime = 10.;//指定任意位置播放
    //[avplay prepareToPlay];//准备播放
    
    //[avplay play];//播放
    //[avplay pause];//暂停
    //[avplay stop];//停止
}

#pragma mark --AVAudioPlayer Delegate
//播放完成后，
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    avplay.currentTime = 10.;//指定任意位置播放
    [avplay prepareToPlay];//准备播放
    
    [avplay play];//播放
}
//处理开始中断
-(void)audioPlayerBeginInterruption:(AVAudioPlayer *)player{
    
}
//解码出错
-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    
}
//处理结束中断
-(void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags
{
    
    [avplay play];//继续播放
}

#pragma mark -- 加载gif
- (void)initWithGifFrame:(CGRect)frame filePath:(NSString *)filePath
{
    
    NSDictionary *gifLoopCount = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:(NSString *)kCGImagePropertyGIFLoopCount];
    
    gifProperties = [NSDictionary dictionaryWithObject:gifLoopCount forKey:(NSString *)kCGImagePropertyGIFDictionary] ;
    
    gif = CGImageSourceCreateWithURL((CFURLRef)[NSURL fileURLWithPath:filePath], (CFDictionaryRef)gifProperties);
    
    count =CGImageSourceGetCount(gif);
    
    timertimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(playGif) userInfo:nil repeats:YES];
    [timertimer fire];
    
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
/**
 *  stop定时器
 */
-(void)stopTimer
{
    [timertimer invalidate];//停止计时器
    timertimer = nil;   //置为nil
    
    [tState invalidate];
    tState  = nil;
    
    [timer invalidate];
    timer  = nil;
    [avplay stop];//停止播放歌曲
}




#pragma mark --  结束通话
-(IBAction)cut:(UIButton *)sender;
{
    
    NSUserDefaults *accountDefaults = [NSUserDefaults standardUserDefaults];
    [accountDefaults setValue:self.timeLength.text forKey:@"timeLength"];
    
    self.timeLength.text = NSLocalizedString(@"Call_Over", nil);
    [UIView beginAnimations:@"" context:@""];
    [UIView setAnimationDuration:.9];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    self.view.alpha = 0;
    
    [UIView setAnimationRepeatCount:0];
    [UIView commitAnimations];

    //保存资料数据 callOut
    NSString *st = [NSString stringWithFormat:@"%@",[accountDefaults objectForKey:@"timeLength"]];
    if (st.length>0) {
        [callAct callEndByMeWithState:1 hisNumber:self.numberLabel.text hisName: self.nameLabel.text timeLength:st];
    }else
    {
        st = @"00:00";
        [callAct callEndByMeWithState:1 hisNumber:self.numberLabel.text hisName: self.nameLabel.text timeLength:st];
    }
    
    [self stopTimer];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.view removeFromSuperview];
        
        //刷新表格
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kCallViewReloadData object:self ]];
        
    });
    
    
    
}

/**
 *  计时，时长的改变
 */
-(void) changedCount
{
    times ++;
    
    NSString *second;
    NSString *min;
    NSString *hours;
    
    //小于10秒
    //00:0s
    hours = @"";
    if (times <10) {
        min = [NSString stringWithFormat:@"00"];
    }
    
    if (10<=times && times<60) {

        min = [NSString stringWithFormat:@"0%d",times/60];
        
    }
    // 1min <= times < 1hours
    if (60<=times && times<3600) {

        if (times/60<10) {
            min = [NSString stringWithFormat:@"0%d",times/60];
        }else
        {
            min = [NSString stringWithFormat:@"%d",times/60];
        }
        
        
    }
    // 1hours <=times < 10 hours
    if (times>=3600 && times<36000) {
        hours = [NSString stringWithFormat:@"0%d:",times/3600];
        if ((times/60)%60<10) {
            min = [NSString stringWithFormat:@"0%d",(times/60)%60];
        }else
        {
            min = [NSString stringWithFormat:@"%d",(times/60)%60];
        }
        
        
        
    }
    
    // times >= 10 hours
    if (times >=36000) {
        hours = [NSString stringWithFormat:@"%d:",times/3600];
        if (times/60<10) {
            min = [NSString stringWithFormat:@"0%d",times/60];
        }else
        {
            min = [NSString stringWithFormat:@"%d",times/60];
        }
        
        
    }
    
    if (times%60 <10) {
        second = [NSString stringWithFormat:@"0%d",times%60];
    }else
    {
        second = [NSString stringWithFormat:@"%d",times%60];
    }

    self.timeLength.text = [NSString stringWithFormat:@"%@%@:%@",hours,min,second];
    self.topViewLabel.text =[NSString stringWithFormat:@"轻按此处返回 %@%@:%@",hours,min,second];
    //使文字闪烁
    if (isLighter) {
        [UIView animateWithDuration:0.5f animations:^{
            self.topViewLabel.alpha = .3;
            isLighter = NO;
        }];
    }else{
        [UIView animateWithDuration:0.5f animations:^{
            self.topViewLabel.alpha = 1;
            isLighter = YES;
        }];
    }
    
    
    VCLog(@"timeLength :%@",self.timeLength.text);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self stopTimer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//展开
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.view.frame.size.height<100) {
        [UIView animateWithDuration:.5 animations:^(){
        
            self.view.frame = CGRectMake(0, -5, DEVICE_WIDTH, DEVICE_HEIGHT+5);
            self.topView.hidden = YES;
            self.view.alpha = 1;
            self.packUp.hidden = NO;
        }];
    }
    
}

//收起
- (IBAction)packUpClick:(UIButton *)sender {
    
    //self.backImageView.hidden = YES;
    
    [UIView animateWithDuration:.5 animations:^{
        self.view.frame = CGRectMake(0, -5, DEVICE_WIDTH, 45);
        self.topViewLabel.textColor = [UIColor whiteColor];
        self.packUp.hidden = YES;
        self.topView.hidden = NO;
        
    }];
    
    
}
@end
