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
NSString *const DirectoryUbiquityDocuments = @"Documents";
NSString *const FileOCName = @"objective-c";
NSString *const FileSwiftName = @"swift";

@implementation NSFileManager (Additions)
-(NSURL*)localSnippetsURL {
    NSString* supportPath = [self applicationSupportDirectory];
    NSURL* url = [NSURL fileURLWithPath:supportPath];
    return url;
}

-(NSURL*)localOCSnippetsURL {
    NSURL* localURL = [self localSnippetsURL];
    NSURL* url = [localURL URLByAppendingPathComponent:FileOCName];
    NSError *error = nil;
    BOOL success = [self createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:&error];
    if (!success) {
        NSLog(@"create local directory error :%@",[error localizedDescription]);
    }
    return url;
}

-(NSURL*)localSwiftSnippetsURL {
    NSURL* localURL = [self localSnippetsURL];
    NSURL* url = [localURL URLByAppendingPathComponent:FileSwiftName];
    NSError *error = nil;
    BOOL success = [self createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:&error];
    if (!success) {
        NSLog(@"create local directory error :%@",[error localizedDescription]);
    }
    return url;
}

-(NSURL*)ubiquitySnippetsURL {
    NSURL* ubiURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    NSURL* url = [ubiURL URLByAppendingPathComponent:DirectoryUbiquityDocuments];
    return url;
}

-(NSURL*)ubiquityOCSnippetsURL {
    NSURL* ubiURL = [self ubiquitySnippetsURL];
    NSURL* url = [ubiURL URLByAppendingPathComponent:FileOCName];
    return url;
}

-(NSURL*)ubiquitySwiftSnippetsURL {
    NSURL* ubiURL = [self ubiquitySnippetsURL];
    NSURL* url = [ubiURL URLByAppendingPathComponent:FileSwiftName];
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

-(NSString*)applicationSupportDirectory {
    NSString *executableName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"];
    NSError *error = nil;
    NSString *result = [self findOrCreateDirectory:NSApplicationSupportDirectory
                                          inDomain:NSUserDomainMask
                               appendPathComponent:executableName
                                             error:&error];
    if (!result) {
        NSLog(@"Unable to find or create application support directory:\n%@", error);
    }
    return result;
}
@end
