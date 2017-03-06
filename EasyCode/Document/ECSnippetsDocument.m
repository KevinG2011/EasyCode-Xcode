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

@interface ECSnippetsDocument ()  {
    NSMutableArray* _entryList;
}
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

-(EShortcutEntry*)entryList {
    return [_entryList copy];
}

//排序
-(void)sortedSnippets {
    [_entryList sortUsingComparator:^NSComparisonResult(EShortcutEntry*  _Nonnull s1, EShortcutEntry*  _Nonnull s2) {
        return [s1.key compare:s2.key];
    }];
}

-(EShortcutEntry*)snippetForKey:(NSString*)key {
    NSString* trimKey = [key trimWhiteSpace];
    NSUInteger index = [_entryList indexOfObjectWithOptions:NSEnumerationConcurrent passingTest:^BOOL(EShortcutEntry*  _Nonnull snippet, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL result = [snippet.key isEqualToString:trimKey];
        if (result) {
            *stop = YES;
        }
        return result;
    }];
    if (index != NSNotFound) {
        return _entryList[index];
    }
    return nil;
}

-(void)addSnippet:(EShortcutEntry*)snippet {
    if ([snippet.key isNotEmpty] == NO) {
        return;
    }
    EShortcutEntry* hitSnippet = [self snippetForKey:snippet.key];
    if (hitSnippet == nil) { //add
        [_entryList addObject:snippet];
        [self saveDocumentCompletionHandler:^{
            if ([_delegate respondsToSelector:@selector(snippetsDocument:performActionWithType:withSnippet:)]) {
                [_delegate snippetsDocument:self performActionWithType:ECSnippetActionTypeCreate withSnippet:snippet];
            }
        }];
    } else {
        [self updateSnippet:snippet];
    }
}

-(void)removeSnippetForKey:(NSString*)key {
    EShortcutEntry* hitSnippet = [self snippetForKey:key];
    if (hitSnippet) {
        [_entryList removeObject:hitSnippet];
        [self saveDocumentCompletionHandler:^{
            if ([_delegate respondsToSelector:@selector(snippetsDocument:performActionWithType:withSnippet:)]) {
                [_delegate snippetsDocument:self performActionWithType:ECSnippetActionTypeDelete withSnippet:hitSnippet];
            }
        }];
    }
}

-(void)updateSnippet:(EShortcutEntry*)snippet {
    EShortcutEntry* hitSnippet = [self snippetForKey:snippet.key];
    [hitSnippet updateBySnippet:snippet];
    if ([_delegate respondsToSelector:@selector(snippetsDocument:performActionWithType:withSnippet:)]) {
        [_delegate snippetsDocument:self performActionWithType:ECSnippetActionTypeUpdate withSnippet:hitSnippet];
    }
}

//保存文档
-(void)saveDocumentCompletionHandler:(void (^)(void))handler {
    [self saveDocument:nil];
    if (handler) {
        handler();
    }
}

#pragma mark - Override Documents

-(NSString *)displayName {
    return @"代码详情";
}

+ (BOOL)autosavesInPlace {
    return YES;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    [self sortedSnippets];
    NSArray* snippetsList = [_entryList copy];
    NSData* entryData = [NSKeyedArchiver archivedDataWithRootObject:snippetsList];
    return entryData;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    if ([data length] > 0) {
        _entryList = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    } else {
        EShortcutEntry* snippet = [EShortcutEntry entryWithKey:@"key" code:@"code"];
        _entryList = [NSMutableArray arrayWithObject:snippet];
    }
    
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
