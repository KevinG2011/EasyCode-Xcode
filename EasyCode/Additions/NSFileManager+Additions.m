//
//  NSFileManager+Additions.m
//  EasyCode
//
//  Created by lijia on 01/03/2017.
//  Copyright © 2017 music4kid. All rights reserved.
//

#import "NSFileManager+Additions.h"
enum {
    DirectoryLocationErrorNoPathFound,
    DirectoryLocationErrorFileExistsAtLocation
};
NSString *const DirectoryLocationDomain = @"DirectoryLocationDomain";
NSString *const DirectoryDocuments = @"Documents";
NSString *const DirectoryOCName = @"objective-c";
NSString *const DirectorySwiftName = @"swift";

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
    return url;
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
    NSString *documentPath = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"] stringByAppendingPathComponent:DirectoryDocuments];
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
