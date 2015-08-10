//
//  GetAllContacts.m
//  TXBoxNew
//
//  Created by Naron on 15/6/17.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "GetAllContacts.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "NSString+helper.h"

@interface GetAllContacts ()
{
    NSMutableDictionary *sectionDicts;
    NSMutableDictionary *phoneDicts;
    NSMutableArray *phonesArray;
}
@end

@implementation GetAllContacts
@synthesize getContactsDelegate;

-(id)init{
    self = [super init];
    if (self) {
        //
        phoneDicts = [[NSMutableDictionary alloc] init];
        sectionDicts =[[NSMutableDictionary alloc] init];
        phonesArray = [[NSMutableArray alloc] init];
    }
    return self;
}

+(GetAllContacts *)shardGet{
    static dispatch_once_t onceToken;
    static GetAllContacts *gets;
    dispatch_once(&onceToken, ^{
        gets=[[GetAllContacts alloc] init];
    });
    return gets;
}
-(void)reloadContacts{
    [self loadAllContacts];
    [self.getContactsDelegate getAllPhoneArray:phonesArray SectionDict:sectionDicts PhoneDict:phoneDicts];
}

-(void)loadAllContacts{
    
    [phonesArray removeAllObjects];
    [sectionDicts removeAllObjects];
    [phoneDicts   removeAllObjects];
    
    //设置sectionDic的键（key）,无值
    for (int i = 0; i < 26; i++){
        
        [sectionDicts setObject:[NSMutableArray array] forKey:[NSString stringWithFormat:@"%c",'A'+i]];
    }
    [sectionDicts setObject:[NSMutableArray array] forKey:[NSString stringWithFormat:@"%c",'~']];
    
    
    //初始化电话簿
    ABAddressBookRef myAddressBook = nil;
    CFErrorRef *error = nil;
    
    //判断ios版本，6.0+需获取权限
    if (IOS_DEVICE_VERSION>=6.0) {
        
        myAddressBook=ABAddressBookCreateWithOptions(NULL, error);
        dispatch_semaphore_t sema=dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(myAddressBook, ^(bool greanted, CFErrorRef error){
            dispatch_semaphore_signal(sema);
        });
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        
    }
    else
    {
        //6.0以下直接获取
        
        myAddressBook = ABAddressBookCreateWithOptions(nil, error);
        //myAddressBook =ABAddressBookCreate();
    }
    
    if (myAddressBook==nil) {
        return ;
    };
    
    //取得本地所有联系人记录
    CFArrayRef results = ABAddressBookCopyArrayOfAllPeople(myAddressBook);
    //VCLog(@"results：%@",results);
    
    CFMutableArrayRef mresults=CFArrayCreateMutableCopy(kCFAllocatorDefault,CFArrayGetCount(results),results);
    
    //将结果按照拼音排序，将结果放入mresults数组中
    CFArraySortValues(mresults,
                      CFRangeMake(0, CFArrayGetCount(results)),
                      (CFComparatorFunction) ABPersonComparePeopleByName,
                      ((void*)ABPersonGetSortOrdering()));
    
    //遍历所有联系人
    for (int k=0;k<CFArrayGetCount(mresults);k++) {
        NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
        //管理地址簿中条目的基类对象是 ABRecord,可以表示一个人 或者一个群体 ABGroup。ABRecord 的指针，标示为 ABRecordRef
        ABRecordRef record=CFArrayGetValueAtIndex(mresults,k);
        //返回个人或群体完整名称
        //NSString *personname = (__bridge NSString *)ABRecordCopyCompositeName(record);
        
        NSString *firstName =(__bridge NSString *)ABRecordCopyValue(record, kABPersonSortByFirstName);  //返回个人名字
        NSString *lastName =(__bridge NSString *)ABRecordCopyValue(record, kABPersonSortByLastName);    //返回个人姓
        NSString *name;
        if (firstName.length>0 && lastName.length>0) {
            name = [[NSString alloc] initWithFormat:@"%@%@",lastName,firstName];
        }else if (firstName.length == 0 && lastName.length>0){
            name = [[NSString alloc] initWithFormat:@"%@",lastName];
        }else if (firstName.length >0 && lastName.length==0){
            name = [[NSString alloc] initWithFormat:@"%@",firstName];
        }else
        {
            name = [[NSString alloc] initWithFormat:@"未知"];
        }
        
        //转拼音
        NSString *namePinYin = [name hanziTopinyin];
        NSString *nameNum = [namePinYin pinyinTrimIntNumber];
        NSString *nameFirstChars = [[name getFirstCharWithHanZi] pinyinTrimIntNumber];
        
        //获取电话号码，通用的，基本的,概括的
        ABMultiValueRef personPhone = ABRecordCopyValue(record, kABPersonPhoneProperty);
        //记录在底层数据库中的ID号。具有唯一性
        ABRecordID recordID=ABRecordGetRecordID(record);
        //循环取出详细的每条号码记录
        for (int k = 0; k<ABMultiValueGetCount(personPhone); k++)
        {
            NSString * phone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(personPhone, k);
            
            //加入phoneDic中
            [phoneDicts setObject:(__bridge id)(record) forKey:[NSString stringWithFormat:@"%@%d",phone,recordID]];
            [tempDic setObject:phone forKey:PersonTel];//把每一条号码存为key:“personTel”的Value
            NSString *phoneNum = [NSString stringWithFormat:@"%@",[phone purifyString]];
            
            [tempDic setObject:phoneNum forKey:PersonTelNum];//-数字号码
            
        }
        [tempDic setObject:name forKey:PersonName];//把名字存为key:"personName"的Value
        [tempDic setObject:nameNum forKey:PersonNameNum];
        [tempDic setObject:(__bridge id)(record) forKey:PersonRecordRef];
        [tempDic setObject:nameFirstChars forKey:FirstNameChars];
        //VCLog(@"tempDictemp：%@",tempDic);
        [phonesArray addObject:tempDic];//把tempDic赋给phoneArray数组
        
    }
    CFIndex nPeople = ABAddressBookGetPersonCount(myAddressBook);
    VCLog(@"people count %ld",nPeople);
    VCLog(@"phoneArray：%@",phonesArray);
    //return phonesArray;
    
    /***
     *  __bridge               arc显式转换。 与__unsafe_unretained 关键字一样 只是引用。
     *  __bridge_retained      类型被转换时，其对象的所有权也将被变换后变量所持有
     *  __bridge_transfer      本来拥有对象所有权的变量，在类型转换后，让其释放原先所有权 就相当于__bridge_retained后，原对像执行了release操作
     */
    
    
}

-(void)getContacts
{
    [self loadAllContacts];
    [self.getContactsDelegate getAllPhoneArray:phonesArray SectionDict:sectionDicts PhoneDict:phoneDicts];
}

@end
