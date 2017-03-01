//
//  NSWindow+Additions.h
//  EasyCode
//
//  Created by lijia on 08/02/2017.
//  Copyright © 2017 music4kid. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSWindow (Additions)
- (void)setCornRadius:(CGFloat)raduis;
- (void)fadeInAnimated:(BOOL)animated;
- (void)fadeOutAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay;
@end
