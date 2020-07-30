//
//  CFRFloppyDisk.m
//  Classic Finder
//
//  Created by Ben Szymanski on 1/14/18.
//  Copyright © 2018 Ben Szymanski. All rights reserved.
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

#import "CFRFloppyDisk.h"
#import "CFRFileSystemUtils.h"
#import "CFRFileModel.h"
#import "CFRDirectoryModel.h"
#import "CFRAppModel.h"

@implementation CFRFloppyDisk

+ (void)restoreFileProperties:(CFRFileModel *)fileModel
{
    NSString *applicationSupportDirectory = [CFRFileSystemUtils applicationSupportDirectory];
    NSString *archivePath = [NSString stringWithFormat:@"%@/%@.plist", applicationSupportDirectory, fileModel.uniqueID];

    BOOL archiveFileExists = [[NSFileManager defaultManager] fileExistsAtPath:archivePath];
    
    if (archiveFileExists) {
        id archivedObject = [NSKeyedUnarchiver unarchiveObjectWithFile:archivePath];
        CFRFileModel *unarchivedFileModel = (CFRFileModel *)archivedObject;
        
        [fileModel setIconPosition:[unarchivedFileModel iconPosition]];
    } else {
        [fileModel setIconPosition:NSMakePoint(-1.0, -1.0)];
    }
}

+ (BOOL)restoreDirectoryProperties:(CFRDirectoryModel *)directoryModel
{
    NSString *applicationSupportDirectory = [CFRFileSystemUtils applicationSupportDirectory];
    NSString *archivePath = [NSString stringWithFormat:@"%@/%@.plist", applicationSupportDirectory, directoryModel.uniqueID];
    
    BOOL archiveFileExists = [[NSFileManager defaultManager] fileExistsAtPath:archivePath];
    
    if (archiveFileExists) {
        id archivedObject = [NSKeyedUnarchiver unarchiveObjectWithFile:archivePath];
        CFRDirectoryModel *unarchivedDirectoryModel = (CFRDirectoryModel *)archivedObject;
        
        [directoryModel setIconPosition:[unarchivedDirectoryModel iconPosition]];
        [directoryModel setWindowDimensions:[unarchivedDirectoryModel windowDimensions]];
        [directoryModel setWindowPosition:[unarchivedDirectoryModel windowPosition]];
    } else {
        [directoryModel setIconPosition:NSMakePoint(-1.0, -1.0)];
        [directoryModel setWindowDimensions:NSMakeSize(-1.0, -1.0)];
        [directoryModel setWindowPosition:NSMakePoint(-1.0, -1.0)];
    }
    
    return archiveFileExists;
}

+ (void)restoreAppDirectoryProperties:(CFRAppModel *)appDirectoryModel
{
    NSString *applicationSupportDirectory = [CFRFileSystemUtils applicationSupportDirectory];
    NSString *archivePath = [NSString stringWithFormat:@"%@/%@.plist", applicationSupportDirectory, appDirectoryModel.uniqueID];
    
    BOOL archiveFileExists = [[NSFileManager defaultManager] fileExistsAtPath:archivePath];
    
    if (archiveFileExists) {
        id archivedObject = [NSKeyedUnarchiver unarchiveObjectWithFile:archivePath];
        CFRAppModel *unarchivedAppModel = (CFRAppModel *)archivedObject;
        
        [appDirectoryModel setIconPosition:[unarchivedAppModel iconPosition]];
    } else {
        [appDirectoryModel setIconPosition:NSMakePoint(-1.0, -1.0)];
    }
}

+ (BOOL)persistFileProperties:(CFRFileModel *)fileModel;
{
    NSString *applicationSupportDirectory = [CFRFileSystemUtils applicationSupportDirectory];
    NSString *archivePath = [NSString stringWithFormat:@"%@/%@.plist", applicationSupportDirectory, fileModel.uniqueID];
    
    BOOL result = [NSKeyedArchiver archiveRootObject:fileModel
                                              toFile:archivePath];
    
    return result;
}

+ (BOOL)persistDirectoryProperties:(CFRDirectoryModel *)directoryModel
{
    NSString *applicationSupportDirectory = [CFRFileSystemUtils applicationSupportDirectory];
    NSString *archivePath = [NSString stringWithFormat:@"%@/%@.plist", applicationSupportDirectory, directoryModel.uniqueID];
    
    BOOL result = [NSKeyedArchiver archiveRootObject:directoryModel
                                              toFile:archivePath];
    
    return result;
}

+ (BOOL)persistAppDirectoryProperties:(CFRAppModel *)appDirectoryModel
{
    NSString *applicationSupportDirectory = [CFRFileSystemUtils applicationSupportDirectory];
    NSString *archivePath = [NSString stringWithFormat:@"%@/%@.plist", applicationSupportDirectory, appDirectoryModel.uniqueID];
    
    BOOL result = [NSKeyedArchiver archiveRootObject:appDirectoryModel
                                              toFile:archivePath];
    
    return result;
}

@end
