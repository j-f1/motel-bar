#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMenu (CleanMenu)

/// This crashes when written in Swift for some reason, so here it is in Objective-C.
- (void)cleanServerMenu:(NSArray<NSString *> *) names;

@end

NS_ASSUME_NONNULL_END
