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
-(ECSnippet*)snippetWithURL:(NSURL*)fileURL;
-(ECSnippet*)snippetWithEditorType:(EditorType)editorType;
@end
