//
//  NSFileManager+Additions.h
//  EasyCode
//
//  Created by lijia on 01/03/2017.
//  Copyright © 2017 music4kid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECDefine.h"

extern NSString *const DirectoryLocationDomain;
extern NSString *const DirectoryUbiquityDocuments;
extern NSString *const DirectoryOCName;
extern NSString *const DirectorySwiftName;
extern NSString *const SnippetFileName;
extern NSString *const VersionFileName;

@interface NSFileManager (Additions)
-(NSURL*)localURL;
-(NSURL*)localSnippetsURLWithFilename:(NSString*)filename;
-(NSURL*)ubiquityURL;
-(NSURL*)ubiquitySnippetsURLWithFilename:(NSString*)filename;

-(NSURL*)currentURLForEditorType:(EditorType)editorType;

-(NSString *)findOrCreateDirectory:(NSSearchPathDirectory)searchPathDirectory
                          inDomain:(NSSearchPathDomainMask)domainMask
               appendPathComponent:(NSString *)appendComponent
                             error:(NSError **)errorOut;
-(NSString*)supportDocumentDirectory;
@end
