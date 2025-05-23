/*
    [script name: send_2ndorder.ck]

    -- Author: Everett Carpenter (Spring 2025)

    What is it?
        This script is the other half of an OSC system designing for 2nd order ambisonics. This script is in charge of sending all the speaker coefficients,
        sound coefficients, as well as appropriate coordinates and angles. 
    How does it work?
        Before sending any coordinates or coefficients regarding the sound source, this script will calculate and send the speaker coefficients. In order
        to calculate accurate coefficients, please change the "speakAngles" array. The values inside the array are predefined, but floating point values
        would be ideal for these calculations. The math on how to find coefficients is well documented, so I will not explain it here. If you would like
        to learn the encoding and decoding process, I highly recommend these classic papers:
        Ambisonics-A Technique for Low-Cost, High-Precision, Three-Dimensional Sound Diffusion by D.G. Malham
        https://quod.lib.umich.edu/i/icmc/bbp2372.1990.030/1/--ambisonics-a-technique-for-low-cost-high-precision-three?rgn=full+text;view=image;q1=Ambisonic
        Higher Order Ambisonic Systems for the Spatialisation of Sound by D.G. Malham
        https://quod.lib.umich.edu/i/icmc/bbp2372.1999.451/1/--higher-order-ambisonic-systems-for-the-spatialisation?rgn=full+text;view=image;q1=Ambisonic
    What do I need to do to make it work?
        This script uses the arrow keys to place the sound source in space, therefore you need to specify which HID device ChucK should listen for. 
        The input arguments for this script are "[address]:[port]:[hid]"
            - Address is the hostname of the computer you are sending data to
            - Port should be the same port as the "recv_2ndorder.ck" instance you are running
            - Hid is the device number you should use. If you are unsure, run "chuck --probe" in the terminal. 
        If you haven't used OSC before or are new, remember that both ends of this system should be on the same network. If you don't want to use two machines,
        it is absolutely possible to send OSC messages to yourself. Simply just run both scripts on the same computer, and address the scripts accordingly.
    You said it's one half, what else is there?
        There is a partner script to this one titled "recv_2ndorder.ck". Running the two of these scripts should complete the loop needed for communication,
        granted you have provided the appropriate hostname and address. Read both this script and the recieving one to understand how they speak to each other.

    If you have any questions, feel free to email me at carpee2 [at] rpi.edu

    To be added:
        Speaker elevation support ( just more math to be programmed )

*/

// instantiate hid message
Hid hi;
HidMsg msg;
Event wakeUp;
Event startShipping;
// mail man
OscOut shippingContainer;
// identify yourself
string address;
int port;
// device #
0 => int device;

if( !me.args() ) 
{
    cherr <= "Input required, format is [address]:[port]:[hid]" <= IO.newline()
          <= "If no port specified, default to 6449" <= IO.newline()
          <= "If no HID specified, default to 0";
    me.exit();
}
else if( me.args() == 1 )
{
    me.arg(0) => address;
    6449 => port;
}
else if( me.args() == 2 )
{
    me.arg(0) => address;
    me.arg(1) => Std.atoi => port;
}
else if( me.args() == 3 )
{
  me.arg(0) => address;
  me.arg(1) => Std.atoi => port;
  me.arg(2) => Std.atoi => device;
}
// print your identity
cherr <= "You're sending mail to " <= address 
      <= " on port " <= port <= IO.newline();

shippingContainer.dest(address,port);

// Array of angles, [0] is direction [1] is elevation
float myAngles[2];

// Array of ambisonic coordinates as [X,Y,Z,W]
float myAmbi[9];

// open keyboard (get device number from command line)
if( !hi.openKeyboard (device) ) 
{
    me.exit();
}

// Create multidimensional array, right side entries will default to 0, which is fine in ambisonics without height speakers.
float speakCoeff[8][9];

// Take args and put them in speaker angle array
int count;
// hardcoded speaker angles, adjust if needed.
[0.0,45.0,90.0,135.0,180.0,225.0,270.0,315.0] @=> float speakAngles[]; // SPEAKER ANGLES

fun void dropShipping()
{
    while( true )
    {
        startShipping => now;
        // coordinates
        shippingContainer.start("/sound/location/coordinates");
        
        for( int i; i < myAmbi.size(); i++ )
        {
            myAmbi[i] => shippingContainer.add;
        }

        shippingContainer.send();

        // angles
        shippingContainer.start("/sound/location/angles");

        myAngles[0] => shippingContainer.add;
        myAngles[1] => shippingContainer.add;

        shippingContainer.send();

        // speaker coefficients (one time for each speaker)
        shippingContainer.start("/speakers/coefficients");
        for( int i; i < speakCoeff.size(); i++ )
        {
            for( int j; j < speakCoeff[0].size(); j++ )
            {
                speakCoeff[i][j] => shippingContainer.add;
            }
        }

        shippingContainer.send();            

        cherr <= "sent!" <= IO.newline();
        10::ms => now;
    }
}

// speaker coefficients
fun void mySpeakerCoeffs()
{
    int count;
    while( count < speakCoeff.size() )
    {
        speakAngles[count] => float speakP;
        // Convert P & Q to radians
        speakP * (pi/180) => speakP;
        0 => float speakQ;
        // Calculate X
        (Math.cos(speakP))*(Math.cos(speakQ)) => float X;
        // Calculate Y
        (Math.sin(speakP))*(Math.cos(speakQ)) => float Y;
        // Calculate Z
        (Math.sin(speakQ)) => float Z;
        // Calculate R
        (Math.sin(2*speakQ)) => float R;
        // Calculate S
        (Math.cos(speakP) * Math.cos(2*speakQ)) => float S;
        // Calculate T
        (Math.sin(speakP)) * (Math.cos(2*speakQ)) => float T;
        // Calculate U
        (Math.cos(2*speakP)) - (Math.cos(2*speakP) * Math.sin(2*speakQ)) => float U;
        // Calculate V
        (Math.sin(2*speakP)) - (Math.sin(2*speakP) * Math.sin(2*speakQ)) => float V;
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
        for( int i; i < speakCoeff[1].size(); i++ ) 
        {
            cherr <= speakCoeff[count][i] <= " ";
        }
              
        count++;
    }
    me.exit();
}

fun void hidArray()
{
    while( true )
    {
        hi => now;
        while( hi.recv(msg) )
        {
            if( msg.isButtonDown() )
            {         
                cherr <= msg.key <= " key" <= IO.newline();
                if( msg.key == 82 && myAngles[1] <= 355 )
                {
                    5.0 + myAngles[1] => myAngles[1];
                }
                else if( msg.key == 82 && myAngles[1] == 360 )
                {
                    0 => myAngles[1];
                }
                if( msg.key == 81 && myAngles[1] >= 5 )
                {
                    myAngles[1] - 5.0 => myAngles[1];
                }
                else if( msg.key == 81 && myAngles[1] == 0 )
                {
                    360 => myAngles[1];
                }
                if( msg.key == 80 && myAngles[0] <= 355 )
                {
                    5.0 + myAngles[0] => myAngles[0];
                }
                else if( msg.key == 80 && myAngles[0] == 360 )
                {
                    0 => myAngles[0];
                }
                if( msg.key == 79 && myAngles[0] >= 5 )
                {
                    myAngles[0] - 5.0 => myAngles[0];
                }
                else if( msg.key == 79 && myAngles[0] == 0 )
                {
                    360 => myAngles[0];
                }
                /* recv announces it
                cherr <= "Elevation angle: " <= myAngles[1] <= IO.newline()
                      <= "Directional angle: " <= myAngles[0] <= IO.newline();
                */
                // wake up
                wakeUp.signal();
           }
       }
    }
}

fun void convAmbi()
{
    while( true )
    {
        wakeUp => now;
        // Convert P & Q to radians
        myAngles[0] * (pi/180) => float P;
        myAngles[1] * (pi/180) => float Q;
        // Calculate X
        (Math.cos(P))*(Math.cos(Q)) => float X;
        // Calculate Y
        (Math.sin(P))*(Math.cos(Q)) => float Y;
        // Calculate Z
        (Math.sin(Q)) => float Z;
        // Calculate R
        (Math.sin(2*Q)) => float R;
        // Calculate S
        (Math.cos(P) * Math.cos(2*Q)) => float S;
        // Calculate T
        (Math.sin(P)) * (Math.cos(2*Q)) => float T;
        // Calculate U
        (Math.cos(2*P)) - (Math.cos(2*P) * Math.sin(2*Q)) => float U;
        // Calculate V
        (Math.sin(2*P)) - (Math.sin(2*P) * Math.sin(2*Q)) => float V;
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
        /*
        // Print your work (recv is going to do this anyways
        cherr <= "X: " <= myAmbi[0] <= IO.newline()
              <= "Y: " <= myAmbi[1] <= IO.newline()
              <= "Z: " <= myAmbi[2] <= IO.newline()
              <= "W: " <= myAmbi[3] <= IO.newline()
              ...
        */
        // ship it off
        startShipping.signal();
    }
}

spork ~ mySpeakerCoeffs();
spork ~ hidArray();
spork ~ convAmbi();
spork ~ dropShipping();

while( true )
{
    if( msg.isButtonDown() )
    {
        if( msg.ascii == 27 )
        {
            900::ms => now;
            me.exit();
        }
    }
    10::ms => now;
}
