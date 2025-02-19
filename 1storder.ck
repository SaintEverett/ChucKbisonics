/* 
    [THIS SCRIPT WILL NOT ENCODE OR DECODE AMBISONICS, RATHER IT EQUIPS YOU WITH THE COEFFICIENTS NEEDED FOR SUCH ENCODING/DECODING]
    This script will calculate the 1st order coefficients for a sound source and four speakers.
    The input arguments are as follows, all directional angles are anti-clockwise to the listener.
    Speaker 1
    Speaker 2
    Speaker 3
    Speaker 4
    Sound source directional
    Sound source elevation
    Adjustment of elevation angles for speakers is possible, but is left out of the user arguments to keep things tidy.
    
    -- Everett M. Carpenter (Spring 2025)
*/

// Check for input args
if( me.args() < 6 ) 
{
    <<< "I need your speaker angles" >>>;
    <<< "Speaker 1:","Speaker 2:","Speaker 3:","Speaker 4:","Direction azimuth of sound:","Elevation azimuth of sound:" >>>;
    me.exit();
}

// Create multidimensional array, right side entries will default to 0, which is fine in ambisonics without height speakers.
float speakCoeff[4][4];

// Array of angles, [0] is direction [1] is elevation
float myAngles[2];

// Take args and put them in speaker angle array
int count;
int speakAngles[4];
while( count < 4 )
{
    me.arg(count) => Std.atoi => speakAngles[count];
    count++;
}
// Take more args and put them in sound angle array
while( count < 6 )
{
    me.arg(count) => Std.atoi => myAngles[count-4];
    count++;
}

// calculate speaker coefficients
fun void mySpeakerCoeffs()
{
    <<< "Speaker coefficients found" >>>;
    int count;
    while( count < 4 )
    {
        speakAngles[count] => float speakP;
        // Convert P & Q to radians
        speakP * (pi/180) => speakP;
        // Calculate X
        (Math.cos(speakP)) => float X;
        // Calculate Y
        (Math.sin(speakP)) => float Y;
        // Store them in array
        X => speakCoeff[count][0];
        Y => speakCoeff[count][1];
        0 => speakCoeff[count][2];   
        0.707 => speakCoeff[count][3]; // W (pressure signal)
        // Print your work
        if( count == 0 ) <<< "-----------------------" >>>;
        <<< "Speaker: ", count + 1, "X: ", speakCoeff[count][0] >>>;
        <<< "Speaker: ", count + 1, "Y: ", speakCoeff[count][1] >>>;
        <<< "Speaker: ", count + 1, "Z: ", speakCoeff[count][2] >>>;
        <<< "Speaker: ", count + 1, "W: ", speakCoeff[count][3] >>>;
        <<< "-----------------------" >>>;
        count++;
    }
    me.exit();
}

// Array of ambisonic coordinates as [X,Y,Z,W]
float myAmbi[4];

fun void convAmbi()
{
    <<< "Sound coefficients found!" >>>;
    // Convert P & Q to radians
    myAngles[0] * (pi/180) => float P;
    myAngles[1] * (pi/180) => float Q;
    // Calculate X
    (Math.cos(P)) * (Math.cos(Q)) => float X;
    // Calculate Y
    (Math.sin(P)) * (Math.cos(Q)) => float Y;
    // Calculate Z
    (Math.sin(Q)) => float Z;
    // Store them in array
    X => myAmbi[0];
    Y => myAmbi[1];
    Z => myAmbi[2];   
    0.707 => myAmbi[3]; // W (pressure signal)
    // Print your work
    <<< "X: ", myAmbi[0] >>>;
    <<< "Y: ", myAmbi[1] >>>;
    <<< "Z: ", myAmbi[2] >>>;
    <<< "W: ", myAmbi[3] >>>;
    me.exit();
}

spork ~ mySpeakerCoeffs();
spork ~ convAmbi();

while( true )
{
    100::ms => now;
    <<< "exiting" >>>;    
    1000::ms => now;
    me.exit();
}
