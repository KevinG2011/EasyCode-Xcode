//
//  NSFileManager+Additions.h
//  EasyCode
//
//  Created by lijia on 01/03/2017.
//  Copyright © 2017 music4kid. All rights reserved.
//

#import <Foundation/Foundation.h>

EC_EXTERN NSString *const DirectoryLocationDomain;
EC_EXTERN NSString *const DirectoryUbiquityDocuments;
EC_EXTERN NSString *const FileOCName;
EC_EXTERN NSString *const FileSwiftName;

@interface NSFileManager (Additions)
-(NSURL*)localURL;
-(NSURL*)localSnippetsURLWithFilename:(NSString*)filename;
-(NSURL*)ubiquityURL;
-(NSURL*)ubiquitySnippetsURLWithFilename:(NSString*)filename;

- (NSString *)findOrCreateDirectory:(NSSearchPathDirectory)searchPathDirectory
                           inDomain:(NSSearchPathDomainMask)domainMask
                appendPathComponent:(NSString *)appendComponent
                              error:(NSError **)errorOut;
-(NSString*)supportDocumentDirectory;
@end
