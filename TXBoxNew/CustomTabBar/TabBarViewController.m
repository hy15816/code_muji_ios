//
//  TabBarViewController.m
//  TXBoxNew
//
//  Created by Naron on 15/4/15.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "TabBarViewController.h"
#import "TXTelNumSingleton.h"
#import "TXCallAction.h"
#import "CallingController.h"
#import "GuideView.h"
#import "CallingView.h"


@interface TabBarViewController ()<tabBarViewDelegate,UIAlertViewDelegate,GuideViewDelegate,CallingDelegate>
{
    CustomTabBarView *tabBarView;
    CustomTabBarBtn *previousBtn;
    TXCallAction *callAct;
    CallingController *calling;
    TXTelNumSingleton *singleton;
    BOOL flag;
    NSUserDefaults *defaults;
    float heightb;
    CallingView *cView;
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
    if (![defaults valueForKey:@"firstLaunch"]) {
        
        GuideView *gview = [[GuideView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
        gview.guideDelegate = self;
        [self.view addSubview:gview];
        [defaults setValue:@"1" forKey:@"firstLaunch"];
        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //1.添加数字键盘
    self.keyView = [[TXKeyView alloc]initWithFrame:CGRectMake(0,DEVICE_HEIGHT, DEVICE_WIDTH, keyHight*5.f+InputBoxView)];
    self.keyView.backgroundColor = [UIColor whiteColor];//键盘背景色
    [self.view addSubview:self.keyView];
    flag = NO;
    
    //2.重新定制tabBar
    tabBarView = [[CustomTabBarView alloc] init];
    tabBarView.frame=CGRectMake(0, DEVICE_HEIGHT-49, DEVICE_WIDTH, 49);
    tabBarView.delegate = self;
    tabBarView.userInteractionEnabled = YES;
    tabBarView.backgroundColor = RGBACOLOR(245, 245, 246, 1);
    self.tabBar.hidden = YES;
    //[self initTabBar];
    [self.view addSubview:tabBarView];
    
    
    /** 通知 **
     *  1.在TXKeyView中创建通知
     *  2.在需要的地方发送通知
     *  3.在需要接收的通知处，注册通知
     *  4.移除通知
     *  *.名字必须相同
     */
    
    /*
    //.注册(接收)单个通知(指定名字的)（在keyView中发送的通知）
    if([self respondsToSelector:@selector(btnChanged:)]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(btnChanged:) name:ktextChangeNotify object:nil];
    }
    */
    
    
    //calling.view.frame = CGRectMake(0, StatusBarHeight, DEVICE_WIDTH, DEVICE_HEIGHT-StatusBarHeight);
    //calling.view.alpha = 0;
    //[self.view addSubview:calling.view];
    
    //初始化单例
    singleton = [TXTelNumSingleton sharedInstance];
    //call action
    callAct = [[TXCallAction alloc] init];
    defaults =[NSUserDefaults standardUserDefaults];
    
    //注册手势
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(initRecognizer:)];
    swipe.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipe];
    
    //
    //接收所有通知
    if([self respondsToSelector:@selector(cutomKeyboradAndTabViewHide:)]) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cutomKeyboradAndTabViewHide:) name:nil object:nil];
    }

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
    
    
    [UIView beginAnimations:@"" context:@""];
    [UIView setAnimationDuration:.37];
    //隐藏键盘，
    self.keyView.frame=CGRectMake(0,DEVICE_HEIGHT, DEVICE_WIDTH, keyHight*5.f+InputBoxView);
    flag = NO;
    //隐藏call按钮
    tabBarView.callBtn.hidden = YES;
    
    [UIView setAnimationRepeatCount:0];
    [UIView commitAnimations];
}


#pragma mark -- 重写tabBar
-(void) initTabBar
{
    //创建TabBar
    VCLog(@"height:%f",self.view.frame.size.height);
    tabBarView.frame=CGRectMake(0, heightb-49, DEVICE_WIDTH, 49);
    
    
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
        
        //显示or隐藏键盘状态
        flag = !flag;
        [UIView beginAnimations:@"" context:@""];
        [UIView setAnimationDuration:.37];
        if (flag) {
            //弹出键盘
            self.keyView .frame=CGRectMake(0,DEVICE_HEIGHT-49-4*keyHight-NaviBarHeight-InputBoxView, DEVICE_WIDTH, keyHight*4.f+InputBoxView);
            flag = YES;
            [button setImage:[UIImage imageNamed:@"icon_up"] forState:UIControlStateSelected];
            //若已输入号码，显示callBtn
            if (singleton.singletonValue.length>0) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.38f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    tabBarView.callBtn.hidden = NO;
                });
            }
            
        }else
        {
            //隐藏键盘，隐藏call按钮
            flag = NO;
            [self customKeyboardHide];
            //
            [button setImage:[UIImage imageNamed:@"icon_down"] forState:UIControlStateSelected];
        }

        [UIView setAnimationRepeatCount:0];
        [UIView commitAnimations];

       
        
        
        
        
    }else
    {
        //隐藏键盘，隐藏call按钮
        [self customKeyboardHide];
        
    }
    
    
    
}

//呼叫事件
-(void) eventCallBtn:(UIButton *)button
{
    //利用单例获取输入的号码
    //获取输入号码
    NSString *strHis =  singleton.singletonValue;
    //判断号码
    if (strHis.length>20 || strHis.length <5){
        
        [self initAlertView];
        return;
        
    }else {
        //添加calling页面
        //是否登录？
        BOOL loginS=[[defaults valueForKey:LOGIN_STATE] intValue];
        //是否登录？
        if (loginS) {
            //获取拇机号码,
            NSString *phoneNumber =[defaults valueForKey:muji_bind_number];
            
            //已有number
            if (phoneNumber.length>0 ) {
                //获取呼转状态
                //添加calling页面
                [self addCallingView];
                [self callingBtn:nil];
            }else
            {
                [self isOrNotCallOutTitle:@"想要通过拇机通讯？" message:@"请到【发现】中【绑定】"];
            }

        }else{//没有登录
            [self isOrNotCallOutTitle:@"想要通过拇机通讯？" message:@"请到【发现】中【登录】后【配置】"];
        }
        
        
        
    }

    VCLog(@"call str:%@",strHis);
    
}

//显示提示框
-(void)initAlertView
{
    //VCLog(@"alert");
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alerts", nil) message:NSLocalizedString(@"Please_enter_the_correct_number", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"No", nil) otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
    alert.delegate = self;
    [alert show];
    
}

//custom 隐藏键盘隐藏call按钮
-(void) customKeyboardHide
{
    //隐藏键盘，
    self.keyView.frame=CGRectMake(0,DEVICE_HEIGHT, DEVICE_WIDTH, keyHight*5.f+InputBoxView);
    //隐藏call按钮
    tabBarView.callBtn.hidden = YES;
    
}

#pragma mark -- 通知
-(void) cutomKeyboradAndTabViewHide:(NSNotification *)notifi
{
    if ([notifi.name isEqual:kKeyboardAndTabViewHide]) {
        
        tabBarView.hidden = YES;
        //隐藏键盘，
        self.keyView.frame=CGRectMake(0,DEVICE_HEIGHT, DEVICE_WIDTH, keyHight*5.f+InputBoxView);
        //隐藏call按钮
        tabBarView.callBtn.hidden = YES;
    }
    
    if ([notifi.name isEqualToString:kCustomKeyboardHide]) {
        //隐藏键盘，
        self.keyView.frame=CGRectMake(0,DEVICE_HEIGHT, DEVICE_WIDTH, keyHight*5.f+InputBoxView);
        //隐藏call按钮
        tabBarView.callBtn.hidden = YES;
    }
    //显示callBtn
    if ([notifi.name isEqualToString:ktextChangeNotify]) {
        tabBarView.callBtn.hidden = NO;
    }
    //点击callBtn
    if ([notifi.name isEqualToString:kCallingBtnClick]) {
        BOOL loginS=[[defaults valueForKey:LOGIN_STATE] intValue];
        //是否登录？
        if (loginS) {
            //获取拇机号码,
            NSString *phoneNumber = [defaults valueForKey:muji_bind_number];
            
            //已有number
            if (phoneNumber.length>0 ) {
                //获取呼转状态
                //添加calling页面
                [self addCallingView];
                [self callingBtn:notifi];
            }else
            {
                [self isOrNotCallOutTitle:@"想要通过拇机通讯？" message:@"请到【发现】中【绑定】"];
            }
        }else{//没有登录
            [self isOrNotCallOutTitle:@"想要通过拇机通讯？" message:@"请到【发现】中【登录】后【配置】"];
        }
        
        
        
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
    
}



//判断是否可以呼叫？
-(void)isOrNotCallOutTitle:(NSString *)title message:(NSString *)message
{
    //没有则弹框提示
    UIAlertView *isNoMujiAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"不OK" otherButtonTitles:@"OK", nil];
    isNoMujiAlert.tag =1200;
    [isNoMujiAlert show];
}

#pragma mark -- 加载Calling view
-(void) addCallingView
{
    //添加calling页面
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    calling = [board instantiateViewControllerWithIdentifier:@"callingVC"];
    calling.view.alpha = 0.f;

    calling.view.frame = CGRectMake(0, -5, DEVICE_WIDTH, DEVICE_HEIGHT+5);
    [self.view addSubview:calling.view];
    
}


//加载call out
-(void) callingBtn:(NSNotification *)notification
{
    //
    [UIView beginAnimations:@"" context:@""];
    [UIView setAnimationDuration:.9];
    calling.view.alpha = 1.f;
    //获取notification传值
    calling.nameLabel.text = [[notification userInfo] objectForKey:@"hisName"];
    calling.numberLabel.text = [[notification userInfo] objectForKey:@"hisNumber"];
    
    if (calling.nameLabel.text.length > 0) {
        calling.nameLabel.hidden = NO;
        calling.numberLabel.hidden = YES;
    }else if (calling.numberLabel.text.length > 0)
    {
        calling.nameLabel.hidden = YES;
        calling.numberLabel.hidden = NO;
    }else
    {
        calling.nameLabel.hidden = YES;
        calling.numberLabel.hidden = NO;
        calling.numberLabel.text = singleton.singletonValue;//输入的号码
    }
    
    [UIView setAnimationRepeatCount:0];
    [UIView commitAnimations];
    VCLog(@"is calling");
    
}

#pragma mark -- AlertView delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1200) {
        if (buttonIndex ==1) {
            //跳转到-发现
            //disvyCtorl
            //
            //self.selectedIndex  =3;
            CustomTabBarBtn *button = [[CustomTabBarBtn alloc] init];
            button.tag =3;
            self.selectedIndex = button.tag; //切换不同控制器的界面
            
            button.selected = YES;//选中
            
            if (previousBtn != button) {
                
                previousBtn.selected = NO;
                
            }
            
            //previousBtn = button;
            
            //[self changeViewController:button];
            //[previousBtn setImage:[UIImage imageNamed:@"icon_discover_selected"] forState:UIControlStateNormal];
            
            
            //隐藏tabbar
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kCustomKeyboardHide object:self]];

        }
    }
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
