//
//  ShowContactsController.m
//  TXBoxNew
//
//  Created by Naron on 15/6/5.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "ShowContactsController.h"
#import "ShowContactsCell.h"

@interface ShowContactsController ()

{
    NSMutableArray *contactsRefArray;   //保存联系人对象
    
    NSMutableArray *selectArray;
    NSIndexPath  *currentPath;
    NSString *currentName;
}
@property (assign,nonatomic) ABAddressBookRef addressBookRef;

@end

@implementation ShowContactsController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kHideCusotomTabBar object:self]];
    self.tabBarController.tabBar.hidden = YES;
    
    [self addFootview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CFErrorRef error;
    _addressBookRef =ABAddressBookCreateWithOptions(nil, &error);
    contactsRefArray = (__bridge NSMutableArray *)(ABAddressBookCopyArrayOfAllPeople(_addressBookRef));
    
    selectArray = [[NSMutableArray alloc] init];
    currentName = [[NSString alloc] init];
}

-(void)addFootview
{
    UIView *footv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 37)];
    UILabel *line =[[UILabel alloc] initWithFrame:CGRectMake(0, 1, DEVICE_HEIGHT, 1)];
    
    line.backgroundColor = [UIColor grayColor];
    line.alpha = .3;
    [footv addSubview:line];
    
    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, DEVICE_WIDTH, 25)];
    text.text = [NSString stringWithFormat:@"共%lu位联系人",contactsRefArray.count];
    text.textAlignment = NSTextAlignmentCenter;
    text.font = [UIFont systemFontOfSize:16];
    
    UILabel *line2 =[[UILabel alloc] initWithFrame:CGRectMake(0, 36, DEVICE_HEIGHT, 1)];
    
    line2.backgroundColor = [UIColor grayColor];
    line2.alpha = .3;
    [footv addSubview:line2];
    
    [footv addSubview:text];
    self.tableView.tableFooterView = footv;


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return contactsRefArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ShowContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ShowContactsCellID" forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    ABRecordRef record = (__bridge ABRecordRef)([contactsRefArray objectAtIndex:indexPath.row]);
    NSString  *firstName = (__bridge NSString *)(ABRecordCopyValue(record, kABPersonFirstNameProperty));
    NSString  *lastName = (__bridge NSString *)(ABRecordCopyValue(record, kABPersonLastNameProperty));
    
    if (firstName.length == 0) {
        firstName = @"";
    }
    if (lastName.length == 0) {
        lastName = @"";
    }
    
    cell.name.text = [NSString stringWithFormat:@"%@%@",firstName,lastName];
    //获取号码
    ABMultiValueRef phoneNumber = ABRecordCopyValue(record, kABPersonPhoneProperty);
    if (ABMultiValueGetCount(phoneNumber) > 0) {
        NSString *phone = [NSString stringWithFormat:@"%@",ABMultiValueCopyValueAtIndex(phoneNumber,0)];//取第一个号码
        NSLog(@"phone:%@",phone);
        cell.number.text  = phone;
    
    
    }else{
        cell.number.text = @"";
    }
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ABRecordRef record = (__bridge ABRecordRef)([contactsRefArray objectAtIndex:indexPath.row]);
    NSString  *firstName = (__bridge NSString *)(ABRecordCopyValue(record, kABPersonFirstNameProperty));
    NSString  *lastName = (__bridge NSString *)(ABRecordCopyValue(record, kABPersonLastNameProperty));
    
    if (firstName.length == 0) {
        firstName = @"";
    }
    if (lastName.length == 0) {
        lastName = @"";
    }
    NSDictionary *dict=@{isRecordRef:(__bridge NSString *)record,isRead:@"1"};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refnoti" object:self userInfo:dict];
    [userDefaults setBool:YES forKey:isRead];
    [self dismissViewControllerAnimated:YES completion:nil];

    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

@end
