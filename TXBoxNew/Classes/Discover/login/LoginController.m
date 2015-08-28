//
//  LoginController.m
//  TXBoxNew
//
//  Created by Naron on 15/6/1.
//  Copyright (c) 2015年 playtime. All rights reserved.
//  登录页面

#import "LoginController.h"
#import "RegisteViewController.h"
#import "UpdatePwdController.h"

@interface LoginController ()<UITextFieldDelegate>
{
    NSUserDefaults *defaults;
    
}
@property (weak, nonatomic) IBOutlet UIButton *numberImg;
@property (weak, nonatomic) IBOutlet UIButton *pwdImg;
@property (weak, nonatomic) IBOutlet UITextField *numberField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *forgetPwd;
@property (weak, nonatomic) IBOutlet UIButton *registers;
- (IBAction)loginButtonClick:(UIButton *)sender;
- (IBAction)forgetPwdBtnClick:(UIButton *)sender;
- (IBAction)reistersButton:(UIButton *)sender;

@end

@implementation LoginController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kHideCusotomTabBar object:self]];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    defaults = [NSUserDefaults standardUserDefaults];
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(loginViewSwipeActions:)];
    swipe.direction = UISwipeGestureRecognizerDirectionDown;
    
    if ([userDefaults valueForKey:CurrentUser]) {
        self.numberField.text = [userDefaults valueForKey:CurrentUser];
    }
    
    self.numberField.delegate = self;
    self.pwdField.delegate = self;
    
    [self.numberField addGestureRecognizer:swipe];
    [self.pwdField addGestureRecognizer:swipe];
    
    //Login
    self.loginBtn.layer.cornerRadius = 3;
    [self.loginBtn setBackgroundColor:LightColor];
    self.loginBtn.alpha = .5f;
}

#pragma mark -- Swipe
-(void)loginViewSwipeActions:(UISwipeGestureRecognizer *)recognizer
{
    [self closeKeyboard];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self closeKeyboard];
}

#pragma mark --textField delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    /*
    if (self.numberField.text.length>0) {
        [self.numberImg setImage:[UIImage imageNamed:@"login_user_highlighted"] forState:UIControlStateNormal];
    }
    if (self.pwdField.text.length>0) {
        [self.pwdImg setImage:[UIImage imageNamed:@"login_key_highlighted"] forState:UIControlStateNormal];
    }
     */

}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self closeKeyboard];
    //登录验证
    [self loginUserAccount];
    
    VCLog(@"登录");
    return YES;
}

-(void)closeKeyboard{
    [self.numberField resignFirstResponder];
    [self.pwdField resignFirstResponder];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *nstring = [NSString stringWithFormat:@"%@%@",self.numberField.text,string];
    NSString *pstring = [NSString stringWithFormat:@"%@%@",self.pwdField.text,string];
    //VCLog(@"%@%@",nstring,pstring);
    if (textField == self.numberField) {
        if (nstring.length > 0) {
            [self.numberImg setImage:[UIImage imageNamed:@"login_user_highlighted"] forState:UIControlStateNormal];
        }else{
            [self.numberImg setImage:[UIImage imageNamed:@"login_user"] forState:UIControlStateNormal];
        }
    }
    if (textField == self.pwdField) {
        if (pstring.length > 0) {
            [self.pwdImg setImage:[UIImage imageNamed:@"login_key_highlighted"] forState:UIControlStateNormal];
        }else{
            [self.pwdImg setImage:[UIImage imageNamed:@"login_key"] forState:UIControlStateNormal];
        }
    }
    
    
    
    
    if (nstring.length > 0 && pstring.length >= 6) {
        [self.loginBtn setEnabled:YES];
        self.loginBtn.alpha = 1.f;
    }
    
    
    
    return YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -- 登录账号
- (IBAction)loginButtonClick:(UIButton *)sender {
    
    NSLog(@"login click");
    
    
    [self loginUserAccount];
    
    
    
}

-(void)loginUserAccount
{
    //
    
    VCLog(@"%@,%@",self.numberField.text,self.pwdField.text);
    
    if (self.numberField.text.length !=11 || self.pwdField.text.length<6) {
        [SVProgressHUD showImage:nil status:@"请输入正确的账号密码"];
        
    }else{
        [SVProgressHUD showWithStatus:@""];
        //[SVProgressHUD showWithStatus:@"登录中..." maskType:SVProgressHUDMaskTypeNone]
        [AVUser logInWithUsernameInBackground:self.numberField.text password:self.pwdField.text block:^(AVUser *user,NSError *error){
            if (error) {
                VCLog(@"login error.code%ld error:%@",(long)error.code,error.localizedDescription);
                NSString *errorString;
                if ([error.localizedDescription isEqualToString:@"THE USERNAME AND PASSWORD MISMATCH."]) {
                    errorString = @"账号或密码不正确";
                    [SVProgressHUD showErrorWithStatus:errorString];
                }else if([error.localizedDescription isEqualToString:@"COULD NOT FIND USER"]){
                    [SVProgressHUD showErrorWithStatus:@"用户不存在"];
                }else{
                    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                }
                
                self.pwdField.text = nil;
                [self.pwdImg setImage:[UIImage imageNamed:@"login_key"] forState:UIControlStateNormal];
            }else{
                //登录成功，返回上一页面
                
                [SVProgressHUD showSuccessWithStatus:@"登录成功"];
                [defaults setValue:@"1" forKey:CONFIG_STATE];
                [defaults setValue:@"1" forKey:LOGIN_STATE];
                [defaults setValue:self.numberField.text forKey:CurrentUser];
                VCLog(@"user:%@",user);
                [self.navigationController popToRootViewControllerAnimated:YES];
                
                
            }
            
        }];
    }
    
}



#pragma mark -- 忘记密码
- (IBAction)forgetPwdBtnClick:(UIButton *)sender {
    
    VCLog(@"forget pwd?");
    
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UpdatePwdController *updateView = [board instantiateViewControllerWithIdentifier:@"UpdatePwdControllerID"];
    [self.navigationController pushViewController:updateView animated:YES];
    
    
    
}

#pragma mark -- 注册账号
- (IBAction)reistersButton:(UIButton *)sender {
    
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RegisteViewController *registerView = [board instantiateViewControllerWithIdentifier:@"RegisteViewControllerID"];
    [self.navigationController pushViewController:registerView animated:YES];
}
@end
