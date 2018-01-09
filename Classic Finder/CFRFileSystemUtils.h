//
//  CFRFileSystemUtils.h
//  Classic Finder
//
//  Created by Ben Szymanski on 1/8/18.
//  Copyright © 2018 Protype Software Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CFRFileSystemUtils : NSObject

+ (NSString *)determineDirectoryNameForURL:(NSURL *)url;

@end
