//
//  TabBarViewController.m
//  TXBoxNew
//
//  Created by Naron on 15/4/15.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#define WindowDownHeight 20.f
#define CallingViewPackUpheight 45.f

#import "TabBarViewController.h"
#import "TXTelNumSingleton.h"
#import "GuideView.h"
#import "NSString+helper.h"
#import "CallingView.h"

@interface TabBarViewController ()<tabBarViewDelegate,UIAlertViewDelegate,GuideViewDelegate,KeyViewDelegate,CallingDelegate>
{
    CustomTabBarView *tabBarView;
    CustomTabBarBtn *previousBtn;
    TXTelNumSingleton *singleton;
    BOOL showKeyboard;
    CallingView *cv;
    CGFloat deviceHeight;
    BOOL isCallingButton;
}
@end

@implementation TabBarViewController
@synthesize keyView;


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    //显示tabBar
    tabBarView.hidden = NO;
    //第一次，则加载引导页
    if (![userDefaults valueForKey:@"firstLaunch"]) {
        
        GuideView *gview = [[GuideView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
        gview.guideDelegate = self;
        [self.view addSubview:gview];
        [userDefaults setValue:@"1" forKey:@"firstLaunch"];
        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    deviceHeight = DEVICE_HEIGHT;
    isCallingButton = NO;
    //添加数字键盘
    self.keyView = [[TXKeyView alloc]init];
    self.keyView.frame = CGRectMake(0,deviceHeight-kTabBarHeight-4*keyHeight-NaviBarHeight-InputBoxViewHeight, DEVICE_WIDTH, keyHeight*5.f+InputBoxViewHeight);
    self.keyView.backgroundColor = [UIColor whiteColor];//键盘背景色
    self.keyView.keyDelegate = self;
    [self.view addSubview:self.keyView];
    showKeyboard = YES;
    
    //init tabBar
    [self initTabBar];
    
    //初始化单例
    singleton = [TXTelNumSingleton sharedInstance];
    
    //注册手势
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(initRecognizer:)];
    swipe.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipe];
    
    //接收所有通知
    if([self respondsToSelector:@selector(customKeyboradAndTabViewHide:)]) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customKeyboradAndTabViewHide:) name:nil object:nil];
    }
    [self respondsToSelector:@selector(changeViewController:)];
}

#pragma mark -- GuideView Delegate
-(Guides *)getInfo
{
    Guides *gds = [[Guides alloc] init];
    NSArray *imageArray = [NSArray arrayWithObjects:@"lch_0_568h", nil];
    gds.imageArray =imageArray;
    
    return gds;
}

//处理swipe
-(void) initRecognizer:(UIGestureRecognizer *)recognizer
{
    [UIView animateWithDuration:.27 animations:^{
        //隐藏键盘，
        self.keyView.frame=CGRectMake(0,deviceHeight, DEVICE_WIDTH, keyHeight*5.f+InputBoxViewHeight);
        showKeyboard = NO;
        //隐藏call按钮
        tabBarView.callBtn.hidden = YES;
        
    }];
    
    [self.keyView removeHudv];
    
}

#pragma mark -- 重写tabBar
-(void) initTabBar
{
    //创建TabBar
    tabBarView = [[CustomTabBarView alloc] init];
    [self getTabbarHeight:DEVICE_HEIGHT];
    [tabBarView createButton];
    tabBarView.delegate = self;
    tabBarView.userInteractionEnabled = YES;
    tabBarView.backgroundColor = [UIColor whiteColor] ;//RGBACOLOR(245, 245, 246, 1);
    self.tabBar.hidden = YES;
    [self.view addSubview:tabBarView];
    
}

-(void)getTabbarHeight:(CGFloat)height{
    
    tabBarView.frame=CGRectMake(0, height-kTabBarHeight, DEVICE_WIDTH, kTabBarHeight);
    deviceHeight = height;
}

#pragma mark -- tabbarView delegate
//点击切换Tab页
-(void) changeViewController:(CustomTabBarBtn *)button
{
    self.selectedIndex = button.tag; //切换不同控制器的界面
     button.selected = YES;//选中
     if (previousBtn != button) {
         previousBtn.selected = NO;
         }
     previousBtn = button;
    
    if (button.tag == 0) {
        
        [self showOrHideKeyborad:button];
    }else{
        //隐藏键盘，隐藏call按钮
        [self customKeyboardHides];
        
    }

}
//显示or隐藏键盘
-(void) showOrHideKeyborad:(UIButton *)button{
    
    showKeyboard = !showKeyboard;
    [UIView animateWithDuration:.27 animations:^{
        if (showKeyboard) {
            //弹出键盘
            self.keyView .frame=CGRectMake(0,deviceHeight-kTabBarHeight-4*keyHeight-NaviBarHeight-InputBoxViewHeight, DEVICE_WIDTH, keyHeight*4.f+InputBoxViewHeight);
            showKeyboard = YES;
            [button setImage:[UIImage imageNamed:@"icon_up"] forState:UIControlStateSelected];
            //若已输入号码，显示callBtn
            if (singleton.singletonValue.length>=1) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.38f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    tabBarView.callBtn.hidden = NO;
                });
            }else{
                tabBarView.callBtn.hidden = YES;
            }
            
        }else{
            //隐藏键盘，隐藏call按钮
            showKeyboard = NO;
            [self customKeyboardHides];
            [button setImage:[UIImage imageNamed:@"icon_down"] forState:UIControlStateSelected];
        }
    }];
}

-(void) customKeyboardHides
{
    //隐藏键盘，
    showKeyboard = NO;
    self.keyView.frame=CGRectMake(0,deviceHeight, DEVICE_WIDTH, keyHeight*5.f+InputBoxViewHeight);
    //隐藏call按钮
    tabBarView.callBtn.hidden = YES;
    //[previousBtn setImage:[UIImage imageNamed:@"icon_down_gray"] forState:UIControlStateNormal];
    [self.keyView removeHudv];
}

#pragma mark -- calling View
-(void)createCallingView{
    cv = [[CallingView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    cv.topView.hidden = NO;
    cv.imgv.hidden = NO;
    cv.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"calling_bg"]];
    cv.alpha = 0;
    cv.delegateCalling = self;
    
    [self.view.window addSubview:cv];
    
    [UIView animateWithDuration:.4 animations:^{
        cv.alpha = 1;
    }];
    
}

//收起
-(void)packUpCallingView{
    
    [UIView animateWithDuration:.4 animations:^{
        self.view.window.frame = CGRectMake(0, WindowDownHeight, DEVICE_WIDTH, DEVICE_HEIGHT-WindowDownHeight);
        [self getTabbarHeight:DEVICE_HEIGHT-WindowDownHeight];
        cv.frame = CGRectMake(0, -WindowDownHeight, DEVICE_WIDTH, CallingViewPackUpheight);
        cv.topView.hidden = NO;
        cv.imgv.hidden = YES;
    }];
    
}
//展开
-(void)changeWindowfram{
    
    [UIView animateWithDuration:.4 animations:^{
        cv.frame = CGRectMake(0, -WindowDownHeight, DEVICE_WIDTH, DEVICE_HEIGHT);
        
        cv.topView.hidden = YES;
        cv.imgv.hidden = NO;
    }];
    
}
//消失
-(void)disMissCallingView{
    
    [UIView animateWithDuration:.4 animations:^{
        cv.alpha = 0;
        self.view.window.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
        [self getTabbarHeight:DEVICE_HEIGHT];
        cv.topView.hidden = YES;
        cv.imgv.hidden = YES;
    }];
}

//赋值
-(void) callingViewsValue:(NSNotification *)notification
{
    cv.hisNames =[[notification userInfo] objectForKey:@"hisName"];
    cv.hisNumbers = [[notification userInfo] objectForKey:@"hisNumber"];
    cv.hisContactId = [[notification userInfo] objectForKey:@"hisContactId"];
    if (isCallingButton) {
        cv.hisNames =@"";
        cv.hisNumbers = singleton.singletonValue;
        isCallingButton = NO;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [cv startTimeLengthTimer];
    });
}

#pragma mark -- keyView delegate
-(void)inputTextLength:(NSString *)text{
    
    if (text.length<1) {
        tabBarView.callBtn.hidden = YES;
    }
}

//呼叫事件
-(void) eventCallBtn:(UIButton *)button
{
    //获取输入的号码
    NSString *strHis =  singleton.singletonValue;
    //判断号码
    if (strHis.length>20 || strHis.length <1){
        
        [self initAlertView];
        return;
        
    }else {
        isCallingButton = YES;
        [self callingButtonClick:nil];
    }

    VCLog(@"call str:%@",strHis);
    
}

//显示提示框
-(void)initAlertView
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入正确的号码" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    
}

#pragma mark -- 通知
-(void) customKeyboradAndTabViewHide:(NSNotification *)notifi
{
    if ([notifi.name isEqual:kKeyboardAndTabViewHide]) {
        tabBarView.hidden = YES;
        self.keyView.frame=CGRectMake(0,deviceHeight, DEVICE_WIDTH, keyHeight*5.f+InputBoxViewHeight);//隐藏键盘，
        tabBarView.callBtn.hidden = YES;//隐藏call按钮
        [self.keyView removeHudv];
    }
    
    if ([notifi.name isEqualToString:kCustomKeyboardHide]) {
        self.keyView.frame=CGRectMake(0,deviceHeight, DEVICE_WIDTH, keyHeight*5.f+InputBoxViewHeight);//隐藏键盘，
        tabBarView.callBtn.hidden = YES;//隐藏call按钮
        [self.keyView removeHudv];
    }
    //显示callBtn
    if ([notifi.name isEqualToString:ktextChangeNotify]) {
        tabBarView.callBtn.hidden = NO;
    }
    //点击callBtn
    if ([notifi.name isEqualToString:kCallingBtnClick]) {
        [self callingButtonClick:notifi];
        
    }
    //显示tabBarView
    if ([notifi.name isEqualToString:kShowCusotomTabBar]) {
        tabBarView.hidden = NO;
    }
    if ([notifi.name isEqualToString:kHideCusotomTabBar]) {
        tabBarView.hidden = YES;
    }
    if ([notifi.name isEqualToString:kHideTabBarAndCallBtn]) {
        tabBarView.callBtn.hidden = YES;
        tabBarView.hidden = YES;
    }
    if ([notifi.name isEqualToString:@"AAAAA"]) {
        [self initRecognizer:nil];
    }
    
    
    if ([notifi.name isEqualToString:kJumptoDiscoeryView]) {
        //        
        [self thisIsDiscv:3];
        VCLog(@"jump");
    }
    
    //indexMessage
    if ([notifi.name isEqualToString:@"indexMessage"]) {
        //
        [self thisIsDiscv:1];
        
    }
}

-(void)callingButtonClick:(NSNotification *)notifi{
    BOOL loginS=[[userDefaults valueForKey:LOGIN_STATE] intValue];
    //是否登录？
    if (loginS) {
        //获取拇机号码,
        NSString *phoneNumber = [userDefaults valueForKey:muji_bind_number];
        
        //已有number
        if (phoneNumber.length>0 ) {
            //获取呼转状态
            //添加calling页面
            [self createCallingView];
            [self callingViewsValue:notifi];
        }else{
            [self isOrNotCallOutTitle:@"想要通过拇机通讯？" message:@"请到【发现】中【绑定】"];
        }
    }else{//没有登录
        [self isOrNotCallOutTitle:@"想要通过拇机通讯？" message:@"请到【发现】中【登录】后【配置】"];
    }

}

//判断是否可以呼叫？
-(void)isOrNotCallOutTitle:(NSString *)title message:(NSString *)message
{
    //没有则弹框提示
    UIAlertView *isNoMujiAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"不OK", nil];
    isNoMujiAlert.tag =1200;
    [isNoMujiAlert show];
}

#pragma mark -- AlertView delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1200) {
        if (buttonIndex ==0) {
            
            [self thisIsDiscv:3];
        }
    }
}

-(void) thisIsDiscv:(NSInteger)index{
    //KVO?
    
    self.selectedIndex = index;
    tabBarView.cusBtnExtern.selected = YES;
    if (previousBtn != tabBarView.cusBtnExtern) {
        previousBtn.selected = NO;
    }
    previousBtn = tabBarView.cusBtnExtern;
    //隐藏键盘
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kCustomKeyboardHide object:self]];
    
    
}
-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //移除通知
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:ktextChangeNotify object:nil];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
