//-------------------------------------------------------------
// Basic Ambisonic Encoder for recording in the nth order...
//-------------------------------------------------------------
AmbiMath ambi; // our ambisonic math library
int order;
int numStream;
if(me.args())
{
    me.arg(0) => Std.atoi => order;
}
else 
{
    cherr <= "Args required, format is: [order]" <= IO.newline();
    me.exit();
}
(order+1)*(order+1) => numStream; // calculate number of audio streams
50::ms => dur interpoRate; // interpolation rate
float realCoord[numStream]; // spherical harmonic coordinates
float targetCoord[numStream]; // target coordinates
string letters[];
["W","Y","Z","X","V","T","R","S","U","Q","O","M","K","L","N","P","4.0","4.1","4.2","4.3","4.4","4.5","4.6","4.7","4.8","5.0","5.1","5.2","5.3","5.4","5.5","5.6","5.7","5.8","5.9","6.0"] @=> letters; 
Gain encoder[numStream]; // 36 audio streams for coordinate coefficients
WvOut recording[numStream]; // record each stream individually
Event wait;
Hid key; // read hid
HidMsg msg; // msg to decode hid
0 => int device; // device # (change to desired hid device)
if (!key.openKeyboard(device)) // open keyboard
{
    cherr <= "Error opening HID device: " <= device <= IO.newline();
}   

for(int i; i < recording.size(); i++)
{
    recording[i].wavFilename("ambi_sitar_channel_"+letters[i]);
    recording[i].record(1);
    recording[i].fileGain(0.5);
}

fun void sitar()
{
    Sitar sit;
    PRCRev r;
    Gain volume;
    0.1 => volume.gain;
    .05 => r.mix;
    // patch
    for(int i; i < encoder.size(); i++)
    {
        sit => volume => r => encoder[i] => recording[i] => blackhole;
    }

    // time loop
    while( true )
    {
        // freq
        Math.random2( 0, 11 ) => float winner;
        Std.mtof( 57 + Math.random2(0,3) * 12 + winner ) => sit.freq;

        // pluck!
        Math.random2f( 0.4, 0.9 ) => sit.noteOn;

        // advance time
        // note: Math.randomf() returns value between 0 and 1
        if( Math.randomf() > .5 ) {
            .5::second => now;
        } else { 
            0.25::second => now;
        }
    }
}

fun void interpolator(int id) // interpolate through the coordinates
{
    while(true)
    {
        if(realCoord[id] != targetCoord[id])
        {
            ((targetCoord[id] - realCoord[id]) * 0.05 + realCoord[id]) => realCoord[id];
            // cherr <= realCoord[id] <= " ";
            // if(id == 35) cherr <= "-------------------------------" <= IO.newline();
        }
        else 
        {
            cherr <= "waiting on: " <= id <= IO.newline();
            wait => now;
        }
        5::ms => now;
    }
}

fun void check()
{
    while(true)
    {
        for(int i; i < numStream; i++)
        {
            cherr <= realCoord[i] <= " | " <= targetCoord[i] <= IO.newline();
        }
        cherr <= "-----------------------------------------" <= IO.newline();
        30::ms => now;
    }
}

fun void coefficient()
{
    for(int i; i < encoder.size(); i++)
    {
        realCoord[i] => encoder[i].gain;
    }
}

for(int i; i < numStream; i++)
{
    spork ~ interpolator(i);
}

// spork ~ check();
int count;

while(true)
{
    ambi.all(Math.random2f(-1.0,1.0),Math.random2f(-1.0,1.0),Math.random2f(-1.0,1.0),targetCoord,order);
    wait.signal();
    cherr <= "interpolating " <= IO.newline();
    8000::ms => now;
    spork ~ coefficient();
    if(!count) spork ~ sitar();
    1 => count;
}