class ambiMathCartesian
{
    1 => int W_CONSTANT;
    fun float vCoordinate(float x, float y, float z)
    {
        return 1.73205080756 * x * y;
    }
    fun float tCoordinate(float x, float y, float z)
    {
        return 1.73205080756 * y * z;
    }
    fun float rCoordinate(float x, float y, float z)
    {
        return 0.5 * (3 * Math.pow(z,2) - 1);
    }
    fun float sCoordinate(float x, float y, float z)
    {
        return 1.73205080756 * x * z;
    }
    fun float uCoordinate(float x, float y, float z)
    {
        return 0.86602540378 * (Math.pow(x,2) - Math.pow(y,2));
    }
    fun float qCoordinate(float x, float y, float z)
    {
        return 0.79056941504 * y * (3 * (Math.pow(x,2)-Math.pow(y,2)));
    }
    fun float oCoordinate(float x, float y, float z)
    {
        return 3.87298334620 * x * y * z;
    }
    fun float mCoordinate(float x, float y, float z)
    {
        return 0.61237243569 * y * (5 * Math.pow(z,2)-1);
    }
    fun float kCoordinate(float x, float y, float z)
    {
        return 0.5 * z * (5 * Math.pow(z,2)-3);
    }
    fun float lCoordinate(float x, float y, float z)
    {
        return 0.61237243569 * x * (5 * Math.pow(z,2)-1);
    }
    fun float nCoordinate(float x, float y, float z)
    {
        return 1.93649167310 * z * (Math.pow(x,2)-Math.pow(y,2));
    }
    fun float pCoordinate(float x, float y, float z)
    {
        return 0.79056941504 * x * ((Math.pow(x,2)-3)*Math.pow(y,2));
    }
    fun void coordinates(float x, float y, float z, float array[], int order)
    {
        if(array.size() == 4 || array.size() == 9 || array.size() == 16)
        {
            Math.pow((order + 1), 2) => float numChans;
            if(numChans == 4)
            {
                x => array[0];
                y => array[1];
                z => array[2];
                W_CONSTANT => array[3];
            }
            else if(numChans == 9)
            {
                x => array[0];
                y => array[1];
                z => array[2];
                W_CONSTANT => array[3];
                vCoordinate(x, y, z) => array[4];
                tCoordinate(x, y, z) => array[5];
                rCoordinate(x, y, z) => array[6];
                sCoordinate(x, y, z) => array[7];
                uCoordinate(x, y, z) => array[8];
            }
            else if( numChans == 16)
            {
                x => array[0];
                y => array[1];
                z => array[2];
                W_CONSTANT => array[3];
                vCoordinate(x, y, z) => array[4];
                tCoordinate(x, y, z) => array[5];
                rCoordinate(x, y, z) => array[6];
                sCoordinate(x, y, z) => array[7];
                uCoordinate(x, y, z) => array[8];
                qCoordinate(x, y, z) => array[9];
                oCoordinate(x, y, z) => array[10];
                mCoordinate(x, y, z) => array[11];
                kCoordinate(x, y, z) => array[12];
                lCoordinate(x, y, z) => array[13];
                nCoordinate(x, y, z) => array[14];
                pCoordinate(x, y, z) => array[15];
            }
        }
        else {cherr <= IO.newline() <= "array is not correct size" <= IO.newline();}
    }
}

ambiMathCartesian mathWiz;
float coordinates[2][16]; // x,y,z,w,v,t,r,s,u,q,o,m,k,l,n,p
["X","Y","Z","W","V","T","R","S","U","Q","O","M","K","L","N","P"] @=> string myLetters[];
@(6,8,26) => vec3 placement;
placement.normalize();
<<< placement >>>;
mathWiz.coordinates(placement.x, placement.y, placement.z, coordinates[0], 3);
for(int i; i < coordinates[0].size(); i++)
{
    cherr <= myLetters[i] <= ": " <= coordinates[0][i] <= IO.newline();
}