//
//  ECSnippetHelper.h
//  EasyCode
//
//  Created by lijia on 07/03/2017.
//  Copyright © 2017 music4kid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECSnippet.h"
#import "ECDefine.h"

@interface ECSnippetHelper : NSObject
+(ECSourceType)sourceTypeForContentUTI:(NSString*)contentUTI;
+(ECSnippet*)snippetWithFileWrapper:(NSFileWrapper*)fileWrapper;
+(ECSnippet*)snippetWithSourceType:(ECSourceType)sourceType;
+(NSInteger)versionWithSourceType:(ECSourceType)sourceType;
@end
