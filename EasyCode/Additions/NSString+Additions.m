//
//  NSString+Additions.m
//  EasyCode
//
//  Created by lijia on 09/02/2017.
//  Copyright © 2017 music4kid. All rights reserved.
//

#import "NSString+Additions.h"

@implementation NSString (Additions)
-(NSString*)trimWhiteSpace {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

-(BOOL)isNotEmpty {
    NSString* trimStr = [self trimWhiteSpace];
    return (trimStr != nil && trimStr.length > 0);
}
@end
