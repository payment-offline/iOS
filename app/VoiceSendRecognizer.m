//
//  VoiceRecognizer.m
//  app
//
//  Created by Remi Robert on 16/04/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

#import "VoiceSendRecognizer.h"
#import "SinVoicePlayer.h"
#include "ESPcmPlayer.h"
#import "MyPcmPlayerImp.h"

static const char* const CODE_BOOK = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ@_";

@interface VoiceSendRecognizer ()
@property (nonnull, nonatomic, assign) SinVoicePlayer *mSinVoicePlayer;
@property (nonatomic, copy) void (^sendCompletion)(void);
@end

ESVoid onSinVoicePlayerStart(ESVoid* cbParam) {
    NSLog(@"onSinVoicePlayerStart, start");
    VoiceSendRecognizer * vc = (__bridge VoiceSendRecognizer *)cbParam;
    [vc onPlayData:vc];
    NSLog(@"onPlayData, end");
}

ESVoid onSinVoicePlayerStop(ESVoid* cbParam) {
    NSLog(@"onSinVoicePlayerStop");
}

SinVoicePlayerCallback gSinVoicePlayerCallback = {onSinVoicePlayerStart, onSinVoicePlayerStop};


@implementation VoiceSendRecognizer {
    ESPcmPlayer mPcmPlayer;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        mPcmPlayer.create = MyPcmPlayerImp_create;
        mPcmPlayer.start = MyPcmPlayerImp_start;
        mPcmPlayer.stop = MyPcmPlayerImp_stop;
        mPcmPlayer.setParam = MyPcmPlayerImp_setParam;
        mPcmPlayer.destroy = MyPcmPlayerImp_destroy;
        self.mSinVoicePlayer = SinVoicePlayer_create2("com.sinvoice.demo",
                                                      "SinVoiceDemo",
                                                      &gSinVoicePlayerCallback,
                                                      (__bridge ESVoid *)(self), &mPcmPlayer);
        
        mMaxEncoderIndex = SinVoicePlayer_getMaxEncoderIndex(self.mSinVoicePlayer);
    }
    return self;
}

- (void)onPlayData:(VoiceSendRecognizer *)data {
    char ch[100] = { 0 };
    for ( int i = 0; i < mPlayCount; ++i ) {
        ch[i] = (char)data->mRates[i];
    }
}

- (void)startPlay:(nonnull NSString *)string completion:(void (^)(void))sendingCompletion {
    self.sendCompletion = sendingCompletion;
    
    int index = 0;
    const char* str = [string cStringUsingEncoding:NSUTF8StringEncoding];
    
    mPlayCount = (int)strlen(str);
    
    if (mMaxEncoderIndex < 255) {
        int lenCodeBook = (int)strlen(CODE_BOOK);
        int isOK = 1;
        while (index < mPlayCount) {
            int i = 0;
            for ( i = 0; i < lenCodeBook; ++i ) {
                if ( str[index] == CODE_BOOK[i] ) {
                    mRates[index] = i;
                    break;
                }
            }
            if ( i >= lenCodeBook ) {
                isOK = 0;
                break;
            }
            ++index;
        }
        if (isOK) {
            SinVoicePlayer_play(self.mSinVoicePlayer, mRates, mPlayCount);
        }
    }
    else {
        int index = 0;
        
        while (index < mPlayCount) {
            mRates[index] = str[index];
            ++index;
        }
        SinVoicePlayer_play(self.mSinVoicePlayer, mRates, mPlayCount);
    }
}

@end
