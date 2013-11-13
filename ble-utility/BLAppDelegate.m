//
//  BLAppDelegate.m
//  ble-utility
//
//  Created by 北京锐和信科技有限公司 on 13-10-29.
//  Copyright (c) 2013年 北京锐和信科技有限公司. All rights reserved.
//

#import "BLAppDelegate.h"
#import "GDataXMLNode.h"
@interface BLAppDelegate ()
@property (nonatomic,strong) NSString * uuidPlistPath;
@end
@implementation BLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self loadNames];
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
#pragma mark - 
- (NSString *) uuidPlistPath
{
    if (!_uuidPlistPath)
    {
        NSArray * dirs = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString * file = [dirs[0] stringByAppendingPathComponent:@"uuid_names.plist"];
        self.uuidPlistPath = file;
    }
    return _uuidPlistPath;
}
- (void)loadNames
{

    if ([[NSFileManager defaultManager] fileExistsAtPath:[self uuidPlistPath]])
    {
        self.uuidNames = [NSMutableDictionary dictionaryWithContentsOfFile:[self uuidPlistPath]];
    }
    if (self.uuidNames == nil|| self.uuidNames.count==0)
    {
        [self parseNames];
        [self.uuidNames writeToFile:self.uuidPlistPath atomically:YES];
    }
}
- (void)parseNames
{
    self.uuidNames = [NSMutableDictionary dictionaryWithCapacity:50];
    NSString * folder = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"servicesdefs"];
    NSFileManager * filer = [NSFileManager defaultManager];
    NSDirectoryEnumerator * enumerator =  [filer enumeratorAtPath: folder];
    NSString * item = nil;
    while (item = [enumerator nextObject])
    {
        NSData * data = [NSData dataWithContentsOfFile:[folder stringByAppendingPathComponent:item]];
        GDataXMLDocument * doc = [[GDataXMLDocument alloc] initWithData:data error:nil];
        if (doc)
        {
            GDataXMLElement * servicexml = [doc rootElement];
            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
            for (GDataXMLNode * att in servicexml.attributes)
            {
                dict[att.name] = [att.children[0] XMLString];
            }
            dict[@"CBObject"] = servicexml.name;
            self.uuidNames[dict[@"uuid"]]=dict;
        }
    }
    
}
@end
