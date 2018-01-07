//
//  CFRWindowManager.m
//  Classic Finder
//
//  Created by Ben Szymanski on 3/25/17.
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

#import "CFRWindowManager.h"
#import "CCIClassicFinderWindow.h"
#import "AppDelegate.h"
#import "CCIClassicFinderWindowController.h"

@interface CFRWindowManager ()

@property (nonatomic, strong) NSMutableDictionary *activeWindows;
@property (nonatomic, strong) CCIClassicFinderWindowController *activeWindow;

@end

@implementation CFRWindowManager

+(CFRWindowManager *)sharedInstance
{
    static CFRWindowManager *sharedInstance = nil;
    static dispatch_once_t pred;
    
    if (sharedInstance != nil) {
        return sharedInstance;
    }
    
    dispatch_once(&pred, ^{
        sharedInstance = [CFRWindowManager alloc];
        sharedInstance = [sharedInstance init];
        sharedInstance.activeWindows = [[NSMutableDictionary alloc] initWithCapacity:30];
    });
    
    return sharedInstance;
}

- (NSWindowController *)createWindowForPath:(NSURL *)path
{
    NSRect screenSize = [[NSScreen mainScreen] frame];
    CGFloat xPos = (screenSize.size.width / 2.0) - 250.0;
    CGFloat yPos = (screenSize.size.height / 2.0) - 150.0;
    
    NSWindowController *newFinderWindow = [self createWindowForPath:path
                                                   atSpecifiedPoint:NSMakePoint(xPos, yPos)];
    
    return newFinderWindow;
}

- (CCIClassicFinderWindowController *)createWindowForPath:(NSURL *)path
                                         atSpecifiedPoint:(NSPoint)point
{
    CCIClassicFinderWindowController *finderWindowController;
    
    if ([self.activeWindows objectForKey:path.absoluteString] != nil)
    {
        finderWindowController = [self.activeWindows objectForKey:path.absoluteString];
    } else
    {
        CCIClassicFinderWindowController *wc = [[CCIClassicFinderWindowController alloc] initForDirectory:path
                                                                                              atPoint:point];
        [wc.window makeKeyAndOrderFront:self];

        finderWindowController = wc;
        
        [self.activeWindows setObject:wc
                               forKey:path.absoluteString];
    }

    return finderWindowController;
}

- (void)windowWillClose:(NSNotification *)notification
{
    CCIClassicFinderWindow *finderWindow = notification.object;
    CCIClassicFinderWindowController *finderWindowController = finderWindow.windowController;
    NSString *pathString = finderWindowController.representedDirectory.absoluteString;
    
    [self.activeWindows removeObjectForKey:pathString];
}

- (void)windowDidBecomeMain:(NSNotification *)notification
{
    CCIClassicFinderWindow *finderWindow = notification.object;
    CCIClassicFinderWindowController *finderWindowController = finderWindow.windowController;
    
    self.activeWindow = finderWindowController;
}

- (NSUInteger)numberOfOpenWindows
{
    return [[self activeWindows] count];
}

@end
