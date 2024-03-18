//
//  NotificationService.m
//  SobotPushNotifiactionService
//
//  Created by lizh on 2024/3/5.
//

#import "NotificationService.h"
#import <UIKit/UIKit.h>
@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;
@property (nonatomic, strong) NSURLSession * session;
@end

@implementation NotificationService


-(void)didReceiveNotificationRequest:(UNNotificationRequest*)request
                  withContentHandler:(void(^)(UNNotificationContent*_Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent =[request.content mutableCopy];
    //[modified]这个是一个标示，可以实现对服务器下发下来的内容进行更改 仅测试使用
    self.bestAttemptContent.title =[NSString stringWithFormat:@"%@ [modified]",self.bestAttemptContent.title];
    
    NSDictionary*apsDic =[request.content.userInfo objectForKey:@"aps"];
    NSString*attachUrl =[apsDic objectForKey:@"sobot_chat_big_img"];
    
    NSString*category =[apsDic objectForKey:@"category"];
    self.bestAttemptContent.categoryIdentifier = category;
    
    NSURLSession*session =[NSURLSession sharedSession];
    NSURL *url =[NSURL URLWithString:attachUrl];
    NSURLSessionDownloadTask*downloadTask =[session downloadTaskWithURL:url
                                                      completionHandler:^(NSURL *_Nullable location,
                                                                          NSURLResponse*_Nullable response,
                                                                          NSError*_Nullable error){
        NSString*caches =[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES) lastObject];
        NSString*file =[caches stringByAppendingPathComponent:response.suggestedFilename];
        NSFileManager*mgr =[NSFileManager defaultManager];
        [mgr moveItemAtPath:location.path toPath:file error:nil];
        
        if(file &&![file  isEqualToString:@""])
        {
            UNNotificationAttachment*attch=[UNNotificationAttachment attachmentWithIdentifier:@"photo"
                                                                                          URL:[NSURL URLWithString:[@"file://" stringByAppendingString:file]]
                                                                                      options:nil
                                                                                        error:nil];
            if(attch)
            {
                self.bestAttemptContent.attachments =@[attch];
            }
        }
        self.contentHandler(self.bestAttemptContent);
    }];
    [downloadTask resume];
    
}
 
#pragma mark - 私有方法
- (void)downloadAndSave:(NSURL *)fileURL handler:(void (^)(NSString *))handler {
    // 这里需要用系统网络请求来下载图片
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:fileURL completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *localPath = nil;
        if (!error) {
            // 临时文件夹路径，APP没有运行时会自动清除图片，不会占用内存
            NSString *localURL = [NSString stringWithFormat:@"%@/%@", NSTemporaryDirectory(), fileURL.lastPathComponent];
            if ([[NSFileManager defaultManager] moveItemAtPath:location.path toPath:localURL error:nil]) {
                localPath = localURL;
            }
        }
        handler(localPath);
    }];
    [task resume];
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end

