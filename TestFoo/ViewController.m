//
//  ViewController.m
//  TestFoo
//
//  Created by apple on 2022/2/9.
//

#import "ViewController.h"
#import <CoreFoundation/CoreFoundation.h>
#include <sys/socket.h>
#include <netinet/in.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self hookSocket];
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:@"https://www.baidu.com"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSLog(@"%@",response);
        }] resume];
    // Do any additional setup after loading the view.
}

- (void)hookSocket{
    
}
@end
