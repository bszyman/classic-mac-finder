//
//  CCIScrollbar.m
//  Classic Scrolling2
//
//  Created by Ben Szymanski on 11/12/17.
//  Copyright © 2017 Ben Szymanski. All rights reserved.
//
//
// This file is part of Classic Finder.
//
// Classic Finder is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Classic Finder is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Classic Finder.  If not, see <http://www.gnu.org/licenses/>.

#import "CCIScrollbar.h"
#import "CCIScrollView.h"
#import "CCIScrollbarScroller.h"
#import "CCIScrollbarArrowButton.h"
#import "CCIApplicationStyles.h"

@interface CCIScrollbar()

@property (nonatomic) BOOL inactive;

@property (nonatomic) NSSize sizeOfScrollView;
@property (nonatomic) CGFloat maxContentSize;
@property (nonatomic) NSPoint scrollerPosition;

@property ScrollDirection direction;

@property (nonatomic, strong) CCIScrollbarScroller *scroller;
@property (nonatomic, strong) CCIScrollbarArrowButton *leftOrUpArrow;
@property (nonatomic, strong) CCIScrollbarArrowButton *downOrRightArrow;

@end

@implementation CCIScrollbar

#pragma mark - CREATION METHODS
+ (CCIScrollbar *)horizontalScrollbarForScrollView:(CCIScrollView *)scrollView
                                withMaxContentSize:(CGFloat)maxContentSize
{
    NSRect scrollViewFrame = [scrollView frame];
    NSRect scrollbarFrame = NSMakeRect(0.0, scrollViewFrame.size.height - 15.0, (scrollViewFrame.size.width - 14.0), 15.0);
    
    CCIScrollbar *scrollbar = [[CCIScrollbar alloc] initWithFrame:scrollbarFrame];
    
    CCIScrollbarArrowButton *leftButton = [CCIScrollbarArrowButton buttonWithDirectionality:Left
                                                                                    atPoint:NSMakePoint(0.0, 1.0)
                                                                        withParentScrollbar:scrollbar];
    [scrollbar addSubview:leftButton];
    [leftButton setAction:@selector(performScrollAction:)];
    [leftButton setTarget:scrollView];
    
    CCIScrollbarArrowButton *rightButton = [CCIScrollbarArrowButton buttonWithDirectionality:Right
                                                                                     atPoint:NSMakePoint(scrollViewFrame.size.width - 28.0, 1.0)
                                                                         withParentScrollbar:scrollbar];
    [scrollbar addSubview:rightButton];
    [rightButton setAction:@selector(performScrollAction:)];
    [rightButton setTarget:scrollView];
    
    NSPoint scrollerPosition = NSMakePoint(15.0, 1.0);
    CCIScrollbarScroller *scroller = [CCIScrollbarScroller scrollerBoxAtPoint:scrollerPosition
                                                           withDirectionality:ScrollerHorizontal];
    [scrollbar addSubview:scroller];
    
    [scrollbar setDirection:Horizontal];
    [scrollbar setLeftOrUpArrow:leftButton];
    [scrollbar setDownOrRightArrow:rightButton];
    [scrollbar setScroller:scroller];
    [scrollbar setMaxContentSize:maxContentSize];
    [scrollbar setScrollerPosition:scrollerPosition];
    [scrollbar setInactive:NO];
    
    return scrollbar;
}

+ (CCIScrollbar *)verticalScrollbarForScrollView:(CCIScrollView *)scrollView
                              withMaxContentSize:(CGFloat)maxContentSize
{
    NSRect scrollViewFrame = [scrollView frame];
    NSRect scrollbarFrame = NSMakeRect(scrollViewFrame.size.width - 15.0, 1.0, 15.0, (scrollViewFrame.size.height - 15.0));
    
    CCIScrollbar *scrollbar = [[CCIScrollbar alloc] initWithFrame:scrollbarFrame];
    
    CCIScrollbarArrowButton *upButton = [CCIScrollbarArrowButton buttonWithDirectionality:Up
                                                                                  atPoint:NSMakePoint(1.0, 0.0)
                                                                      withParentScrollbar:scrollbar];
    [scrollbar addSubview:upButton];
    [upButton setAction:@selector(performScrollAction:)];
    [upButton setTarget:scrollView];
    
    CCIScrollbarArrowButton *downButton = [CCIScrollbarArrowButton buttonWithDirectionality:Down
                                                                                    atPoint:NSMakePoint(1.0, scrollViewFrame.size.height - 29.0)
                                                                        withParentScrollbar:scrollbar];
    [scrollbar addSubview:downButton];
    [downButton setAction:@selector(performScrollAction:)];
    [downButton setTarget:scrollView];
    
    NSPoint scrollerPosition = NSMakePoint(1.0, 14.0);
    CCIScrollbarScroller *scroller = [CCIScrollbarScroller scrollerBoxAtPoint:scrollerPosition
                                                           withDirectionality:ScrollerVertical];
    [scrollbar addSubview:scroller];
    
    [scrollbar setDirection:Vertical];
    [scrollbar setLeftOrUpArrow:upButton];
    [scrollbar setDownOrRightArrow:downButton];
    [scrollbar setScroller:scroller];
    [scrollbar setMaxContentSize:maxContentSize];
    [scrollbar setScrollerPosition:scrollerPosition];
    [scrollbar setInactive:NO];

    return scrollbar;
}

- (void)setScrollerYPosition:(CGFloat)yPOS
{
    NSPoint newPoint = NSMakePoint(self.scrollerPosition.x, yPOS);
    self.scrollerPosition = newPoint;
    
    [[self scroller] moveScrollerBoxToPoint:newPoint];
}

- (void)setScrollerXPosition:(CGFloat)xPOS
{
    NSPoint newPoint = NSMakePoint(xPOS, self.scrollerPosition.y);
    self.scrollerPosition = newPoint;
    
    [[self scroller] moveScrollerBoxToPoint:newPoint];
}

- (void)updateMaxContentSize:(CGFloat)newMaxContentSize
{
    self.maxContentSize = newMaxContentSize;
}

#pragma mark - DRAWING METHODS
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    if ([self inactive]) {
        [[[CCIApplicationStyles instance] whiteColor] setFill];
        
        NSRect backgroundRect = NSMakeRect(0.0, 0.0, self.frame.size.width, self.frame.size.height);
        NSRectFill(backgroundRect);
    } else {
        [self drawTexturedBackground];
        [self drawDividerLine];
        [self drawButtonDividerBars];
    }
}

- (void)drawTexturedBackground
{
    [[[CCIApplicationStyles instance] lightGrayColor] setFill];
    NSRectFill(NSMakeRect(0.0, 0.0, self.frame.size.width, self.frame.size.height));
    
    // Texture Color
    [[[CCIApplicationStyles instance] darkGrayColor] setFill];
    
    for (NSUInteger x = 0; x <= self.frame.size.width; x++) {
        for (NSUInteger y = 0; y <= self.frame.size.height; y++) {
            if (x % 2 == 0) {
                if (y % 2 == 0) {
                    NSRect pixel = NSMakeRect(x, y, 1.0, 1.0);
                    NSRectFill(pixel);
                }
            } else {
                if (y % 2 == 1) {
                    NSRect pixel = NSMakeRect(x, y, 1.0, 1.0);
                    NSRectFill(pixel);
                }
            }
        }
    }
}

- (void)drawDividerLine
{
    NSBezierPath *dividerLine = [[NSBezierPath alloc] init];
    
    if (self.direction == Horizontal) {
        [dividerLine moveToPoint:NSMakePoint(0.0, 0.5)];
        [dividerLine lineToPoint:NSMakePoint(self.frame.size.width, 0.5)];
    } else {
        [dividerLine moveToPoint:NSMakePoint(0.5, 0.0)];
        [dividerLine lineToPoint:NSMakePoint(0.5, self.frame.size.height)];
    }
    
    [[[CCIApplicationStyles instance] blackColor] setStroke];
    [dividerLine stroke];
}

- (void)drawButtonDividerBars
{
    NSBezierPath *firstLine = [[NSBezierPath alloc] init];
    NSBezierPath *secondLine = [[NSBezierPath alloc] init];
    
    if (self.direction == Horizontal) {
        [firstLine moveToPoint:NSMakePoint(14.5, 0.0)];
        [firstLine lineToPoint:NSMakePoint(14.5, self.frame.size.height)];
        
        CGFloat offsetWidth = self.frame.size.width - 14.5;
        
        [secondLine moveToPoint:NSMakePoint(offsetWidth, 0.0)];
        [secondLine lineToPoint:NSMakePoint(offsetWidth, self.frame.size.height)];
    } else {
        [firstLine moveToPoint:NSMakePoint(0.0, 14.5)];
        [firstLine lineToPoint:NSMakePoint(self.frame.size.width, 14.5)];
        
        CGFloat offsetHeight = self.frame.size.height - 14.5;
        
        [secondLine moveToPoint:NSMakePoint(0.0, offsetHeight)];
        [secondLine lineToPoint:NSMakePoint(self.frame.size.width, offsetHeight)];
    }
    
    [[[CCIApplicationStyles instance] blackColor] setStroke];
    [firstLine stroke];
    [secondLine stroke];
}

- (BOOL)isFlipped
{
    return YES;
}

@end
