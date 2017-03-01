//
//  AppDelegate.h
//  AirCode
//
//  Created by Loriya on 2017/3/1.
//  Copyright © 2017年 music4kid. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (nonatomic, assign) BOOL useiCloud;

- (IBAction)showEditorWindowForOC:(id)sender;
- (IBAction)showEditorWindowForSwift:(id)sender;
- (IBAction)showHowToUse:(id)sender;

-(NSURL*)cloudDocumentURL;
@end

