//
//  TXBoxNewTests.m
//  TXBoxNewTests
//
//  Created by Naron on 15/4/13.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#define userd [NSUserDefaults standardUserDefaults]

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "PinYin4Objc.h"
#import "BLEHelper.h"
#import "BLEmanager.h"

@interface TXBoxNewTests : XCTestCase

@end

@implementation TXBoxNewTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    /*
    HanyuPinyinOutputFormat *outputFormat =[[HanyuPinyinOutputFormat alloc] init];
    [outputFormat setToneType:ToneTypeWithoutTone];//声调
    [outputFormat setVCharType:VCharTypeWithV];//特殊拼音的显示格式如 ü
    [outputFormat setCaseType:CaseTypeLowercase];//大小(Lowercase)写

    NSString *str = @"啊";
    NSArray *Array = [PinyinHelper toHanyuPinyinStringArrayWithChar:[str characterAtIndex:0] withHanyuPinyinOutputFormat:outputFormat];
     NSMutableArray *allPY4CurrentHZ = [PinyinHelper toHanyuPinyinStringArrayWithChar:[str characterAtIndex:0 ] withHanyuPinyinOutputFormat:outputFormat];
    //NSArray *allPY4CurrentHZ = [PinyinHelper toHanyuPinyinString
    NSLog(@"allPY4CurrentHZ=%@",allPY4CurrentHZ);
     */
    
    BLEmanager *ble = [BLEmanager sharedInstance];
    Messages *m =[[Messages alloc] init];
    m.number = @"13698006536";
    m.content = @"这是一条短信，内容不知道有多长";
    [[BLEHelper shareHelper] requestTransmit:m withBLE:ble];
    [[BLEHelper shareHelper] sendDataWithMessage:m withBLE:ble];
    
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    //[self tearDown];
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.


    }];
}


//将传入的NSData类型转换成NSString并返回
- (NSString*)hexadecimalString:(NSData *)data{
    
    NSString* result;
    static const unsigned char*dataBuffer;
    dataBuffer = (const unsigned char*)[data bytes];
    
    if(!dataBuffer){
        return nil;
    }
    NSUInteger dataLength =[data length];//20;
    NSMutableString* hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
    for(int i = 0; i < dataLength; i++){
        
        [hexString appendString:[NSString stringWithFormat:@"%02lx ", (unsigned long)dataBuffer[i]]];
        
    }
    result = [NSString stringWithString:hexString];
    return result;
}


/**
 *  16进制字符串转化为汉字
 *  @param hexString hexString
 *  @return string
 */
- (NSString *)stringFromHexString:(NSString *)hexString {  // eg. hexString = @"8c376b4c"
    
    char *myBuffer = (char *)malloc((int)[hexString length] / 2 + 1);
    bzero(myBuffer, [hexString length] / 2 + 1);
    for (int i = 0; i < [hexString length] - 1; i += 2) {
        unsigned int anInt;
        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
    }
    NSString *unicodeString = [NSString stringWithCString:myBuffer encoding:NSUnicodeStringEncoding];
    //NSLog(@"unicodeString:%@",unicodeString);
    free(myBuffer);
    
    NSString *temp1 = [unicodeString stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *temp2 = [temp1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *temp3 = [[@"\"" stringByAppendingString:temp2] stringByAppendingString:@"\""];
    NSData *tempData = [temp3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *temp4 = [NSPropertyListSerialization propertyListWithData:tempData options:NSPropertyListImmutable format:NULL error:NULL];
    NSString *string = [temp4 stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@"\n"];
    
    NSLog(@"%@----%@",hexString, string); //输出 谷歌
    return string;
}

@end
