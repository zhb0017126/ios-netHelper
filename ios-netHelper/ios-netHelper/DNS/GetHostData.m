//
//  GetHostData.m
//  ios-netHelper
//
//  Created by 赵泓博 on 2020/9/15.
//  Copyright © 2020 zhaohongbo. All rights reserved.
//

#import "GetHostData.h"
#import <netdb.h>
#import <netinet/in.h>
#import <netinet/in.h>
#import <net/if.h>
#import <arpa/inet.h>
#include <sys/socket.h>
#import <Availability.h>
@implementation GetHostData
+(NSMutableArray *)getDataFromHost:(NSString *)host port:(NSString *)port
{
    NSString *portStr = [NSString stringWithFormat:@"%hu", port];
    struct addrinfo hints, *res, *res0;
    
    //初始化为0
    memset(&hints, 0, sizeof(hints));
    
    //相当于 AF_UNSPEC ，返回的是适用于指定主机名和服务名且适合任何协议族的地址。
    hints.ai_family   = PF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_protocol = IPPROTO_TCP;
    //相当于 AF_UNSPEC ，返回的是适用于指定主机名和服务名且适合任何协议族的地址。
   hints.ai_family   = PF_UNSPEC;
   hints.ai_socktype = SOCK_STREAM;
   hints.ai_protocol = IPPROTO_TCP;
//    hints：可以是一个空指针，也可以是一个指向某个addrinfo结构体的指针，调用者在这个结构中填入关于期望返回的信息类型的暗示。举例来说：指定的服务既可支持TCP也可支持UDP，所以调用者可以把hints结构中的ai_socktype成员设置成SOCK_DGRAM使得返回的仅仅是适用于数据报套接口的信息。
//    hints  指期望获取的数据类型，而真正获取数据，存储于res0中
//    res0返回的是一个sockaddr结构的链表而不是一个地址清单。而该结构中获取地址的，是本机地址
    NSMutableArray *addresses ;
   int gai_error = getaddrinfo([host UTF8String], [portStr UTF8String], &hints, &res0);
    if (gai_error)
    {   //获取到错误
         [self gaiError:gai_error];
    }else{
        NSUInteger capacity = 0;
        //遍历 res0
        for (res = res0; res; res = res->ai_next)
        {
            //如果有IPV4 IPV6的，capacity+1
            if (res->ai_family == AF_INET || res->ai_family == AF_INET6) {
                capacity++;
            }
        }
        //生成一个地址数组，数组为capacity大小
        addresses = [NSMutableArray arrayWithCapacity:capacity];
        //再次遍历一遍，是 为了节约开销，遍历的开销，小于动态数组扩容缩容的开销
       for (res = res0; res; res = res->ai_next)
       {
           //IPV4
           if (res->ai_family == AF_INET)
           {
               // Found IPv4 address.
               // Wrap the native address structure, and add to results.
               //加到数组中
               NSData *address4 = [NSData dataWithBytes:res->ai_addr length:res->ai_addrlen];
               [addresses addObject:address4];
           }
           else if (res->ai_family == AF_INET6)
           {
               // Fixes connection issues with IPv6
               // https://github.com/robbiehanson/CocoaAsyncSocket/issues/429#issuecomment-222477158
               
               // Found IPv6 address.
               // Wrap the native address structure, and add to results.
               //强转
               struct sockaddr_in6 *sockaddr = (struct sockaddr_in6 *)res->ai_addr;
               //拿到port
               in_port_t *portPtr = &sockaddr->sin6_port;
               //如果Port为0
               if ((portPtr != NULL) && (*portPtr == 0)) {
                   //赋值，用传进来的port
                       *portPtr = htons(port);
               }
               //添加到数组
               NSData *address6 = [NSData dataWithBytes:res->ai_addr length:res->ai_addrlen];
               [addresses addObject:address6];
           }
           
       }
        //对应getaddrinfo 释放内存
       freeaddrinfo(res0);
       
       //如果地址里一个没有，报错 EAI_FAIL：名字解析中不可恢复的失败
       if ([addresses count] == 0)
       {
           [self gaiError:EAI_FAIL];
       }
    }
    
    return addresses;
}

#pragma mark 处理错误
+(void)gaiError:(int)gai_error
{
    //getaddrinfo出错时返回非零值，gai_strerror根据返回的非零值返回指向对应的出错信息字符串的指针
    //EAI_ADDRFAMILY    不支持hostname的地址族
//    EAI_AGAIN    名字解析中的暂时失败
//    EAI_BADFLAGS    ai_flags的值无效
//    EAI_FAIL    名字解析中不可恢复的失败
//    EAI_FAMILY    不支持ai_family
//    EAI_MEMORY    内存分配失败
//    EAI_NODATA    没有与hostname相关联的地址
//    EAI_NONAME    hostname或service未提供，或者不可知
//    EAI_SERVICE    不支持ai_socktype类型的service
//    EAI_SOCKTYPE    不支持ai_socktype
//    EAI_SYSTEM    errno中有系统错误返回
    NSString *errString = @"";
    switch (gai_error) {
        case EAI_ADDRFAMILY:
            errString = @"不支持hostname的地址族";
            break;
        case EAI_AGAIN:
             errString = @"名字解析中的暂时失败";
            break;
      default:
            break;
    }
    NSString *errMsg = [NSString stringWithCString:gai_strerror(gai_error) encoding:NSASCIIStringEncoding];
    //根据错误内容生成字典
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errMsg forKey:NSLocalizedDescriptionKey];
    //返回该错误，code为gai_error
   [NSError errorWithDomain:@"kCFStreamErrorDomainNetDB" code:gai_error userInfo:userInfo];
    
    
}
@end
