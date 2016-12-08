//
//  SendViewController.m
//  textDemo
//
//  Created by dadahua on 16/9/25.
//  Copyright © 2016年 dahua. All rights reserved.
//

#import "SendViewController.h"
#import "GCDAsyncUdpSocket.h"
#define CLIENTPORT 8085
#define SERVERPORT 9600

/**
 *  客户端
 */
@interface SendViewController ()<GCDAsyncUdpSocketDelegate>
{
    GCDAsyncUdpSocket *sendSocket;
    __weak IBOutlet UITextField *msgTF;
    __weak IBOutlet UITextField *ipTF;
    __weak IBOutlet UILabel *receiveLab;
}

@end

@implementation SendViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"客户端";
    dispatch_queue_t qQueue = dispatch_queue_create("Client queue", NULL);
    sendSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self
                                               delegateQueue:qQueue];
    NSError *error;
    [sendSocket bindToPort:CLIENTPORT error:&error];
    if (error) {
        NSLog(@"客户端绑定失败");
    }
    [sendSocket beginReceiving:nil];
}

#pragma mark 发送消息
- (IBAction)sendMsgClick:(UIButton *)sender {
    
    NSData *sendData = [msgTF.text dataUsingEncoding:NSUTF8StringEncoding];
    [sendSocket sendData:sendData
                  toHost:ipTF.text
                    port:SERVERPORT
             withTimeout:60
                     tag:200];
}



#pragma mark - delegate
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
    
    if (tag == 200) {
        NSLog(@"client发送失败-->%@",error);
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    
    NSString *receiveStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"服务器ip地址--->%@,host---%u,内容--->%@",
          [GCDAsyncUdpSocket hostFromAddress:address],
          [GCDAsyncUdpSocket portFromAddress:address],
          receiveStr);
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        receiveLab.text = receiveStr;
    });
}

- (void)dealloc {
    
    [sendSocket close];
    sendSocket = nil;
}

@end
