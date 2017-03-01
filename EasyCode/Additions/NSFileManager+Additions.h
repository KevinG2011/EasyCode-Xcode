//
//  NSFileManager+Additions.h
//  EasyCode
//
//  Created by lijia on 01/03/2017.
//  Copyright © 2017 music4kid. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (Additions)
-(NSURL*)localSnippetsURL;
-(NSURL*)localOCSnippetsURL;
-(NSURL*)localSwiftSnippetsURL;

-(NSURL*)ubiquitySnippetsURL;
-(NSURL*)ubiquityOCSnippetsURL;
-(NSURL*)ubiquitySwiftSnippetsURL;

- (NSString *)findOrCreateDirectory:(NSSearchPathDirectory)searchPathDirectory
                           inDomain:(NSSearchPathDomainMask)domainMask
                appendPathComponent:(NSString *)appendComponent
                              error:(NSError **)errorOut;
-(NSString*)applicationSupportDirectory;
@end
