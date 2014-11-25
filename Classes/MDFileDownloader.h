//
//  MDFileDownloader.h
//  MDFileDownloader
//
//  Created by mohamed mohamed El Dehairy on 11/25/14.
//  Copyright (c) 2014 mohamed mohamed El Dehairy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MDFileDownloader : NSObject<NSStreamDelegate>
{
    
}
-(void)downloadFileFromUrl:(NSURL*)remoteUrl toFilePath:(NSString*)filePath withCompletion:(void (^)(BOOL finished,NSError *error))completionBlock;
@end
