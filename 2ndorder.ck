/*
    [THIS SCRIPT WILL NOT ENCODE OR DECODE AMBISONICS, RATHER IT EQUIPS YOU WITH THE COEFFICIENTS NEEDED FOR SUCH ENCODING/DECODING]
    This script will calculate 2nd order ambisonic coefficients for eight speakers of any direction.
    The elevation angles are defaulted to 0, but they can be changed if desired.
    The lack of specificity in elevation angle is to keep the script from excessive input arguments.
    They are stored in the multidimensional array speakCoeff[] where the index is the speaker #.
    The command line arguements are for the direction of eight speakers, anti clockwise to the listener.
    The last two arguements are for the coefficients of a sound source, the order being directional angle, then elevation angle.
    
    -- Everett M. Carpenter (Spring 2025)
*/
// Check for input args
if( me.args() < 10 ) 
{
    <<< "I need your speaker angles" >>>;
    <<< "Speaker 1:","Speaker 2:","Speaker 3:","Speaker 4:","Speaker 5:","Speaker 6:","Speaker 7:","Speaker 8:","Direction azimuth of sound:","Elevation azimuth of sound:" >>>;
    me.exit();
}

// Create multidimensional array
float speakCoeff[8][9];

// Array of angles, [0] is direction [1] is elevation
float myAngles[2];

// Take args and put them in speaker angle array
int count;
float speakAngles[8][2];
while( count < 8 )
{
    me.arg(count) => Std.atof => speakAngles[count][0];
    count++;
}

// Take more args and put them in sound angle array
while( count < 10 )
{
    me.arg(count) => Std.atof => myAngles[count-8];
    count++;
}

// calculate speaker coefficients [X,Y,Z,W,R,S,T,U,V]
fun void mySpeakerCoeffs()
{
    <<< "Speaker coefficients found" >>>;
    int count;
    while( count < 8 )
    {
        // Directional 
        speakAngles[count][0] => float speakD;
        speakAngles[count][1] => float speakE;
        // Convert P & Q to radians
        speakD * (pi/180) => speakD;
        speakE * (pi/180) => speakE;
        // Calculate X
        (Math.cos(speakD))*(Math.cos(speakE)) => float X;
        // Calculate Y
        (Math.sin(speakD))*(Math.cos(speakE)) => float Y;
        // Calculate Z
        (Math.sin(speakE)) => float Z;
        // Calculate R
        (Math.sin(2*speakE)) => float R;
        // Calculate S
        (Math.cos(speakD) * Math.cos(2*speakE)) => float S;
        // Calculate T
        (Math.sin(speakD)) * (Math.cos(2*speakE)) => float T;
        // Calculate U
        (Math.cos(2*speakD)) - (Math.cos(2*speakD) * Math.sin(2*speakE)) => float U;
        // Calculate V
        (Math.sin(2*speakD)) - (Math.sin(2*speakD) * Math.sin(2*speakE)) => float V;
        // Store them in array
        X => speakCoeff[count][0];
        Y => speakCoeff[count][1];       
        Z => speakCoeff[count][2];
        0.707 => speakCoeff[count][3]; // W (pressure signal)
        R => speakCoeff[count][4];
        S => speakCoeff[count][5];
        T => speakCoeff[count][6];
        U => speakCoeff[count][7];
        V => speakCoeff[count][8];
        // Print your work
        if( count == 0 ) <<< "-----------------------" >>>;
        <<< "Speaker: ", count + 1, "X: ", speakCoeff[count][0] >>>;
        <<< "Speaker: ", count + 1, "Y: ", speakCoeff[count][1] >>>;
        <<< "Speaker: ", count + 1, "Z: ", speakCoeff[count][2] >>>;
        <<< "Speaker: ", count + 1, "W: ", speakCoeff[count][3] >>>;
        <<< "Speaker: ", count + 1, "R: ", speakCoeff[count][4] >>>;
        <<< "Speaker: ", count + 1, "S: ", speakCoeff[count][5] >>>;
        <<< "Speaker: ", count + 1, "T: ", speakCoeff[count][6] >>>;
        <<< "Speaker: ", count + 1, "U: ", speakCoeff[count][7] >>>;
        <<< "Speaker: ", count + 1, "V: ", speakCoeff[count][8] >>>;
        <<< "-----------------------" >>>;
        count++;
    }
    me.exit();
}

// Array of ambisonic coordinates as [X,Y,Z,W,R,S,T,U,V]
float myAmbi[9];

fun void convAmbi()
{
    <<< "Sound coefficients found!" >>>;
    // Convert P & Q to radians
    myAngles[0] * (pi/180) => float soundD;
    myAngles[1] * (pi/180) => float soundE;
    // Convert P & Q to radians
    soundD * (pi/180) => soundD;
    soundE * (pi/180) => soundE;
    // Calculate X
    (Math.cos(soundD))*(Math.cos(soundE)) => float X;
    // Calculate Y
    (Math.sin(soundD))*(Math.cos(soundE)) => float Y;
    // Calculate Z
    (Math.sin(soundE)) => float Z;
    // Calculate R
    (Math.sin(2*soundE)) => float R;
    // Calculate S
    (Math.cos(soundD) * Math.cos(2*soundE)) => float S;
    // Calculate T
    (Math.sin(soundD)) * (Math.cos(2*soundE)) => float T;
    // Calculate U
    (Math.cos(2*soundD)) - (Math.cos(2*soundD) * Math.sin(2*soundE)) => float U;
    // Calculate V
    (Math.sin(2*soundD)) - (Math.sin(2*soundD) * Math.sin(2*soundE)) => float V;
    // Store them in array
    X => myAmbi[0];
    Y => myAmbi[1];       
    Z => myAmbi[2];
    0.707 => myAmbi[3]; // W (pressure signal)
    R => myAmbi[4];
    S => myAmbi[5];
    T => myAmbi[6];
    U => myAmbi[7];
    V => myAmbi[8];
    // Print your work
    <<< "X: ", myAmbi[0] >>>;
    <<< "Y: ", myAmbi[1] >>>;
    <<< "Z: ", myAmbi[2] >>>;
    <<< "W: ", myAmbi[3] >>>;
    <<< "R: ", myAmbi[4] >>>;
    <<< "S: ", myAmbi[5] >>>;
    <<< "T: ", myAmbi[6] >>>;
    <<< "U: ", myAmbi[7] >>>;
    <<< "V: ", myAmbi[8] >>>;
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
