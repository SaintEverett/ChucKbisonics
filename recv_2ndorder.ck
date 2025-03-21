/*
    [script name: recv_2ndorder.ck]

    -- Author: Everett Carpenter (Spring 2025)

    What is it?
        This script is one half of an OSC system for 2nd order ambisonics. This script should be ran on the device that is performing the audio processing.
    How does it work?
        This script listens to OSC messages on the network. Using the input arguments ([hostname]:[port]), the device running the script will be able
        to recieve OSC messages addressed to it on the specified port. These OSC messages contain coefficients needed to encode the audio for ambisonics.
    What do I need to do to make it work?
        If you do not wish to have a sine cluster for your sound source, delete the "SinOsc sine[6]" and bring in any audio you wish. With your new audio
        source, connect it to "inputStage" which will do the rest of the routing for you. Note that the ADSR object "env" is between the inputStage and
        sine oscillators, if you don't want this, just get rid of it. Aside from audio input, double check that your speaker system is ready to go and 
        if possible, please have a master fader turned all the way down before raising it to test levels. 
    You said it's one half, what else is there?
        There is a partner script titled "send_2ndorder.ck". This script will send you all the coefficients you need, assuming it has your OSC address.
        There is a similar section to this in the script, detailing everything you need to get it running. 

    If you have any questions, feel free to email me at carpee2 [at] rpi.edu

    To be added:
        Speaker elevation support ( just more math to be programmed )

*/
// identify yourself
string hostname;
int port;
Hid hi;
HidMsg msg;
Event changeGain;
Event setSpeakers;
// sound source 
SinOsc sine[6];
// sum of sine osc
Gain inputStage;  /// THIS IS AN INPUT STAGE, CONNECT ANYTHING YOU WANT TO IT
// envelope for sine cluster
ADSR env(5::ms, 500::ms, 0.2, 10::ms);
// random freq
for( int i; i < sine.size(); i++ )
{
    Math.random2f(67.5, 567.3) => sine[i].freq;
    sine[i] => env;
}
env => inputStage;

// device #
0 => int device; // CHANGE THIS VARIABLE IF YOU WANT A DIFFERENT HID DEVICE
// open keyboard (get device number from command line)
if( !hi.openKeyboard (device) ) 
{
    me.exit();
}
<<< "keyboard ready" >>>;

// mailbox & letter opener
OscIn mailBox[3];
OscMsg letterOpener;

if( !me.args() ) 
{
    cherr <= "Input required, format is [hostname]:[port]" <= IO.newline()
          <= "If no port specified, default to 6449";
    me.exit();
}
else if( me.args() == 1 )
{
    me.arg(0) => hostname;
    6449 => port;
}
else if( me.args() == 2 )
{
    me.arg(0) => hostname;
    me.arg(1) => Std.atoi => port;
}

// print your identity
cherr <= "Your name is " <= hostname <= IO.newline()
      <= "You're getting mail on port " <= port <= IO.newline();

// coordinate storage
float coordinates[9];
// angle storage
float angles[2];
// speaker coefficients
float speakerGain[8][9];

// state you're address and city
for( auto x : mailBox )
{
    port => x.port;
}

mailBox[0].addAddress("/sound/location/coordinates");
mailBox[1].addAddress("/sound/location/angles");
mailBox[2].addAddress("/speakers/coefficients");

fun void oscListen()
{
    while( true )
    {
        // wait for mail
        mailBox[0] => now;

        // did you get mail?
        while( mailBox[0].recv(letterOpener) )
        {
            // read your letter
            /* This announces it 
            cherr <= "received OSC message: " <= letterOpener.address
                  <= "type: " <= letterOpener.typetag
                  <= " there are: " <= letterOpener.numArgs() <= " arguments" <= IO.newline();
            */
            for( int i; i < letterOpener.numArgs(); i++ )
            {
                letterOpener.getFloat(i) => coordinates[i];
            }
            changeGain.signal();
            // print them out
            cherr <= "Coordinates [X,Y,Z,W]" <= IO.newline();
            for( int i; i < letterOpener.numArgs(); i++ )
            {
                cherr <= coordinates[i] <= " ";
            }
            cherr <= IO.newline(); 
        }
        while( mailBox[1].recv(letterOpener) )
        {
            // read your letter
            /* This announces it
            cherr <= "received OSC message: " <= letterOpener.address
                  <= "type: " <= letterOpener.typetag
                  <= " there are: " <= letterOpener.numArgs() <= " arguments" <= IO.newline();
            */
            for( int i; i < letterOpener.numArgs(); i++ )
            {
                letterOpener.getFloat(i) => angles[i];
            }
            // print them out
            cherr <= "Angles in degrees" <= IO.newline()
                  <= angles[0] <= " | " <= angles[1] <= IO.newline();
        }
    }
}

fun void ambisonicProcess()
{
     // enc & dec
    Gain encode[9];
    Gain decodeX[8];
    Gain decodeY[8];
    Gain decodeZ[8];
    Gain decodeW[8];
    Gain decodeR[8];
    Gain decodeS[8];
    Gain decodeT[8];
    Gain decodeU[8];
    Gain decodeV[8];
    Gain speakSum(0.05)[8];

    // input encode patch
    for( auto e : encode )
    {
        env => e;
    }
    // decode x
    for( auto x : decodeX )
    {
        encode[0] => x;
    }
    // decode y
    for( auto y : decodeY )
    {
        encode[1] => y;
    }
    // decode z
    for( auto z : decodeZ )
    {
        encode[2] => z;
    }
    // decode w
    for( auto w : decodeW )
    {
        encode[3] => w;
    }
    // decode R
    for( auto r : decodeR )
    {
        encode[4] => r;
    }
    // decode S
    for( auto s : decodeS )
    {
        encode[5] => s;
    }
    // decode T
    for( auto t : decodeT )
    {
        encode[6] => t;
    }
    // decode U
    for( auto u : decodeU )
    {
        encode[7] => u;
    }
    // decode V
    for( auto v : decodeV )
    {
        encode[8] => v;
    }
    // sum to speakers
    for( int i; i < speakSum.size(); i++ )
    {
        decodeX[i] => speakSum[i];
        decodeY[i] => speakSum[i];
        decodeZ[i] => speakSum[i];
        decodeW[i] => speakSum[i];
        decodeR[i] => speakSum[i];
        decodeS[i] => speakSum[i];
        decodeT[i] => speakSum[i];
        decodeU[i] => speakSum[i];
        decodeV[i] => speakSum[i];
        speakSum[i] => dac.chan(i); // MAKE SURE THIS WORKS FOR YOUR AUDIO SYSTEM
    }

    setSpeakers => now;

    for( int i; i < speakerGain.size(); i++ )
    {
        speakerGain[i][0] => decodeX[i].gain;
        speakerGain[i][1] => decodeY[i].gain;
        speakerGain[i][2] => decodeZ[i].gain;
        speakerGain[i][3] => decodeW[i].gain;
        speakerGain[i][4] => decodeR[i].gain;
        speakerGain[i][5] => decodeS[i].gain;
        speakerGain[i][6] => decodeT[i].gain;
        speakerGain[i][7] => decodeU[i].gain;
        speakerGain[i][8] => decodeV[i].gain;
        <<< decodeX[i].gain(), decodeY[i].gain(), decodeZ[i].gain(), decodeW[i].gain(), decodeR[i].gain(), decodeS[i].gain(), decodeT[i].gain(), decodeU[i].gain(), decodeV[i].gain() >>>;
    }  

    while( true )
    {
        changeGain => now; // changeGain is an event that should be triggered via the parent thread when the array of coefficients changes
        for( int i; i < coordinates.size(); i++ )
        {
            coordinates[i] => encode[i].gain;
        }
    }
}

spork ~ ambisonicProcess();
spork ~ oscListen();

// one time message from speaker coefficients
mailBox[2] => now;

while( mailBox[2].recv(letterOpener) )
{
    // read your letter2
    /* This announces it
    cherr <= "received OSC message: " <= letterOpener.address
          <= "type: " <= letterOpener.typetag
          <= " there are: " <= letterOpener.numArgs() <= " arguments" <= IO.newline();
    */
    for( int i; i < letterOpener.numArgs(); i++ )
    {
        letterOpener.getFloat(i) => speakerGain[i/9][i%9];
        <<< speakerGain[i/9][i%9], i/9, i%9 >>>;
    }  
    <<< "i'm done" >>>;    
    setSpeakers.signal();
}

while( true )
{
    env.keyOn();
    Math.random2f(75.3,500.8)::ms => now; 
    env.keyOff();
    Math.random2f(75.1,500.7)::ms => now;
    while( hi.recv(msg) )
    {
        if( msg.isButtonDown() )
        {
            if( msg.ascii == 27 )
            {
                cherr <= "exiting";
                300::ms => now;
                cherr <= " . ";
                300::ms => now;
                cherr <= " . ";
                300::ms => now;
                cherr <= " . " <= IO.newline();
                me.exit();
            }
        }
    }
    10::ms => now;
}