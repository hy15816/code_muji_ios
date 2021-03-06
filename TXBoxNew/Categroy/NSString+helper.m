//
//  NSString+helper.h
//  hy
//
//  Created by mac on 15-04-12.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import "NSString+helper.h"
#import "PinYin4Objc.h"


@implementation NSString (helper)

#pragma mark --去除字符串左右的空格以及换行符，中间的清不了
-(NSString *)trimLeftOrRightString{

    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

}

#pragma mark --去除字符串中的空格
-(NSString *)trimOfString
{
    //其实是替换
    return [self stringByReplacingOccurrencesOfString:@" " withString:@""];
}


#pragma mark --是否为空字符串
-(BOOL) isEmptyString{
    
    return (self == nil || self.length ==0);

}

#pragma mark --过滤字符串中的“－”
-(NSString *) iPhoneStandardFormat{
   return [self stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
}

#pragma mark --过滤字符串中的“,”
-(NSString *) iPhoneStandards_douhao_En{
    return [self stringByReplacingOccurrencesOfString:@"," withString:@""];
    
}

#pragma mark --过滤字符串中的“，”
-(NSString *) iPhoneStandards_douhao_Ch{
    return [self stringByReplacingOccurrencesOfString:@"，" withString:@""];
    
}

#pragma mark --过滤字符串中的“(”
-(NSString *) iPhoneStandardedFormat{
    return [self stringByReplacingOccurrencesOfString:@"(" withString:@""];
    
}

#pragma mark --过滤字符串中的“)”
-(NSString *) iPhoneStandardededFormat{
    return [self stringByReplacingOccurrencesOfString:@")" withString:@""];
    
}

#pragma mark --过滤字符串中的““”,
-(NSString *) iPhoneStandardedleftMarkFormat{
    return [self stringByReplacingOccurrencesOfString:@"“" withString:@""];
    
}
#pragma mark --过滤字符串中的“””
-(NSString *) iPhoneStandardedrightMarkFormat{
    return [self stringByReplacingOccurrencesOfString:@"”" withString:@""];
    
}
#pragma mark --过滤字符串中的“*”
-(NSString *) iPhoneStandardedXingMarkFormat{
    return [self stringByReplacingOccurrencesOfString:@"*" withString:@""];
    
}
#pragma mark --过滤字符串中的“\\w”
-(NSString *) iPhoneStandardedWWMarkFormat{
    return [self stringByReplacingOccurrencesOfString:@"\\w" withString:@""];
    
}

#pragma mark --写入系统偏好
-(void)saveToNSDefaultWithKey:(NSString*)key{

    [[NSUserDefaults standardUserDefaults]setObject:self forKey:key];
    [[NSUserDefaults standardUserDefaults]synchronize];

}

#pragma mark --格式化，如“123-4567-8910”
-(NSString *)insertStr
{
    NSMutableString *mutStr = [[NSMutableString alloc] initWithFormat:@"%@",self];
    //str<=7
    if (mutStr.length<=8) {
        return (NSString *)mutStr;
    }
    //str>7
    
    if (mutStr.length>8 &&mutStr.length<=11) {
        [mutStr insertString:@"-" atIndex:3];
        [mutStr insertString:@"-" atIndex:8];
        return (NSString *)mutStr;
    }
    
    if (mutStr.length==12 ) {
        [mutStr insertString:@"-" atIndex:4];
        return (NSString *)mutStr;

    }
    
    if (mutStr.length>11) {
        [mutStr insertString:@" " atIndex:3];
        [mutStr insertString:@"-" atIndex:7];
        [mutStr insertString:@"-" atIndex:12];
        return (NSString *)mutStr;
    }
    
    
    return (NSString *)mutStr;
}

#pragma mark --过滤字符串
-(NSString *)purifyString
{
    NSString *string = [[NSString alloc] init];
    
    if (self.length>0) {
        string = [self trimLeftOrRightString];//去除左右空格和换行符
        string = [string iPhoneStandardedFormat ];//去除左括号
        string = [string iPhoneStandardededFormat];//去除右括号
        string = [string trimOfString];     //去除字符串中间的空格
        string = [string iPhoneStandardFormat];//去除 -
        
        string = [string iPhoneStandards_douhao_En];//逗号
        string = [string iPhoneStandards_douhao_Ch];//逗号
        string = [string iPhoneStandardedleftMarkFormat];
        string = [string iPhoneStandardedrightMarkFormat];
        //551 87896
        //123654896
        //string = [string iPhoneStandardedWWMarkFormat];
        //string = [string iPhoneStandardedXingMarkFormat];
    }
    return string;
}

#pragma mark --给string 计算文本size
- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize
{  NSDictionary *attrs = @{NSFontAttributeName: font};
    CGSize size =[self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
    return size;
}


#pragma mark --邮箱验证
-(BOOL)isValidateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

#pragma mark --手机号码验证
-(BOOL) isValidateMobile:(NSString *)mobile
{
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    //    NSLog(@"phoneTest is %@",phoneTest);
    return [phoneTest evaluateWithObject:mobile];
}

#pragma mark --车牌号验证
-(BOOL) validateCarNo:(NSString* )carNo;
{
    NSString *carRegex = @"^[A-Za-z]{1}[A-Za-z_0-9]{5}$";
    NSPredicate *carTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",carRegex];
    NSLog(@"carTest is %@",carTest);
    return [carTest evaluateWithObject:carNo];
}

#pragma mark -- 汉字转拼音
-(NSMutableArray  *)hanziTopinyin{
    
    HanyuPinyinOutputFormat *outputFormat =[[HanyuPinyinOutputFormat alloc] init];
    [outputFormat setToneType:ToneTypeWithoutTone];//声调
    [outputFormat setVCharType:VCharTypeWithV];//特殊拼音的显示格式如 ü
    [outputFormat setCaseType:CaseTypeLowercase];//大小(Lowercase)写
    NSString *inSeperator = @"-";
    
    NSString *hanzi =  self;
    if (hanzi.length <= 5) {
        NSMutableArray *outStringListList = [[NSMutableArray alloc] init];
        for(int i = 0;i < hanzi.length; i++){
            NSString *currChar = [hanzi substringWithRange:NSMakeRange(i, 1)];//取出每个汉字
            NSMutableArray *thisList = [[NSMutableArray alloc] init];
            if ([self thisHanZi: [currChar characterAtIndex:0]]) {
                NSMutableArray *allPY4CurrentHZ = (NSMutableArray*)[PinyinHelper toHanyuPinyinStringArrayWithChar:[currChar characterAtIndex:0]withHanyuPinyinOutputFormat:outputFormat];//转化成拼音，若是多音字则有多个
                
                if (allPY4CurrentHZ.count != 0) {
                    for (int j = 0; j < allPY4CurrentHZ.count; j++) {
                        allPY4CurrentHZ[j] = [NSString stringWithFormat:@"%@%@",inSeperator,allPY4CurrentHZ[j]];//格式化，加上‘-’
                    }
                    [thisList addObject:allPY4CurrentHZ];
                }
            }else{//不是汉字，直接添加，
                NSMutableArray *a = [[NSMutableArray alloc] initWithObjects:[NSString stringWithFormat:@"%@%@",inSeperator,currChar], nil];
                [thisList addObject:a];
            }
            
            [outStringListList addObject:thisList];
            
        }
        
        //字符串长度小于5个
        NSMutableArray *mutArray =[[NSMutableArray alloc] initWithObjects:@"", nil];
        for (NSArray *ar in outStringListList) {//abc中的所有数组

            NSMutableArray *arr = [[NSMutableArray alloc] init];
            for (NSArray *s in ar) {//abc中数组里的所有元素

                for (NSString *a in s) {

                    for (NSString *ss in mutArray) {//mutArray中的所有元素
                        if (![arr containsObject:[NSString stringWithFormat:@"%@%@",ss,a]]) {
                            [arr addObject:[NSString stringWithFormat:@"%@%@",ss,a]];
                        }
                        
                    }
                }
                
                
            }
            mutArray = arr;//把arr赋给mutArray
        }
        return mutArray;
    }else{//长度大于5
        
        NSMutableArray *outStringListList = [[NSMutableArray alloc] init];
        for(int i = 0;i < hanzi.length; i++){
            NSString *currChar = [hanzi substringWithRange:NSMakeRange(i, 1)];//取出每个汉字
            NSMutableArray *thisList = [[NSMutableArray alloc] init];
            if ([self thisHanZi: [currChar characterAtIndex:0]]) {
                NSMutableArray *allPY4CurrentHZ = (NSMutableArray*)[PinyinHelper toHanyuPinyinStringArrayWithChar:[currChar characterAtIndex:0]withHanyuPinyinOutputFormat:outputFormat];//转化成拼音，若是多音字则有多个
                
                if (allPY4CurrentHZ.count != 0) {
                    for (int j = 0; j < allPY4CurrentHZ.count; j++) {
                        allPY4CurrentHZ[j] = [NSString stringWithFormat:@"%@%@",inSeperator,allPY4CurrentHZ[j]];//格式化，加上‘-’
                    }
                    NSArray *arr = [NSArray arrayWithObject:[allPY4CurrentHZ objectAtIndex:0]];
                    [thisList addObject:arr];
                    
                }
            }else{//不是汉字，直接添加，
                NSMutableArray *a = [[NSMutableArray alloc] initWithObjects:[NSString stringWithFormat:@"%@%@",inSeperator,currChar], nil];
                [thisList addObject:a];
            }
            
            [outStringListList addObject:thisList];
            
        }
        NSMutableArray *mutArray =[[NSMutableArray alloc] initWithObjects:@"", nil];
        NSMutableString *string = [[NSMutableString alloc] initWithString:@""];
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        for (NSArray *ar in outStringListList) {//abc中的所有数组
            for (NSArray *a in ar) {
                for (NSString *s in a) {
                    [string appendString:s];
                }
            }
        }
        [arr addObject:string];
        mutArray = arr;//把arr赋给mutArray
        return mutArray;
        
    }
    
    //VCLog(@"self:%@-----mutArray:%@",self,mutArray);
    return nil;
}


/**
 *  @method
 *  @abstract   判断是否中文,
 *  @pragma string 输入的字符(串)
 *  @return YES是，NO否
 */
-(BOOL)thisHanZi:(unichar)c{
    
//    unichar c = [string characterAtIndex:0];
    
    if (c >=0x4E00 && c <=0x9FFF){
        
        return  YES;
        
    }
    
    return NO;
}

//转为拼音，只取首字母
-(NSMutableArray *)getFirstCharWithHanZi{
    
    HanyuPinyinOutputFormat *outputFormat =[[HanyuPinyinOutputFormat alloc] init];
    [outputFormat setToneType:ToneTypeWithoutTone];//声调
    [outputFormat setVCharType:VCharTypeWithV];//特殊拼音的显示格式如 ü
    [outputFormat setCaseType:CaseTypeLowercase];//大小(Lowercase)写
    
    NSString *hanzi =  self;
    NSMutableArray *outStringListList = [[NSMutableArray alloc] init];
    if (hanzi.length==1) {
        NSMutableArray *thisList = [[NSMutableArray alloc] init];
        NSMutableArray *allPY4CurrentHZ = (NSMutableArray*)[PinyinHelper toHanyuPinyinStringArrayWithChar:[hanzi characterAtIndex:0]withHanyuPinyinOutputFormat:outputFormat];
        
        if (allPY4CurrentHZ.count != 0) {
            
            [thisList addObject:allPY4CurrentHZ];
            [outStringListList addObject:thisList];
        }
    }else{
        for(int i = 0;i < hanzi.length; i++){
            NSString *currChar = [hanzi substringWithRange:NSMakeRange(i, 1)];
            NSMutableArray *thisList = [[NSMutableArray alloc] init];
            if ([self thisHanZi: [currChar characterAtIndex:0]]) {
                NSMutableArray *allPY4CurrentHZ = (NSMutableArray*)[PinyinHelper toHanyuPinyinStringArrayWithChar:[currChar characterAtIndex:0]withHanyuPinyinOutputFormat:outputFormat];
                
                if (allPY4CurrentHZ.count != 0) {
                    for (int j = 0; j < allPY4CurrentHZ.count; j++) {
                        allPY4CurrentHZ[j] = [allPY4CurrentHZ[j] substringToIndex:1];
                    }
                    [thisList addObject:allPY4CurrentHZ];
                }
            }else{//不是汉字
                NSMutableArray *a = [[NSMutableArray alloc] initWithObjects:currChar, nil];
                [thisList addObject:a];
            }
            
            [outStringListList addObject:thisList];
            
        }

    }
    
        
    NSMutableArray *mutArray =[[NSMutableArray alloc] initWithObjects:@"", nil];
    for (NSArray *ar in outStringListList) {//abc中的所有数组
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        for (NSArray *s in ar) {//abc中数组里的所有元素
            for (NSString *a in s) {
                for (NSString *ss in mutArray) {//mutArray中的所有元素
                    if (![arr containsObject:[NSString stringWithFormat:@"%@%@",ss,a]]) {
                        [arr addObject:[NSString stringWithFormat:@"%@%@",ss,a]];
                    }
                    
                }
            }
            
        }
        mutArray = arr;//把arr赋给mutArray
        
    }
    
    return mutArray;
}

#pragma mark -- 拼音转数字
-(NSString *)pinyinTrimIntNumber
{
    NSString *lString=[[NSString alloc] init];
    NSString *ss = [[NSString alloc] init];
    for (int i =0; i<self.length; i++) {
        char s = [self  characterAtIndex:i];
        switch (s) {
            case 'a':
            case 'b':
            case 'c':
            case 'A':
            case 'B':
            case 'C':
                ss = @"2";
                break;
            case 'd':
            case 'e':
            case 'f':
            case 'D':
            case 'E':
            case 'F':
                ss = @"3";
                break;
            case 'g':
            case 'h':
            case 'i':
            case 'G':
            case 'H':
            case 'I':
                ss = @"4";
                break;
            case 'j':
            case 'k':
            case 'l':
            case 'J':
            case 'K':
            case 'L':
                ss = @"5";
                break;
            case 'm':
            case 'n':
            case 'o':
            case 'M':
            case 'N':
            case 'O':
                ss = @"6";
                break;
            case 'p':
            case 'q':
            case 'r':
            case 's':
            case 'P':
            case 'Q':
            case 'R':
            case 'S':
                ss = @"7";
                break;
            case 't':
            case 'u':
            case 'v':
            case 'T':
            case 'U':
            case 'V':
                ss = @"8";
                break;
            case 'w':
            case 'x':
            case 'y':
            case 'z':
            case 'W':
            case 'X':
            case 'Y':
            case 'Z':
                ss = @"9";
                break;
            case '*':
                ss = @"A";
                break;
            case '#':
                ss = @"B";
                break;
            case '+':
                ss = @"C";
                break;
            default:
                ss = [self substringWithRange:NSMakeRange(i, 1)];
                break;
        }
        
        lString = [NSString stringWithFormat:@"%@%@",lString,ss];
    }
    if (self.length == 1) {
        return [NSString stringWithFormat:@"%@1",lString];
    }
    //VCLog(@"-lString:%@",[NSString stringWithFormat:@"-%@",lString]);
    return [NSString stringWithFormat:@"%@",lString];
}

-(NSString *)isMobileNumberWhoOperation
{
    //处理str
    NSString *mobileNum = [self purifyString];
    if (mobileNum.length == 0) {
        return @"";
    }
    
    /**
     * 手机号码
     * 移动：134,135,136,137,138,139,150,151,152,157,158,159,182,183,187,188
     * 联通：130,131,132,155,156,185,186
     * 电信：133,153,180,189
     */
    
    /**
     * 中国移动
     */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[0127-9]|8[2378])|4[7]\\d).*$";
    /**
     * 中国联通
     */
    NSString * CU = @"^1(3[0-2]|5[56]|8[56]).*$";
    /**
     * 中国电信
     */
    NSString * CT = @"^1(33|53|8[09]).*$";
    
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    NSString *str = [[NSString alloc] init];
    
    if([regextestcm evaluateWithObject:mobileNum] == YES) {
        str = @"移动";//NSLocalizedString(@"Communication_Corp", nil);
        //VCLog(@"China Mobile");
    } else if([regextestct evaluateWithObject:mobileNum] == YES) {
        str = @"联通";//  NSLocalizedString(@"Unicom", nil);
        //VCLog(@"China Telecom");
    } else if ([regextestcu evaluateWithObject:mobileNum] == YES) {
        str = @"电信";//  NSLocalizedString(@"Telecom", nil);
        //VCLog(@"China Unicom");
    } else {
        str  = @"其它";// NSLocalizedString(@"Other", nil);
        //VCLog(@"Unknow");
    }
    
    
    
    return str;
    
    
}

#pragma mark -- 判断手机号码运营商格式
- (NSString *)isMobileNumber:(NSString *)number
{
    //处理str
    NSString *mobileNum = [number purifyString];
    
    
    /**
     * 手机号码
     * 移动：134,135,136,137,138,139,150,151,152,157,158,159,182,183,187,188
     * 联通：130,131,132,155,156,185,186
     * 电信：133,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9]).*$";
    /**
     * 中国移动：China Mobile
     * 134[0-8],135,136,137,138,139,
     150,151,157,158,159,
     182,187,188
     */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[0127-9]|8[2378])\\d).*$";
    /**
     * 中国联通：China Unicom
     * 130,131,132,155,156,185,186
     */
    NSString * CU = @"^1(3[0-2]|5[56]|8[56]).*$";
    /**
     * 中国电信：China Telecom
     * 133,153,180,189
     */
    NSString * CT = @"^1(33|53|8[09]).*$";
    /**
     * 大陆地区固话及小灵通
     * 区号：010,020,021,022,023,024,025,027,028,029
     * 号码：七位或八位
     */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    NSString *str = [[NSString alloc] init];
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES))
    {
        if([regextestcm evaluateWithObject:mobileNum] == YES) {
            str = @"移动";//NSLocalizedString(@"Communication_Corp", nil);
            //VCLog(@"China Mobile");
        } else if([regextestct evaluateWithObject:mobileNum] == YES) {
            str =  @"联通";//NSLocalizedString(@"Unicom", nil);
            //VCLog(@"China Telecom");
        } else if ([regextestcu evaluateWithObject:mobileNum] == YES) {
            str =  @"电信";//NSLocalizedString(@"Telecom", nil);
            //VCLog(@"China Unicom");
        } else {
            str  = @"其它";//NSLocalizedString(@"Other", nil);;
            //VCLog(@"Unknow");
        }
        
        return str;
    }
    else
    {
        return @"其它";
    }
}



@end
