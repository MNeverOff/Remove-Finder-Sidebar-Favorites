//
//  main.m
//  Remove Sidebar Favorites
//
//  Created by Mikhail Neverov on 26.12.2021
//  mike@neveroff.dev
//

#import <Foundation/Foundation.h>
#import <Appkit/AppKit.h>
const int TIMEOUT = 300; // Number of seconds to repeat the code after app launch
const int TIMEOUT_CLEANUP = 60; // Number of seconds after the first folder removal was detected to allow Google Drive to get rid of the folders slowly appearing in case of multiple folders being present
const double SLEEP_INTERVAL = 1.0; // Constant for the thread sleep, 1 second by default
bool FOLDERS_REMOVED = false; // A flag to break the cycle early

// TODO: Put both UNIX Execs into the Applications folder

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // Getting the input parameter for the sidebar item name to be removed
        NSString* input = [NSString stringWithFormat:@"%s",argv[1]];

        // External loop to catch the folders initializing after the machine boot correctly
        // TODO: Instead of a cycle try to subscribe to Finder.Open() event or something like that when a new finder window/tab is opened and handle that instead of the loop
        for (int t = 0; t < TIMEOUT; t++) {
            // Getting the shared file list (sfl) reference
            LSSharedFileListRef favoriteItems = LSSharedFileListCreate(NULL,  kLSSharedFileListFavoriteItems, NULL);
            // Getting the current snapshot of the sfl
            CFArrayRef snapshot = LSSharedFileListCopySnapshot(favoriteItems, NULL);
            // Getting the number of items in the sidebar fevorites list
            CFIndex sidebarItemsCount = CFArrayGetCount(snapshot);
            
            NSArray *apps = [[NSWorkspace sharedWorkspace] runningApplications];
            
            // Iterating over the sidebar items
            for(int i = 0; i < sidebarItemsCount; ++i)
            {
                // Getting the display name for the current sidebar item
                NSString* name = (__bridge NSString *)(LSSharedFileListItemCopyDisplayName(CFArrayGetValueAtIndex(snapshot, i)));
                // Comparing the current sidebar item name with the input name
                if (![input  isEqual: @"(null)"]) {
                    if ([name isEqualToString: input]) {
                        // Removing the item from the sfl using it's reference and snapshot index
                        // !!! IMPORTANT NOTE. If you'll aim to repurpose this code this line most likely needs improvement, since snapshot would, as I assume, contain an old version of the sidebar. I'm not 100% sure that's the case but you might need to reassign snapshot and account for that in the parent loop to make sure you're not out of array bounds and not using a mismatched index
                        LSSharedFileListItemRemove(favoriteItems, CFArrayGetValueAtIndex(snapshot, i));
                        
                        // Ciurcumventing the repeat logic because thus block is used only for the manual execution. Not the most elegant but would do in this case.
                        goto outer;
                    }
                }
                else {
                    if ([name rangeOfString:@" - Google Drive"].location != NSNotFound || [name isEqualToString:@"OneDrive"]) {
                        // Removing the item from the sfl using it's reference and snapshot index
                        // !!! IMPORTANT NOTE. If you'll aim to repurpose this code this line most likely needs improvement, since snapshot would, as I assume, contain an old version of the sidebar. I'm not 100% sure that's the case but you might need to reassign snapshot and account for that in the parent loop to make sure you're not out of array bounds and not using a mismatched index
                        LSSharedFileListItemRemove(favoriteItems, CFArrayGetValueAtIndex(snapshot, i));
                        FOLDERS_REMOVED = true;
                    }
                }
            }
            
            // Releasing the references in order to get the new values after the timeout
            // ISSUE: This doesn't seem to work. Whenever an ItemRemove is called - the quantity
            // of items decreases as expected. However, for some reason, if the loop is already
            // initialized and Google Drive or OneDrive add a Favorite item - it's not present in
            // the referenced list, even ef it's released and we syncrhonize as shown below.
            // Curiously, when I re-run the application it detects the correct number of items again. Same happens if I goto outside the "t" loop.
            CFPreferencesAppSynchronize((CFStringRef)@"com.apple.sidebarlists");
            CFRelease(favoriteItems);
            CFRelease(snapshot);
            // After I added these two it worked for a little while, until Google Drive added it's 2nd drive smb mount back. Then it stopped working and updating again.
            favoriteItems = nil;
            snapshot = nil;
            
            // Idea is to "skip ahead" to the end of the TIMEOUT value, whilst still allowing for 30 seconds to cleanup Google Drive folders that slowly show up (in case you have several)
            if (FOLDERS_REMOVED && t < TIMEOUT-TIMEOUT_CLEANUP) {
                t = TIMEOUT-TIMEOUT_CLEANUP;
            }
            else {
                [NSThread sleepForTimeInterval:SLEEP_INTERVAL];
            }
        }
        outer:;
    }
    return 0;
}
