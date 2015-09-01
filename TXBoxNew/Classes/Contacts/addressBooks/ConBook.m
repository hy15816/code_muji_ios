//
//  ConBook.m
//  TXBoxNew
//
//  Created by Naron on 15/8/11.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "ConBook.h"

@interface ConBook ()
{
    ABAddressBookRef addressBook;
}
@property (assign,nonatomic) ABAddressBookRef addressBook;
@end

@implementation ConBook
@synthesize addressBook;
@synthesize recordID = _recordID;

@synthesize prefixName = _prefixName;
@synthesize lastName = _lastName;
@synthesize middleName = _middleName;
@synthesize firstName = _firstName;
@synthesize suffixName = _suffixName;
@synthesize fullName = _fullName;

@synthesize phoneNumberArray = _phoneNumberArray;
@synthesize emailArray = _emailArray;




+(ConBook *)sharBook{
    
    ConBook *book;
    
    if (!book) {
        book = [[ConBook alloc] init];
    }
    
    return book;
}
-(id)init{
    self = [super init];
    if (self) {
        //
        addressBook = ABAddressBookCreateWithOptions(nil, nil);
        
    }
    return self;
    
}

-(NSString *)AssemblyName{
    
    if (_prefixName.length<=0) {
        _prefixName = @"";
    }
    if (_lastName.length<=0) {
        _lastName = @"";
    }
    if (_middleName.length<=0) {
        _middleName = @"";
    }
    if (_firstName.length<=0) {
        _firstName = @"";
    }
    if (_suffixName.length<=0) {
        _suffixName = @"";
    }
    
    _fullName = [NSString stringWithFormat:@"%@%@%@%@%@",_prefixName,_lastName,_middleName,_firstName,_suffixName];
    
    if (_phoneNumberArray.count>0 || _fullName.length > 0) {
        return _fullName.length>0?_fullName:_phoneNumberArray[0];
    }
    
    return _emailArray.count>0?_emailArray[0]:@"未命名";
    
}

-(NSString *)getCompositeName:(ABRecordRef)record{
    NSString  *compositeName = (__bridge NSString *)(ABRecordCopyCompositeName(record));
    
    if (compositeName.length == 0) {
        //获取号码
        ABMultiValueRef phoneNumber = ABRecordCopyValue(record, kABPersonPhoneProperty);
        if (ABMultiValueGetCount(phoneNumber) > 0) {
            NSString *phone = [NSString stringWithFormat:@"%@;",ABMultiValueCopyValueAtIndex(phoneNumber,0)];
            NSLog(@"phone:%@",phone);
            compositeName = phone;
        }
        
    }
    return compositeName.length>0?compositeName:@"1无名称";
}
/**
 *  根据一条联系人记录(recordRef)获取ID
 */
-(ABRecordID)getRecordIDByRef:(ABRecordRef)recordRef{
    ABRecordID abid = 0;
    abid = ABRecordGetRecordID(recordRef);
    return abid;
}

/**
 *  根据ID和通讯录对象获取一条联系人记录(recordRef)
 */
-(ABRecordRef)getRecordRefWithID:(ABRecordID)recordID{
    ABRecordRef abRef = nil;
    abRef = ABAddressBookGetPersonWithRecordID(addressBook, recordID);
    return abRef;
}
/**
 *  获取一个通讯录对象
 */
-(ABAddressBookRef)getAbAddressBookRef:(CFDictionaryRef)option error:(CFErrorRef *)error{
    ABAddressBookRef addressbook = nil;
    addressbook = ABAddressBookCreateWithOptions(option, error);
    return addressbook;
}

/**
 *  获取组装的名字
 *  @param abRef ABRecordRef
 *  @return name
 */
-(NSString *)getNameWithRef:(ABRecordRef)abRef{
    NSString *allName;
    
    NSString  *firstName = (__bridge NSString *)(ABRecordCopyValue(abRef, kABPersonFirstNameProperty));
    NSString  *lastName = (__bridge NSString *)(ABRecordCopyValue(abRef, kABPersonLastNameProperty));
    
    if (firstName.length == 0) {
        firstName = @"";
    }
    if (lastName.length == 0) {
        lastName = @"";
    }

    allName = [NSString stringWithFormat:@"%@%@",lastName,firstName];
    if (firstName.length == 0 && lastName.length == 0) {
        //获取号码
        ABMultiValueRef phoneNumber = ABRecordCopyValue(abRef, kABPersonPhoneProperty);
        if (ABMultiValueGetCount(phoneNumber) > 0) {
            NSString *phone = [NSString stringWithFormat:@"%@;",ABMultiValueCopyValueAtIndex(phoneNumber,0)];
            NSLog(@"phone:%@",phone);
            allName = phone;
        }
        
    }
    
    return allName.length>0?allName:@"";
}

/**
 *  获取组装的名字
 *  @param abid ABRecordID
 *  @return name
 */
-(NSString *)getNameWithAbid:(ABRecordID)abid {
    NSString *allName;
     ABRecordRef ref = ABAddressBookGetPersonWithRecordID(addressBook, abid);
    
    NSString  *firstName = (__bridge NSString *)(ABRecordCopyValue(ref, kABPersonFirstNameProperty));
    NSString  *lastName = (__bridge NSString *)(ABRecordCopyValue(ref, kABPersonLastNameProperty));
    
    if (firstName.length == 0) {
        firstName = @"";
    }
    if (lastName.length == 0) {
        lastName = @"";
    }
    
    allName = [NSString stringWithFormat:@"%@%@",lastName,firstName];
    if (firstName.length == 0 && lastName.length == 0) {
        //获取号码
        ABMultiValueRef phoneNumber = ABRecordCopyValue(ref, kABPersonPhoneProperty);
        if (ABMultiValueGetCount(phoneNumber) > 0) {
            NSString *phone = [NSString stringWithFormat:@"%@;",ABMultiValueCopyValueAtIndex(phoneNumber,0)];
            allName = phone;
        }
        
    }
    
    return allName.length>0?allName:@"1无名称";
}


-(NSString *)getFirstNumber:(ABRecordID)abid {
    NSString *number = @"" ;
    NSMutableArray *phongArray = [[NSMutableArray alloc] init];
    
    ABRecordRef ref =  [self getRecordRefWithID:abid];
    
    ABMultiValueRef phoneNumber = ABRecordCopyValue(ref, kABPersonPhoneProperty);
    if (ABMultiValueGetCount(phoneNumber) > 0) {
        for (int i=0; i<ABMultiValueGetCount(phoneNumber); i++) {
            NSString *phone = [NSString stringWithFormat:@"%@",ABMultiValueCopyValueAtIndex(phoneNumber,i)];
            [phongArray addObject:phone];
        }
        
    }
    if (phongArray.count >0) {
        number = phongArray[0];
    }
    
    
    return number.length>0?number:@"";
}

-(NSMutableArray *)getNumberArray:(ABRecordID)abid{

    NSMutableArray *phongArray = [[NSMutableArray alloc] init];
    
    ABRecordRef ref =  [self getRecordRefWithID:abid];
    
    ABMultiValueRef phoneNumber = ABRecordCopyValue(ref, kABPersonPhoneProperty);
    if (ABMultiValueGetCount(phoneNumber) > 0) {
        for (int i=0; i<ABMultiValueGetCount(phoneNumber); i++) {
            NSString *phone = [NSString stringWithFormat:@"%@",ABMultiValueCopyValueAtIndex(phoneNumber,i)];
            [phongArray addObject:phone];
        }
        
    }
    
    
    return phongArray;
}

/**
 *  根据联系人号码获取名字
 *
 */
-(NSString *)getRecordRefWithName:(NSString *)name{
    NSString *nameString = [[NSString alloc] init];
    CFStringRef cfName = (__bridge CFStringRef)name;
    NSArray *array = (__bridge NSArray *)(ABAddressBookCopyPeopleWithName(addressBook, cfName));
    ABRecordRef ref = CFBridgingRetain(array[0]);
    nameString = [self getNameWithRef:ref];
    return nameString;
}

/**
 *  添加联系人到通讯录
 *
 */
-(BOOL)addPerson:(ConBook *)conbook{
    CFErrorRef error;
    //abAddressBookRef = ABAddressBookCreateWithOptions(NULL, &error);
    //创建一条联系人记录
    ABRecordRef tmpRecord = ABPersonCreate();
    BOOL tmpSuccess = NO;
    
    CFStringRef lastName = (__bridge CFStringRef)conbook.lastName;
    tmpSuccess = ABRecordSetValue(tmpRecord, kABPersonLastNameProperty, lastName, &error);
    
    CFStringRef middleName = (__bridge CFStringRef)conbook.middleName;
    tmpSuccess = ABRecordSetValue(tmpRecord, kABPersonMiddleNameProperty, middleName, &error);
    
    CFStringRef firstName = (__bridge CFStringRef)conbook.firstName;
    tmpSuccess = ABRecordSetValue(tmpRecord, kABPersonFirstNameProperty, firstName, &error);
    
    CFTypeRef tmpPhones = (__bridge CFStringRef)conbook.phoneNumberArray[0];
    ABMutableMultiValueRef tmpMutableMultiPhones = ABMultiValueCreateMutable(kABPersonPhoneProperty);
    ABMultiValueAddValueAndLabel(tmpMutableMultiPhones, tmpPhones, kABPersonPhoneMobileLabel, NULL);
    tmpSuccess = ABRecordSetValue(tmpRecord, kABPersonPhoneProperty, tmpMutableMultiPhones, &error);
    
    tmpSuccess = ABAddressBookAddRecord(addressBook, tmpRecord, &error);
    tmpSuccess = ABAddressBookSave(addressBook, &error);
    
    return tmpSuccess;
}
/**
 *  组合名字
 */
-(NSString *)AssemblyName:(NSString *)prefixName lastn:(NSString *)lastn middleName:(NSString *)middleName firstn:(NSString *)firstn suffixName:(NSString *)suffixName{
    
    NSString *fullName;
    if (prefixName.length<=0) {
        prefixName = @"";
    }
    if (lastn.length<=0) {
        lastn = @"";
    }
    if (middleName.length<=0) {
        middleName = @"";
    }
    if (firstn.length<=0) {
        firstn = @"";
    }
    if (suffixName.length<=0) {
        suffixName = @"";
    }
    
    fullName = [NSString stringWithFormat:@"%@%@%@%@%@",prefixName,lastn,middleName,firstn,suffixName];
    return fullName.length>0?fullName:@"1无名称";
    
}

+ (NSString *)getCountryCode
{
    NSLocale *currentLocale = [NSLocale currentLocale];
    
    //    NSLog(@"Country Code is %@", [currentLocale objectForKey:NSLocaleCountryCode]);
    return [currentLocale objectForKey:NSLocaleCountryCode];
}
+ (NSString *)getLanguageCode
{
    NSLocale *currentLocale = [NSLocale currentLocale];
    
    NSLog(@"Language Code is %@", [currentLocale objectForKey:NSLocaleLanguageCode]);
    
    return [currentLocale objectForKey:NSLocaleLanguageCode];
}

@end



