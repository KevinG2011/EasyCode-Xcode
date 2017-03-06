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

static NSString *const SnippetFileName = @"snippets.dat";
static NSString *const ECDocumentChangedNotification = @"ECDocumentChangedNotification";

@interface ECSnippetsDocument ()  {
    NSMutableArray* _snippetList;
}
@property (nonatomic, strong) NSFileWrapper *fileWrapper;
@end

@implementation ECSnippetsDocument
-(instancetype)initWithFileURL:(NSURL *)itemURL editorType:(EditorType)type {
    self = [super initWithContentsOfURL:itemURL ofType:@"" error:nil];
    if (self) {
        _itemURL = itemURL;
        _editorType = type;
    }
    return self;
}

-(EShortcutEntry*)snippetList {
    return [_snippetList copy];
}

//排序
-(void)sortedSnippets {
    [_snippetList sortUsingComparator:^NSComparisonResult(EShortcutEntry*  _Nonnull s1, EShortcutEntry*  _Nonnull s2) {
        return [s1.key compare:s2.key];
    }];
}

-(NSInteger)snippetCount {
    return _snippetList.count;
}

-(EShortcutEntry*)snippetForKey:(NSString*)key {
    NSString* trimKey = [key trimWhiteSpace];
    NSUInteger index = [_snippetList indexOfObjectWithOptions:NSEnumerationConcurrent passingTest:^BOOL(EShortcutEntry*  _Nonnull snippet, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL result = [snippet.key isEqualToString:trimKey];
        if (result) {
            *stop = YES;
        }
        return result;
    }];
    if (index != NSNotFound) {
        return _snippetList[index];
    }
    return nil;
}

-(void)addSnippet:(EShortcutEntry*)snippet {
    if ([snippet.key isNotEmpty] == NO) {
        return;
    }
    EShortcutEntry* hitSnippet = [self snippetForKey:snippet.key];
    if (hitSnippet == nil) { //add
        [_snippetList addObject:snippet];
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
        [_snippetList removeObject:hitSnippet];
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
    return @"Code Snippet";
}

+ (BOOL)autosavesInPlace {
    return YES;
}

- (NSFileWrapper *)fileWrapperOfType:(NSString *)typeName error:(NSError **)outError {
    NSData* snippetData = [NSKeyedArchiver archivedDataWithRootObject:_snippetList];
    NSFileWrapper* newWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:snippetData];
    newWrapper.preferredFilename = SnippetFileName;
    if (_fileWrapper == nil) {
        NSDictionary<NSString*,NSFileWrapper*>* fileWrappers = @{ SnippetFileName:newWrapper };
        _fileWrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:fileWrappers];
    } else {
        NSFileWrapper* oldWrapper = [[_fileWrapper fileWrappers] objectForKey:SnippetFileName];
        if (oldWrapper) {
            [_fileWrapper removeFileWrapper:oldWrapper];
        }
        [_fileWrapper addFileWrapper:newWrapper];
    }
    
    return _fileWrapper;
}

- (BOOL)readFromFileWrapper:(NSFileWrapper *)fileWrapper ofType:(NSString *)typeName error:(NSError * _Nullable *)outError {
    NSDictionary *fileWrappers = [fileWrapper fileWrappers];
    NSFileWrapper *dataWrapper = [fileWrappers objectForKey:SnippetFileName];
    NSData* data = [dataWrapper regularFileContents];
    if (data.length > 0) {
        _snippetList = [NSKeyedUnarchiver unarchiveObjectWithData:[dataWrapper regularFileContents]];
    } else {
        EShortcutEntry* snippet = [EShortcutEntry entryWithKey:@"key" code:@"code"];
        _snippetList = [NSMutableArray arrayWithObject:snippet];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:ECDocumentChangedNotification
                                                        object:self];
    return YES;
}

@end
