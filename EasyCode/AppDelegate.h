//
//  AppDelegate.h
//  EasyCode
//
//  Created by gao feng on 2016/10/15.
//  Copyright © 2016年 music4kid. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (nonatomic, assign) BOOL useiCloud;

- (IBAction)showEditorWindowForOC:(id)sender;
- (IBAction)showEditorWindowForSwift:(id)sender;
- (IBAction)showHowToUse:(id)sender;

-(NSURL*)cloudDocumentURL;

@end

