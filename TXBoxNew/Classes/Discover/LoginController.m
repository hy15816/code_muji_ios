//
//  LoginController.m
//  TXBoxNew
//
//  Created by Naron on 15/6/1.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "LoginController.h"

@interface LoginController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *numberImg;
@property (weak, nonatomic) IBOutlet UIButton *pwdImg;
@property (weak, nonatomic) IBOutlet UITextField *numberField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *forgetPwd;
@property (weak, nonatomic) IBOutlet UIButton *registers;
- (IBAction)loginButtonClick:(UIButton *)sender;
- (IBAction)forgetPwdBtnClick:(UIButton *)sender;

@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(loginViewSwipeActions:)];
    swipe.direction = UISwipeGestureRecognizerDirectionDown;
    
    self.numberField.delegate = self;
    self.pwdField.delegate = self;
    
    [self.numberField addGestureRecognizer:swipe];
    [self.pwdField addGestureRecognizer:swipe];
    
    //Login
    self.loginBtn.layer.cornerRadius = 3;
    [self.loginBtn setBackgroundColor:RGBACOLOR(100, 211, 100, 1)];
    self.loginBtn.alpha = .5f;
}

-(void)loginViewSwipeActions:(UISwipeGestureRecognizer *)recognizer
{
    [self.numberField resignFirstResponder];
    [self.pwdField resignFirstResponder];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.numberField resignFirstResponder];
    [self.pwdField resignFirstResponder];
}

#pragma mark textField delegate
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
    //登录验证
    
    VCLog(@"登录");
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.numberField.text.length>0) {
        [self.numberImg setImage:[UIImage imageNamed:@"login_user_highlighted"] forState:UIControlStateNormal];
    }else{
        [self.numberImg setImage:[UIImage imageNamed:@"login_user"] forState:UIControlStateNormal];
    }
    if (self.pwdField.text.length>0) {
        [self.pwdImg setImage:[UIImage imageNamed:@"login_key_highlighted"] forState:UIControlStateNormal];
    }else{
        [self.pwdImg setImage:[UIImage imageNamed:@"login_key"] forState:UIControlStateNormal];
    }
    
    if (self.numberField.text.length > 0 && self.pwdField.text.length >0) {
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

- (IBAction)loginButtonClick:(UIButton *)sender {
    
    NSLog(@"login click");
}

- (IBAction)forgetPwdBtnClick:(UIButton *)sender {
    
    VCLog(@"forget pwd?");
    
}
@end
