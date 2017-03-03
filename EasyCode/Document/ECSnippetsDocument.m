//
//  ECSnippetsDocument.m
//  AirCode
//
//  Created by Loriya on 2017/3/1.
//  Copyright © 2017年 music4kid. All rights reserved.
//

#import "ECSnippetsDocument.h"
#import "NSWindowController+Additions.h"
#import "EShortcutEntry.h"
#import "ECMappingForObjectiveC.h"
#import "ECMappingForSwift.h"

static NSString *const ECDocumentChangedNotification = @"ECDocumentChangedNotification";

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

-(instancetype)initWithItemURL:(NSURL*)itemURL {
    self = [super init];
    if (self) {
        _itemURL = itemURL;
    }
    return self;
}

-(void)makeWindowControllers {
    [super makeWindowControllers];
}

-(NSString *)displayName {
    return @"代码详情";
}

+ (BOOL)autosavesInPlace {
    return YES;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    NSMutableDictionary* entryMapping = [NSMutableDictionary dictionaryWithCapacity:_entryList.count];
    for (EShortcutEntry* entry in _entryList) {
        [entryMapping setObject:entry.code forKey:entry.key];
    }
    NSData* entryData = [NSKeyedArchiver archivedDataWithRootObject:entryMapping];
    return entryData;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    NSDictionary* entryMapping = nil;
    if ([data length] > 0) {
        entryMapping = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    } else {
        if (_editorType == EditorTypeOC) {
            entryMapping = [ECMappingForSwift provideMapping];
        } else {
            entryMapping = [ECMappingForObjectiveC provideMapping];
        }
    }
    NSMutableArray* entryList = [NSMutableArray arrayWithCapacity:entryMapping.count];
    [entryMapping enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSString* code, BOOL* stop) {
        EShortcutEntry* entry = [EShortcutEntry entryWithKey:key code:code];
        [entryList addObject:entry];
    }];
    _entryList = entryList;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ECDocumentChangedNotification
                                                        object:self];
    
    return YES;
}

- (NSFileWrapper *)fileWrapperOfType:(NSString *)typeName error:(NSError **)outError {
    return nil;
}

- (BOOL)readFromFileWrapper:(NSFileWrapper *)fileWrapper ofType:(NSString *)typeName error:(NSError * _Nullable *)outError {
    
    return YES;
}

@end
