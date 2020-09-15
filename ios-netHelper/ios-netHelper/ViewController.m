//
//  ViewController.m
//  ios-netHelper
//
//  Created by 赵泓博 on 2020/9/15.
//  Copyright © 2020 zhaohongbo. All rights reserved.
//

#import "ViewController.h"

#import "DNSHelper.h"
#import "GetHostData.h"


@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
/**<#标注#>*/
@property (nonatomic,strong) UITableView *tabelView;
/**<#标注#>*/
@property (nonatomic,strong) NSMutableArray *titleArrays;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabelView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)) style:UITableViewStylePlain];
    
    self.tabelView.delegate = self;
    
    self.tabelView.dataSource = self;
    [self.view addSubview:self.tabelView];
    NSArray* hostArray =   [DNSHelper getIpAddressFromHostName:@"www.163.com"];
     

    self.titleArrays = hostArray;
    //@[@"DNS验证"].mutableCopy;
    
    [self.tabelView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];

}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titleArrays.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = [self.titleArrays objectAtIndex:indexPath.row];
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *string = [self.titleArrays objectAtIndex:indexPath.row];
    if ([string isEqualToString:@"DNS验证"]) {
     NSArray* hostArray =   [DNSHelper getIpAddressFromHostName:@"www.163.com"];
        NSString *hosts = @"";
        for (int i = 0 ; i< hostArray.count; i++) {
            NSString *temp = hostArray[i];
            if (i == 0) {
                hosts = [NSString stringWithFormat:@"%@\n",temp];
            }else{
                hosts = [NSString stringWithFormat:@"%@\n%@\n",hosts,temp];
            }
        }
      [self alertTitle:@"DNS" message:hosts];
    }else{
      NSArray* hostArray =      [GetHostData getDataFromHost:string port:@"80"];
        NSLog(@"%@",hostArray);
    }
}


-(void)alertTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title
                                                                            message:message
                                                                        preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"好"
                                                style:UIAlertActionStyleDefault
                                              handler:nil]];
    [self presentViewController:alertVC animated:YES completion:nil];
    
}












@end
