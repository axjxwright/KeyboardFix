//
//  AppDelegate.m
//  KeyboardFix2
//
//  Created by Andrew Wright on 18/12/2015.
//  Copyright © 2015 Andrew Wright. All rights reserved.
//

#import "AppDelegate.h"
#import <Carbon/Carbon.h>
#include <unordered_map>
#include <iostream>

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

struct Key
{
    EventHotKeyRef Ref;
    EventHotKeyID  HotKey;
    UInt32         InKeyCode;
    UInt32         OutKeyCode;
};

std::unordered_map<UInt32, Key> kHotKeys;

OSStatus OnHotKeyDown(EventHandlerCallRef nextHandler, EventRef event, void *userData)
{
    return ProcessEvent( event, true );
}

OSStatus OnHotKeyUp(EventHandlerCallRef nextHandler, EventRef event, void *userData)
{
    return ProcessEvent ( event, false );
}

OSStatus ProcessEvent ( EventRef event, bool down )
{
    EventHotKeyID hotKeyID;
    OSStatus result = GetEventParameter(event, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(hotKeyID), NULL, &hotKeyID);
    
    if ( result == noErr )
    {
        if ( kHotKeys.count( hotKeyID.id ) )
        {
            auto& key = kHotKeys[hotKeyID.id];
            
            CGEventSourceRef src = CGEventSourceCreate(kCGEventSourceStateHIDSystemState);
            
            CGEventRef cmdd = CGEventCreateKeyboardEvent(src, key.OutKeyCode, down);
            CGEventSetFlags(cmdd, static_cast<CGEventFlags>(0));
            CGEventTapLocation loc = kCGHIDEventTap;
            CGEventPost(loc, cmdd);
            CFRelease(cmdd);
            CFRelease(src);
        }
    }
    return result;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    kHotKeys = { { 1337, { EventHotKeyRef(), { 'hot9', 1337 }, kVK_ANSI_8, kVK_ANSI_9 } },
                 { 1338, { EventHotKeyRef(), { 'hoto', 1338 }, kVK_ANSI_I, kVK_ANSI_O } },
                 { 1339, { EventHotKeyRef(), { 'hotl', 1339 }, kVK_ANSI_K, kVK_ANSI_L } },
                 { 1340, { EventHotKeyRef(), { 'hot.', 1340 }, kVK_ANSI_Comma, kVK_ANSI_Period } } };
    
    
    EventTypeSpec   eventTypeDown;
    eventTypeDown.eventClass    = kEventClassKeyboard;
    eventTypeDown.eventKind     = kEventHotKeyPressed;
    
    EventTypeSpec   eventTypeUp;
    eventTypeUp.eventClass    = kEventClassKeyboard;
    eventTypeUp.eventKind     = kEventHotKeyReleased;
    
    InstallApplicationEventHandler(&OnHotKeyDown, 1, &eventTypeDown, NULL, NULL);
    InstallApplicationEventHandler(&OnHotKeyUp, 1, &eventTypeUp, NULL, NULL);
    
    for ( auto& hotKey : kHotKeys )
    {
        auto& key = hotKey.second;
        RegisterEventHotKey(key.InKeyCode, optionKey, key.HotKey, GetApplicationEventTarget(), 0, &key.Ref);
    }
    
    [_window close];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    // Insert code here to tear down your application
}

@end
