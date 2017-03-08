//
//  ECMappingHelper.m
//  EasyCode
//
//  Created by gao feng on 2016/10/18.
//  Copyright © 2016年 music4kid. All rights reserved.
//

#import "ECMappingHelper.h"
#import "NSFileManager+Additions.h"
#import "ESharedUserDefault.h"
#import "ECSnippet.h"

@interface ECMappingHelper ()
@property (nonatomic, strong) ECSnippet* snippetsOC;
@property (nonatomic, strong) ECSnippet* snippetsSwift;
@end

@implementation ECMappingHelper

+ (instancetype)sharedInstance
{
    static ECMappingHelper* instance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [ECMappingHelper new];
    });

    return instance;
}

- (void)checkForDuplicatedKeys:(NSDictionary*)mapping
{
    //check for duplicated keys
    NSArray* keys = mapping.allKeys;
    NSMutableDictionary* dic = @{}.mutableCopy;
    for (NSString* key in keys) {
        if ([dic objectForKey:keys]) {
//            NSLog(@"detect duplicated keys!");
        }
        else
        {
            dic[key] = key;
        }
    }
}



- (BOOL)handleInvocation:(XCSourceEditorCommandInvocation *)invocation {
    BOOL isOC = true;
    if ([invocation.buffer.contentUTI isEqualToString:@"public.swift-source"]) {
        isOC = false;
    }
    
    //read from NSUserDefault each time
//    [self clearMapping];
    
    XCSourceTextRange *selection = invocation.buffer.selections.firstObject;
    NSMutableArray* lines = invocation.buffer.lines;
    NSInteger index = selection.start.line;
    NSInteger column = selection.end.column;
    
    int matchedCount = 0;
    
    if (index > lines.count - 1) {
        return false;
    }
    
    NSString* originalLine = lines[index];
    int matchLength = 8;//max match length for shortcut
    while (matchLength >= 1) {
        
        if (column-matchLength >= 0)
        {
            NSRange targetRange = NSMakeRange(column-matchLength, matchLength);
            NSString* lastNStr = [originalLine substringWithRange:targetRange];
            

            NSString* matchedVal = [self getMatchedCode:lastNStr isOC:isOC];
            
            if (matchedVal.length > 0) {
                int numberOfSpaceIndent = (int)[originalLine rangeOfString:lastNStr].location;
                NSString* indentStr = @"";
                while (numberOfSpaceIndent>0) {
                    indentStr = [indentStr stringByAppendingString:@" "];
                    numberOfSpaceIndent --;
                }
                
                NSArray* linesToInsert = [self convertToLines:matchedVal];
                
                //insert 1st line
                lines[index] = [originalLine stringByReplacingOccurrencesOfString:lastNStr
                                                                       withString:linesToInsert[0]
                                                                          options:NSBackwardsSearch
                                                                            range:targetRange];
                
                //insert the rest
                for (int i = 1; i < linesToInsert.count; i ++) {
                    NSString* lineToInsert = linesToInsert[i];
                    //indent
                    lineToInsert = [NSString stringWithFormat:@"%@%@", indentStr, lineToInsert];
                    [lines insertObject:lineToInsert atIndex:index+i];
                }
                
                matchedCount = matchLength;
                
                break;
            }
        }
        
        matchLength--;
        
    }
    
    
    //adjust selection
    if (matchedCount > 0) {
        selection.start = XCSourceTextPositionMake(selection.start.line, selection.start.column-matchedCount);
        selection.end = selection.start;
    }
    return true;
}


- (NSString*)getMatchedCode:(NSString*)abbr isOC:(BOOL)isOC
{
    //need to detect swift or oc
    NSArray<ECSnippetEntry*>* entries = nil;
    
    if (isOC) {
        entries = self.snippetsOC.entries;
    }
    else
    {
        entries = self.snippetsSwift.entries;
    }
    
    __block NSInteger index = NSNotFound;
    [entries enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(ECSnippetEntry * _Nonnull entry, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([entry.key hasPrefix:abbr] || [entry.key isEqual:abbr]) {
            index = idx;
            *stop = YES;
        }
    }];
    
    if (index != NSNotFound) {
        NSString* matchedCode = [entries[index] code];
        return matchedCode;
    }
    
    return nil;
}


- (NSArray*)convertToLines:(NSString*)codeStr {
    NSMutableArray* lines = @[].mutableCopy;
    NSArray* arr = [codeStr componentsSeparatedByString:@"\n"];
    for (NSString* line in arr) {
        [lines addObject:line];
    }
    
    return lines;
}

-(ECSnippet *)snippetsOC {
    if (_snippetsOC == nil) {
        _snippetsOC = [ESharedUserDefault objectForKey:SnippetFileName];
    }
    return _snippetsOC;
}

-(ECSnippet *)snippetsSwift {
    if (_snippetsSwift == nil) {
        _snippetsSwift = [ESharedUserDefault objectForKey:VersionFileName];
    }
    return _snippetsSwift;
}

//- (void)clearMapping
//{
//    self.mappingOC = nil;
//    self.mappingSwift = nil;
//    
//    [_UD clearMapping];
//}

@end
