//
//  ECSnippet.m
//  EasyCode
//
//  Created by lijia on 07/03/2017.
//  Copyright © 2017 music4kid. All rights reserved.
//

#import "ECSnippet.h"

@implementation ECSnippet
- (instancetype)initWithCoder:(NSCoder *)decoder {
    self.version = [decoder decodeObjectForKey:@"version"];
    self.entries = [decoder decodeObjectForKey:@"entries"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_version forKey:@"version"];
    [encoder encodeObject:_entries forKey:@"entries"];
}

- (id)copyWithZone:(NSZone *)zone {
    ECSnippet* snippet = [[[self class] allocWithZone:zone] init];
    snippet.version = _version;
    snippet.entries = _entries;
    return snippet;
}
@end
