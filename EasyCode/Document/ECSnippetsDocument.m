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

static NSString *const SnippetFileName = @"snippets.dat";
NSString *const ECDocumentLoadedNotification = @"ECDocumentLoadedNotification";

@interface ECSnippetEntrysDocument ()  {
    NSMutableArray* _snippetList;
}
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

-(ECSnippetEntry*)snippetList {
    return [_snippetList copy];
}

//排序
-(void)sortedSnippets {
    [_snippetList sortUsingComparator:^NSComparisonResult(ECSnippetEntry*  _Nonnull s1, ECSnippetEntry*  _Nonnull s2) {
        return [s1.key compare:s2.key];
    }];
}

-(NSInteger)snippetCount {
    return _snippetList.count;
}

-(ECSnippetEntry*)snippetForKey:(NSString*)key {
    NSString* trimKey = [key trimWhiteSpace];
    NSUInteger index = [_snippetList indexOfObjectWithOptions:NSEnumerationConcurrent passingTest:^BOOL(ECSnippetEntry*  _Nonnull snippet, NSUInteger idx, BOOL * _Nonnull stop) {
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

-(void)addSnippet:(ECSnippetEntry*)snippet {
    if ([snippet.key isNotEmpty] == NO) {
        return;
    }
    ECSnippetEntry* hitSnippet = [self snippetForKey:snippet.key];
    if (hitSnippet == nil) { //add
        [_snippetList addObject:snippet];
        [self saveDocumentCompletionHandler:^{
            if ([_delegate respondsToSelector:@selector(snippetsDocument:performActionWithType:withSnippet:)]) {
                [_delegate snippetsDocument:self performActionWithType:ECSnippetEntryActionTypeCreate withSnippet:snippet];
            }
        }];
    } else {
        [self updateSnippet:snippet];
    }
}

-(void)removeSnippetForKey:(NSString*)key {
    ECSnippetEntry* hitSnippet = [self snippetForKey:key];
    if (hitSnippet) {
        [_snippetList removeObject:hitSnippet];
        [self saveDocumentCompletionHandler:^{
            if ([_delegate respondsToSelector:@selector(snippetsDocument:performActionWithType:withSnippet:)]) {
                [_delegate snippetsDocument:self performActionWithType:ECSnippetEntryActionTypeDelete withSnippet:hitSnippet];
            }
        }];
    }
}

-(void)updateSnippet:(ECSnippetEntry*)snippet {
    ECSnippetEntry* hitSnippet = [self snippetForKey:snippet.key];
    [hitSnippet updateBySnippet:snippet];
    if ([_delegate respondsToSelector:@selector(snippetsDocument:performActionWithType:withSnippet:)]) {
        [_delegate snippetsDocument:self performActionWithType:ECSnippetEntryActionTypeUpdate withSnippet:hitSnippet];
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
        NSString* fileName = [self.fileURL lastPathComponent];
        if ([fileName isEqualToString:FileOCName]) {
            _snippetList = [[ECMappingForObjectiveC defaultEntries] mutableCopy];
        } else {
            _snippetList = [[ECMappingForSwift defaultEntries] mutableCopy];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:ECDocumentLoadedNotification
                                                        object:self];
    return YES;
}

@end
