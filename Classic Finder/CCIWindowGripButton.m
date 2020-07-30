//
//  CCIWindowGripButton.m
//  Classic Scrolling2
//
//  Created by Ben Szymanski on 11/23/17.
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

#import "CCIWindowGripButton.h"
#import "CCIApplicationStyles.h"
#import "CCIWindowGripButtonDelegate.h"

@interface CCIWindowGripButton() {
    id delegate;
    BOOL disabled;
    BOOL whiteOut;
}

@property (nonatomic) BOOL isClicked;

@end

@implementation CCIWindowGripButton

#pragma mark - INITIALIZATION METHODS

- (instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    
    if (self) {
        [self setIsClicked:NO];
        disabled = NO;
        whiteOut = NO;
    }
    
    return self;
}

- (id)delegate
{
    return delegate;
}

- (void)setDelegate:(id)newDelegate
{
    delegate = newDelegate;
}

#pragma mark - EVENTS

- (void)mouseDragged:(NSEvent *)event
{
    NSPoint pointDraggedTo = [NSEvent mouseLocation];
    
    if ([[self delegate] respondsToSelector:@selector(gripButtonIsDraggingToCoordinates:)]) {
        [[self delegate] gripButtonIsDraggingToCoordinates:pointDraggedTo];
    }
}

- (void)mouseUp:(NSEvent *)event
{
    NSPoint pointDraggedTo = [NSEvent mouseLocation];
    
    if ([[self delegate] respondsToSelector:@selector(gripButtonDidFinishDraggingToCoordinates:)]) {
        [[self delegate] gripButtonDidFinishDraggingToCoordinates:pointDraggedTo];
    }
}

#pragma mark - DRAWING STATE MODIFIERS
- (void)enableButton
{
    disabled = NO;
    whiteOut = NO;
    [self setNeedsDisplay:YES];
}

- (void)disableButton
{
    disabled = YES;
    whiteOut = NO;
    [self setNeedsDisplay:YES];
}

- (void)disableAndWhiteOutButton
{
    disabled = YES;
    whiteOut = YES;
    [self setNeedsDisplay:YES];
}

#pragma mark - DRAWING METHODS

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    if (disabled && whiteOut) {
        [[[CCIApplicationStyles instance] blackColor] setFill];
        
        NSRect backgroundRect = NSMakeRect(0.0, 0.0, self.frame.size.width, self.frame.size.height);
        NSRectFill(backgroundRect);
        
        [[[CCIApplicationStyles instance] whiteColor] setFill];
        
        NSRect whiteRect = NSMakeRect(1.0,
                                      1.0,
                                      self.frame.size.width - 1.0,
                                      self.frame.size.height - 1.0);
        NSRectFill(whiteRect);
    } else {
        [[[CCIApplicationStyles instance] blackColor] setFill];
        
        NSRect blackFrameRect = NSMakeRect(0.0, 0.0, self.frame.size.width, self.frame.size.height);
        NSRectFill(blackFrameRect);
        
        [[[CCIApplicationStyles instance] lightGrayColor] setFill];
        
        NSRect backgroundRect = NSMakeRect(1.0,
                                           1.0,
                                           self.frame.size.width - 1.0,
                                           self.frame.size.height - 1.0);
        NSRectFill(backgroundRect);
        
        [[[CCIApplicationStyles instance] darkPurpleColor] setFill];
        NSRectFill(NSMakeRect(4.0, 4.0, 9.0, 9.0));
        
        [[[CCIApplicationStyles instance] lightPurpleColor] setFill];
        NSRectFill(NSMakeRect(5.0, 5.0, 8.0, 8.0));
        
        [[[CCIApplicationStyles instance] darkPurpleColor] setFill];
        NSRectFill(NSMakeRect(6.0, 6.0, 7.0, 7.0));
        
        [[[CCIApplicationStyles instance] midGrayColor] setFill];
        NSRectFill(NSMakeRect(6.0, 6.0, 6.0, 6.0));
        
        //small suqare
        [[[CCIApplicationStyles instance] darkPurpleColor] setFill];
        NSRectFill(NSMakeRect(3.0, 3.0, 6.0, 6.0));
        
        [[[CCIApplicationStyles instance] lightPurpleColor] setFill];
        NSRectFill(NSMakeRect(4.0, 4.0, 5.0, 5.0));
        
        [[[CCIApplicationStyles instance] darkPurpleColor] setFill];
        NSRectFill(NSMakeRect(5.0, 5.0, 4.0, 4.0));
        
        [[NSColor colorWithCalibratedRed:0.73
                                   green:0.73
                                    blue:0.73
                                   alpha:1.00] setFill];
        NSRectFill(NSMakeRect(5.0, 5.0, 3.0, 3.0));
    }
}

- (BOOL)isFlipped
{
    return YES;
}

@end
