//
//  NSFileManager+Additions.m
//  EasyCode
//
//  Created by lijia on 01/03/2017.
//  Copyright © 2017 music4kid. All rights reserved.
//

#import "NSFileManager+Additions.h"
#import "ESharedUserDefault.h"

enum {
    DirectoryLocationErrorNoPathFound,
    DirectoryLocationErrorFileExistsAtLocation
};
NSString *const DirectoryLocationDomain =   @"DirectoryLocationDomain";
NSString *const DirectoryDocuments =        @"Documents";
NSString *const DirectoryOCName =           @"objective-c";
NSString *const DirectorySwiftName =        @"swift";
NSString *const SnippetFileName =           @"snippets.dat";
NSString *const VersionFileName =           @"version.dat";

@implementation NSFileManager (Additions)
-(NSURL*)localURL
{
    NSString* supportPath = [self supportDocumentDirectory];
    NSURL* url = [NSURL fileURLWithPath:supportPath];
    return url;
}

-(NSURL*)localSnippetsURLWithFilename:(NSString*)filename
{
    NSURL* localURL = [self localURL];
    NSURL* url = [localURL URLByAppendingPathComponent:filename];
    
    NSError *error = nil;
    BOOL success = [self createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:&error];
    if (!success) {
        NSLog(@"create local directory error :%@",[error localizedDescription]);
    }
    
    return url;
}

-(NSURL*)ubiquityURL
{
    NSURL* ubiURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    ubiURL = [ubiURL URLByAppendingPathComponent:DirectoryDocuments];
    return ubiURL;
}

-(NSURL*)ubiquitySnippetsURLWithFilename:(NSString*)filename
{
    NSURL* ubiURL = [self ubiquityURL];
    NSURL* url = [ubiURL URLByAppendingPathComponent:filename];
    
    NSError *error = nil;
    BOOL success = [self createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:&error];
    if (!success) {
        NSLog(@"create ubiquity directory error :%@",[error localizedDescription]);
    }
    
    return url;
}

-(NSURL*)currentURLForEditorType:(EditorType)editorType
{
    NSString* dirname = DirectoryOCName;
    if (editorType == EditorTypeSwift) {
        dirname = DirectorySwiftName;
    }
    
    NSURL* fileURL = [[NSFileManager defaultManager] localSnippetsURLWithFilename:dirname];;
    BOOL useiCloud = [ESharedUserDefault boolForKey:KeyUseiCloudSync];
    if (useiCloud) {
        id ubiq = [[NSFileManager defaultManager] ubiquityIdentityToken];    
        if (ubiq) {
            fileURL = [[NSFileManager defaultManager] ubiquitySnippetsURLWithFilename:dirname];
        }
    }
    
    return fileURL;
}

- (NSString *)findOrCreateDirectory:(NSSearchPathDirectory)searchPathDirectory
                           inDomain:(NSSearchPathDomainMask)domainMask
                appendPathComponent:(NSString *)appendComponent
                              error:(NSError **)errorOut {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(searchPathDirectory, domainMask, YES);
    if ([paths count] == 0) {
        if (errorOut) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"No path found for directory in domain.",
                                       @"NSSearchPathDirectory" : @(searchPathDirectory),
                                       @"NSSearchPathDomainMask" : @(domainMask) };

            *errorOut = [NSError errorWithDomain:DirectoryLocationDomain
                                            code:DirectoryLocationErrorNoPathFound
                                        userInfo:userInfo];
        }
        return nil;
    }

    NSString *resolvedPath = [paths objectAtIndex:0];
    if (appendComponent) {
        resolvedPath = [resolvedPath stringByAppendingPathComponent:appendComponent];
    }
    
    NSError *error = nil;
    BOOL success = [self createDirectoryAtPath:resolvedPath
                   withIntermediateDirectories:YES
                                    attributes:nil
                                         error:&error];
    if (!success) {
        if (errorOut) {
            *errorOut = error;
        }
        return nil;
    }
    
    if (errorOut) {
        *errorOut = nil;
    }
    return resolvedPath;
}

-(NSString*)supportDocumentDirectory {
    NSString* appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"];
    NSString *documentPath = [appName stringByAppendingPathComponent:DirectoryDocuments];
    NSError *error = nil;
    NSString *result = [self findOrCreateDirectory:NSApplicationSupportDirectory
                                          inDomain:NSUserDomainMask
                               appendPathComponent:documentPath
                                             error:&error];
    if (!result) {
        NSLog(@"Unable to find or create application support directory:\n%@", error);
    }
    return result;
}
@end
