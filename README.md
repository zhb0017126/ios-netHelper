# ios-netHelper
关于ios中常用的网络辅助功能

# 01 根据网页获取DNS功能

## 核心源码
```
struct hostent    *gethostbyname(const char *);
```


根据网址解析出端口号

但是由于解析出的格式是hostent 格式，所以需要进一步解析成字符串
###
```
struct hostent {
    char    *h_name;    /* official name of host */  端口正式名称，即实际访问的端口名
    char    **h_aliases;    /* alias list */ 别名 ，通常是我们访问的网址
    int    h_addrtype;    /* host address type */ 网络类型，包括ipv4 和ipv6
    int    h_length;    /* length of address */
    char    **h_addr_list;    /* list of addresses from name server */ 保存多个主机地址 就是我们要获取的端口地址
    
#if !defined(_POSIX_C_SOURCE) || defined(_DARWIN_C_SOURCE)
#define    h_addr    h_addr_list[0]    /* address, for backward compatibility */
#endif /* (!_POSIX_C_SOURCE || _DARWIN_C_SOURCE) */
};
```

```
#include <arpe/inet.h>
int inet_pton(int family, const char *strptr, void *addrptr);    
//将点分十进制的ip地址转化为用于网络传输的数值格式
   返回值：若成功则为1，若输入不是有效的表达式则为0，若出错则为-1
 
const char * inet_ntop(int family, const void *addrptr, char *strptr, size_t len);     //将数值格式转化为点分十进制的ip地址格式
        返回值：若成功则为指向结构的指针，若出错则为NULL
```
