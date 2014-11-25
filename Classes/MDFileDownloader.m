//
//  MDFileDownloader.m
//  MDFileDownloader
//
//  Created by mohamed mohamed El Dehairy on 11/25/14.
//  Copyright (c) 2014 mohamed mohamed El Dehairy. All rights reserved.
//

#import "MDFileDownloader.h"

@interface MDFileDownloader ()
{
    void (^downloadCompletionBlock) (BOOL finished,NSError *error);
    
    NSOutputStream *fileOutPutStream;
    
    NSInputStream *remoteInputStream;
    NSOutputStream *remoteOutputStream;
}
@end

@implementation MDFileDownloader
-(void)downloadFileFromUrl:(NSURL *)remoteUrl toFilePath:(NSString *)filePath withCompletion:(void (^)(BOOL, NSError *))completionBlock
{
    downloadCompletionBlock = completionBlock;
    
    fileOutPutStream = [NSOutputStream outputStreamToFileAtPath:filePath append:YES];
    
    [self creatRemoteInputStreamWithRemoteUrl:remoteUrl];
    
    
    
    [remoteInputStream setDelegate:self];
    [remoteOutputStream setDelegate:self];
    [remoteInputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [remoteOutputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [remoteInputStream open];
    [remoteOutputStream open];
    [fileOutPutStream open];
    
    
}

-(void)creatRemoteInputStreamWithRemoteUrl:(NSURL*)url
{
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)[url host], 80, &readStream, &writeStream);
    
    remoteInputStream = (__bridge_transfer NSInputStream *)readStream;
    remoteOutputStream = (__bridge_transfer NSOutputStream *)writeStream;
    
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {
    
    switch(eventCode) {
        case NSStreamEventHasBytesAvailable:
        {
            uint8_t buf[1024];
            unsigned int len = 0;
            len = [(NSInputStream *)stream read:buf maxLength:1024];
            if(len) {
                [fileOutPutStream write:buf maxLength:1024];
                
            } else {
                NSLog(@"no buffer!");
            }
            break;
        }
        case NSStreamEventEndEncountered:
        {
            [fileOutPutStream close];
            
            [remoteInputStream close];
            [remoteOutputStream close];
            [remoteOutputStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                              forMode:NSDefaultRunLoopMode];
            [remoteInputStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                                          forMode:NSDefaultRunLoopMode];
            
            downloadCompletionBlock(YES,nil);
            break;
        }
        case NSStreamEventErrorOccurred:
        {
            [fileOutPutStream close];
            
            [remoteInputStream close];
            [remoteOutputStream close];
            [remoteOutputStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                                          forMode:NSDefaultRunLoopMode];
            [remoteInputStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                                         forMode:NSDefaultRunLoopMode];
            downloadCompletionBlock(YES,stream.streamError);
            break;
        }
        default:
            break;
    }
}
@end
