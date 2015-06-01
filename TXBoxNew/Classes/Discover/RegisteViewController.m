//
//  RgisteViewController.m
//  TXBoxNew
//
//  Created by Naron on 15/6/1.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "RegisteViewController.h"

@interface RegisteViewController ()<UITextFieldDelegate>
{
    int secondsCountDown;
    NSTimer *countDownTimer;
}
@property (weak, nonatomic) IBOutlet UITextField *regNumberField;
@property (weak, nonatomic) IBOutlet UITextField *regPwdField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
- (IBAction)cancelBtnClick:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UIButton *clause;
- (IBAction)registerBtnClick:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITextField *enterSmsCode;
@property (weak, nonatomic) IBOutlet UITextField *pwdFieldAgain;
@property (weak, nonatomic) IBOutlet UIButton *smsCode;
- (IBAction)smsCodeClick:(UIButton *)sender;

@end

@implementation RegisteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.registerBtn.layer.cornerRadius = 3.f;
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(registerViewSwipeActions:)];
    swipe.direction = UISwipeGestureRecognizerDirectionDown;
    
    self.regNumberField.delegate = self;
    self.regPwdField.delegate = self;
    self.enterSmsCode.delegate = self;
    self.pwdFieldAgain.delegate =self;
    
    [self.regNumberField addGestureRecognizer:swipe];
    [self.regPwdField addGestureRecognizer:swipe];
    [self.pwdFieldAgain addGestureRecognizer:swipe];
    [self.enterSmsCode addGestureRecognizer:swipe];
    
    
    [self.registerBtn setBackgroundColor:RGBACOLOR(100, 211, 100, 1)];
    [self.registerBtn setEnabled:NO];
    self.registerBtn.alpha =.5;
}

-(void)registerViewSwipeActions:(UISwipeGestureRecognizer *)recognizer
{
    [self.regNumberField resignFirstResponder];
    [self.regPwdField resignFirstResponder];
    [self.pwdFieldAgain resignFirstResponder];
    [self.enterSmsCode resignFirstResponder];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.regNumberField resignFirstResponder];
    [self.regPwdField resignFirstResponder];
    [self.pwdFieldAgain resignFirstResponder];
    [self.enterSmsCode resignFirstResponder];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)cancelBtnClick:(UIBarButtonItem *)sender {
    
    
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"cancel");
    }];
    
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if (self.regNumberField.text.length>0 && self.regPwdField.text.length >0 && self.enterSmsCode.text.length >0 && self.pwdFieldAgain.text.length >0 ) {
        [self.registerBtn setEnabled:YES];
        self.registerBtn.alpha = 1.f;
    }else{
        [self.registerBtn setEnabled:NO];
        self.registerBtn.alpha = 0.5f;
    }

    return YES;
}

#pragma mark--用户注册
- (IBAction)registerBtnClick:(UIButton *)sender {
    //验证手机验证码
    
    [AVOSCloud verifySmsCode:self.enterSmsCode.text mobilePhoneNumber:self.regNumberField.text callback:^(BOOL suc,NSError *error){
        if (error) {
            VCLog(@"验证- error");
        }else{
            VCLog(@"验证-suc");
            
            //用户注册
            AVUser *user = [AVUser user];
            user.username = self.regNumberField.text;
            user.password = self.regPwdField.text;
            
            [user signUpInBackgroundWithBlock:^(BOOL suc,NSError *error){
            
                if (error) {
                    VCLog(@"reg - error");
                }else{
                    VCLog(@"reg -suc");

                }
            }];
            
            
        }
        
    }];
    
    
    VCLog(@"reg btn");
}

- (IBAction)smsCodeClick:(UIButton *)sender {
    /*
    //请求手机验证码
    [AVOSCloud requestSmsCodeWithPhoneNumber:self.regNumberField.text callback:^(BOOL suc,NSError *error){
        if (suc) {
            NSLog(@"suc");
            
        }else{
            NSLog(@"reg error-code:%ld errorInfo:%@",(long)error.code,error.localizedDescription);
        }
    }];
*/
    /*
    //========GCD
    __block int timeout = 60;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), 1.0*NSEC_PER_SEC, 0);//每秒执行
    
    dispatch_source_set_event_handler(timer, ^{
        if (timeout<=0) {//结束
            dispatch_source_cancel(timer);
            //dispatch_release(timer);
            dispatch_async(dispatch_get_main_queue(), ^{
            //
                [self.smsCode setTitle:@"重新获取" forState:UIControlStateNormal];
            });
            
        }else{//倒计时ing...
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [self.smsCode setTitle:[NSString stringWithFormat:@"重新获取%d",timeout] forState:UIControlStateNormal];
            }); 
            timeout--;
            
        }
        
    });
    dispatch_resume(timer);
    */
    
    
    
    
    
    
    
    
    //========NSTimer
    
    secondsCountDown = 60;//60秒倒计时
    countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFireMethod) userInfo:nil repeats:YES];
    
    [self.smsCode setEnabled:NO];
    
}

-(void)timeFireMethod{
    
    secondsCountDown--;
    
    [self.smsCode setTitle:[NSString stringWithFormat:@"重新获取%d",secondsCountDown] forState:UIControlStateNormal];
    [self.smsCode setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    if(secondsCountDown==0){
        [countDownTimer invalidate];
        [self.smsCode setTitle:@"重新获取" forState:UIControlStateNormal];
        [self.smsCode setTitleColor:RGBACOLOR(0, 120, 230, 1) forState:UIControlStateNormal];
        [self.smsCode setEnabled:YES];
    } 
}



@end
