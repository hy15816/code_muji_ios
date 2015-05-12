//
//  DiscoverController.m
//  TXBoxNew
//
//  Created by Naron on 15/4/16.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "DiscoverController.h"
#import "PopView.h"
#import "NSString+helper.h"

@interface DiscoverController ()<PopViewDelegate>
{
    PopView *popview;
    UIView *shadeView;
    NSUserDefaults *defaults;
    UIAlertView *_alertView;
}
@end

@implementation DiscoverController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults valueForKey:muji_bind_number] length] == 0) {
        self.muji_number.text =@"未设置";
    }
    
    //
    _alertView = [[UIAlertView alloc] initWithTitle:nil message:@"请输入正确的邮箱和拇机号码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    _alertView.delegate = self;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 2 || section ==1) {
        return 2;
    }
    
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if ([[defaults valueForKey:muji_bind_number] length]<=0) {
           [self addShadeAndAlertView];
        }
    }
    
    
}

#pragma mark -- 弹出框
-(void)addShadeAndAlertView
{
    //透明层
    shadeView =[[UIView alloc] initWithFrame:self.view.window.bounds];
    shadeView.backgroundColor = [UIColor grayColor];//self.view.window.bounds
    shadeView.alpha = .5;
    
    //pop
    popview = [[PopView alloc] initWithFrame:CGRectMake((DEVICE_WIDTH-200)/2, (DEVICE_HEIGHT-170)/2-50, 200, 170)];
    popview.delegate = self;
    [popview initWithTitle:@"呼叫转移需要拇机号码等配置信息，请填写" firstMsg:@"邮箱" secondMsg:@"拇机号码" cancelButtonTitle:@"取消" otherButtonTitles:@"确定"];
    
    [self.view.window addSubview:shadeView];
    [self.view.window addSubview:popview];
}

#pragma mark -- popview Delegate
-(void)resaultsButtonClick:(UIButton *)button firstField:(UITextField *)ffield secondField:(UITextField *)sfield
{
    //获取输入的text
    NSString *email =ffield.text;
    NSString *number = [sfield.text trimOfString];
    //取消
    if (button.tag == 0) {
        
        [shadeView removeFromSuperview];
        [popview removeFromSuperview];
    }
    //sure按钮
    if (button.tag == 1) {
        if (email.length<=0 || number.length<=0 || ![email isValidateEmail:email] || ![number isValidateMobile:number]) {
            [_alertView show];
        }else
        {
            //保存数据
            [defaults setValue:email forKey:email_number];
            [defaults setValue:number forKey:muji_bind_number];
            
            VCLog(@"save-->email:%@,number:%@",email,number);
            [shadeView removeFromSuperview];
            [popview removeFromSuperview];
            
        }
    }

    
}
@end
