/*
    [THIS SCRIPT WILL NOT ENCODE OR DECODE AMBISONICS, RATHER IT EQUIPS YOU WITH THE COEFFICIENTS NEEDED FOR SUCH]
    This script will calculate speaker coefficients in the 3rd order. 
    The elevation angles are defaulted to 0, but they can be changed if desired.
    The lack of specificity in elevation angle is to keep the script from excessive input arguments.
    They are stored in the multidimensional array speakCoeff[] where the index is the speaker #.
    The command line arguements are for the direction of eight speakers, anti clockwise to the listener.
    The last two arguements are for the coefficients of a sound source, the order being directional angle, then elevation angle.
    This process is with a gain normalization that abides by SN3D standards, more information on how this script was informed can be found
    at this webpage :: https://www.angelofarina.it/Aurora/HOA_explicit_formulas.htm
    
    -- Everett M. Carpenter (Spring 2025)
*/

/* 
 * N = (M + 1)^2 for 3D production of sound in ambisonics, where N is the number of channels and M is the order.
 * Therefor, (3+1)^2 = 16 meaning we need 16 speakers, and will have 16 cartesian coordinate values
 */

 class ambisonicHelper 
 {
    (1/Math.sqrt(2)) => float W_CONSTANT;
    Math.sqrt(3/4) => float SQ34_CONSTANT; // constant often used in V,T,R,S,U
    fun float degreeRad(float angle)
    {
        angle * (pi/180) => angle;
        return angle;
    }
    // needed for 1st order
    fun float xCoordinate(float elevation, float direction)
    {
        return Math.cos(degreeRad(direction)) * Math.cos(degreeRad(elevation)); 
    }
    fun float yCoordinate(float elevation, float direction)
    {
        return Math.sin(degreeRad(direction)) * Math.cos(degreeRad(elevation));
    }
    fun float zCoordinate(float elevation, float direction)
    {
        return Math.sin(degreeRad(elevation));
    }
    // needed for 2nd order
    fun float vCoordinate(float elevation, float direction)
    {
        return SQ34_CONSTANT * Math.sin(2*degreeRad(direction)) * Math.pow(Math.cos(degreeRad(elevation)),2);
    }
    fun float tCoordinate(float elevation, float direction)
    {
        return SQ34_CONSTANT * Math.sin(degreeRad(direction)) * Math.sin(2 * degreeRad(elevation));
    }
    fun float rCoordinate(float elevation, float direction)
    {
        return 0.5 * (3 * Math.pow(Math.sin(degreeRad(elevation)),2) - 1);
    }
    fun float sCoordinate(float elevation, float direction)
    {
        return SQ34_CONSTANT * Math.cos(degreeRad(direction) * Math.sin(2 * degreeRad(elevation)));
    }
    fun float uCoordinate(float elevation, float direction)
    {
        return SQ34_CONSTANT * Math.cos(2 * degreeRad(direction)) * Math.pow(Math.cos(degreeRad(elevation)),2);
    }
    // needed for 3rd order
    fun float qCoordinate(float elevation, float direction)
    {
        return 0.79056941 * Math.sin(3 * degreeRad(direction)) * Math.pow(Math.cos(degreeRad(elevation)),3);
    }
    fun float oCoordinate(float elevation, float direction)
    {
        return 1.93649167 * Math.sin(2 * degreeRad(direction)) * Math.sin(degreeRad(elevation)) * Math.pow(Math.cos(degreeRad(elevation)),2);
    }
    fun float mCoordinate(float elevation, float direction)
    {
        return 0.61237244 * Math.sin(degreeRad(direction)) * Math.cos(degreeRad(elevation)) * (5 * Math.pow(Math.sin(degreeRad(elevation)),2) - 1);
    }
    fun float kCoordinate(float elevation, float direction)
    {
        return 0.5 * Math.sin(degreeRad(elevation)) * (5 * Math.pow(Math.sin(degreeRad(elevation)),2) - 3);
    }
    fun float lCoordinate(float elevation, float direction)
    {
        return 0.61237244 * Math.cos(degreeRad(direction)) * Math.sin(degreeRad(elevation)) * (5 * Math.pow(Math.sin(degreeRad(elevation)),2) -1 );
    }
    fun float nCoordinate(float elevation, float direction)
    {
        return 1.93649167 * Math.cos(2 * degreeRad(direction)) * Math.sin(degreeRad(elevation)) * Math.pow(Math.cos(degreeRad(elevation)),2);
    }
    fun float pCoordinate(float elevation, float direction)
    {
        return 0.79056941 * Math.cos(3 * degreeRad(direction)) * Math.pow(Math.cos(degreeRad(elevation)),4);
    }
    fun void coordinates(float elevation, float direction, float array[], int order)
    {
        if(array.size() == 4 || array.size() == 9 || array.size() == 16)
        {
            Math.pow((order + 1), 2) => float numChans;
            if(numChans == 4)
            {
                xCoordinate(elevation, direction) => array[0];
                yCoordinate(elevation, direction) => array[1];
                zCoordinate(elevation, direction) => array[2];
                W_CONSTANT => array[3];
            }
            else if(numChans == 9)
            {
                xCoordinate(elevation, direction) => array[0];
                yCoordinate(elevation, direction) => array[1];
                zCoordinate(elevation, direction) => array[2];
                W_CONSTANT => array[3];
                vCoordinate(elevation, direction) => array[4];
                tCoordinate(elevation, direction) => array[5];
                rCoordinate(elevation, direction) => array[6];
                sCoordinate(elevation, direction) => array[7];
                uCoordinate(elevation, direction) => array[8];
            }
            else if( numChans == 16)
            {
                xCoordinate(elevation, direction) => array[0];
                yCoordinate(elevation, direction) => array[1];
                zCoordinate(elevation, direction) => array[2];
                W_CONSTANT => array[3];
                vCoordinate(elevation, direction) => array[4];
                tCoordinate(elevation, direction) => array[5];
                rCoordinate(elevation, direction) => array[6];
                sCoordinate(elevation, direction) => array[7];
                uCoordinate(elevation, direction) => array[8];
                qCoordinate(elevation, direction) => array[9];
                oCoordinate(elevation, direction) => array[10];
                mCoordinate(elevation, direction) => array[11];
                kCoordinate(elevation, direction) => array[12];
                lCoordinate(elevation, direction) => array[13];
                nCoordinate(elevation, direction) => array[14];
                pCoordinate(elevation, direction) => array[15];
            }
        }
        else {cherr <= IO.newline() <= "array is not correct size" <= IO.newline();}
    }
}

ambisonicHelper mathWiz;

0 => float myElevation;
0 => float myDirection;
["X","Y","Z","W","V","T","R","S","U","Q","O","M","K","L","N","P"] @=> string myLetters[];
float myCoordinates[16]; // X, Y, Z, W, V, T, R, S, U, Q, O, M, K, L, N, P
mathWiz.coordinates(myElevation, myDirection, myCoordinates, 3);
/*
for(1=>int j; j < 10; j++)
{
    cherr <= IO.newline();
    for(int i; i < myCoordinates.size(); i++)
    {
        cherr <= myLetters[i] <= ": " <= myCoordinates[i] <= "   "; 
        if(i%4 == 3) cherr <= IO.newline();
    }
    cherr <= myDirection <= "  " <= myElevation <= IO.newline();
    45*j => myDirection;
    1::second => now;
}
*/