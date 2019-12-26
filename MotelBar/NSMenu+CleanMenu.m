#import "NSMenu+CleanMenu.h"

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
