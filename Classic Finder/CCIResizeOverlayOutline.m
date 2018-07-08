//
//  CCIResizeOverlayOutline.m
//  Classic Finder
//
//  Created by Ben Szymanski on 3/25/18.
//  Copyright © 2018 Protype Software Ltd. All rights reserved.
//

#import "CCIResizeOverlayOutline.h"
#import "CCIApplicationStyles.h"

@interface CCIResizeOverlayOutline() {
    NSBezierPath *windowTopPath;
    NSBezierPath *windowLeftPath;
    NSBezierPath *windowRightPath;
    NSBezierPath *windowBottomPath;
    NSBezierPath *menuBarBottomPath;
    NSBezierPath *verticalScrollbarLeftPath;
    NSBezierPath *horizontalScrollbarTopPath;
}

@end

@implementation CCIResizeOverlayOutline

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [[[CCIApplicationStyles instance] blackColor] setStroke];
    
    if (windowTopPath == nil) {
        windowTopPath = [[NSBezierPath alloc] init];
    }
    
    if (![windowTopPath isEmpty]) {
        [windowTopPath removeAllPoints];
    }
    
    [windowTopPath moveToPoint:NSMakePoint(0.0, 0.5)];
    [windowTopPath lineToPoint:NSMakePoint(self.frame.size.width, 0.5)];
    [windowTopPath stroke];
    
    
    if (windowLeftPath == nil) {
        windowLeftPath = [[NSBezierPath alloc] init];
    }
    
    if (![windowLeftPath isEmpty]) {
        [windowLeftPath removeAllPoints];
    }
    
    [windowLeftPath moveToPoint:NSMakePoint(0.5, 0.0)];
    [windowLeftPath lineToPoint:NSMakePoint(0.5, self.frame.size.height)];
    [windowLeftPath stroke];
    
    if (windowRightPath == nil) {
        windowRightPath = [[NSBezierPath alloc] init];
    }
    
    if (![windowRightPath isEmpty]) {
        [windowRightPath removeAllPoints];
    }
    
    [windowRightPath moveToPoint:NSMakePoint((self.frame.size.width - 0.5), 0.0)];
    [windowRightPath lineToPoint:NSMakePoint((self.frame.size.width - 0.5), self.frame.size.height)];
    [windowRightPath stroke];
    
    if (windowBottomPath == nil) {
        windowBottomPath = [[NSBezierPath alloc] init];
    }
    
    if (![windowBottomPath isEmpty]) {
        [windowBottomPath removeAllPoints];
    }
    
    [windowBottomPath moveToPoint:NSMakePoint(0.0, (self.frame.size.height - 0.5))];
    [windowBottomPath lineToPoint:NSMakePoint(self.frame.size.width, (self.frame.size.height - 0.5))];
    [windowBottomPath stroke];
    
    if (menuBarBottomPath == nil) {
        menuBarBottomPath = [[NSBezierPath alloc] init];
    }
    
    if (![menuBarBottomPath isEmpty]) {
        [menuBarBottomPath removeAllPoints];
    }
    
    [menuBarBottomPath moveToPoint:NSMakePoint(0.0, 19.0)];
    [menuBarBottomPath lineToPoint:NSMakePoint(self.frame.size.width, 19.0)];
    [menuBarBottomPath stroke];
    
    if (verticalScrollbarLeftPath == nil) {
        verticalScrollbarLeftPath = [[NSBezierPath alloc] init];
    }
    
    if (![verticalScrollbarLeftPath isEmpty]) {
        [verticalScrollbarLeftPath removeAllPoints];
    }
    
    [verticalScrollbarLeftPath moveToPoint:NSMakePoint((self.frame.size.width - 20.5), 19.0)];
    [verticalScrollbarLeftPath lineToPoint:NSMakePoint((self.frame.size.width - 20.5), self.frame.size.height)];
    [verticalScrollbarLeftPath stroke];
    
    if (horizontalScrollbarTopPath == nil) {
        horizontalScrollbarTopPath = [[NSBezierPath alloc] init];
    }
    
    if (![horizontalScrollbarTopPath isEmpty]) {
        [horizontalScrollbarTopPath removeAllPoints];
    }
    
    [horizontalScrollbarTopPath moveToPoint:NSMakePoint(0.0, (self.frame.size.height - 20.5))];
    [horizontalScrollbarTopPath lineToPoint:NSMakePoint(self.frame.size.width, (self.frame.size.height - 20.5))];
    [horizontalScrollbarTopPath stroke];
}

- (BOOL)isFlipped
{
    return YES;
}

@end
