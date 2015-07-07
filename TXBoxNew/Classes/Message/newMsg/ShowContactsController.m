//
//  ShowContactsController.m
//  TXBoxNew
//
//  Created by Naron on 15/6/5.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#define personTel @"personTel"
#define personName @"personName"

#import "ShowContactsController.h"
#import "ShowContactsCell.h"
#import "GetAllContacts.h"
@interface ShowContactsController ()<GetContactsDelegate>

{
    NSMutableArray *mutPhoneArr;
    NSMutableDictionary *phoneDic;      //同一个人的手机号码dic
    
    NSMutableArray *selectArray;
    NSMutableDictionary *selectDict;
    UIImageView *checkImg;
    UIImageView *disCheckImg;
    
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBtn;

@end

@implementation ShowContactsController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kHideCusotomTabBar object:self]];
    self.tabBarController.tabBar.hidden = YES;
    [self loadContacts];
    [self addFootview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mutPhoneArr = [[NSMutableArray alloc] init];
    phoneDic = [[NSMutableDictionary alloc] init];
    selectArray = [[NSMutableArray alloc] init];
    selectDict = [[NSMutableDictionary alloc] init];
    checkImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellBlueSelected"]];
    disCheckImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellNotSelected"]];
    self.cancelBtn.enabled = NO;
}

-(void)addFootview
{
    UIView *footv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 37)];
    UILabel *line =[[UILabel alloc] initWithFrame:CGRectMake(0, 1, DEVICE_HEIGHT, 1)];
    
    line.backgroundColor = [UIColor grayColor];
    line.alpha = .3;
    [footv addSubview:line];
    
    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, DEVICE_WIDTH, 25)];
    text.text = [NSString stringWithFormat:@"共%lu位联系人",mutPhoneArr.count];
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
    return mutPhoneArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ShowContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ShowContactsCellID" forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellBlueSelected"]];;
    cell.name.text = [[mutPhoneArr objectAtIndex:indexPath.row] valueForKey:personName];
    cell.number.text = [[mutPhoneArr objectAtIndex:indexPath.row] valueForKey:personTel];
    cell.checkImgv.hidden = YES;
    cell.accessoryView.hidden = YES;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath: indexPath ];
    
    if (cell.accessoryView.hidden == YES){
        //选中，如果数组里没有，则add
        if (![selectArray containsObject:[[mutPhoneArr objectAtIndex:indexPath.row] valueForKey:personTel]]) {
            if ([[mutPhoneArr objectAtIndex:indexPath.row] valueForKey:personTel]) {
                [selectDict setObject:[[mutPhoneArr objectAtIndex:indexPath.row] valueForKey:personTel]forKey:indexPath];
            }else{
                return;
            }
            
            [selectArray addObject:[[mutPhoneArr objectAtIndex:indexPath.row] valueForKey:personTel]];

            cell.accessoryView.hidden = NO;
        }
    
    }else{
        
        //如果数组里有，则remove
        if ([selectArray containsObject:[[mutPhoneArr objectAtIndex:indexPath.row] valueForKey:personTel]]) {
            [selectDict removeObjectForKey:indexPath];
            [selectArray removeObject:[[mutPhoneArr objectAtIndex:indexPath.row] valueForKey:personTel]];

            cell.accessoryView.hidden = YES;
        }
        
    }

    if (selectArray.count > 0) {
        self.cancelBtn.enabled = YES;
        [self.cancelBtn setTitle:@"确定"];
    }else{
        self.cancelBtn.enabled = NO;
    }
    
    
    VCLog(@"selectDict:%@",selectDict);
    VCLog(@"selectArray:%@",selectArray);
    //[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark-- 获取通讯录联系人
-(void)loadContacts
{
    GetAllContacts *contacts = [[GetAllContacts alloc] init];
    contacts.getContactsDelegate = self;
    [contacts getContacts];
}

#pragma mark -- getContacts Delegate
-(void)getAllPhoneArray:(NSMutableArray *)array SectionDict:(NSMutableDictionary *)sDict PhoneDict:(NSMutableDictionary *)pDict
{
    mutPhoneArr = array;
    VCLog(@"mutPhoneArray:%@",array);
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if (sender != self.cancelBtn) {
        return;
    }
    if (selectArray.count >0) {
        self.selectContacts = [[ShowContacts alloc] init];
        self.selectContacts.mmutArray = selectArray;
    }

    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

@end
