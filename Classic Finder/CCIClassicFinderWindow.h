//
//  CCIClassicFinderWindow.h
//  Classic Finder
//
//  Created by Ben Szymanski on 2/19/17.
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

#import <Cocoa/Cocoa.h>

@class CCIClassicFinderWindowController;

@interface CCIClassicFinderWindow : NSWindow

@property (nonatomic, copy) NSString* windowTitle;
@property (nonatomic, copy) NSArray* fileList;

- (instancetype)initWithContentRect:(NSRect)contentRect
                          styleMask:(NSWindowStyleMask)style
                            backing:(NSBackingStoreType)bufferingType
                              defer:(BOOL)flag
                    withWindowTitle:(NSString *)windowTitle
                           fileList:(NSArray *)fileList
                      andController:(CCIClassicFinderWindowController *)wc;
- (void)setWindowActive;
- (void)setWindowInactive;
- (void)liveResizeToFrame:(NSRect)frameRect;
- (void)finishedResizeToFrame:(NSRect)frameRect;

@end
