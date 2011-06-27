//
//  main.m
//  MacOS X iTunes Remote
//
//  Created by Wim van Ommen on 4/28/11.
//  Copyright TopIT 2011. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppleScriptObjC/AppleScriptObjC.h>

int main(int argc, char *argv[])
{
	[[NSBundle mainBundle] loadAppleScriptObjectiveCScripts];

	return NSApplicationMain(argc, (const char **) argv);
}
