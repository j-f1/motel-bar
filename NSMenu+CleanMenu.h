//
//  NSMenu+CleanMenu.h
//  MotelBar
//
//  Created by Jed Fox on 12/25/19.
//  Copyright © 2019 Jed Fox. All rights reserved.
//

#import <AppKit/AppKit.h>


#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMenu (CleanMenu)

/// This crashes when written in Swift for some reason, so here it is in Objective-C.
- (void)cleanServerMenu:(NSArray<NSString *> *) names;

@end

NS_ASSUME_NONNULL_END
