#import <Cocoa/Cocoa.h>

@class CCIScrollView;

typedef NS_ENUM(NSUInteger, ScrollDirection) {
    Horizontal,
    Vertical
};

@interface CCIScrollbar : NSControl

+ (CCIScrollbar *)horizontalScrollbarForScrollView:(CCIScrollView *)scrollView
                                withMaxContentSize:(CGFloat)maxContentSize;
+ (CCIScrollbar *)verticalScrollbarForScrollView:(CCIScrollView *)scrollView
                              withMaxContentSize:(CGFloat)maxContentSize;
- (void)setScrollerYPosition:(CGFloat)yPOS;
- (void)setScrollerXPosition:(CGFloat)xPOS;
- (void)updateMaxContentSize:(CGFloat)newMaxContentSize;
- (void)enableScrollbar;
- (void)disableScrollbar;
- (void)disableAndWhiteOutScrollbar;

@end
