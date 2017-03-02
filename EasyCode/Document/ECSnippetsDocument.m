//
//  ECSnippetsDocument.m
//  AirCode
//
//  Created by Loriya on 2017/3/1.
//  Copyright © 2017年 music4kid. All rights reserved.
//

#import "ECSnippetsDocument.h"
#import "NSWindowController+Additions.h"

@interface ECSnippetsDocument ()

@end

@implementation ECSnippetsDocument
-(instancetype)initWithEditorType:(EditorType)editorType {
    self = [super init];
    if (self) {
        _editorType = editorType;
    }
    return self;
}

-(void)makeWindowControllers {

}

-(NSString *)displayName {
    return @"代码详情";
}

+ (BOOL)autosavesInPlace {
    return YES;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    [NSException raise:@"UnimplementedMethod" format:@"%@ is unimplemented", NSStringFromSelector(_cmd)];
    return nil;
}


- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    [NSException raise:@"UnimplementedMethod" format:@"%@ is unimplemented", NSStringFromSelector(_cmd)];
    return YES;
}


@end
