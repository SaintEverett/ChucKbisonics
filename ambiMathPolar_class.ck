/*
* 
*   This class is used to quickly calculate the cartesian coordinates of an object within a 3D plane given elevation and directional angles.
*   These coordinates can be useful in finding speaker coefficients for Ambisonic decoding, or for encoding sounds for Ambisonics.
* 
*
*
*/

 class ambiMathPolar
 {
    float W_CONSTANT;
    float SQ34_CONSTANT;
    int mode;
    (1/Math.sqrt(2)) => W_CONSTANT;
    0.86602540 => SQ34_CONSTANT; // constant often used in V,T,R,S,U
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
        return SQ34_CONSTANT * Math.sin(2 * (degreeRad(direction))) * Math.pow(Math.cos(degreeRad(elevation)),2);
    }
    fun float tCoordinate(float elevation, float direction)
    {
        return SQ34_CONSTANT * Math.sin(degreeRad(direction)) * Math.sin(2 * (degreeRad(elevation)));
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

ambiMathPolar mathWiz;

0 => float myElevation;
0 => float myDirection;
["X","Y","Z","W","V","T","R","S","U","Q","O","M","K","L","N","P"] @=> string myLetters[];
float myCoordinates[16]; // X, Y, Z, W, V, T, R, S, U, Q, O, M, K, L, N, P

for(1=>int j; j < 10; j++)
{
    mathWiz.coordinates(myElevation, myDirection, myCoordinates, 3);
    cherr <= IO.newline();
    for(int i; i < myCoordinates.size(); i++)
    {
        cherr <= myLetters[i] <= ": " <= myCoordinates[i] <= "   "; 
        if(i%4 == 3) cherr <= IO.newline();
    }
    cherr <= myDirection <= "  " <= myElevation <= IO.newline();
    13.678*j => myDirection;
    15.735123*j => myElevation;
    1::second => now;
}
for(1=>int j; j > 10; j--)
{
    mathWiz.coordinates(myElevation, myDirection, myCoordinates, 3);
    cherr <= IO.newline();
    for(int i; i < myCoordinates.size(); i++)
    {
        cherr <= myLetters[i] <= ": " <= myCoordinates[i] <= "   "; 
        if(i%4 == 3) cherr <= IO.newline();
    }
    cherr <= myDirection <= "  " <= myElevation <= IO.newline();
    45*j => myDirection;
    15*j => myElevation;
    1::second => now;
}
