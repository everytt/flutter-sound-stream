#ifndef SoundStreamPlugin_h
#define SoundStreamPlugin_h

#import <Flutter/Flutter.h>
#import <AVFoundation/AVFoundation.h>
#import <flutter_sound_core/Flauto.h>
@interface SoundStreamPlugin : NSObject<FlutterPlugin, AVAudioPlayerDelegate>
{
    
}
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar;
@end
#endif /* SoundStreamPlugin_h */
