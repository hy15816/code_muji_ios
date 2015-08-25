//
//  ProvisionViewController.m
//  TXBoxNew
//
//  Created by Naron on 15/7/23.
//  Copyright (c) 2015年 playtime. All rights reserved.
//  服务条款

#import "ProvisionViewController.h"

@interface ProvisionViewController ()<UIScrollViewDelegate>
@property (strong, nonatomic)  UIScrollView *sc;

@end

@implementation ProvisionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.sc = [[UIScrollView alloc] initWithFrame:CGRectMake(5, 44+20+5, DEVICE_WIDTH-10, DEVICE_HEIGHT-10-44-20)];
    self.sc.contentSize =CGSizeMake(0, DEVICE_HEIGHT) ;
    self.sc.backgroundColor = RGBACOLOR(226, 226, 226, 1);
    self.sc.delegate = self;
    self.sc.bounces = YES;
    self.sc.showsVerticalScrollIndicator = YES;
    [self.view addSubview:self.sc];
    
    UILabel *l =[[UILabel alloc] initWithFrame:CGRectMake(100, 50, 50, 30)];
    l.backgroundColor =[UIColor blackColor];
    [self.sc addSubview:l];
    
    
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

@end
