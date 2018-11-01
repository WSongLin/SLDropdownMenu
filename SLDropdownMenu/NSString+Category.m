//
//  NSString+Category.m
//  SLDropdownMenu
//
//  Created by sl on 2018/10/30.
//  Copyright © 2018年 WSonglin. All rights reserved.
//

#import "NSString+Category.h"

@implementation NSString (Category)

+ (NSString *)convertText:(NSString *)text {
    NSMutableString *mString = [[NSMutableString alloc] initWithString:text];
    //转换成拼音
    CFStringTransform((CFMutableStringRef)mString, NULL, kCFStringTransformMandarinLatin, NO);
    //转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)mString, NULL, kCFStringTransformStripDiacritics, NO);
    
    NSArray *allArray = [mString componentsSeparatedByString:@" "];
    NSMutableString *appendString = [[NSMutableString alloc] init];
    NSInteger count = 0;
    
    for (NSInteger i = 0; i < allArray.count; i++) {
        for (NSInteger j = 0; j < allArray.count; j++) {
            if (j == count) {
                //区分第几个字母
                [appendString appendString:@"#"];
            }
            
            [appendString appendFormat:@"%@", allArray[j]];
        }
        
        [appendString appendString:@","];
        
        count++;
    }
    
    //拼音首字母
    NSMutableString *initialString = [[NSMutableString alloc] init];
    for (NSString *str in allArray) {
        if (str.length > 0) {
            [initialString appendString:[str substringToIndex:1]];
        }
    }
    
    [appendString appendFormat:@"#%@", initialString];
    [appendString appendFormat:@",#%@", text];
    
    return appendString;
}

@end
