//
//  CCIScrollView.m
//  Classic Scrolling2
//
//  Created by Ben Szymanski on 11/12/17.
//  Copyright © 2017 Ben Szymanski. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "CCIScrollView.h"
#import "CCIScrollContentContainer.h"
#import "CCIScrollContentView.h"
#import "CCIScrollbar.h"
#import "CCIScrollbarArrowButton.h"
#import "CCIWindowGripButton.h"
#import "CCIApplicationStyles.h"
#import "CCIClassicFinderWindowController.h"

@interface CCIScrollView() {
    id delegate;
    BOOL windowIsActive;
    BOOL activateHorizontalScrollbar;
    BOOL activateVerticleScrollbar;
}

@property (nonatomic) NSSize scrollableDistance;
@property (nonatomic) NSSize scrollIntervalSize;
@property (nonatomic) NSPoint currentScrollPosition;
@property (nonatomic) NSPoint currentScrollerBarPosition;

@property (nonatomic, strong) CCIScrollbar *horizontalScrollbar;
@property (nonatomic, strong) CCIScrollbar *verticalScrollbar;
@property (nonatomic, strong) CCIWindowGripButton *gripButton;

@end

@implementation CCIScrollView

#pragma mark - INITIALIZATION METHODS
- (instancetype)initWithFrame:(NSRect)frameRect
                andController:(CCIClassicFinderWindowController *)wc
{
    self = [super initWithFrame:frameRect];
    
    if (self) {
        delegate = wc;
        
        // Create content view container
        // this view is a container for the actual content view
        // we are wrapping the actual content view in this thing
        // to set the visible bounds of the content area. The actual
        // content view can be any super large size, but it needs
        // a parent view to clip that and set the bounds.
        // Without this, the white of the file icon erases/overlaps over
        // the black line at the top of the scroll view. Looks strange. No good!
        NSRect contentViewContainerFrame = NSMakeRect(0.0, 1.0, frameRect.size.width, (frameRect.size.height - 1.0));
         CCIScrollContentContainer *contentViewContainer = [[CCIScrollContentContainer alloc] initWithFrame:contentViewContainerFrame];
        [self setContentViewContainer:contentViewContainer];
        [self addSubview:self.contentViewContainer];
        
        // // Create content view
        NSRect contentViewFrame = NSMakeRect(0.0, 1.0, frameRect.size.width, (frameRect.size.height - 1.0));
        CCIScrollContentView *contentView = [[CCIScrollContentView alloc] initWithFrame:contentViewFrame];
        [self setContentView:contentView];
        //[self addSubview:self.contentView];
        [[self contentViewContainer] addSubview:contentView];
        
        // // Calculate scroll travel distances
        CGFloat scrollableDistanceW = (contentViewFrame.size.width > frameRect.size.width) ? (contentViewFrame.size.width - frameRect.size.width + 16.0) : 0.0;
        CGFloat scrollableDistanceH = (contentViewFrame.size.height > frameRect.size.height) ? (contentViewFrame.size.height - frameRect.size.height + 16.0) : 0.0;
        
        NSSize scrollableDistance = NSMakeSize(scrollableDistanceW, scrollableDistanceH);
        [self setScrollableDistance:scrollableDistance];
        
        //
        NSPoint currentScrollPosition = NSMakePoint(0.0, 0.0);
        [self setCurrentScrollPosition:currentScrollPosition];
        
        //
        CGFloat leftButtonWidth = 16.0;
        CGFloat rightButtonWidth = 16.0;
        CGFloat scrollerMidWidth = (16.0/2.0);
        CGFloat combinedNegativeWidth = leftButtonWidth + rightButtonWidth + scrollerMidWidth;
        
        CGFloat horizontalScrollInterval = (contentViewFrame.size.width > frameRect.size.width) ? (round(contentViewFrame.size.width - combinedNegativeWidth)) : 0.0;
        
        CGFloat verticalScrollInterval = (contentViewFrame.size.height > frameRect.size.height) ? (contentViewFrame.size.height - frameRect.size.height) : 0.0;
        
        NSSize scrollIntervalSize = NSMakeSize(horizontalScrollInterval, verticalScrollInterval);
        [self setScrollIntervalSize:scrollIntervalSize];
        
        // // Create scrollbar controls
        CCIScrollbar *verticalScrollbar = [CCIScrollbar verticalScrollbarForScrollView:self
                                                                    withMaxContentSize:900.0];
        [self setVerticalScrollbar:verticalScrollbar];
        [self addSubview:verticalScrollbar];
        
        CCIScrollbar *horizontalScrollbar = [CCIScrollbar horizontalScrollbarForScrollView:self
                                                                        withMaxContentSize:300.0];
        [self setHorizontalScrollbar:horizontalScrollbar];
        [self addSubview:horizontalScrollbar];
        
        // // Create Grip button
        NSRect gripButtonFrame = NSMakeRect(self.frame.size.width - 15.0, self.frame.size.height - 15.0, 15.0, 15.0);
        CCIWindowGripButton *gripButton = [[CCIWindowGripButton alloc] initWithFrame:gripButtonFrame];
        [gripButton setDelegate:delegate];
        [self setGripButton:gripButton];
        
        [self addSubview:gripButton];
        
        // // Init scroller positions
        NSPoint scrollerInitialPoints = NSMakePoint(0.0, 0.0);
        [self setCurrentScrollerBarPosition:scrollerInitialPoints];
    }
    
    return self;
}

#pragma mark - NON-COMPUTED PROPERTIES

- (id)delegate
{
    return delegate;
}

- (void)setDelegate:(id)newDelegate
{
    delegate = newDelegate;
}

#pragma mark - EVENT METHODS
- (void)performScrollAction:(id)sender
{
    CCIScrollbarArrowButton *clickedBtn = (CCIScrollbarArrowButton *)sender;
    ButtonDirectionality direction = clickedBtn.direction;
    
    if (direction == Up) {
        CGFloat newYPosition = self.currentScrollPosition.y + 50.0;
        newYPosition = (newYPosition < 0) ? newYPosition : 0.0;

        NSRect newFrame = NSMakeRect(self.currentScrollPosition.x, newYPosition, self.contentView.frame.size.width, self.contentView.frame.size.height);
        [self.contentView setFrame:newFrame];
        
        self.currentScrollPosition = NSMakePoint(self.currentScrollPosition.x, newYPosition);
        
        // Set scroller position
        
        CGFloat scrollbarTrackHeight = self.verticalScrollbar.frame.size.height - 16.0 - 16.0;
        
        // current scroll position * height of scrollbar track / max height of scrollable distance
        CGFloat step1 = (0.0 - self.currentScrollPosition.y) * scrollbarTrackHeight;
        CGFloat YPositionOfScroller = step1 / self.scrollableDistance.height;
        YPositionOfScroller = (YPositionOfScroller < 16.0) ? 16.0 : YPositionOfScroller + 16.0;
        
        self.currentScrollerBarPosition = NSMakePoint(self.currentScrollerBarPosition.x, YPositionOfScroller);
        
        [self.verticalScrollbar setScrollerYPosition:YPositionOfScroller];
        
    } else if (direction == Down) {
        CGFloat newYPosition = self.currentScrollPosition.y - 50.0;
        newYPosition = (newYPosition > (0.0 - self.scrollableDistance.height)) ? newYPosition : 0.0 - self.scrollableDistance.height;
        
        NSRect newFrame = NSMakeRect(self.currentScrollPosition.x, newYPosition, self.contentView.frame.size.width, self.contentView.frame.size.height);
        [self.contentView setFrame:newFrame];
        
        self.currentScrollPosition = NSMakePoint(self.currentScrollPosition.x, newYPosition);
        
        // Set scroller position
        
        CGFloat scrollbarTrackHeight = self.verticalScrollbar.frame.size.height - 16.0 - 16.0;
        
        // current scroll position * height of scrollbar track / max height of scrollable distance
        CGFloat step1 = (0.0 - self.currentScrollPosition.y) * scrollbarTrackHeight;
        CGFloat YPositionOfScroller = step1 / self.scrollableDistance.height;
        YPositionOfScroller = (YPositionOfScroller >= scrollbarTrackHeight - 16.0) ? (scrollbarTrackHeight - 16.0) + 16.0 : YPositionOfScroller + 16.0;
        
        self.currentScrollerBarPosition = NSMakePoint(self.currentScrollerBarPosition.x, YPositionOfScroller);
        
        [self.verticalScrollbar setScrollerYPosition:YPositionOfScroller];
    } else if (direction == Left) {
        CGFloat newXPosition = self.currentScrollPosition.x + 50.0;
        newXPosition = (newXPosition < 0) ? newXPosition : 0.0;
        
        NSRect newFrame = NSMakeRect(newXPosition, self.currentScrollPosition.y, self.contentView.frame.size.width, self.contentView.frame.size.height);
        [self.contentView setFrame:newFrame];
        
        self.currentScrollPosition = NSMakePoint(newXPosition, self.currentScrollPosition.y);
        
        // Set scroller position
        
        CGFloat scrollbarTrackWidth = self.horizontalScrollbar.frame.size.width - 16.0 - 16.0;
        
        // current scroll position * height of scrollbar track / max height of scrollable distance
        CGFloat step1 = (0 - self.currentScrollPosition.x) * scrollbarTrackWidth;
        CGFloat XPositionOfScroller = step1 / self.scrollableDistance.width;
        XPositionOfScroller = (XPositionOfScroller < 16.0) ? 16.0 : XPositionOfScroller + 16.0;
        
        self.currentScrollerBarPosition = NSMakePoint(XPositionOfScroller, self.currentScrollerBarPosition.y);
        
        [self.horizontalScrollbar setScrollerXPosition:XPositionOfScroller];
    } else if (direction == Right) {
        CGFloat newXPosition = self.currentScrollPosition.x - 50.0;
        newXPosition = (newXPosition > (0 - self.scrollableDistance.width)) ? newXPosition : (0.0 - self.scrollableDistance.width);
        
        NSRect newFrame = NSMakeRect(newXPosition, self.currentScrollPosition.y, self.contentView.frame.size.width, self.contentView.frame.size.height);
        [self.contentView setFrame:newFrame];
        
        self.currentScrollPosition = NSMakePoint(newXPosition, self.currentScrollPosition.y);
        
        
        // Set scroller position
        
        CGFloat scrollbarTrackWidth = self.horizontalScrollbar.frame.size.width - 16.0 - 16.0;
        
        // current scroll position * height of scrollbar track / max height of scrollable distance
        CGFloat step1 = (0.0 - self.currentScrollPosition.x) * scrollbarTrackWidth;
        CGFloat XPositionOfScroller = step1 / self.scrollableDistance.width;
        XPositionOfScroller = (XPositionOfScroller >= (scrollbarTrackWidth - 16.0)) ? ((scrollbarTrackWidth - 16.0) + 16.0) : (XPositionOfScroller + 16.0);
        
        self.currentScrollerBarPosition = NSMakePoint(XPositionOfScroller, self.currentScrollerBarPosition.y);
        
        [self.horizontalScrollbar setScrollerXPosition:XPositionOfScroller];
    }
}

- (void)resizeContentView:(NSRect)newFrame
{
    [[self contentView] setFrame:newFrame];
    
    CGFloat scrollableDistanceW = (newFrame.size.width > self.frame.size.width) ? (newFrame.size.width - self.frame.size.width + 14.0) : 0.0;
    CGFloat scrollableDistanceH = (newFrame.size.height > self.frame.size.height) ? (newFrame.size.height - self.frame.size.height + 14.0) : 0.0;
    
    NSSize scrollableDistance = NSMakeSize(scrollableDistanceW, scrollableDistanceH);
    [self setScrollableDistance:scrollableDistance];
    
    [[self verticalScrollbar] updateMaxContentSize:newFrame.size.height];
    [[self horizontalScrollbar] updateMaxContentSize:newFrame.size.width];

    if (self.contentView.frame.size.width <= self.frame.size.width) {
        [[self horizontalScrollbar] setEnabled:NO];
        [[self horizontalScrollbar] disableScrollbar];
        activateHorizontalScrollbar = NO;
    } else {
        [[self horizontalScrollbar] setEnabled:YES];
        [[self horizontalScrollbar] enableScrollbar];
        activateHorizontalScrollbar = YES;
    }
    
    if (self.contentView.frame.size.height <= self.frame.size.height) {
        [[self verticalScrollbar] setEnabled:NO];
        [[self verticalScrollbar] disableScrollbar];
        activateVerticleScrollbar = NO;
    } else {
        [[self verticalScrollbar] setEnabled:YES];
        [[self verticalScrollbar] enableScrollbar];
        activateVerticleScrollbar = YES;
    }
}

- (void)mouseUp:(NSEvent *)event
{
    CCIClassicFinderWindowController *wc = event.window.windowController;
    [wc deselectAllItems];
}

#pragma mark - WINDOW STATE METHODS
- (void)setWindowIsActive:(BOOL)pWindowIsActive
{
    windowIsActive = pWindowIsActive;
    
    if (windowIsActive) {
        if (activateHorizontalScrollbar) {
            [[self horizontalScrollbar] enableScrollbar];
        } else {
            [[self horizontalScrollbar] disableScrollbar];
        }
        
        if (activateVerticleScrollbar) {
            [[self verticalScrollbar] enableScrollbar];
        } else {
            [[self verticalScrollbar] disableScrollbar];
        }

        [[self gripButton] enableButton];
    } else {
        [[self verticalScrollbar] disableAndWhiteOutScrollbar];
        [[self horizontalScrollbar] disableAndWhiteOutScrollbar];
        
        [[self gripButton] disableAndWhiteOutButton];
    }
    
    [self setNeedsDisplay:YES];
}

#pragma mark - DRAWING METHODS
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSRect blackBackgroundFrame = NSMakeRect(0.0, 0.0, self.frame.size.width, self.frame.size.height);
    [[[CCIApplicationStyles instance] blackColor] setFill];
    NSRectFill(blackBackgroundFrame);
    
    NSRect backgroundFrame = NSMakeRect(0.0, 1.0, self.frame.size.width, (self.frame.size.height - 1.0));
    
    // Background Color
    [[[CCIApplicationStyles instance] whiteColor] setFill];
    NSRectFill(backgroundFrame);
    
//    NSBezierPath *topBorder = [[NSBezierPath alloc] init];
//    [topBorder moveToPoint:NSMakePoint(0.0, 0.0)];
//    [topBorder lineToPoint:NSMakePoint(self.frame.size.width, 0.0)];
//    
//    [[[CCIApplicationStyles instance] blackColor] setStroke];
//    [topBorder stroke];
}

- (BOOL)isFlipped
{
    return YES;
}

@end
