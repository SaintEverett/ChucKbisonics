/* 
    [THIS SCRIPT WILL NOT ENCODE OR DECODE AMBISONICS, RATHER IT EQUIPS YOU WITH THE COEFFICIENTS NEEDED FOR SUCH ENCODING/DECODING]
    This script will calculate what is commonly referred to as "1.5" order ambisonic coefficients.
    The arugments are as follows, directional angles are anti clockwise to the listener
    Speaker 1
    Speaker 2
    Speaker 3
    Speaker 4
    Sound directional angle
    Sound elevation angle
    The coordinates provided by this script are organized as [X,Y,Z,W,U,V]
    
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
float speakCoeff[4][6];

// Array of angles, [0] is direction [1] is elevation
float myAngles[2];

// Take args and put them in speaker angle array
int count;
int speakAngles[4][2];
while( count < 4 )
{
    me.arg(count) => Std.atoi => speakAngles[count][0];
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
        // Directional 
        speakAngles[count][0] => float speakD;
        speakAngles[count][1] => float speakE;
        // Convert P & Q to radians
        speakD * (pi/180) => speakD;
        speakE * (pi/180) => speakE;
        // Calculate X
        (Math.cos(speakD)) * (Math.cos(speakE)) => float X;
        // Calculate Y
        (Math.sin(speakD)) * (Math.cos(speakE)) => float Y;
        // Calculate Z
        (Math.sin(speakE)) => float Z;
        // Calculate U
        (Math.cos(2*speakD) * Math.cos(speakE)) => float U;
        // Calculate V
        (Math.sin(2*speakD) * Math.cos(speakE)) => float V;
        // Store them in array
        X => speakCoeff[count][0];
        Y => speakCoeff[count][1];
        0 => speakCoeff[count][2];   
        0.707 => speakCoeff[count][3]; // W (pressure signal)
        U => speakCoeff[count][4];
        V => speakCoeff[count][5];
        // Print your work
        if( count == 0 ) <<< "-----------------------" >>>;
        <<< "Speaker: ", count + 1, "X: ", speakCoeff[count][0] >>>;
        <<< "Speaker: ", count + 1, "Y: ", speakCoeff[count][1] >>>;
        <<< "Speaker: ", count + 1, "Z: ", speakCoeff[count][2] >>>;
        <<< "Speaker: ", count + 1, "W: ", speakCoeff[count][3] >>>;
        <<< "Speaker: ", count + 1, "U: ", speakCoeff[count][4] >>>;
        <<< "Speaker: ", count + 1, "V: ", speakCoeff[count][5] >>>;
        <<< "-----------------------" >>>;
        count++;
    }
    me.exit();
}

// Array of ambisonic coordinates as [X,Y,Z,W]
float myAmbi[6];

fun void convAmbi()
{
    <<< "Sound coefficients found!" >>>;
    // Convert P & Q to radians
    myAngles[0] * (pi/180) => float soundD;
    myAngles[1] * (pi/180) => float soundE;
    // Calculate X
    (Math.cos(soundD)) * (Math.cos(soundE)) => float X;
    // Calculate Y
    (Math.sin(soundD)) * (Math.cos(soundE)) => float Y;
    // Calculate Z
    (Math.sin(soundE)) => float Z;
    // Calculate U
    (Math.cos(2*soundD) * Math.cos(soundE)) => float U;
    // Calculate V
    (Math.sin(2*soundD) * Math.cos(soundE)) => float V;
    // Store them in array
    X => myAmbi[0];
    Y => myAmbi[1];
    Z => myAmbi[2];   
    0.707 => myAmbi[3]; // W (pressure signal)
    U => myAmbi[4];
    V => myAmbi[5];
    // Print your work
    <<< "X: ", myAmbi[0] >>>;
    <<< "Y: ", myAmbi[1] >>>;
    <<< "Z: ", myAmbi[2] >>>;
    <<< "W: ", myAmbi[3] >>>;
    <<< "U: ", myAmbi[4] >>>;
    <<< "V: ", myAmbi[5] >>>;
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
