//
//  EShortcutEntry.m
//  EasyCode
//
//  Created by gao feng on 2016/10/20.
//  Copyright © 2016年 music4kid. All rights reserved.
//

#import "EShortcutEntry.h"

@implementation EShortcutEntry

+(instancetype)entryWithKey:(NSString*)key code:(NSString*)code {
    EShortcutEntry* entry = [[[self class] alloc] init];
    entry.key = key;
    entry.code = code;
    return entry;
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    _key = [decoder decodeObjectForKey:@"key"];
    _code = [decoder decodeObjectForKey:@"code"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_key forKey:@"key"];
    [encoder encodeObject:_code forKey:@"code"];
}

- (id)copyWithZone:(NSZone *)zone {
    EShortcutEntry *entry = [[[self class] allocWithZone:zone] init];
    entry.key = _key;
    entry.code = _code;
    return entry;
}

@end
