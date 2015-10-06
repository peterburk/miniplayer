//
//  mplyAppDelegate.m
//  miniPlayer
//
//  Created by Peter Burkimsher on 19/01/2014
//  Copyright (c) 2014 Peter Burkimsher. All rights reserved.
//

#import "mplyAppDelegate.h"
#import "TrackSlider.h"
#import "VolumeSlider.h"
#import "AVPanel.h"
#import "ScrollingTextView.h"
#import "VerticalTrafficLightsWindowDelegate.h"
#import <QuartzCore/QuartzCore.h>

@implementation mplyAppDelegate

@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

/*
 * applicationDidFinishLaunching
 * Run final setup for the window
 */
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Instantiate a Core Image "Glass Distortion" filter.
    CIFilter* filter = [CIFilter filterWithName:@"CIGlassDistortion"];
    [filter setDefaults];
    CIImage *glassImage = [CIImage imageWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForImageResource:@"smoothtexture"]]];
    [filter setValue:glassImage forKey:@"inputTexture"];
    
    // Apply the glass distortion to the LCD view
    [_lcdSection setBackgroundFilters:[NSArray arrayWithObject:filter]];
    
    // Set default title text
    [_titleTextView setText:@"Track title"];
    // Set scrolling speed
    [_titleTextView setSpeed:0.05]; //redraws every 1/100th of a second

    // Set default artist text
    [_artistTextView setText:@"Artist - Album"];
    // Set scrolling speed
    [_artistTextView setSpeed:0.05]; //redraws every 1/100th of a second
    
    // Refresh iTunes information every half second
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateTrackInfoTimer:) userInfo:nil repeats:YES];
    
    // Hide the about field
    [_aboutTextField setAlphaValue:0.0];
    // Set the about field text
    [_aboutTextField setStringValue:@"iTunes MiniPlayer Clone\nPeter Burkimsher\npeterburk@gmail.com"];
    
    // Set up an iTunes ScriptingBridge instance
    iTunesApplication* iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    
    // Track length is a string value of the track duration. Track position is the current position as an integer.
    double trackDuration = [iTunes currentTrack].duration;
    NSInteger trackPosition = [iTunes playerPosition];
    
    // Calculate the proportion of the track time slider to use.
    double trackProportion = trackPosition / trackDuration * 100;
    
    [[_trackTimeSlider cell] startTrackingAt:NSMakePoint((trackProportion / 100 * 59), 0) inView:nil];
    [[_trackTimeSlider cell] stopTracking:NSMakePoint((trackProportion / 100 * 59), 0) at:NSMakePoint((trackProportion / 100 * 59), 0) inView:nil mouseIsUp:YES];
    
    [self updateTrackInfo];
    
    [[_volumeSlider cell] drawKnob];
    
    [_titleTextView setBold:true];
    [_titleTextView setWidth:150];
    [_artistTextView setBold:false];
    [_artistTextView setWidth:110];
    
}

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "peterburk.miniPlayer" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"peterburk.miniPlayer"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"miniPlayer" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}


// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

/*
 * playButtonClicked
 * The play/pause button was clicked. Play/pause iTunes through ScriptingBridge. 
 */
- (IBAction)playButtonClicked:(NSButton *)sender
{
    // Set up an iTunes ScriptingBridge instance
    iTunesApplication* iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    
    // Check if iTunes is running
    if ([iTunes isRunning])
    {
        // Play/pause
        [iTunes playpause];
    }
    
    // Update the track info every time anything gets clicked. 
    [self updateTrackInfo];
}

/*
 * backButtonClicked
 * The back button was clicked. Click the back button in iTunes through ScriptingBridge.
 */
- (IBAction)backButtonClicked:(NSButton *)sender
{
    // Set up an iTunes ScriptingBridge instance
    iTunesApplication* iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    
    // Check if iTunes is running
    if ([iTunes isRunning])
    {
        // Click the back button
        [iTunes backTrack];
    }
    
    // Update the track info every time anything gets clicked.
    [self updateTrackInfo];
}

/*
 * nextButtonClicked
 * The next button was clicked. Click the next button in iTunes through ScriptingBridge.
 */
- (IBAction)nextButtonClicked:(NSButton *)sender
{
    // Set up an iTunes ScriptingBridge instance
    iTunesApplication* iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    
    // Check if iTunes is running
    if ([iTunes isRunning])
    {
        // Click the next button
        [iTunes nextTrack];
    }
    
    // Update the track info every time anything gets clicked.
    [self updateTrackInfo];
}

/*
 * updateTrackInfoTimer
 * Update track information from iTunes every time the timer triggers (every half second).
 */
- (void) updateTrackInfoTimer:(NSTimer *)timer
{
    // Update the track info.
    [self updateTrackInfo];
}

/*
 * updateTrackInfo
 * Update track information from iTunes
 */
- (void)updateTrackInfo
{
    // Set up an iTunes ScriptingBridge instance
    iTunesApplication* iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    
    // Check if iTunes is running
    if ([iTunes isRunning])
    {
        // If iTunes is playing a song
        if ([iTunes playerState] == iTunesEPlSPlaying)
        {
            // Set the play/pause button to a "Play" image
            [_playPauseButton setState:1];
        } else {
            // Set the play/pause button to a "Pause" image
            [_playPauseButton setState:0];
        }
        
        // Read the track name, artist, album
        NSString* trackName = [iTunes currentTrack].name;
        NSString* trackArtist = [iTunes currentTrack].artist;
        NSString* trackAlbum = [iTunes currentTrack].album;
        
        // Track length is a string value of the track duration. Track position is the current position as an integer.
        NSString* trackLength = [iTunes currentTrack].time;
        double trackDuration = [iTunes currentTrack].duration;
        NSInteger trackPosition = [iTunes playerPosition];
        
        // iTunes has its own sound volume.
        NSInteger soundVolume = [iTunes soundVolume];
        
        // Combine the artist and album for display
        NSString* trackArtistAlbum = [NSString stringWithFormat:@"%@ - %@   ", trackArtist, trackAlbum];

        // If there's no album, never mind that, just use the artist
        if ([trackAlbum isEqualToString:@""]) {
            trackArtistAlbum = [NSString stringWithFormat:@"%@   ", trackArtist];
        }
        
        // Format the track position to be a string
        NSString* trackTimeString = [self timeFormatted:trackPosition];
        
        // Set the text fields. _artistTextView is a scrolling text view, so it uses setText instead of setStringValue
//        [_trackNameTextField setStringValue:trackName];
        [_titleTextView setText:[NSString stringWithFormat:@"%@   ", trackName]];
        [_artistTextView setText:trackArtistAlbum];
        [_trackLengthTextField setStringValue:trackLength];
        [_trackTimeTextField setStringValue:trackTimeString];
        
        // Calculate the proportion of the track time slider to use.
        double trackProportion = trackPosition / trackDuration * 100;
        
        // Set the track time and volume sliders
        [_trackTimeSlider setDoubleValue:trackProportion];
                
        [_volumeSlider setDoubleValue:soundVolume];
    }
}

/*
 * timeFormatted
 * Format an integer number of seconds into a text string
 * Input
 *  - NSInteger totalSeconds: The number of seconds
 * Output
 *  - NSString: The formatted string in MM:SS
 */
- (NSString *)timeFormatted:(NSInteger)totalSeconds
{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    
    return [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
}

/*
 * maximiseButtonClicked
 * Open and maximise the iTunes window
 */
- (IBAction)maximiseButtonClicked:(id)sender {
    // Run an AppleScript to open iTunes.
    NSAppleScript *openiTunes = [[NSAppleScript alloc] initWithSource: @"tell application \"iTunes\" to activate"];
    [openiTunes executeAndReturnError:nil];
    
    // Maximise the front window, even if it's in the real iTunes mini player mode. 
    NSAppleScript *maximiseiTunes = [[NSAppleScript alloc] initWithSource: @"tell application \"iTunes\" to set minimized of front window to false"];
    [maximiseiTunes executeAndReturnError:nil];

}

/*
 * volumeSliderClicked
 * Set the iTunes volume
 */
- (IBAction)volumeSliderClicked:(id)sender {
    
    // Read the new volume from the slider
    NSInteger newVolume = [_volumeSlider integerValue];
    
    // Run an AppleScript to set the iTunes volume.
    NSAppleScript *setiTunesVolume = [[NSAppleScript alloc] initWithSource: [NSString stringWithFormat:@"tell application \"iTunes\" to set sound volume to %ld", newVolume ]];
    [setiTunesVolume executeAndReturnError:nil];    
}

/*
 * trackTimeSliderClicked
 * Set the track time
 */
- (IBAction)trackTimeSliderClicked:(id)sender
{
    // Set up an iTunes ScriptingBridge instance
    iTunesApplication* iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    
    // Find the track's duration
    double trackDuration = [iTunes currentTrack].duration;
    
    // Read the slider
    double trackProportion = [_trackTimeSlider doubleValue];
    
    // Calculate the new track position
    NSInteger trackPosition = trackProportion * trackDuration;
    
    // Run an AppleScript to set the iTunes player position.
    NSAppleScript *setiTunesPosition = [[NSAppleScript alloc] initWithSource: [NSString stringWithFormat:@"tell application \"iTunes\" to set player position to %ld", trackPosition ]];
    [setiTunesPosition executeAndReturnError:nil];
    
    // Update the track info every time anything gets clicked.
    [self updateTrackInfo];
}

/*
 * revealButtonClicked
 * Reveal the current track in iTunes
 */
- (IBAction)revealButtonClicked:(id)sender
{
    // Run an AppleScript to open iTunes.
    NSAppleScript *openiTunes = [[NSAppleScript alloc] initWithSource: @"tell application \"iTunes\" to activate"];
    [openiTunes executeAndReturnError:nil];

    // Run an AppleScript to reveal the iTunes track.
    NSAppleScript *itunesReveal = [[NSAppleScript alloc] initWithSource: [NSString stringWithFormat:@"tell application \"iTunes\" to reveal current track" ]];
    [itunesReveal executeAndReturnError:nil];
    
}

/*
 * eqButtonClicked
 * Does anyone really use the equaliser? I put an about box here instead. 
 */
- (IBAction)eqButtonClicked:(id)sender
{
    // Is the LCD showing?
    CGFloat lcdAlphaValue = [_lcdViewContent alphaValue];

    // If the LCD is showing, hide it and show the about text instead.
    if (lcdAlphaValue == 1.0)
    {
        [_lcdViewContent setAlphaValue:0];
        [_aboutTextField setAlphaValue:1];
    }
    
    // If the about text is showing, hide it and show the LCD instead.
    if (lcdAlphaValue == 0.0)
    {
        [_lcdViewContent setAlphaValue:1];
        [_aboutTextField setAlphaValue:0];
    }
}


- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

@end
