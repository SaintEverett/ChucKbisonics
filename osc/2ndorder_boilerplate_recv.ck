/*
    name: '2ndorder_boilerplate_recv.ck'
    Author: Everett M. Carpenter, written Spring 2025
    
    #----- [HOW TO USE] -----#
    This is the recieving end of an OSC pair that endcodes audio sources into ambisonic B-format signals, then decodes them. This program is used to spatialize sound via 2nd order ambisonics.
    This end of the script simply recieves gain coefficients and applies them, calculations of those coefficients are done in '2ndorder_boilerplate_send.ck'.
    #------------------------#

    If you wish to modify this script, each variable, class, UGen, Event or function is labelled, so hot rodding this script should be easy. 

    Direct any questions to carpee2 @ rpi.edu

*/

// instantiation
int nChans; // number of dac channels
int nSources; // number of desired sources (specified in command line)
string hostname; // address to recieve OSC messages
int port; // port to recieve OSC messages
0 => int device; // where are you getting HID messages
Hid hi; // keyboard 
HidMsg msg; // keyboard reader
OscIn mailBox[7]; // recieves OSC messages
OscMsg letterOpener; // OSC reader
["X","Y","Z","W","R","S","T","U","V"] @=> string coordinateMarkers[]; // just used to print messages for assurance
Event ready; // confirms everything is ready
dac.channels() => nChans; // remember how many dac channels
/*
if( dac.channels() < 8 )
{
    cherr <= "you don't have enough output channels!" <= IO.newline();
    me.exit();
}
*/
// check the command line
if( !me.args() || me.args() == 1 ) // take arguments
{
    cherr <= "Input required, format is [nSources]:[hostname]:[port]" <= IO.newline()
          <= "If no port specified, default to 6449";
    me.exit();
}
else if( me.args() == 2 )
{
    me.arg(0) => Std.atoi => nSources;
    me.arg(1) => hostname;
    6449 => port;
}
else if( me.args() == 3 )
{
    me.arg(0) => Std.atoi => nSources;
    me.arg(1) => hostname;
    me.arg(2) => Std.atoi => port;
}
// Input & Master Faders
Gain inFade(0.5)[nSources]; // input fader for better volume control
Gain outFade(0.5)[nSources]; // master fader for better volume control
// encoder and decoder declarations
Gain encoder[nSources][9]; // creates x amount of 9 segment rows
Gain decoder[8][9]; // big decode block, 8 rows of 9, each row is a coordinate (x,y,z,w,r,s,t,u,v)
Gain speakSum(0.8)[8]; // this is the sum of the decoding into a single stream for the corresponding speaker
// state you're address
for( auto x : mailBox ) // set your port for OSC
{
    port => x.port; // set port
}
// all the OSC addresses
mailBox[0].addAddress("/sound/location/coordinates");
mailBox[1].addAddress("/sound/location/angles");
mailBox[2].addAddress("/speakers/coefficients");

fun void sourceCoordinates()
{
    float srcCoordinates[nSources][9]; // temp storage for coordinate data
    while( true )
    {
        mailBox[0] => now;
        // did you get mail?
        while( mailBox[0].recv(letterOpener) )
        {
            // read your letter
            for( int i; i < letterOpener.numArgs(); i++ )
            {
                letterOpener.getFloat(i) => srcCoordinates[i/9][i%9]; // assigns massive message of coefficients to temporary array
                srcCoordinates[i/9][i%9] => encoder[i/9][i%9].gain; // copies array over to encoder gains
                // <<< "encoder: ", encoder[i/9][i%9].gain() >>>;
            }
        }
    }
}

fun void angleRecv() // not used but could be impletmented if desired
{
    float tempAngles[nSources][2];
    while( true )
    {
        mailBox[1] => now;
        while( mailBox[1].recv(letterOpener) )
        {
            for( int i; i < letterOpener.numArgs(); i++ )
            {
                letterOpener.getFloat(i) => myGPS[i/nSources].angles[i%2];
                cherr <= myGPS[i/nSources].angles[0] <= myGPS[i/nSources].angles[1] <= IO.newline();
            }
        }
    }
}

fun void speakerCoeff() // assigns speaker coefficients then waits for new encoder coefficients
{
    float speakCoeff[8][9]; // where the speaker coefficients are stored, this will die when the shred does
    mailBox[2] => now;
    // did you get mail?
    while( mailBox[2].recv(letterOpener) )
    {
        // read your letter
        for( int i; i < letterOpener.numArgs(); i++ )
        {
            letterOpener.getFloat(i) => speakCoeff[i/9][i%9]; // assigns massive message of coefficients to temporary array
            speakCoeff[i/9][i%9] => decoder[i/9][i%9].gain; // copies array over to decoder gains
            // <<< "decoder: ", i/9, i%9, decoder[i/9][i%9].gain() >>>;
        }
    }
    ready.signal();
    me.exit();
}

for( int i; i < encoder.size(); i++ ) // three layer for loop that sends encoder blocks to their respective decoder blocks
{
    for( int j; j < encoder[0].size(); j++ )
    {
        fader[i] => encoder[i][j];
        for( int g; g < decoder.size(); g++ )
        {
            encoder[i][j] => decoder[g][j];
            // cherr <= "fader: " <= i <= " into encoder: " <= i <= " section/coordinate: " <= coordinateMarkers[j] <= IO.newline();
            // cherr <= "encoder: " <= i <= " coordinate: " <= coordinateMarkers[j] <= " into decoder: " <= g <= " coordinate: " <= coordinateMarkers[j] <= IO.newline();
        }   
    }
}

for( int i; i < speakSum.size(); i++ ) // sends decode blocks to their respective speaker sums
{
    for( int j; j < decoder[0].size(); j++ )
    {
        decoder[i][j] => speakSum[i];
        // cherr <= "decoder: " <= i <= " coordinate: " <= coordinateMarkers[j] <= " into speaker sum: " <= i <= IO.newline();
    }
}

for( int i; i < dac.channels(); i++ ) // attaches the final speaker sums to their corresponding speakers
{
    speakSum[i] => dac.chan(i);
    // cherr <= "speak sum " <= i <= " connected to channel " <= i <= IO.newline();
}

// spork off OSC recievers
spork ~ speakerCoeff(); 

// open keyboard 
if( !hi.openKeyboard( device ) ) me.exit();
<<< "keyboard '" + hi.name() + "' ready", "" >>>;

// print your identity
cherr <= "Your name is " <= hostname <= IO.newline()
      <= "You're getting mail on port " <= port <= IO.newline();

ready => now;

cherr <= "Decoder gains are set and ready" <= IO.newline();

// begin listening for coordinates
spork ~ sourceCoordinates();

// go!
while( true ) // the main thread is simply responsible for when to close, it just sits and waits for you to press the esc key
{
    hi => now;
    while( hi.recv( msg ))
    {
        if( msg.isButtonDown() )
        { 
            // get out of here (escape)
            if( msg.ascii == 27 )
            {
                cherr <= "It's all over now, baby blue";
                300::ms => now;
                cherr <= " . ";
                300::ms => now;
                cherr <= " . ";
                300::ms => now;
                cherr <= " . " <= IO.newline();
                100::ms => now;
                me.exit();
            }
        }
    }
    10::ms => now;
}