//
//  AppDelegate.m
//  Classic Finder
//
//  Created by Ben Szymanski on 2/18/17.
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

#import "AppDelegate.h"
#import "CCIClassicFinderWindow.h"
#import "CCIClassicFinderWindowController.h"
#import "CFRWindowManager.h"
#import "CFRDirectoryModel.h"
#import "CFRFloppyDisk.h"
#import "CFRFileSystemUtils.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

- (instancetype)init
{
    self = [super init];
    
    if (self)
    { }
    
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    [self openRootVolumeWindow];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    CFRWindowManager *windowManager = [CFRWindowManager sharedInstance];
    
    if ([windowManager numberOfOpenWindows] == 0) {
        [self openRootVolumeWindow];
    }
}

// Inspiration for the following two methods comes from:
// http://www.cocoabuilder.com/archive/cocoa/238362-how-to-detect-click-on-app-dock-icon-when-the-app-is-active.html

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
    return YES;
}

- (BOOL)applicationOpenUntitledFile:(NSApplication *)sender
{
    CFRWindowManager *windowManager = [CFRWindowManager sharedInstance];
    
    if ([windowManager numberOfOpenWindows] == 0) {
        [self openRootVolumeWindow];
    }
    
    return YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)openRootVolumeWindow
{
    NSURL *rootDirectoryPath = [NSURL URLWithString:@"file:///"];
    
    CFRDirectoryModel *rootDirectoryModel = [[CFRDirectoryModel alloc] init];
    [rootDirectoryModel setObjectPath:rootDirectoryPath];
    
    NSString *title = [CFRFileSystemUtils determineDirectoryNameForURL:rootDirectoryPath];
    [rootDirectoryModel setTitle:title];
    
    NSError *error = nil;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:rootDirectoryPath.path error:&error];
    NSNumber *fileSystemNumber = fileAttributes[NSFileSystemNumber];
    
    [rootDirectoryModel setFileSystemNumber:[fileSystemNumber unsignedLongLongValue]];
    
    [CFRFloppyDisk restoreDirectoryProperties:rootDirectoryModel];
    NSPoint persistedWindowPosition = [rootDirectoryModel windowPosition];
    
    if ((persistedWindowPosition.x == -1.0) &&
        (persistedWindowPosition.y == -1.0))
    {
        // We assume the window position hasn't been
        // previously set if windowPosition = (-1, -1).
        // We will just position at the midpoint of
        // the user's main screen
        
        NSRect screenSize = [[NSScreen mainScreen] frame];
        CGFloat xPos = (screenSize.size.width / 2.0) - 250.0;
        CGFloat yPos = (screenSize.size.height / 2.0) - 150.0;
        
        NSPoint newWindowPosition = NSMakePoint(xPos, yPos);
        [rootDirectoryModel setWindowPosition:newWindowPosition];
    } else {
        // Handle overflow
        // if the last-recorded position of the window is somewhere off-screen,
        // reposition it so that it is visible on screen
        // handy for cases when switching between a large desktop monitor and
        // a smaller built-in laptop screen
        NSRect mainScreenFrame = [[NSScreen mainScreen] frame];
        
        // window horizontal position is out of right-side of screen
        if (persistedWindowPosition.x > (mainScreenFrame.size.width) - 30.0) {
            NSPoint currentWindowPosition = [rootDirectoryModel windowPosition];
            NSPoint newWindowPosition = NSMakePoint(mainScreenFrame.size.width - 500.0, currentWindowPosition.y);
            [rootDirectoryModel setWindowPosition:newWindowPosition];
        }
        
        // window vertical position is below bottom of screen
        if (persistedWindowPosition.y > (mainScreenFrame.size.height) - 30.0) {
            NSPoint currentWindowPosition = [rootDirectoryModel windowPosition];
            NSPoint newWindowPosition = NSMakePoint(currentWindowPosition.x, mainScreenFrame.size.height - 300.0);
            [rootDirectoryModel setWindowPosition:newWindowPosition];
        }
        
        // window horizontal position is out of left-side of screen
        if (persistedWindowPosition.x < 0.0) {
            NSPoint currentWindowPosition = [rootDirectoryModel windowPosition];
            NSPoint newWindowPosition = NSMakePoint(30.0, currentWindowPosition.y);
            [rootDirectoryModel setWindowPosition:newWindowPosition];
        }
        
        // window vertical position is above top of screen
        if (persistedWindowPosition.y < 0.0) {
            NSPoint currentWindowPosition = [rootDirectoryModel windowPosition];
            NSPoint newWindowPosition = NSMakePoint(currentWindowPosition.x, 30.0);
            [rootDirectoryModel setWindowPosition:newWindowPosition];
        }
    }
    
    NSSize persistedWindowDimensions = [rootDirectoryModel windowDimensions];
    NSSize safeWindowDimensions = persistedWindowDimensions;
    
    if (persistedWindowDimensions.width < 0.0) {
        safeWindowDimensions = NSMakeSize(500.0, persistedWindowDimensions.height);
        [rootDirectoryModel setWindowDimensions:safeWindowDimensions];
    }
    
    if (persistedWindowDimensions.height < 0.0) {
        safeWindowDimensions = NSMakeSize(safeWindowDimensions.width, (safeWindowDimensions.width * 0.6));
        [rootDirectoryModel setWindowDimensions:safeWindowDimensions];
    }
    
    [CFRFloppyDisk persistDirectoryProperties:rootDirectoryModel];
    
    CCIClassicFinderWindowController *finderWindow = [CFRWindowManager.sharedInstance createWindowForDirectory:rootDirectoryModel];
    [finderWindow showWindow:self];
    
    self.window = finderWindow.window;
}

@end
