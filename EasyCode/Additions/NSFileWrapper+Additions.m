//
//  NSFileWrapper+Additions.m
//  EasyCode
//
//  Created by lijia on 07/03/2017.
//  Copyright © 2017 music4kid. All rights reserved.
//

#import "NSFileWrapper+Additions.h"

@implementation NSFileWrapper (Additions)
-(void)replaceFileWrapper:(NSFileWrapper*)child forKey:(NSString*)filename {
    if (filename.length == 0) {
        return;
    }
    NSFileWrapper* oldChild = [[self fileWrappers] objectForKey:filename];
    if (oldChild) {
        [self removeFileWrapper:oldChild];
    }
    [self addFileWrapper:child];
}
@end