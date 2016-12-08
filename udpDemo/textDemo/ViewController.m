//
//  ViewController.m
//  textDemo
//
//  Created by dadahua on 16/9/23.
//  Copyright © 2016年 dahua. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncUdpSocket.h"
#define SERVERPORT 9600

/**
 *  服务器端
 */
@interface ViewController ()<GCDAsyncUdpSocketDelegate>
{
    GCDAsyncUdpSocket *receiveSocket;
}
@property (weak, nonatomic) IBOutlet UILabel *textView;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSocket];
}

- (void)initSocket {
    
    self.title = @"服务器";
    dispatch_queue_t dQueue = dispatch_queue_create("Server queue", NULL);
    receiveSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self
                                                  delegateQueue:dQueue];
    NSError *error;
    [receiveSocket bindToPort:SERVERPORT error:&error];
    if (error) {
        NSLog(@"服务器绑定失败");
    }
    [receiveSocket beginReceiving:nil];
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    /**
     *  更新UI一定要到主线程去操作啊
     */
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.textView.text = msg;
    });
    NSLog(@"客户端ip地址-->%@,port--->%u,内容-->%@",
          [GCDAsyncUdpSocket hostFromAddress:address],
          [GCDAsyncUdpSocket portFromAddress:address],
          msg);
    
    NSString *sendStr = @"我收到了";
    NSData *sendData = [sendStr dataUsingEncoding:NSUTF8StringEncoding];
    [receiveSocket sendData:sendData toHost:[GCDAsyncUdpSocket hostFromAddress:address]
                       port:[GCDAsyncUdpSocket portFromAddress:address]
                withTimeout:60
                        tag:500];
    
}


@end
