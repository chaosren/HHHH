//
//  NDPlayMovie.h
//  dhlj
//
//  Created by zhangwq on 13-3-22.
//  Copyright (c) 2013Äê All rights reserved.
//


#import <MediaPlayer/MediaPlayer.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIView.h>

@class UIView;
@class NSURL;
@class NSNotification;
@class NSTimer;

@interface NDPlayMovie : NSObject
{
    UIView* _ownerView;
    UIControl* _overlay;
    MPMoviePlayerController* _moviePlayerController;
    NSTimer* _myTimer_PauseMusic;
    NSTimer* _myTimer_StopMovie;
}

@property (retain) MPMoviePlayerController *moviePlayerController;
@property (retain) UIView *ownerView;
@property (retain) UIControl* overlay;


+(id) sharedObj;
-(Boolean) check;
-(NSURL *)localMovieURL;

-(void)playTest;
-(void)playMovieFile:(NSURL *)movieFileURL;
-(void)onPlayMovieBegin;
-(void)onPlayMovieEnd;
-(Boolean)isPlaying;

-(void)addOverlay;
-(void)onTouchDown;

-(void)onTimerStopMovie;

-(void)createAndConfigurePlayerWithURL:(NSURL *)movieURL
                            sourceType:(MPMovieSourceType)sourceType;

-(void)createAndPlayMovieForURL:(NSURL *)movieURL
                     sourceType:(MPMovieSourceType)sourceType;

-(void)applyUserSettingsToMoviePlayer;
-(void)moviePlayBackDidFinish:(NSNotification*)notification;

-(void)loadStateDidChange:(NSNotification *)notification;
-(void)moviePlayBackStateDidChange:(NSNotification*)notification;
-(void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification;
-(void)movieDurationAvailable:(NSNotification*)notification;

-(void)installMovieNotificationObservers;
-(void)removeMovieNotificationHandlers;
-(void)deletePlayerAndNotificationObservers;

@end
