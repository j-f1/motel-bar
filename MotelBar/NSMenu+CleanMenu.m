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

@implementation NSMenu (CleanMenu)

- (void)cleanServerMenu:(NSArray<NSString *> *) names {
    for (NSMenuItem *item in self.itemArray) {
        if (item.isSeparatorItem) {
            return;
        }
        if (![names containsObject:item.representedObject]) {
            [self removeItem:item];
        }
    }
}

@end

NS_ASSUME_NONNULL_END
