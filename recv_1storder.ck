/*
    [script name: recv_1stdorder.ck] // first order version of "recv_2ndorder.ck"

    -- Author: Everett Carpenter (Spring 2025)

    What is it?
        This script is one half of an OSC system for 1st order ambisonics. This script should be ran on the device that is performing the audio processing.
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
0 => int device;
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
float coordinates[4];
// angle storage
float angles[2];
// speaker coefficients
float speakerGain[4][4];

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
            cherr <= "Coordinates [X,Y,Z,W]" <= IO.newline()
                  <= coordinates[0] <= " " <= coordinates[1] <= " " <= coordinates[2] <= " " <= coordinates[3] <= IO.newline();
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
    Gain encode[4];
    Gain decodeX[4];
    Gain decodeY[4];
    Gain decodeZ[4];
    Gain decodeW[4];
    Gain speakSum(0.5)[4];

    // encode patch
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
    // sum to speakers
    for( int i; i < speakSum.size(); i++ )
    {
        decodeX[i] => speakSum[i];
        decodeY[i] => speakSum[i];
        decodeZ[i] => speakSum[i];
        decodeW[i] => speakSum[i];
    }

    setSpeakers => now;
    <<< "we're moving" >>>;

    for( int i; i < decodeX.size(); i++ )
    {
        speakerGain[i][0] => decodeX[i].gain;
        speakerGain[i][1] => decodeY[i].gain;
        speakerGain[i][2] => decodeZ[i].gain;
        speakerGain[i][3] => decodeW[i].gain;
        <<< decodeX[i].gain(), decodeY[i].gain(), decodeZ[i].gain(), decodeW[i].gain() >>>;
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
    // read your letter
    /* This announces it
    cherr <= "received OSC message: " <= letterOpener.address
          <= "type: " <= letterOpener.typetag
          <= " there are: " <= letterOpener.numArgs() <= " arguments" <= IO.newline();
    */
    for( int i; i < letterOpener.numArgs(); i++ )
    {
        letterOpener.getFloat(i) => speakerGain[i/4][i%4];
    }  
    <<< "i'm done" >>>;    
    setSpeakers.signal();
}

while( true )
{
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