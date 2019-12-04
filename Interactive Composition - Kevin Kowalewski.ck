// Kevin Kowalewski - Interactive Composition

// MARK: - Sound Chain 
adc => blackhole;
SinOsc sineOsc => PRCRev oscRev => Pan2 oscPan => dac;
SndBuf2 sampler1 => Pan2 samplerPan1 => dac;
SndBuf2 sampler2 => Pan2 samplerPan2 => dac;


// MARK: - Instance Variables
0 => int clapCount;
0 => int melodyIsPlaying;
0 => int sweepIsPlaying;
0.03 => float oscillatorGainValue;

Shred melodyShred;
Shred effectsShred;
0 => int clapControlDisabled;


// MARK: - Initial Setup
0 => sampler1.pos;
0.0 => sampler1.gain;
0 => sampler2.pos;
0.0 =>sampler2.gain;
setOscillatorGain(oscillatorGainValue);
me.dir() + "/samples/sample1.aiff" => sampler1.read;
me.dir() + "/samples/sample2.aiff" => sampler2.read;


// MARK: - Main Composition Calls
listen();


// MARK: - Helper Methods
fun void listen() {
    while( true ) {
        if( adc.last() > 0.7 ) {
            clapCount++;
            wait();
            handleClap();
            
            if( clapCount == 1 ) {
                if(melodyIsPlaying == 0) {
                    <<< "Command: play melody" >>>;
                   playMelody();
                }else { 
                    <<< "Command: pause melody" >>>;
                    pauseMelody();
                }
            }else if( clapCount == 2 ) {
                <<< "Command: decrease volume" >>>;
                oscillatorGainValue - 0.03 => oscillatorGainValue;
                setOscillatorGain(oscillatorGainValue);
            }else if( clapCount == 3 ) {
                <<< "Command: increase volume" >>>;
                oscillatorGainValue + 0.03 => oscillatorGainValue;
                setOscillatorGain(oscillatorGainValue);
            }else if( clapCount == 4 ) {
                <<< "Command: play sweep" >>>;
                playSweep();
            }else if( clapCount == 6 ) {
                <<< "Command: play screech" >>>;
                playScreech();
            }
        } else if( adc.last() < 0.7 ) { }
        
        0 => clapCount;
        0.5::samp => now;
    }
}

fun void handleClap() {
    // starts listening for second clap
    for(0 => int i; i < 40000; i++) {
        if( adc.last() > 0.7 ) {
            // updates clap count and handles latency issues with sample inputs
            clapCount++;
            wait();
            
            handleClap();
            break;
        }else if( adc.last() < 0.7) {  }
        
        0.5::samp => now;
    }
}

fun void playMelody() {
    setOscillatorGain(oscillatorGainValue);
    spork ~ melody() @=> melodyShred;     
    0::ms => now;
    1 => melodyIsPlaying;
}

fun void pauseMelody() {
    setOscillatorGain(0.0);
    melodyShred.exit();
    0 => melodyIsPlaying;
}

fun void playSweep() {
    spork ~ sweep() @=> effectsShred;
    0::ms => now;
    0.7 => sampler1.gain;
    1 => sweepIsPlaying;
}

fun void playScreech() {
    spork ~ screech(3);
    0::ms => now;
}

fun void wait() {
    0 => int counter;
    while( true ) {
        if(counter == 30000) { break; }
        adc.last() => float useless;
        counter++;
        0.5::samp => now;
    }
} 

// plays a melody
fun void melody() {
    [440.00, 523.25, 659.25, 880.00] @=> float phrase1[];
    [349.23, 523.25, 659.25, 880.00] @=> float phrase2[];
    [293.66, 523.25, 659.25, 880.00] @=> float phrase3[];
    [phrase1, phrase2, phrase3, phrase2, phrase1, phrase2, phrase3, phrase2, phrase1, phrase2, phrase3, phrase2] @=> float phrases[][];
    
    for(0 => int i; i < phrases.cap(); i++) {
        playPhrase(phrases[i]);
    }
    setOscillatorGain(0.0);
}

// plays sweep sound
fun void sweep() {
    
    // pans from left to right
    for(0 => int i; i < 15; i++) {
        0.1 * i => samplerPan1.pan;
        0 => sampler1.pos;
        advanceTime(0.25::second);
    } 
    
    // pans from right to left
    for(15 => int i; i > 0; i--) {
        0.1 * i => samplerPan1.pan;
        0 => sampler1.pos;
        advanceTime(0.25::second);
    } 
}

// plays melody specified by the array
fun void playPhrase(float phrase[]) {
    [0.4, 0.25, 0.15, 0.05] @=> float mixValues[];
    [-1.0, -0.8, -0.6, -0.4, 0.0, 0.2, 0.4, 0.6] @=> float panValues[];
    
    for(0 => int z; z < panValues.cap(); z++) {
        panValues[z] => oscPan.pan;
        for(0 => int q; q < phrase.cap(); q++) {
            mixValues[q] => oscRev.mix;
            phrase[q] => sineOsc.freq;            
            advanceTime(0.15::second);
        }
    }
}

// plays screech sound
fun void screech(int length) {
    for(0 => int i; i < length; i++) {
        0.1 * i => samplerPan2.pan;
        0.05 => sampler2.rate;
        0 => sampler2.pos;
        advanceTime(6.0::second);
    }
}

// sets sinOsc gain to the specified value
fun void setOscillatorGain(float value) {
    value => sineOsc.gain;
    //value => sampler1.gain;
    value => sampler2.gain;
}

// advances time by the specified duration
fun void advanceTime(dur duration) {
    duration => now;
}
