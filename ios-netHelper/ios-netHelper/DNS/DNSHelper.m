//
//  DNSHelper.m
//  ios-netHelper
//
//  Created by 赵泓博 on 2020/9/15.
//  Copyright © 2020 zhaohongbo. All rights reserved.
//

#import "DNSHelper.h"
#import <netdb.h>
#import <netinet/in.h>
#import <netinet/in.h>
#import <net/if.h>
#import <arpa/inet.h>
@implementation DNSHelper

/**从host中，获取ipv4信息*/
+ (NSArray<NSString *>*)getIpv4AddressFromHost: (NSString *)host {
    NSMutableArray *hostArray = [NSMutableArray array];
    const char * hostName = host.UTF8String;
    struct hostent * phost = [self getHostByName: hostName];
    if ( phost == NULL ) { return nil; }
    
    char ** aliases;
    char ip[20] = {0};
    for (aliases = phost->h_addr_list; *aliases != NULL; aliases++) {
        
        NSString * ipAddress = [NSString stringWithUTF8String: inet_ntop(phost->h_addrtype, *aliases, ip, sizeof(ip))];
            if (ipAddress) {
                [hostArray addObject:ipAddress];
            }
    }
    /**另一种获取方式*/
//    struct in_addr ip_addr;
//    memcpy(&ip_addr, phost->h_addr_list[0], 4);
//   char ip[20] = {0};
//    inet_ntop(AF_INET, &ip_addr, ip, sizeof(ip));
//    return [NSString stringWithUTF8String: ip];
    return hostArray.count >0?  hostArray.copy:nil;
}
+ (struct hostent *)getHostByName: (const char *)hostName {
    __block struct hostent * phost = NULL;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSOperationQueue * queue = [NSOperationQueue new];
    [queue addOperationWithBlock: ^{
#pragma mark 核心，开启异步线程根据 gethostbyname 获取host信息
        phost = gethostbyname(hostName);
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC));
    [queue cancelAllOperations];
    return phost;
}
/**从host中，获取ipv6信息*/
+ (NSArray<NSString *>*)getIpv6AddressFromHost: (NSString *)host {
    NSMutableArray *hostArray = [NSMutableArray array];
    const char * hostName = host.UTF8String;
    struct hostent * phost = [self getHostByName: hostName];
    if ( phost == NULL ) { return nil; }
 
    char ip[32] = { 0 };
    char ** aliases;
    switch (phost->h_addrtype) {
        case AF_INET:
        case AF_INET6: {
            for (aliases = phost->h_addr_list; *aliases != NULL; aliases++) {
                NSString * ipAddress = [NSString stringWithUTF8String: inet_ntop(phost->h_addrtype, *aliases, ip, sizeof(ip))];
                    if (ipAddress) {
                        //return ipAddress;
                        [hostArray addObject:ipAddress];
                    }
            }
        } break;
 
        default:
            break;
    }
    return hostArray.count ==0? nil: hostArray;
}
 
+ (NSArray <NSString *>*)getIpAddressFromHostName: (NSString *)host {
   NSArray <NSString *>* ipAddress = [self getIpv4AddressFromHost: host];
    if (ipAddress == nil) {
        ipAddress = [self getIpv6AddressFromHost: host];
    }
    return ipAddress;
}
@end
