//
//  EShortcutEntry.m
//  EasyCode
//
//  Created by gao feng on 2016/10/20.
//  Copyright © 2016年 music4kid. All rights reserved.
//

#import "EShortcutEntry.h"
static NSDateFormatter* formatter = nil;

@implementation EShortcutEntry
+ (void)initialize {
    if (self == [EShortcutEntry class]) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMdd_hhmmss"];
    }
}

+(instancetype)entryWithKey:(NSString*)key code:(NSString*)code {
    EShortcutEntry* entry = [[[self class] alloc] init];
    entry.key = key;
    entry.code = code;
    entry.createAt = [formatter stringFromDate:[NSDate date]];
    return entry;
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self.key = [decoder decodeObjectForKey:@"key"];
    self.code = [decoder decodeObjectForKey:@"code"];
    self.createAt = [decoder decodeObjectForKey:@"createAt"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_key forKey:@"key"];
    [encoder encodeObject:_code forKey:@"code"];
    [encoder encodeObject:_createAt forKey:@"createAt"];
}

- (id)copyWithZone:(NSZone *)zone {
    EShortcutEntry *entry = [[[self class] allocWithZone:zone] init];
    entry.key = _key;
    entry.code = _code;
    entry.createAt = _createAt;
    return entry;
}

- (void)setKey:(NSString *)key {
    _key = [key trimWhiteSpace];
}

-(void)updateBySnippet:(EShortcutEntry*)snippet {
    if ([self.key isEqualToString:snippet.key]) {
        self.code = snippet.code;
    }
}

@end
