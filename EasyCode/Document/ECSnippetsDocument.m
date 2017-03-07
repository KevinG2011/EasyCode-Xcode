//
//  ECSnippetEntrysDocument.m
//  AirCode
//
//  Created by Loriya on 2017/3/1.
//  Copyright © 2017年 music4kid. All rights reserved.
//

#import "ECSnippetsDocument.h"
#import "NSWindowController+Additions.h"
#import "ECSnippetEntry.h"
#import "ECMappingForObjectiveC.h"
#import "ECMappingForSwift.h"
#import "ECMappingForObjectiveC.h"
#import "NSFileWrapper+Additions.h"
#import "ECSnippetHelper.h"

NSString *const ECDocumentLoadedNotification = @"ECDocumentLoadedNotification";

@interface ECSnippetEntrysDocument ()
@property (nonatomic, strong) NSFileWrapper *fileWrapper;
@end

@implementation ECSnippetEntrysDocument
-(instancetype)initWithFileURL:(NSURL *)itemURL editorType:(EditorType)type {
    self = [super initWithContentsOfURL:itemURL ofType:@"" error:nil];
    if (self) {
        _itemURL = itemURL;
        _editorType = type;
    }
    return self;
}

-(void)sortedSnippets {
    
}

-(NSInteger)snippetEntryCount {
    return [_snippet entryCount];
}

-(ECSnippetEntry*)snippetEntryForKey:(NSString*)key {
    return [_snippet entryForKey:key];
}

-(void)addSnippetEntry:(ECSnippetEntry*)entry {
    [_snippet addEntry:entry];
    [self saveDocumentCompletionHandler:^{
        if ([_delegate respondsToSelector:@selector(snippetsDocument:performActionWithType:withEntry:)]) {
            [_delegate snippetsDocument:self performActionWithType:ECSnippetEntryActionTypeCreate withEntry:entry];
        }
    }];
}

-(void)removeSnippetEntryForKey:(NSString*)key {
    ECSnippetEntry* hitEntry = [_snippet removeEntryForKey:key];
    [self saveDocumentCompletionHandler:^{
        if ([_delegate respondsToSelector:@selector(snippetsDocument:performActionWithType:withEntry:)]) {
            [_delegate snippetsDocument:self performActionWithType:ECSnippetEntryActionTypeDelete withEntry:hitEntry];
        }
    }];
}

-(void)updateSnippetEntry:(ECSnippetEntry*)entry {
    ECSnippetEntry* hitEntry = entry;
    [self saveDocumentCompletionHandler:^{
        if ([_delegate respondsToSelector:@selector(snippetsDocument:performActionWithType:withEntry:)]) {
            [_delegate snippetsDocument:self performActionWithType:ECSnippetEntryActionTypeUpdate withEntry:hitEntry];
        }
    }];
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
    return NO;
}

- (NSFileWrapper *)fileWrapperOfType:(NSString *)typeName error:(NSError **)outError {
    //snippet data
    NSData* snippetData = [NSKeyedArchiver archivedDataWithRootObject:_snippet];
    NSFileWrapper* snippetWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:snippetData];
    //version data    
    NSData* verData = [_snippet.version.stringValue dataUsingEncoding:NSUTF8StringEncoding];
    NSFileWrapper* verWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:verData];
    if (_fileWrapper == nil) {
        NSDictionary<NSString*,NSFileWrapper*>* fileWrappers = @{ SnippetFileName:snippetWrapper,
                                                                  VersionFileName:verWrapper};
        _fileWrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:fileWrappers];
    } else {
        [_fileWrapper replaceFileWrapper:snippetWrapper forKey:SnippetFileName];
        [_fileWrapper replaceFileWrapper:verWrapper forKey:VersionFileName];
    }
    
    return _fileWrapper;
}

- (BOOL)readFromFileWrapper:(NSFileWrapper *)fileWrapper ofType:(NSString *)typeName error:(NSError * _Nullable *)outError {
    _snippet = [ECSnippetHelper snippetWithFileWrapper:fileWrapper];
    [[NSNotificationCenter defaultCenter] postNotificationName:ECDocumentLoadedNotification
                                                        object:self];
    return YES;
}

@end
