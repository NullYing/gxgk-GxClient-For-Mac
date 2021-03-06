//
//  PreferencesWindowController.m
//  LevoClient
//
//  Created by iBcker on 13-5-10.
//  Copyright (c) 2013年 iBcker. All rights reserved.
//

#import "PreferencesWindowController.h"
#import "PreferencesModel.h"
#import "LevoConnet.h"

@interface PreferencesWindowController ()
@property(assign)PreferencesModel *config;
@end

@implementation PreferencesWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    self.config=[PreferencesModel sharedInstance];
    self.tabView.delegate=self;
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)loadDataAndShow:(int)index
{
    [self.BnApply setAction:@selector(onApply:)];
    self.UserName.stringValue=self.config.UserName;
    self.UserPwd.stringValue=self.config.UserPwd;
    self.AutoRelogin.state=self.config.AutoReConnet?1:0;
    self.AutoLogin.state=self.config.AutoLogin?1:0;
    
    if (self.config.CheckOfflineHost.length>0) {
        self.CheckOfflineHost.stringValue=self.config.CheckOfflineHost;
    }else{
        NSString *host=[[LevoConnet sharedInstance] getGateWay];
        self.CheckOfflineHost.stringValue=host.length>0?host:@"";
    }
    
    //网卡
    NSArray *deviceList=[[LevoConnet sharedInstance] readDeviceList];
    if ([deviceList count]>0) {
        [self.DeviceList addItemsWithTitles:deviceList];
        NSUInteger sindex=[deviceList indexOfObject:self.config.Device];
        if (sindex==NSNotFound) {
            //默认选择第一块设备
            [self.DeviceList selectItemAtIndex:0];
        }else{
            [self.DeviceList selectItemAtIndex:sindex];
        }
    }else{
        [self.DeviceList addItemsWithTitles:@[@"未来发现设备"]];
    }
    
    //检测断线时间
    NSArray *itemarr=[self.CheckOfflineTime itemArray];
    for (int i=0;i<itemarr.count;i++) {
        if(((NSMenuItem*)itemarr[i]).tag==self.config.CheckOfflineTime){
            [self.CheckOfflineTime selectItemAtIndex:i];
            break;
        }
    }
    [self.tabView selectTabViewItemAtIndex:index];
}

- (IBAction)showWindow:(id)sender
{
    [self loadDataAndShow:0];
    [super showWindow:sender];
}

- (IBAction)onWeibo:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://weibo.com/cz5424"]];
    [self.wAbout close];
}

- (void)onApply:(id)sender
{
    if (self.UserName.stringValue.length==0) {
        [self.UserName becomeFirstResponder];
        return;
    }
    if (self.UserPwd.stringValue.length==0) {
        [self.UserPwd becomeFirstResponder];
        return;
    }
    self.config.UserName=self.UserName.stringValue;
    self.config.UserPwd=self.UserPwd.stringValue;
    self.config.AutoReConnet=self.AutoRelogin.state==0?NO:YES;
    self.config.AutoLogin=self.AutoLogin.state==0?NO:YES;
    self.config.Device=[self.DeviceList selectedItem].title?[self.DeviceList selectedItem].title:@"";
    self.config.CheckOfflineTime=[self.CheckOfflineTime selectedItem].tag;
    self.config.CheckOfflineHost=self.CheckOfflineHost.stringValue;
    [self.delegate onPreferencesApply];
    [self close];
}

- (IBAction)onAbout:(id)sender
{
    self.LbAboutVersion.stringValue=[NSString stringWithFormat:@"Version  %@",self.config.versionStr];
    [self.wAbout makeKeyAndOrderFront:nil];
    [NSApp showWindow:self.wAbout];
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    if (self.AutoRelogin.state==0) {
        [self.CheckOfflineTime setEnabled:NO];
        [self.CheckOfflineHost setEnabled:NO];
    }else{
        [self.CheckOfflineTime setEnabled:YES];
        [self.CheckOfflineHost setEnabled:YES];
    }
}

@end
