//
//  CFRFileSystemOperations.m
//  Classic Finder
//
//  Created by Ben Szymanski on 10/5/17.
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

#import "CFRFileSystemOperations.h"
#import "CFRFileModel.h"
#import "CFRDirectoryModel.h"
#import "CFRAppModel.h"

@implementation CFRFileSystemOperations

+ (NSArray *)getListingForDirectory:(NSURL *)directory
{
    NSMutableArray *fileList = [[NSMutableArray alloc] initWithCapacity:64];
    NSArray *keys = @[NSURLNameKey, NSURLPathKey, NSURLAddedToDirectoryDateKey, NSURLContentModificationDateKey];
    NSError *err = nil;
    
    NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:directory
                                                               includingPropertiesForKeys:keys
                                                                                  options:(NSDirectoryEnumerationSkipsPackageDescendants |
                                                                                           NSDirectoryEnumerationSkipsHiddenFiles |
                                                                                           NSDirectoryEnumerationSkipsSubdirectoryDescendants)
                                                                                    error:&err];
    
    if (err != nil) {
        NSLog(@"%@", err);
    } else {
        for (NSURL *directoryItem in directoryContents) {
            NSNumber *isDirectory;
            [directoryItem getResourceValue:&isDirectory
                                     forKey:NSURLIsDirectoryKey
                                      error:nil];
            
            NSString *title;
            [directoryItem getResourceValue:&title
                                     forKey:NSURLNameKey
                                      error:nil];
            
            NSString *path;
            [directoryItem getResourceValue:&path
                                     forKey:NSURLPathKey
                                      error:nil];
            
            NSDate *createdDate;
            [directoryItem getResourceValue:&createdDate
                                     forKey:NSURLAddedToDirectoryDateKey
                                      error:nil];
            
            NSDate *lastModifiedDate;
            [directoryItem getResourceValue:&lastModifiedDate
                                     forKey:NSURLContentModificationDateKey
                                      error:nil];
            
            NSError *err;
            NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:directoryItem.path
                                                                                                   error:&err];
            
            if (err != nil) {
                NSLog(@"%@", err.description);
            }
            
            NSNumber *fileSystemNumber = fileAttributes[NSFileSystemNumber];
            
            if ([isDirectory boolValue]) {
                CFRDirectoryModel *directoryModel = [[CFRDirectoryModel alloc] init];
                [directoryModel setTitle:title];
                [directoryModel setCreationDate:createdDate];
                [directoryModel setLastModified:lastModifiedDate];
                [directoryModel setObjectPath:directoryItem];
                [directoryModel setFileSystemNumber:[fileSystemNumber unsignedLongLongValue]];
                
                [fileList addObject:directoryModel];
            } else {
                CFRFileModel *fileModel = [[CFRFileModel alloc] init];
                [fileModel setTitle:title];
                [fileModel setCreationDate:createdDate];
                [fileModel setLastModified:lastModifiedDate];
                [fileModel setObjectPath:directoryItem];
                [fileModel setFileSystemNumber:[fileSystemNumber unsignedLongLongValue]];
                
                [fileList addObject:fileModel];
            }
        }
    }
    
    return fileList;
}

+ (void)openFileAtURL:(NSURL *)fileURL
{
    NSTask *openTask = [[NSTask alloc] init];
    NSArray *args = @[fileURL.absoluteString];
    
    [openTask setLaunchPath:@"/usr/bin/open"];
    [openTask setArguments:args];
    
    [openTask launch];
}

+ (void)createNewFolderInDirectory:(NSURL *)directory
                             named:(NSString *)directoryName
{
    NSURL *parentDirectoryOfOriginalDirectory = [directory URLByDeletingLastPathComponent];
    
    NSString *pathOfNewDirectory = [NSString stringWithFormat:@"%@/%@", parentDirectoryOfOriginalDirectory.absoluteString, directoryName];
    
    // Create and run copy/duplicate task
    NSTask *createDirectoryTask = [[NSTask alloc] init];
    NSArray *args = @[pathOfNewDirectory];
    
    [createDirectoryTask setLaunchPath:@"/bin/mkdir"];
    [createDirectoryTask setArguments:args];
    
    @try {
        [createDirectoryTask launch];
    }
    @catch (NSException *e) {
        NSLog(@"Error while running create directory operation. (%@ / %@)", e.name, e.reason);
    }
}

+ (void)printFile:(NSURL *)file
{
    
}

+ (void)duplicateFile:(NSURL *)file
{
    // Create file name for new file
    NSString *fileName = [file lastPathComponent];
    NSString *regexPattern = @"([A-Za-z0-9_ ]+)+";
    
    NSError *regexError = nil;
    NSRegularExpression *fileNameRegex = [[NSRegularExpression alloc] initWithPattern:regexPattern
                                                                              options:NSRegularExpressionCaseInsensitive
                                                                                error:&regexError];
    
    if (regexError != nil) {
        NSLog(@"Error while parsing filename. (%@)", regexError.description);
    } else {
        NSArray *fileNameCaptureGroups = [fileNameRegex matchesInString:fileName
                                                                options:0 range:NSMakeRange(0, [fileName length])];
        if ([fileNameCaptureGroups count] >= 2) {
            NSString *duplicateFileName = [NSString stringWithFormat:@"%@ copy", fileName];
            
            // start at the second array index
            for (NSUInteger x = 1; x < [fileNameCaptureGroups count]; x += 1) {
                NSString *fileNameExtra = [fileNameCaptureGroups objectAtIndex: x];
                duplicateFileName = [NSString stringWithFormat:@"%@.%@", duplicateFileName, fileNameExtra];
            }
            
            NSString *pathOfOriginalFile = [file absoluteString];
            NSURL *parentDirectoryOfOriginalFile = [file URLByDeletingLastPathComponent];
            
            NSString *pathOfNewFile = [NSString stringWithFormat:@"%@/%@", parentDirectoryOfOriginalFile.absoluteString, duplicateFileName];
            
            // Create and run copy/duplicate task
            NSTask *duplicateTask = [[NSTask alloc] init];
            NSArray *args = @[pathOfOriginalFile, pathOfNewFile];
            
            [duplicateTask setLaunchPath:@"/bin/cp"];
            [duplicateTask setArguments:args];
            
            @try {
                [duplicateTask launch];
            }
            @catch (NSException *e) {
                NSLog(@"Error while running duplicate operation. (%@ / %@)", e.name, e.reason);
            }
        } else {
            NSLog(@"Error while creating duplicate file name - not parsed correctly or missing extension.");
        }
    }
}

+ (void)duplicateDirectory:(NSURL *)directory
{
    // Create file name for new directory
    NSString *directoryName = [directory lastPathComponent];
    NSString *duplicateDirectoryName = [NSString stringWithFormat:@"%@ copy", directoryName];
    
    NSString *pathOfOriginalDirectory = [directory absoluteString];
    NSURL *parentDirectoryOfOriginalDirectory = [directory URLByDeletingLastPathComponent];
    
    NSString *pathOfNewDirectory = [NSString stringWithFormat:@"%@/%@", parentDirectoryOfOriginalDirectory.absoluteString, duplicateDirectoryName];
    
    // Create and run copy/duplicate task
    NSTask *duplicateTask = [[NSTask alloc] init];
    NSArray *args = @[@"-r", pathOfOriginalDirectory, pathOfNewDirectory];
    
    [duplicateTask setLaunchPath:@"/bin/cp"];
    [duplicateTask setArguments:args];
    
    @try {
        [duplicateTask launch];
    }
    @catch (NSException *e) {
        NSLog(@"Error while running duplicate operation. (%@ / %@)", e.name, e.reason);
    }
}

+ (void)renameFile:(NSURL *)file
                to:(NSString *)newName
{
    NSString *originalFileName = [file lastPathComponent];
    NSString *regexPattern = @"([A-Za-z0-9_ ]+)+";
    
    NSError *regexError = nil;
    NSRegularExpression *fileNameRegex = [[NSRegularExpression alloc] initWithPattern:regexPattern
                                                                              options:NSRegularExpressionCaseInsensitive
                                                                                error:&regexError];
    
    if (regexError != nil) {
        NSLog(@"Error while parsing filename. (%@)", regexError.description);
    } else {
        NSArray *fileNameCaptureGroups = [fileNameRegex matchesInString:originalFileName
                                                                options:0 range:NSMakeRange(0, [originalFileName length])];
        if ([fileNameCaptureGroups count] >= 2) {
            NSString *newFileName = [NSString stringWithFormat:@"%@", newName];
            
            // start at the second array index
            for (NSUInteger x = 1; x < [fileNameCaptureGroups count]; x += 1) {
                NSString *fileNameExtra = [fileNameCaptureGroups objectAtIndex: x];
                newFileName = [NSString stringWithFormat:@"%@.%@", newFileName, fileNameExtra];
            }
            
            NSString *pathOfOriginalFile = [file absoluteString];
            NSURL *parentDirectoryOfOriginalFile = [file URLByDeletingLastPathComponent];
            
            NSString *pathOfNewFile = [NSString stringWithFormat:@"%@/%@", parentDirectoryOfOriginalFile.absoluteString, newFileName];
            
            // Create and run copy/duplicate task
            NSTask *moveFileTask = [[NSTask alloc] init];
            NSArray *args = @[pathOfOriginalFile, pathOfNewFile];
            
            [moveFileTask setLaunchPath:@"/bin/mv"];
            [moveFileTask setArguments:args];
            
            @try {
                [moveFileTask launch];
            }
            @catch (NSException *e) {
                NSLog(@"Error while running move file operation. (%@ / %@)", e.name, e.reason);
            }
        } else {
            NSLog(@"Error while creating new file name - not parsed correctly or missing extension.");
        }
    }
}

+ (void)renameDirectory:(NSURL *)directory
                     to:(NSString *)newName
{
    NSString *pathOfOriginalDirectory = [directory absoluteString];
    NSURL *parentDirectoryOfOriginalDirectory = [directory URLByDeletingLastPathComponent];
    
    NSString *pathOfNewDirectory = [NSString stringWithFormat:@"%@/%@", parentDirectoryOfOriginalDirectory.absoluteString, newName];
    
    // Create and run copy/duplicate task
    NSTask *renameTask = [[NSTask alloc] init];
    NSArray *args = @[pathOfOriginalDirectory, pathOfNewDirectory];
    
    [renameTask setLaunchPath:@"/bin/mv"];
    [renameTask setArguments:args];
    
    @try {
        [renameTask launch];
    }
    @catch (NSException *e) {
        NSLog(@"Error while running rename directory operation. (%@ / %@)", e.name, e.reason);
    }
}

+ (void)moveFileToTrash:(NSURL *)file
{
    NSString *pathOfFile = [file absoluteString];
    
    NSURL *userTrashDirectory = [NSURL URLWithString:@"~/.Tash"];
    NSString *userTrashDirectoryFullPath = [userTrashDirectory absoluteString];
    
    // Create and run copy/duplicate task
    NSTask *trashFileTask = [[NSTask alloc] init];
    NSArray *args = @[pathOfFile, userTrashDirectoryFullPath];
    
    [trashFileTask setLaunchPath:@"/bin/mv"];
    [trashFileTask setArguments:args];
    
    @try {
        [trashFileTask launch];
    }
    @catch (NSException *e) {
        NSLog(@"Error while running delete file operation. (%@ / %@)", e.name, e.reason);
    }
}

+ (void)moveDirectoryToTrash:(NSURL *)directory
{
    NSString *pathOfDirectory = [directory absoluteString];
    
    NSURL *userTrashDirectory = [NSURL URLWithString:@"~/.Tash"];
    NSString *userTrashDirectoryFullPath = [userTrashDirectory absoluteString];
    
    // Create and run copy/duplicate task
    NSTask *trashDirectoryTask = [[NSTask alloc] init];
    NSArray *args = @[pathOfDirectory, userTrashDirectoryFullPath];
    
    [trashDirectoryTask setLaunchPath:@"/bin/mv"];
    [trashDirectoryTask setArguments:args];
    
    @try {
        [trashDirectoryTask launch];
    }
    @catch (NSException *e) {
        NSLog(@"Error while running delete directory operation. (%@ / %@)", e.name, e.reason);
    }
}

+ (void)moveFile:(NSURL *)file
   toNewLocation:(NSURL *)location
{
    NSString *pathOfFile = [file absoluteString];
    NSString *pathOfNewLocation = [location absoluteString];
    
    // Create and run copy/duplicate task
    NSTask *moveFileTask = [[NSTask alloc] init];
    NSArray *args = @[pathOfFile, pathOfNewLocation];
    
    [moveFileTask setLaunchPath:@"/bin/mv"];
    [moveFileTask setArguments:args];
    
    @try {
        [moveFileTask launch];
    }
    @catch (NSException *e) {
        NSLog(@"Error while running move file operation. (%@ / %@)", e.name, e.reason);
    }
}

+ (void)moveDirectoryToTrash:(NSURL *)directory
               toNewLocation:(NSURL *)location
{
    NSString *pathOfDirectory = [directory absoluteString];
    NSString *pathOfNewLocation = [location absoluteString];
    
    // Create and run copy/duplicate task
    NSTask *moveDirectoryTask = [[NSTask alloc] init];
    NSArray *args = @[pathOfDirectory, pathOfNewLocation];
    
    [moveDirectoryTask setLaunchPath:@"/bin/mv"];
    [moveDirectoryTask setArguments:args];
    
    @try {
        [moveDirectoryTask launch];
    }
    @catch (NSException *e) {
        NSLog(@"Error while running move directory operation. (%@ / %@)", e.name, e.reason);
    }
}

+ (void)createSymLinkOfFile:(NSURL *)file
{
    
}

+ (void)searchForFilesNamedLike:(NSString *)searchText
{
    // use mdfind command
}

+ (void)emptyTrash
{
    
}

+ (void)ejectDisk
{
    
}


@end
