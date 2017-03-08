//
//  ECSnippetHelper.m
//  EasyCode
//
//  Created by lijia on 07/03/2017.
//  Copyright © 2017 music4kid. All rights reserved.
//

#import "ECSnippetHelper.h"
#import "NSFileManager+Additions.h"
#import "ECMappingForObjectiveC.h"
#import "ECMappingForSwift.h"

@implementation ECSnippetHelper

+(ECSnippet*)snippetWithFileWrapper:(NSFileWrapper*)fileWrapper {
    NSDictionary *fileWrappers = [fileWrapper fileWrappers];
    NSFileWrapper *snippetWrapper = [fileWrappers objectForKey:SnippetFileName];
    if (snippetWrapper == nil) { //switch ubiquity to local
        NSString* filename = [fileWrapper filename];
        NSURL* fileURL = [[NSFileManager defaultManager] localSnippetsURLWithFilename:filename];
        fileWrapper = [[NSFileWrapper alloc] initWithURL:fileURL options:NSFileWrapperReadingWithoutMapping error:nil];
        fileWrappers = [fileWrapper fileWrappers];
        snippetWrapper = [fileWrappers objectForKey:SnippetFileName];
    }
    NSData* data = [snippetWrapper regularFileContents];
    ECSnippet* snippet = nil;
    if ([data length] > 0) {
        snippet = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    } else { //create from memory if local not exist
        NSArray* entries = nil;
        if ([[fileWrapper filename] isEqualToString:DirectoryOCName]) {
            entries = [ECMappingForObjectiveC defaultEntries];
        } else {
            entries = [ECMappingForSwift defaultEntries];
        }
        snippet = [[ECSnippet alloc] initWithEntries:entries];
    }
    return snippet;
}

+(ECSnippet*)snippetWithEditorType:(EditorType)editorType {
    NSURL* fileURL = [[NSFileManager defaultManager] detectURLForEditorType:editorType];
    NSFileWrapper* fileWrapper = [[NSFileWrapper alloc] initWithURL:fileURL
                                                            options:NSFileWrapperReadingWithoutMapping
                                                              error:nil];
    ECSnippet* snippet = [self snippetWithFileWrapper:fileWrapper];
    return snippet;
}
@end
