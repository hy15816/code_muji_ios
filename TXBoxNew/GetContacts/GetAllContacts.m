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
    
    /*
    for (int s=0; s<1000; s++) {
        [self adds];
    }
    */
    
    
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
        {   ABMultiValueRef personPhone = ABRecordCopyValue(record, kABPersonPhoneProperty);
            if (ABMultiValueGetCount(personPhone)>0) {
                name = (__bridge NSString*)ABMultiValueCopyValueAtIndex(personPhone, 0);
                name = [name purifyString];
            }else{name = @"未命名";}
        }
        
        //转拼音
        NSMutableArray *namePinYinArray = [name hanziTopinyin];
        for (int l=0;l<namePinYinArray.count;l++) {
            namePinYinArray[l] = [namePinYinArray[l] pinyinTrimIntNumber];
        }
        
        NSMutableArray *nameFirstCharsArr = [name getFirstCharWithHanZi] ;
        for (int j=0;j<nameFirstCharsArr.count;j++) {
            nameFirstCharsArr[j] = [nameFirstCharsArr[j] pinyinTrimIntNumber];
        }
        
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
        [tempDic setObject:namePinYinArray forKey:PersonNameNum];
        [tempDic setObject:[NSString stringWithFormat:@"%d",recordID] forKey:PersonRecordID];
        [tempDic setObject:nameFirstCharsArr forKey:FirstNameChars];
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
/**
 *  添加测试数据，模拟联系人数据
 */
-(void)adds{
    //int delta = 0x9fa5-0x4e00 + 1;
        NSString *phoneNumber = [NSString stringWithFormat:@"1%d%d%d%d%d%d%d%d%d%d",arc4random_uniform(8),arc4random_uniform(8),arc4random_uniform(8),arc4random_uniform(8),arc4random_uniform(8),arc4random_uniform(8),arc4random_uniform(8),arc4random_uniform(8),arc4random_uniform(8),arc4random_uniform(8)];
    NSString *name = [NSString stringWithFormat:@"%@%@%d%d%d",[self getHanzi],[self getPinyin],arc4random_uniform(8),arc4random_uniform(8),arc4random_uniform(8)];
    [self addContacts:name number:phoneNumber];
    
}

/**
 *  高效费舍尔茨洗牌(这里只获取前3个字)
 */
-(NSString *)getPinyin{
    
    NSString *alphabet = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    
    // Get the characters into a C array for efficient shuffling
    NSUInteger numberOfCharacters = [alphabet length];
    unichar *characters = calloc(numberOfCharacters, sizeof(unichar));
    [alphabet getCharacters:characters range:NSMakeRange(0, numberOfCharacters)];
    
    // Perform a Fisher-Yates shuffle
    for (NSUInteger i = 0; i < numberOfCharacters; ++i) {
        NSUInteger j = (NSInteger)arc4random_uniform(numberOfCharacters - i) + i;
        unichar c = characters[i];
        characters[i] = characters[j];
        characters[j] = c;
    }
    
    // Turn the result back into a string
    NSString *result = [NSString stringWithCharacters:characters length:numberOfCharacters];
    free(characters);
    return [result substringToIndex:3];
    
    
}

/**
 *  随机获取3个汉字
 */
-(NSString *)getHanzi{
    NSMutableString *sname = [[NSMutableString alloc] initWithString:@""];;
    for (int i=0; i<3; i++) {
        NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSInteger randomH = 0xA1+arc4random()%(0xFE - 0xA1+1);
        NSInteger randomL = 0xB0+arc4random()%(0xF7 - 0xB0+1);
        
        NSInteger number = (randomH<<8)+randomL;
        NSData *data = [NSData dataWithBytes:&number length:2];
        
        NSString *string = [[NSString alloc] initWithData:data encoding:gbkEncoding];
        
        [sname appendFormat:@"%@",string];
        
    }
    return (NSString *)sname;
}
/**
 *  转化成为数据源，提供搜索
 */
-(void)addContacts:(NSString *)name number:(NSString *)numbers{
    
    NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
    //转拼音
    NSMutableArray *namePinYinArray = [name hanziTopinyin];
    for (int l=0;l<namePinYinArray.count;l++) {
        namePinYinArray[l] = [namePinYinArray[l] pinyinTrimIntNumber];
    }
    
    NSMutableArray *nameFirstCharsArr = [name getFirstCharWithHanZi] ;
    for (int j=0;j<nameFirstCharsArr.count;j++) {
        nameFirstCharsArr[j] = [nameFirstCharsArr[j] pinyinTrimIntNumber];
    }
    NSString *rid = [NSString stringWithFormat:@"%d",(arc4random()%200)+100];
    
    [tempDic setObject:numbers forKey:PersonTel];
    [tempDic setObject:numbers forKey:PersonTelNum];//-数字号码
    [tempDic setObject:name forKey:PersonName];//把名字存为key:"personName"的Value
    [tempDic setObject:namePinYinArray forKey:PersonNameNum];
    [tempDic setObject:rid forKey:PersonRecordID];
    [tempDic setObject:nameFirstCharsArr forKey:FirstNameChars];
    [phonesArray addObject:tempDic];
}

-(void)getContacts
{
    [self loadAllContacts];
    [self.getContactsDelegate getAllPhoneArray:phonesArray SectionDict:sectionDicts PhoneDict:phoneDicts];
}

@end
