//
//  ConBook.m
//  TXBoxNew
//
//  Created by Naron on 15/8/11.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "ConBook.h"

@implementation ConBook

@synthesize recordID = _recordID;

@synthesize prefixName = _prefixName;
@synthesize lastName = _lastName;
@synthesize middleName = _middleName;
@synthesize firstName = _firstName;
@synthesize suffixName = _suffixName;
@synthesize fullName = _fullName;

@synthesize phoneNumberArray = _phoneNumberArray;
@synthesize emailArray = _emailArray;


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

@end



