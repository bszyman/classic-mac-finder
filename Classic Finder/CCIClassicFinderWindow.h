//
//  CCIClassicFinderWindow.h
//  Classic Finder
//
//  Created by Ben Szymanski on 2/19/17.
//  Copyright © 2017 Protype Software Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CCIClassicFinderWindow : NSWindow

@property (nonatomic, copy) NSString *directoryPath;

- (instancetype)initWithContentRect:(NSRect)contentRect
                          styleMask:(NSWindowStyleMask)style
                            backing:(NSBackingStoreType)bufferingType
                              defer:(BOOL)flag
                    atDirectoryPath: (NSString *)directoryPath;

@end
